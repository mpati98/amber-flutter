import 'dart:async';

import 'package:amber_flutter/features/nghi_su_duong/models/key_result.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/project_summary.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/task.dart';
import 'package:amber_flutter/features/nghi_su_duong/widgets/key_results_block.dart';
import 'package:amber_flutter/features/nghi_su_duong/widgets/project_header.dart';
import 'package:amber_flutter/features/nghi_su_duong/widgets/task_board.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'detail_test_support.dart';

// Màn Chi tiết dự án: đầu trang, Kết quả then chốt, bảng Kanban. API giả.

/// Bố cục hẹp: nhóm "Xong" gập mặc định — mở ra.
Future<void> expandDone(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.expand_more));
  await tester.pumpAndSettle();
}

void main() {
  group('đầu trang', () {
    test('detailBadge: 4 trường hợp nhãn trạng thái', () {
      expect(detailBadge(ProjectStatus.paused, 5)?.label, 'Tạm dừng');
      expect(detailBadge(ProjectStatus.done, 0)?.label, 'Đã xong');
      final warn = detailBadge(ProjectStatus.active, 2);
      expect(warn?.label, '2 việc cần xử lý');
      expect(warn?.warning, isTrue);
      expect(detailBadge(ProjectStatus.active, 0)?.label, 'Đúng nhịp');
    });

    testWidgets('tên, mục tiêu, khoảng ngày, nhãn, mốc kế tiếp (việc mốc chưa xong, hạn sớm nhất)', (tester) async {
      await pumpDetail(
        tester,
        project: mkProject(goal: 'Tổ chức thành công', start: '2026-10-06', end: '2026-12-31'),
        tasks: [
          mkTask('a', 'Việc quá hạn', TaskStatus.prep, attention: const TaskAttention(kind: 'OVERDUE', days: 3)),
          mkTask('b', 'Mốc xa', TaskStatus.prep, milestone: true, due: '2026-11-20'),
          mkTask('c', 'Mốc gần', TaskStatus.inProgress, milestone: true, due: '2026-10-14'),
          mkTask('d', 'Mốc đã xong', TaskStatus.done, milestone: true, due: '2026-10-01'),
        ],
      );
      expect(find.text('Tổ chức thành công'), findsOneWidget);
      expect(find.text('06/10 – 31/12'), findsOneWidget);
      expect(find.text('1 việc cần xử lý'), findsOneWidget);
      expect(find.text('Mốc kế tiếp: Mốc gần · 14/10'), findsOneWidget);
    });

    testWidgets('không có mục tiêu / mốc / việc cần xử lý', (tester) async {
      await pumpDetail(tester, tasks: [mkTask('a', 'Việc', TaskStatus.prep)]);
      expect(find.text('Chưa ghi mục tiêu.'), findsOneWidget);
      expect(find.text('Chưa có ngày'), findsWidgets);
      expect(find.text('Chưa có mốc sắp tới'), findsOneWidget);
      expect(find.text('Đúng nhịp'), findsOneWidget);
    });

    testWidgets('PAUSED và DONE hiện nhãn trạng thái dù có việc cần xử lý', (tester) async {
      await pumpDetail(tester, project: mkProject(status: ProjectStatus.paused), tasks: [mkTask('a', 'x', TaskStatus.prep, attention: const TaskAttention(kind: 'IDLE', days: 6))]);
      expect(find.text('Tạm dừng'), findsOneWidget);
      expect(find.text('1 việc cần xử lý'), findsNothing);
    });

    testWidgets('Sửa dự án: chỉ gửi trường đổi; end_before_start → câu báo', (tester) async {
      final api = await pumpDetail(tester, project: mkProject(goal: 'Cũ', start: '2026-10-06'));
      await tester.tap(find.text('Sửa dự án'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'Sửa dự án'), findsOneWidget);
      expect(tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Lưu')).onPressed, isNull, reason: 'chưa đổi gì');

      await tester.enterText(find.widgetWithText(TextField, 'Tên dự án'), 'Tên mới');
      await tester.tap(find.widgetWithText(ChoiceChip, 'Tạm dừng'));
      await tester.pump();
      final req = RequestOptions(path: '/api/projects/p1');
      api.projectPatchError = DioException(
        requestOptions: req,
        type: DioExceptionType.badResponse,
        response: Response(requestOptions: req, statusCode: 400, data: {'error': 'end_before_start'}),
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Lưu'));
      await tester.pumpAndSettle();
      expect(api.projectPatches.single, {'name': 'Tên mới', 'status': 'PAUSED'});
      expect(find.text('Hạn phải sau ngày bắt đầu.'), findsOneWidget);

      api.projectPatchError = null;
      final fetches = api.projectFetches;
      await tester.tap(find.widgetWithText(FilledButton, 'Lưu'));
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsNothing);
      expect(api.projectFetches, greaterThan(fetches), reason: 'làm mới dữ liệu màn này');
    });
  });

  group('Kết quả then chốt', () {
    final krs = [
      mkKr('k1', 'Bán vé', unit: 'vé', target: 4, current: 2),
      mkKr('k2', 'Hoàn thành khâu chuẩn bị', mode: KrMode.auto, linkedTotal: 3, linkedDone: 1),
      mkKr('k3', 'Truyền thông', mode: KrMode.auto),
    ];

    test('keyResultValueLabel: ba dạng giá trị', () {
      expect(keyResultValueLabel(krs[0]), '2 / 4 vé');
      expect(keyResultValueLabel(krs[1]), '1 / 3');
      expect(keyResultValueLabel(krs[2]), 'Chưa gắn việc');
      expect(keyResultValueLabel(mkKr('k', 'x', target: 10, current: 3)), '3 / 10');
    });

    testWidgets('mỗi KR một dòng: nhãn KR n, tên, cách tính, giá trị', (tester) async {
      await pumpDetail(tester, project: mkProject(krs: krs));
      for (final s in ['KR 1', 'KR 2', 'KR 3', 'Bán vé', 'Truyền thông', '2 / 4 vé', '1 / 3', 'Chưa gắn việc', 'nhập tay']) {
        expect(find.text(s), findsOneWidget, reason: s);
      }
      expect(find.text('tự đếm từ việc'), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });

    testWidgets('chưa có KR → dòng trống', (tester) async {
      await pumpDetail(tester);
      expect(find.text('Dự án chưa có kết quả then chốt nào.'), findsOneWidget);
    });

    testWidgets('nút tăng gửi PATCH current đúng giá trị; khoá ở target; giảm khoá ở 0', (tester) async {
      final api = await pumpDetail(tester, project: mkProject(krs: [mkKr('k1', 'Bán vé', unit: 'vé', target: 4, current: 3)]));
      await tester.tap(find.byTooltip('Tăng 1'));
      await tester.pumpAndSettle();
      expect(api.krPatches.single, {'krId': 'k1', 'current': 4});
      expect(find.text('4 / 4 vé'), findsOneWidget);
      expect(btnOf(tester, find.byTooltip('Tăng 1')).onPressed, isNull, reason: 'đạt target');

      await tester.tap(find.byTooltip('Giảm 1'));
      await tester.pumpAndSettle();
      expect(api.krPatches.last, {'krId': 'k1', 'current': 3});
    });

    testWidgets('nút giảm khoá ở 0; KR AUTO không có nút tăng / giảm', (tester) async {
      await pumpDetail(tester, project: mkProject(krs: [mkKr('k1', 'a', target: 4), mkKr('k2', 'b', mode: KrMode.auto)]));
      expect(btnOf(tester, find.byTooltip('Giảm 1')).onPressed, isNull);
      expect(find.byTooltip('Tăng 1'), findsOneWidget, reason: 'chỉ KR MANUAL');
    });

    testWidgets('khoá trong lúc đang gửi: bấm liên tiếp chỉ 1 PATCH', (tester) async {
      final api = await pumpDetail(tester, project: mkProject(krs: [mkKr('k1', 'Bán vé', target: 4, current: 1)]));
      api.gate = Completer();
      await tester.tap(find.byTooltip('Tăng 1'));
      await tester.pump();
      expect(btnOf(tester, find.byTooltip('Tăng 1')).onPressed, isNull);
      await tester.tap(find.byTooltip('Tăng 1'), warnIfMissed: false);
      await tester.pump();
      expect(api.krPatches, hasLength(1));
      api.gate!.complete();
      await tester.pumpAndSettle();
      expect(api.krPatches, hasLength(1));
    });

    testWidgets('Thêm KR nhập tay: cần tên và mục tiêu ≥ 1; gửi đúng trường', (tester) async {
      final api = await pumpDetail(tester);
      await tester.tap(find.text('Thêm KR'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'Thêm KR'), findsOneWidget);
      FilledButton add() => tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Thêm'));
      await tester.enterText(find.widgetWithText(TextField, 'Tên KR'), 'Bán vé');
      await tester.pump();
      expect(add().onPressed, isNotNull, reason: 'mặc định tự đếm: chỉ cần tên');

      await tester.tap(find.widgetWithText(ChoiceChip, 'Nhập tay theo con số'));
      await tester.pump();
      expect(add().onPressed, isNull, reason: 'nhập tay thiếu mục tiêu');
      await tester.enterText(find.widgetWithText(TextField, 'Mục tiêu (số nguyên ≥ 1)'), '0');
      await tester.pump();
      expect(add().onPressed, isNull);
      await tester.enterText(find.widgetWithText(TextField, 'Mục tiêu (số nguyên ≥ 1)'), '50');
      await tester.enterText(find.widgetWithText(TextField, 'Đơn vị (tuỳ chọn)'), 'vé');
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Thêm'));
      await tester.pumpAndSettle();

      expect(api.krCreates.single, {'name': 'Bán vé', 'mode': KrMode.manual, 'unit': 'vé', 'target': 50});
      expect(find.text('KR 1'), findsOneWidget);
    });

    testWidgets('Sửa KR: chỉ gửi trường đổi; Xoá KR hỏi lại, Huỷ không gọi API, Xoá thì xoá', (tester) async {
      final api = await pumpDetail(tester, project: mkProject(krs: [mkKr('k1', 'Bán vé', target: 4, current: 2)]));
      await tester.tap(find.byTooltip('Sửa KR'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'Sửa KR'), findsOneWidget);
      await tester.enterText(find.widgetWithText(TextField, 'Mục tiêu (số nguyên ≥ 1)'), '8');
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Lưu'));
      await tester.pumpAndSettle();
      expect(api.krPatches.single, {'krId': 'k1', 'target': 8});

      await tester.tap(find.byTooltip('Sửa KR'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Xoá KR'));
      await tester.pumpAndSettle();
      expect(find.text('Xoá KR này? Các việc đang gắn sẽ thành không gắn.'), findsOneWidget);
      await tester.tap(find.text('Huỷ'));
      await tester.pumpAndSettle();
      expect(api.krDeletes, isEmpty);

      await tester.tap(find.text('Xoá KR'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Xoá'));
      await tester.pumpAndSettle();
      expect(api.krDeletes, ['k1']);
      expect(find.byType(Dialog), findsNothing);
      expect(find.text('Dự án chưa có kết quả then chốt nào.'), findsOneWidget);
    });
  });

  group('bảng việc', () {
    testWidgets('4 nhóm đúng thứ tự; nhóm rỗng "Trống"; đếm việc xong', (tester) async {
      await pumpDetail(tester, tasks: [mkTask('a', 'Việc A', TaskStatus.prep), mkTask('b', 'Việc B', TaskStatus.done)]);
      final ys = [for (final s in ['Chờ', 'Đang làm', 'Thẩm định', 'Xong']) tester.getTopLeft(find.text(s).first).dy];
      expect(ys, orderedEquals([...ys]..sort()));
      expect(find.text('Trống'), findsNWidgets(2));
      expect(find.text('Việc B'), findsNothing, reason: 'nhóm Xong gập ở bố cục hẹp');
      await expandDone(tester);
      expect(find.text('Việc B'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.expand_less));
      await tester.pumpAndSettle();
      expect(find.text('Việc B'), findsNothing);
      expect(find.text('1 / 2 việc xong'), findsOneWidget);
      expect(find.text('Thêm việc'), findsOneWidget);
    });

    testWidgets('"Đang làm" có 2 việc: "2 / 2"; 3 việc: "Vượt WIP 3 / 2"', (tester) async {
      await pumpDetail(tester, tasks: [mkTask('a', 'A', TaskStatus.inProgress), mkTask('b', 'B', TaskStatus.inProgress)]);
      expect(find.text('2 / 2'), findsOneWidget);
      expect(find.textContaining('Vượt WIP'), findsNothing);

      await pumpDetail(tester, tasks: [for (final i in [1, 2, 3]) mkTask('t$i', 'Việc $i', TaskStatus.inProgress)]);
      expect(find.text('Vượt WIP 3 / 2'), findsOneWidget);
    });

    testWidgets('thứ tự trong nhóm: hạn tăng dần, không có hạn xuống cuối, rồi createdAt', (tester) async {
      await pumpDetail(tester, tasks: [
        mkTask('a', 'Không hạn cũ', TaskStatus.prep, created: 1),
        mkTask('b', 'Hạn xa', TaskStatus.prep, due: '2026-12-01'),
        mkTask('c', 'Không hạn mới', TaskStatus.prep, created: 5),
        mkTask('d', 'Hạn gần', TaskStatus.prep, due: '2026-11-01'),
      ]);
      final order = ['Hạn gần', 'Hạn xa', 'Không hạn cũ', 'Không hạn mới'];
      final ys = [for (final t in order) tester.getTopLeft(find.text(t)).dy];
      expect(ys, orderedEquals([...ys]..sort()));
    });

    test('compareBoardTasks', () {
      final a = mkTask('a', 'a', TaskStatus.prep, due: '2026-10-01');
      final b = mkTask('b', 'b', TaskStatus.prep);
      expect(compareBoardTasks(a, b), lessThan(0));
      expect(compareBoardTasks(b, a), greaterThan(0));
    });

    testWidgets('thẻ việc: nhãn KR / Không gắn KR / Mốc, cảnh báo, checklist, dòng hạn', (tester) async {
      await pumpDetail(
        tester,
        project: mkProject(krs: [mkKr('k1', 'KR một', target: 3), mkKr('k2', 'KR hai', target: 3)]),
        tasks: [
          mkTask('a', 'Gắn KR hai', TaskStatus.prep, krId: 'k2', due: '2026-10-20', attention: const TaskAttention(kind: 'OVERDUE', days: 3)),
          mkTask('b', 'Việc mốc', TaskStatus.inProgress, milestone: true, due: '2026-10-14', attention: const TaskAttention(kind: 'IDLE', days: 6)),
          mkTask('c', 'Có checklist', TaskStatus.review, checklist: const [
            ChecklistItem(id: 'c1', text: 'x', done: true, position: 0),
            ChecklistItem(id: 'c2', text: 'y', done: false, position: 1),
            ChecklistItem(id: 'c3', text: 'z', done: false, position: 2),
          ]),
          mkTask('d', 'Đã xong', TaskStatus.done, due: '2026-10-01'),
        ],
      );
      await expandDone(tester);
      expect(inCard('a', find.text('KR 2')), findsOneWidget);
      expect(inCard('a', find.text('Quá hạn 3 ngày')), findsOneWidget);
      expect(inCard('a', find.text('Hạn 20/10')), findsOneWidget);
      expect(inCard('b', find.text('Mốc')), findsOneWidget);
      expect(inCard('b', find.text('Nằm im 6 ngày')), findsOneWidget);
      expect(inCard('b', find.text('14/10')), findsOneWidget, reason: 'việc mốc chỉ hiện dd/MM');
      expect(inCard('c', find.text('Không gắn KR')), findsOneWidget);
      expect(inCard('c', find.text('1 / 3')), findsOneWidget);
      expect(inCard('c', find.text('Chưa có ngày')), findsOneWidget);
      expect(inCard('d', find.text('Xong')), findsOneWidget);
      expect(inCard('a', find.byType(Checkbox)), findsNothing, reason: 'không còn ô tick');
    });

    testWidgets('nút tiến chuyển sang nhóm sau (PATCH status đúng) và thẻ đổi nhóm', (tester) async {
      final api = await pumpDetail(tester, tasks: [mkTask('a', 'Việc A', TaskStatus.inProgress)]);
      expect(find.text('1 / 2'), findsOneWidget);
      await tester.tap(inCard('a', find.byTooltip('Chuyển sang Thẩm định')));
      await tester.pumpAndSettle();
      expect(api.taskPatches.single, {'id': 'a', 'status': TaskStatus.review});
      expect(find.text('0 / 2'), findsOneWidget, reason: 'cột Đang làm đã trống');
      expect(tester.getTopLeft(find.text('Việc A')).dy, greaterThan(tester.getTopLeft(find.text('Thẩm định').first).dy));
      expect(inCard('a', find.byTooltip('Chuyển về Đang làm')), findsOneWidget);

      await tester.tap(inCard('a', find.byTooltip('Chuyển về Đang làm')));
      await tester.pumpAndSettle();
      expect(api.taskPatches.last, {'id': 'a', 'status': TaskStatus.inProgress});
    });

    testWidgets('bấm hai lần liên tiếp chỉ gửi 1 PATCH (kể cả khi thẻ đã sang nhóm khác)', (tester) async {
      final api = await pumpDetail(tester, tasks: [mkTask('a', 'Việc A', TaskStatus.prep)]);
      api.gate = Completer();
      await tester.tap(inCard('a', find.byTooltip('Chuyển sang Đang làm')));
      await tester.pump();
      expect(btnOf(tester, inCard('a', find.byTooltip('Chuyển sang Thẩm định'))).onPressed, isNull, reason: 'khoá trong lúc gửi');
      expect(btnOf(tester, inCard('a', find.byTooltip('Chuyển về Chờ'))).onPressed, isNull);
      await tester.tap(inCard('a', find.byTooltip('Chuyển sang Thẩm định')), warnIfMissed: false);
      await tester.pump();
      expect(api.taskPatches, hasLength(1));
      api.gate!.complete();
      await tester.pumpAndSettle();
      expect(api.taskPatches, hasLength(1));
      expect(btnOf(tester, inCard('a', find.byTooltip('Chuyển sang Thẩm định'))).onPressed, isNotNull, reason: 'mở khoá sau khi xong');
    });

    testWidgets('khoá nút lùi ở nhóm đầu, nút tiến ở nhóm cuối', (tester) async {
      await pumpDetail(tester, tasks: [mkTask('a', 'A', TaskStatus.prep), mkTask('d', 'D', TaskStatus.done)]);
      await expandDone(tester);
      expect(btnOf(tester, inCard('a', find.byTooltip('Đã ở nhóm đầu'))).onPressed, isNull);
      expect(btnOf(tester, inCard('a', find.byTooltip('Chuyển sang Đang làm'))).onPressed, isNotNull);
      expect(btnOf(tester, inCard('d', find.byTooltip('Đã ở nhóm cuối'))).onPressed, isNull);
    });

    testWidgets('bề rộng 390: xếp dọc, không tràn; bề rộng 1200: 4 cột cạnh nhau', (tester) async {
      final tasks = [mkTask('a', 'A', TaskStatus.prep), mkTask('b', 'B', TaskStatus.inProgress), mkTask('c', 'C', TaskStatus.review), mkTask('d', 'D', TaskStatus.done)];
      await pumpDetail(tester, tasks: tasks, project: mkProject(krs: [mkKr('k1', 'Bán vé một tên khá dài để thử tràn ngang', unit: 'vé', target: 4, current: 2)]));
      expect(tester.takeException(), isNull);
      expect(find.text('D'), findsNothing, reason: 'nhóm Xong gập ở bố cục hẹp');
      await expandDone(tester);
      expect({for (final t in ['A', 'B', 'C', 'D']) tester.getTopLeft(find.text(t)).dx}.length, 1);

      await pumpDetail(tester, tasks: tasks, width: 1200);
      expect(tester.takeException(), isNull);
      expect({for (final t in ['A', 'B', 'C', 'D']) tester.getTopLeft(find.text(t)).dy}.length, 1, reason: 'cùng hàng');
      expect({for (final t in ['A', 'B', 'C', 'D']) tester.getTopLeft(find.text(t)).dx}.length, 4);
    });

    testWidgets('nhóm Xong không gập ở bề rộng', (tester) async {
      await pumpDetail(tester, tasks: [mkTask('d', 'Việc D', TaskStatus.done)], width: 1200);
      expect(find.text('Việc D'), findsOneWidget);
      expect(find.byIcon(Icons.expand_more), findsNothing);
      expect(find.byIcon(Icons.expand_less), findsNothing);
    });

    testWidgets('chạm thẻ mở trang chi tiết việc', (tester) async {
      await pumpDetail(tester, tasks: [mkTask('a', 'Việc A', TaskStatus.prep)]);
      await tester.tap(find.text('Việc A'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'Chi tiết việc'), findsOneWidget);
    });
  });

  group('Thêm việc', () {
    testWidgets('dùng được khi dự án PAUSED: không có ô chọn dự án, tạo đúng projectId, không cần overview', (tester) async {
      final api = await pumpDetail(tester, project: mkProject(status: ProjectStatus.paused));
      final overview = api.overviewFetches;
      await tester.tap(find.text('Thêm việc'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'Thêm việc'), findsOneWidget);
      expect(find.text('Dự án'), findsNothing, reason: 'không có ô chọn dự án');
      await tester.enterText(find.widgetWithText(TextField, 'Tên việc'), 'Việc mới');
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Lưu'));
      await tester.pumpAndSettle();
      expect(api.taskCreates.single, allOf(containsPair('projectId', 'p1'), containsPair('title', 'Việc mới')));
      expect(find.text('Việc mới'), findsOneWidget, reason: 'bảng được làm mới');
      expect(api.overviewFetches, greaterThanOrEqualTo(overview));
    });
  });
}
