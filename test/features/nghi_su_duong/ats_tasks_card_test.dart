import 'package:amber_flutter/features/nghi_su_duong/models/ats_task.dart';
import 'package:amber_flutter/features/nghi_su_duong/services/ats_tasks_api.dart';
import 'package:amber_flutter/features/nghi_su_duong/widgets/ats_tasks_card.dart';
import 'package:amber_flutter/shared/theme/app_theme.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ats_test_support.dart';

// Khối "Công việc ATS" của màn Dự án (chỉ đọc, gom theo dự án, mỗi việc một dòng). API giả.

Future<FakeAtsTasksApi> _pump(WidgetTester tester, FakeAtsTasksApi api, {double width = 390}) async {
  tester.view.physicalSize = Size(width, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [atsTasksApiProvider.overrideWithValue(api)],
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: const Scaffold(body: SingleChildScrollView(child: AtsTasksCard())),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return api;
}

const _fair = {'atsId': 'pF', 'name': 'Hội chợ X', 'type': 'FAIR', 'archived': false};
const _camp = {'atsId': 'pC', 'name': 'Chiến dịch Y', 'type': 'CAMPAIGN', 'archived': false};

final _tasks = [
  atsTaskJson('o1', title: 'Việc quá hạn', status: 'IN_PROGRESS', rawStatus: 'DOING', dueDate: '2026-11-10', attention: 'OVERDUE', project: _camp),
  atsTaskJson('o2', title: 'Việc chờ', status: 'WAITING', rawStatus: 'WAITING', dueDate: '2026-11-25', project: _fair),
  atsTaskJson('o3', title: 'Report', status: null, dueDate: '2026-11-17', project: _fair),
  atsTaskJson('o4', title: 'Report', status: null, dueDate: '2026-11-17', project: _fair),
  atsTaskJson('o5', title: 'Report', status: null, dueDate: '2026-11-17', project: _fair),
  atsTaskJson('o6', title: 'Việc không dự án', status: null, project: null),
  atsTaskJson('d1', title: 'Việc xong', status: 'DONE', rawStatus: 'DONE', dueDate: '2026-11-11', doneAt: '2026-11-11T04:50:45.000Z', project: _fair),
];

List<String> _rowIds(WidgetTester tester) => tester.widgetList<AtsTaskRow>(find.byType(AtsTaskRow)).map((r) => r.task.id).toList();

Future<void> _menu(WidgetTester tester, String item) async {
  await tester.tap(find.byKey(const ValueKey('ats-menu')));
  await tester.pumpAndSettle();
  await tester.tap(find.text(item).last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('gom theo dự án: tiêu đề nhóm, thứ tự nhóm (quá hạn trước, rồi hạn gần nhất), mỗi việc một dòng', (tester) async {
    await _pump(tester, FakeAtsTasksApi(data: atsData(_tasks)));
    expect(find.textContaining('6 chưa xong', findRichText: true), findsOneWidget); // đếm việc thật (o1–o6), không phải dòng gộp
    // 06:05Z = 13:05 giờ VN — cùng hàng tiêu đề.
    expect(find.text('Cập nhật lúc 13:05 17/11'), findsOneWidget);

    expect(find.text('Chiến dịch Y · Chiến dịch'), findsOneWidget);
    expect(find.text('Hội chợ X · Hội chợ'), findsOneWidget);
    expect(find.text('Không thuộc dự án'), findsOneWidget);
    final groupY = tester.getTopLeft(find.text('Chiến dịch Y · Chiến dịch')).dy;
    final groupX = tester.getTopLeft(find.text('Hội chợ X · Hội chợ')).dy;
    final groupNone = tester.getTopLeft(find.text('Không thuộc dự án')).dy;
    expect(groupY < groupX && groupX < groupNone, isTrue, reason: 'nhóm quá hạn → hạn gần nhất → không hạn');

    // Trong nhóm X giữ thứ tự server (Việc chờ rồi Report); 3 Report gộp một dòng.
    expect(_rowIds(tester), ['o1', 'o2', 'o3', 'o6']);
    expect(find.text('Việc xong'), findsNothing);
    // Không có nút sửa / xoá / tạo.
    for (final s in ['Sửa', 'Xoá', '+ Thêm', 'Thêm việc']) {
      expect(find.text(s), findsNothing);
    }
  });

  testWidgets('gộp việc trùng: "×3" sau tên; chạm mở chi tiết "3 việc giống nhau trên ats-app"', (tester) async {
    await _pump(tester, FakeAtsTasksApi(data: atsData(_tasks)));
    expect(find.text('Report ×3', findRichText: true), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('ats-task-o3')));
    await tester.pumpAndSettle();
    expect(find.text('3 việc giống nhau trên ats-app'), findsOneWidget);
    expect(find.textContaining('Sửa trên ats-app'), findsOneWidget);
  });

  testWidgets('chip: chỉ Đang làm / Chờ / Quá hạn; Chưa làm không chip mà hiện ngày; Quá hạn thay ngày', (tester) async {
    await _pump(tester, FakeAtsTasksApi(data: atsData(_tasks)));
    Finder inRow(String id, Finder f) => find.descendant(of: find.byKey(ValueKey('ats-task-$id')), matching: f);

    // o1: Đang làm + Quá hạn, không có ngày.
    expect(inRow('o1', find.text('Đang làm')), findsOneWidget);
    expect(find.byKey(const ValueKey('ats-overdue-o1')), findsOneWidget);
    expect(find.byKey(const ValueKey('ats-due-o1')), findsNothing);
    // o2: Chờ + ngày.
    expect(inRow('o2', find.text('Chờ')), findsOneWidget);
    expect(inRow('o2', find.text('25/11')), findsOneWidget);
    // o3 (Chưa làm): không chip, chỉ ngày.
    expect(find.byKey(const ValueKey('ats-status-o3')), findsNothing);
    expect(inRow('o3', find.text('Chưa làm')), findsNothing);
    expect(inRow('o3', find.text('17/11')), findsOneWidget);
    // o6: Chưa làm, không hạn → không có gì bên phải.
    expect(find.byKey(const ValueKey('ats-status-o6')), findsNothing);
    expect(find.byKey(const ValueKey('ats-due-o6')), findsNothing);
    expect(find.text('Quá hạn'), findsOneWidget);
  });

  testWidgets('tối đa 6 dòng việc, còn lại "Xem thêm N"; bấm thì hiện hết và có "Thu gọn"', (tester) async {
    final many = [
      for (var i = 0; i < 9; i++) atsTaskJson('m$i', title: 'Việc $i', status: null, dueDate: '2026-11-${(20 + i).toString()}', project: _fair),
    ];
    await _pump(tester, FakeAtsTasksApi(data: atsData(many)));
    expect(find.byType(AtsTaskRow), findsNWidgets(6));
    expect(find.text('Xem thêm 3'), findsOneWidget);
    await tester.tap(find.text('Xem thêm 3'));
    await tester.pumpAndSettle();
    expect(find.byType(AtsTaskRow), findsNWidgets(9));
    await tester.tap(find.text('Thu gọn'));
    await tester.pumpAndSettle();
    expect(find.byType(AtsTaskRow), findsNWidgets(6));
  });

  testWidgets('dòng gộp tính là MỘT dòng trong giới hạn 6', (tester) async {
    final rows = [
      for (var i = 0; i < 5; i++) atsTaskJson('d$i', title: 'Trùng', status: null, dueDate: '2026-11-20', project: _fair),
      for (var i = 0; i < 5; i++) atsTaskJson('u$i', title: 'Riêng $i', status: null, dueDate: '2026-11-2${i + 1}', project: _fair),
    ];
    await _pump(tester, FakeAtsTasksApi(data: atsData(rows)));
    expect(find.byType(AtsTaskRow), findsNWidgets(6)); // Trùng ×5 + 5 việc riêng
    expect(find.text('Trùng ×5', findRichText: true), findsOneWidget);
    expect(find.byKey(const ValueKey('ats-more')), findsNothing);
  });

  testWidgets('menu ⋯ "Xem cả việc đã xong": việc xong mờ, có chip "Xong", không gọi ?all=1; "Ẩn" thu lại', (tester) async {
    final api = await _pump(tester, FakeAtsTasksApi(data: atsData(_tasks)));
    await _menu(tester, 'Xem cả việc đã xong (1)');
    expect(find.text('Việc xong'), findsOneWidget);
    expect(find.descendant(of: find.byKey(const ValueKey('ats-task-d1')), matching: find.text('Xong')), findsOneWidget);
    final opacity = tester.widget<Opacity>(find.ancestor(of: find.byKey(const ValueKey('ats-task-d1')), matching: find.byType(Opacity)).first);
    expect(opacity.opacity, lessThan(1));
    expect(api.getCalls, [false]);
    await _menu(tester, 'Ẩn việc đã xong');
    expect(find.text('Việc xong'), findsNothing);
  });

  testWidgets('menu ⋯ "Xem tất cả (gồm lưu trữ)" tải ?all=1, nhóm lưu trữ có nhãn', (tester) async {
    final api = FakeAtsTasksApi(data: atsData(_tasks.take(1).toList()))
      ..allData = atsData([
        ..._tasks,
        atsTaskJson('a1', title: 'Việc dự án lưu trữ', status: null, project: {'atsId': 'p9', 'name': 'Cũ', 'type': 'OTHER', 'archived': true}),
      ]);
    await _pump(tester, api);
    await _menu(tester, 'Xem tất cả (gồm lưu trữ)');
    expect(api.getCalls, [false, true]);
    expect(find.text('Cũ · Khác · Lưu trữ'), findsOneWidget);
    // Bật "tất cả" thì hiện cả việc xong (có thể nằm sau "Xem thêm").
    if (find.byKey(const ValueKey('ats-more')).evaluate().isNotEmpty) {
      await tester.tap(find.byKey(const ValueKey('ats-more')));
      await tester.pumpAndSettle();
    }
    expect(find.text('Việc xong'), findsOneWidget);
  });

  testWidgets('rỗng: "Không có việc ATS nào"', (tester) async {
    await _pump(tester, FakeAtsTasksApi(data: atsData([])));
    expect(find.text('Không có việc ATS nào'), findsOneWidget);
    expect(find.byType(AtsTaskRow), findsNothing);
  });

  testWidgets('chưa đồng bộ lần nào: "Chưa đồng bộ"', (tester) async {
    await _pump(tester, FakeAtsTasksApi(data: atsData([], sync: {'lastSuccessAt': null, 'lastAttemptAt': null, 'lastError': null})));
    expect(find.text('Chưa đồng bộ'), findsOneWidget);
  });

  testWidgets('lỗi đồng bộ: "Lỗi đồng bộ: …" thay dòng cập nhật, vẫn hiện dữ liệu cũ', (tester) async {
    await _pump(
      tester,
      FakeAtsTasksApi(data: atsData(_tasks, sync: {'lastSuccessAt': '2026-11-17T06:05:00.000Z', 'lastError': 'unauthorized: ats-app từ chối token (HTTP 401)'})),
    );
    expect(find.text('Lỗi đồng bộ: unauthorized: ats-app từ chối token (HTTP 401)'), findsOneWidget);
    expect(find.textContaining('Cập nhật lúc'), findsNothing);
    expect(find.byType(AtsTaskRow), findsNWidgets(4));
  });

  testWidgets('GET lỗi: khối tự hiện lỗi + Thử lại tải lại', (tester) async {
    final api = FakeAtsTasksApi(getError: atsHttpError(500, {'error': 'x'}));
    await _pump(tester, api);
    expect(find.text('Không tải được việc ATS.'), findsOneWidget);
    api
      ..getError = null
      ..data = atsData(_tasks);
    await tester.tap(find.text('Thử lại'));
    await tester.pumpAndSettle();
    expect(find.byType(AtsTaskRow), findsNWidgets(4));
  });

  testWidgets('Đồng bộ ngay: thành công → toast + tải lại danh sách', (tester) async {
    final api = FakeAtsTasksApi(data: atsData([]), syncResult: const AtsSyncResult(fetched: 3, inserted: 3, updated: 0, deleted: 0));
    await _pump(tester, api);
    api.data = atsData(_tasks);
    await tester.tap(find.byKey(const ValueKey('ats-sync')));
    await tester.pumpAndSettle();
    expect(api.syncCalls, 1);
    expect(find.text('Đã đồng bộ: thêm 3 · sửa 0 · xoá 0'), findsOneWidget);
    expect(find.byType(AtsTaskRow), findsNWidgets(4));
  });

  testWidgets('Đồng bộ ngay: 429 → "Thử lại sau N giây" và vẫn tải lại danh sách', (tester) async {
    final api = await _pump(tester, FakeAtsTasksApi(data: atsData([]), syncError: atsHttpError(429, {'error': 'sync_throttled', 'retryAfterSeconds': 27})));
    api.data = atsData(_tasks);
    await tester.tap(find.byKey(const ValueKey('ats-sync')));
    await tester.pumpAndSettle();
    expect(find.text('Thử lại sau 27 giây'), findsOneWidget);
    expect(api.getCalls.length, 2);
    expect(find.byType(AtsTaskRow), findsNWidgets(4));
  });

  testWidgets('Đồng bộ ngay: 502 → toast kèm message server', (tester) async {
    await _pump(
      tester,
      FakeAtsTasksApi(data: atsData([]), syncError: atsHttpError(502, {'error': 'ats_sync_failed', 'code': 'unauthorized', 'message': 'ats-app từ chối token (HTTP 401)'})),
    );
    await tester.tap(find.byKey(const ValueKey('ats-sync')));
    await tester.pumpAndSettle();
    expect(find.text('ats-app từ chối token (HTTP 401)'), findsOneWidget);
  });

  testWidgets('chạm dòng → chi tiết chỉ đọc + ghi chú "Sửa trên ats-app"', (tester) async {
    await _pump(tester, FakeAtsTasksApi(data: atsData(_tasks)));
    await tester.tap(find.byKey(const ValueKey('ats-task-o1')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('ats-detail-title')), findsOneWidget);
    expect(find.text('Chiến dịch Y'), findsOneWidget);
    expect(find.text('Chiến dịch'), findsOneWidget);
    expect(find.text('10/11'), findsOneWidget);
    expect(find.byKey(const ValueKey('ats-detail-count')), findsNothing);
    expect(find.textContaining('Sửa trên ats-app'), findsOneWidget);
    for (final s in ['Lưu', 'Sửa', 'Xoá']) {
      expect(find.text(s), findsNothing);
    }
  });

  testWidgets('mỗi việc một dòng ở bề rộng thường: tên và chip cùng hàng', (tester) async {
    await _pump(tester, FakeAtsTasksApi(data: atsData(_tasks)), width: 700);
    final title = tester.getCenter(find.text('Việc chờ', findRichText: true));
    final chip = tester.getCenter(find.descendant(of: find.byKey(const ValueKey('ats-task-o2')), matching: find.text('Chờ')));
    expect((title.dy - chip.dy).abs(), lessThan(6));
  });

  testWidgets('bề rộng 320, chữ ×2: không tràn', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _pump(tester, FakeAtsTasksApi(data: atsData(_tasks)), width: 320);
    expect(tester.takeException(), isNull);
  });
}
