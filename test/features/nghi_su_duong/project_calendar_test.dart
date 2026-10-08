import 'package:amber_flutter/features/nghi_su_duong/models/task.dart';
import 'package:amber_flutter/features/nghi_su_duong/utils/timeline.dart';
import 'package:amber_flutter/shared/utils/vn_time.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'detail_test_support.dart';

// Tab Lịch của màn Chi tiết dự án. Ngày lấy theo hôm nay (vnToday) nên không phụ thuộc ngày chạy test.

String _plus(int days) {
  final d = DateTime.parse('${vnToday()}T00:00:00Z').add(Duration(days: days));
  return d.toIso8601String().substring(0, 10);
}

Future<void> _openCalendar(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(ChoiceChip, 'Lịch'));
  await tester.pumpAndSettle();
}

void main() {
  group('chuyển tab', () {
    testWidgets('mặc định Bảng; chuyển sang Lịch và về lại; đầu trang, KR, "Thêm việc" dùng chung', (tester) async {
      await pumpDetail(
        tester,
        project: mkProject(krs: [mkKr('k1', 'Bán vé', target: 4)]),
        tasks: [mkTask('a', 'Việc A', TaskStatus.prep, start: _plus(0), due: _plus(2))],
      );
      expect(tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Bảng')).selected, isTrue);
      expect(find.text('Chờ'), findsWidgets, reason: 'bảng: tiêu đề cột');
      expect(find.byKey(const ValueKey('bar-a')), findsNothing);

      await _openCalendar(tester);
      expect(tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Lịch')).selected, isTrue);
      expect(find.byKey(const ValueKey('bar-a')), findsOneWidget);
      expect(find.text('Kết quả then chốt'), findsOneWidget);
      expect(find.text('Thêm việc'), findsOneWidget);
      expect(find.text('Sửa dự án'), findsOneWidget);
      expect(find.text('Trống'), findsNothing, reason: 'không còn bảng');

      await tester.tap(find.widgetWithText(ChoiceChip, 'Bảng'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('bar-a')), findsNothing);
      expect(find.text('Trống'), findsWidgets);
    });
  });

  group('lưới', () {
    testWidgets('việc có ngày là một dòng; xếp theo ngày bắt đầu (hoặc hạn); nhãn có khoảng ngày', (tester) async {
      await pumpDetail(tester, tasks: [
        mkTask('late', 'Việc muộn', TaskStatus.prep, start: _plus(6), due: _plus(9)),
        mkTask('one', 'Việc một ngày', TaskStatus.inProgress, due: _plus(3)),
        mkTask('early', 'Việc sớm', TaskStatus.review, start: _plus(1), due: _plus(2)),
      ]);
      await _openCalendar(tester);
      final order = ['early', 'one', 'late'];
      final ys = [for (final id in order) tester.getTopLeft(find.byKey(ValueKey('timeline-row-$id'))).dy];
      expect(ys, orderedEquals([...ys]..sort()));
      expect(find.byKey(const ValueKey('bar-late')), findsOneWidget);
      expect(find.byKey(const ValueKey('bar-one')), findsOneWidget);
      expect(find.text('Việc sớm'), findsOneWidget);
      // dòng phụ: khoảng ngày, hoặc một ngày
      String dm(String iso) => '${iso.substring(8)}/${iso.substring(5, 7)}';
      expect(find.text('${dm(_plus(1))} – ${dm(_plus(2))}'), findsOneWidget);
      expect(find.text(dm(_plus(3))), findsWidgets);
    });

    testWidgets('thanh một ngày hẹp hơn thanh nhiều ngày; thanh đủ rộng ghi tên trạng thái', (tester) async {
      await pumpDetail(tester, tasks: [
        mkTask('one', 'Một ngày', TaskStatus.prep, due: _plus(1)),
        mkTask('long', 'Dài', TaskStatus.inProgress, start: _plus(2), due: _plus(9)),
      ]);
      await _openCalendar(tester);
      final one = tester.getSize(find.byKey(const ValueKey('bar-one'))).width;
      final long = tester.getSize(find.byKey(const ValueKey('bar-long'))).width;
      expect(one, greaterThan(10), reason: 'vẫn thấy được thanh 1 ngày');
      expect(long, greaterThan(one * 4));
      expect(find.descendant(of: find.byKey(const ValueKey('bar-long')), matching: find.text('Đang làm')), findsOneWidget);
      expect(find.descendant(of: find.byKey(const ValueKey('bar-one')), matching: find.text('Chờ')), findsNothing, reason: 'quá hẹp');
    });

    testWidgets('hàng đầu: mỗi tuần một ô ghi ngày thứ Hai; tuần hiện tại được nhấn; có vạch hôm nay', (tester) async {
      await pumpDetail(tester, tasks: [mkTask('a', 'A', TaskStatus.prep, due: _plus(1))], width: 1200);
      await _openCalendar(tester);
      final monday = mondayOf(vnToday());
      String dm(String iso) => '${iso.substring(8)}/${iso.substring(5, 7)}';
      final weekCell = find.text(dm(monday));
      expect(weekCell, findsOneWidget);
      expect(tester.widget<Text>(weekCell).style?.fontWeight, FontWeight.w700, reason: 'tuần hiện tại được nhấn');
      expect(find.byKey(const ValueKey('today-line')), findsOneWidget);
      // ít nhất 4 tuần
      expect(find.byKey(const ValueKey('week-3')), findsOneWidget);
    });

    testWidgets('việc có attention: dòng phụ là nhãn cảnh báo thay cho khoảng ngày', (tester) async {
      await pumpDetail(tester, tasks: [
        mkTask('a', 'Trễ', TaskStatus.inProgress, start: _plus(-5), due: _plus(-2), attention: const TaskAttention(kind: 'OVERDUE', days: 2)),
        mkTask('b', 'Im', TaskStatus.review, start: _plus(0), due: _plus(2), attention: const TaskAttention(kind: 'IDLE', days: 6)),
      ]);
      await _openCalendar(tester);
      expect(find.text('Quá hạn 2 ngày'), findsOneWidget);
      expect(find.text('Nằm im 6 ngày'), findsOneWidget);
    });

    testWidgets('việc mốc: dấu hình thoi tại hạn, không có thanh', (tester) async {
      await pumpDetail(tester, tasks: [
        mkTask('m', 'Mốc ra mắt', TaskStatus.prep, milestone: true, due: _plus(4)),
        mkTask('t', 'Thường', TaskStatus.prep, due: _plus(4)),
      ]);
      await _openCalendar(tester);
      expect(find.byKey(const ValueKey('milestone-m')), findsOneWidget);
      expect(find.byKey(const ValueKey('bar-m')), findsNothing);
      expect(find.byKey(const ValueKey('bar-t')), findsOneWidget);
      expect(find.byKey(const ValueKey('milestone-t')), findsNothing);
    });

    testWidgets('chú giải: Chờ, Đang làm, Thẩm định, Xong, Mốc', (tester) async {
      await pumpDetail(tester, tasks: [mkTask('a', 'A', TaskStatus.prep, due: _plus(1))]);
      await _openCalendar(tester);
      for (final s in ['Chờ', 'Đang làm', 'Thẩm định', 'Xong', 'Mốc']) {
        expect(find.text(s), findsWidgets, reason: s);
      }
    });

    testWidgets('việc nằm hẳn ngoài cửa sổ: vẫn có dòng, không có thanh', (tester) async {
      // Dự án kéo dài nhiều năm → cửa sổ cắt còn 26 tuần quanh hôm nay.
      await pumpDetail(
        tester,
        project: mkProject(start: _plus(-900), end: _plus(900)),
        tasks: [
          mkTask('far', 'Việc xa', TaskStatus.prep, start: _plus(-800), due: _plus(-700)),
          mkTask('near', 'Việc gần', TaskStatus.prep, due: _plus(2)),
        ],
      );
      await _openCalendar(tester);
      expect(find.byKey(const ValueKey('timeline-row-far')), findsOneWidget);
      expect(find.byKey(const ValueKey('bar-far')), findsNothing);
      expect(find.byKey(const ValueKey('bar-near')), findsOneWidget);
    });

    testWidgets('chạm nhãn hoặc thanh mở trang chi tiết việc', (tester) async {
      await pumpDetail(tester, tasks: [mkTask('a', 'Việc A', TaskStatus.prep, start: _plus(1), due: _plus(5))]);
      await _openCalendar(tester);
      await tester.tap(find.byKey(const ValueKey('timeline-row-a')));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'Chi tiết việc'), findsOneWidget);
      await tester.tap(find.byType(CloseButton));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('bar-a')));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'Chi tiết việc'), findsOneWidget);
    });

    testWidgets('chạm dấu mốc mở trang chi tiết việc', (tester) async {
      await pumpDetail(tester, tasks: [mkTask('m', 'Mốc', TaskStatus.prep, milestone: true, due: _plus(3))]);
      await _openCalendar(tester);
      await tester.tap(find.byKey(const ValueKey('milestone-m')));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'Chi tiết việc'), findsOneWidget);
    });
  });

  group('Chưa xếp lịch và trạng thái rỗng', () {
    testWidgets('việc không có ngày nằm ở "Chưa xếp lịch" (tên + trạng thái); chạm mở chi tiết', (tester) async {
      await pumpDetail(tester, tasks: [
        mkTask('d', 'Có ngày', TaskStatus.prep, due: _plus(1)),
        mkTask('u', 'Chưa có ngày', TaskStatus.review),
      ]);
      await _openCalendar(tester);
      expect(find.text('Chưa xếp lịch'), findsOneWidget);
      expect(find.byKey(const ValueKey('unscheduled-u')), findsOneWidget);
      expect(find.descendant(of: find.byKey(const ValueKey('unscheduled-u')), matching: find.text('Thẩm định')), findsOneWidget);
      expect(find.byKey(const ValueKey('timeline-row-u')), findsNothing, reason: 'không là dòng trong lưới');
      expect(find.byKey(const ValueKey('timeline-row-d')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('unscheduled-u')));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'Chi tiết việc'), findsOneWidget);
    });

    testWidgets('không có việc chưa xếp lịch thì ẩn khối', (tester) async {
      await pumpDetail(tester, tasks: [mkTask('d', 'Có ngày', TaskStatus.prep, due: _plus(1))]);
      await _openCalendar(tester);
      expect(find.text('Chưa xếp lịch'), findsNothing);
    });

    testWidgets('không có việc nào có ngày → "Chưa có việc nào có ngày."', (tester) async {
      await pumpDetail(tester, tasks: [mkTask('u', 'Chưa ngày', TaskStatus.prep)]);
      await _openCalendar(tester);
      expect(find.text('Chưa có việc nào có ngày.'), findsOneWidget);
      expect(find.byKey(const ValueKey('today-line')), findsNothing);
      expect(find.text('Chưa xếp lịch'), findsOneWidget);
    });

    testWidgets('dự án chưa có việc nào → "Chưa có việc nào có ngày."', (tester) async {
      await pumpDetail(tester);
      await _openCalendar(tester);
      expect(find.text('Chưa có việc nào có ngày.'), findsOneWidget);
    });
  });

  group('bố cục', () {
    final tasks = [
      mkTask('a', 'Một tên việc khá dài để thử xuống dòng và cắt ở hai dòng thôi nhé', TaskStatus.inProgress, start: _plus(-50), due: _plus(40)),
      mkTask('m', 'Mốc', TaskStatus.done, milestone: true, due: _plus(20)),
      mkTask('u', 'Chưa ngày', TaskStatus.prep),
    ];

    testWidgets('390: không tràn toàn trang; lưới cuộn ngang và tự cuộn tới tuần hiện tại', (tester) async {
      await pumpDetail(tester, tasks: tasks);
      await _openCalendar(tester);
      expect(tester.takeException(), isNull);
      // Cột nhãn cố định ~150 và nằm trong khung 390.
      final label = tester.getSize(find.byKey(const ValueKey('timeline-row-a')));
      expect(label.width, 150);
      expect(label.height, 56);
      // Lưới có thể cuộn ngang (rộng hơn khung), và đã cuộn khỏi mép trái để thấy tuần hiện tại.
      final scroll = tester.state<ScrollableState>(find.byType(Scrollable).last);
      expect(scroll.position.maxScrollExtent, greaterThan(0));
      expect(scroll.position.pixels, greaterThan(0));
      // Nhãn và thanh cùng một dòng (thẳng hàng theo chiều dọc).
      final rowCenter = tester.getCenter(find.byKey(const ValueKey('timeline-row-a'))).dy;
      expect((tester.getCenter(find.byKey(const ValueKey('bar-a'))).dy - rowCenter).abs(), lessThan(1));
    });

    testWidgets('1200: không tràn; cột nhãn 240; lưới giãn vừa khung, không cần cuộn', (tester) async {
      await pumpDetail(tester, tasks: tasks, width: 1200);
      await _openCalendar(tester);
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byKey(const ValueKey('timeline-row-a'))).width, 240);
    });
  });
}
