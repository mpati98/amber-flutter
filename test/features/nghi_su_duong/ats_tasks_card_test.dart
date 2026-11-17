import 'package:amber_flutter/features/nghi_su_duong/models/ats_task.dart';
import 'package:amber_flutter/features/nghi_su_duong/services/ats_tasks_api.dart';
import 'package:amber_flutter/features/nghi_su_duong/widgets/ats_tasks_card.dart';
import 'package:amber_flutter/shared/theme/app_theme.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ats_test_support.dart';

// Khối "Công việc ATS" của màn Dự án (chỉ đọc). API giả.

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

final _tasks = [
  atsTaskJson('o1', title: 'Việc quá hạn', status: 'IN_PROGRESS', rawStatus: 'DOING', dueDate: '2026-11-10', attention: 'OVERDUE'),
  atsTaskJson('o2', title: 'Việc chờ', status: 'WAITING', rawStatus: 'WAITING', dueDate: '2026-11-25'),
  atsTaskJson('o3', title: 'Việc chưa làm', status: null, project: null),
  atsTaskJson('d1', title: 'Việc xong', status: 'DONE', rawStatus: 'DONE', dueDate: '2026-11-11', doneAt: '2026-11-11T04:50:45.000Z'),
];

void main() {
  testWidgets('có dữ liệu: tiêu đề + số chưa xong, dòng cập nhật giờ VN, chỉ hiện việc chưa xong, giữ thứ tự server', (tester) async {
    await _pump(tester, FakeAtsTasksApi(data: atsData(_tasks)));
    expect(find.textContaining('Công việc ATS', findRichText: true), findsOneWidget);
    expect(find.textContaining('3 chưa xong', findRichText: true), findsOneWidget);
    // 06:05Z = 13:05 giờ VN.
    expect(find.text('Cập nhật lúc 13:05 17/11'), findsOneWidget);

    final rows = tester.widgetList<AtsTaskRow>(find.byType(AtsTaskRow)).map((r) => r.task.id).toList();
    expect(rows, ['o1', 'o2', 'o3']);
    expect(find.text('Việc xong'), findsNothing);

    // Chip trạng thái + dự án / loại / hạn.
    expect(find.descendant(of: find.byKey(const ValueKey('ats-task-o1')), matching: find.text('Đang làm')), findsOneWidget);
    expect(find.descendant(of: find.byKey(const ValueKey('ats-task-o2')), matching: find.text('Chờ')), findsOneWidget);
    expect(find.descendant(of: find.byKey(const ValueKey('ats-task-o3')), matching: find.text('Chưa làm')), findsOneWidget);
    expect(find.text('Hội chợ X · Hội chợ · Hạn 25/11'), findsOneWidget);
    expect(find.text('Không thuộc dự án'), findsOneWidget);
    // Không có nút sửa / xoá / tạo.
    for (final s in ['Sửa', 'Xoá', '+ Thêm', 'Thêm việc']) {
      expect(find.text(s), findsNothing);
    }
  });

  testWidgets('OVERDUE: nhãn "Quá hạn" chỉ ở việc quá hạn', (tester) async {
    await _pump(tester, FakeAtsTasksApi(data: atsData(_tasks)));
    expect(find.byKey(const ValueKey('ats-overdue-o1')), findsOneWidget);
    expect(find.text('Quá hạn'), findsOneWidget);
    expect(find.byKey(const ValueKey('ats-overdue-o2')), findsNothing);
  });

  testWidgets('"Xem cả việc đã xong" bung phần DONE (mờ), không gọi ?all=1; "Ẩn" thu lại', (tester) async {
    final api = await _pump(tester, FakeAtsTasksApi(data: atsData(_tasks)));
    await tester.tap(find.text('Xem cả việc đã xong (1)'));
    await tester.pumpAndSettle();
    expect(find.text('Việc xong'), findsOneWidget);
    final opacity = tester.widget<Opacity>(find.ancestor(of: find.byKey(const ValueKey('ats-task-d1')), matching: find.byType(Opacity)).first);
    expect(opacity.opacity, lessThan(1));
    expect(api.getCalls, [false]);
    await tester.tap(find.text('Ẩn việc đã xong'));
    await tester.pumpAndSettle();
    expect(find.text('Việc xong'), findsNothing);
  });

  testWidgets('"Xem tất cả (gồm lưu trữ)" tải ?all=1 và hiện cả việc xong', (tester) async {
    final api = FakeAtsTasksApi(data: atsData(_tasks.take(1).toList()))
      ..allData = atsData([
        ..._tasks,
        atsTaskJson('a1', title: 'Việc dự án lưu trữ', project: {'atsId': 'p9', 'name': 'Cũ', 'type': 'OTHER', 'archived': true}),
      ]);
    await _pump(tester, api);
    await tester.tap(find.text('Xem tất cả (gồm lưu trữ)'));
    await tester.pumpAndSettle();
    expect(api.getCalls, [false, true]);
    expect(find.text('Việc dự án lưu trữ'), findsOneWidget);
    expect(find.text('Lưu trữ'), findsOneWidget);
    expect(find.text('Việc xong'), findsOneWidget);
    expect(find.text('Chỉ việc hiện hành'), findsOneWidget);
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
    expect(find.byType(AtsTaskRow), findsNWidgets(3));
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
    expect(find.byType(AtsTaskRow), findsNWidgets(3));
  });

  testWidgets('Đồng bộ ngay: thành công → toast + tải lại danh sách', (tester) async {
    final api = FakeAtsTasksApi(data: atsData([]), syncResult: const AtsSyncResult(fetched: 3, inserted: 3, updated: 0, deleted: 0));
    await _pump(tester, api);
    api.data = atsData(_tasks);
    await tester.tap(find.byKey(const ValueKey('ats-sync')));
    await tester.pumpAndSettle();
    expect(api.syncCalls, 1);
    expect(find.text('Đã đồng bộ: thêm 3 · sửa 0 · xoá 0'), findsOneWidget);
    expect(find.byType(AtsTaskRow), findsNWidgets(3));
  });

  testWidgets('Đồng bộ ngay: 429 → "Thử lại sau N giây"', (tester) async {
    final api = await _pump(tester, FakeAtsTasksApi(data: atsData([]), syncError: atsHttpError(429, {'error': 'sync_throttled', 'retryAfterSeconds': 27})));
    // Đồng bộ nền phía server vừa chạy xong (lý do bị 429) — danh sách mới phải hiện sau khi bấm.
    api.data = atsData(_tasks);
    await tester.tap(find.byKey(const ValueKey('ats-sync')));
    await tester.pumpAndSettle();
    expect(find.text('Thử lại sau 27 giây'), findsOneWidget);
    expect(api.getCalls.length, 2, reason: '429 vẫn tải lại danh sách');
    expect(find.byType(AtsTaskRow), findsNWidgets(3));
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
    expect(find.text('Hội chợ X'), findsOneWidget);
    expect(find.text('Hội chợ'), findsOneWidget);
    expect(find.text('10/11'), findsOneWidget);
    expect(find.textContaining('Sửa trên ats-app'), findsOneWidget);
    for (final s in ['Lưu', 'Sửa', 'Xoá']) {
      expect(find.text(s), findsNothing);
    }
  });

  testWidgets('bề rộng 320, chữ ×2: không tràn', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _pump(tester, FakeAtsTasksApi(data: atsData(_tasks)), width: 320);
    expect(tester.takeException(), isNull);
  });
}
