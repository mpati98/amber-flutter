import 'package:amber_flutter/features/nghi_su_duong/utils/timeline.dart';
import 'package:flutter_test/flutter_test.dart';

// 2026-10-07 là thứ Tư; thứ Hai của tuần đó là 2026-10-05.
const _today = '2026-10-07';

void main() {
  group('mondayOf / daysBetween', () {
    test('thứ Hai của tuần', () {
      expect(mondayOf('2026-10-05'), '2026-10-05');
      expect(mondayOf('2026-10-07'), '2026-10-05');
      expect(mondayOf('2026-10-11'), '2026-10-05'); // Chủ nhật
      expect(mondayOf('2026-10-12'), '2026-10-12');
      expect(mondayOf('2026-01-01'), '2025-12-29'); // qua năm
    });

    test('daysBetween', () {
      expect(daysBetween('2026-10-05', '2026-10-07'), 2);
      expect(daysBetween('2026-10-07', '2026-10-05'), -2);
      expect(daysBetween('2026-02-28', '2026-03-01'), 1);
    });
  });

  group('computeTimelineWindow', () {
    test('không có gì ngoài hôm nay → đúng 4 tuần, bắt đầu từ thứ Hai tuần hiện tại', () {
      final w = computeTimelineWindow(today: _today);
      expect(w.start, '2026-10-05');
      expect(w.end, '2026-11-01');
      expect(w.weeks, 4);
      expect(w.days, 28);
    });

    test('bắt đầu từ tuần chứa ngày sớm nhất (kể cả startDate dự án), kết thúc ở Chủ nhật tuần chứa ngày muộn nhất', () {
      final w = computeTimelineWindow(
        projectStart: '2026-09-02', // thứ Tư
        projectEnd: '2026-12-10', // thứ Năm
        today: _today,
      );
      expect(w.start, '2026-08-31');
      expect(w.end, '2026-12-13');
      expect(w.weeks, 15);
    });

    test('ngày của việc mở rộng cửa sổ cả hai phía', () {
      final w = computeTimelineWindow(
        taskDates: const [(start: '2026-09-20', due: null), (start: null, due: '2026-11-20')],
        today: _today,
      );
      expect(w.start, '2026-09-14');
      expect(w.end, '2026-11-22');
      expect(w.contains(_today), isTrue);
    });

    test('hôm nay nằm ngoài khoảng dự án vẫn được bao trong cửa sổ', () {
      final w = computeTimelineWindow(projectStart: '2026-08-10', projectEnd: '2026-08-20', today: _today);
      expect(w.contains(_today), isTrue);
      expect(w.start, '2026-08-10');
      expect(w.end, '2026-10-11');
    });

    test('dài hơn 26 tuần → 26 tuần, bắt đầu 2 tuần trước tuần hiện tại', () {
      final w = computeTimelineWindow(projectStart: '2025-01-06', projectEnd: '2027-12-31', today: _today);
      expect(w.weeks, 26);
      expect(w.start, '2026-09-21'); // 2026-10-05 trừ 14 ngày
      expect(w.end, '2027-03-21');
      expect(w.contains(_today), isTrue);
      expect(w.contains(mondayOf(_today)), isTrue);
    });

    test('26 tuần không vượt ra ngoài khoảng gốc: chạm cuối thì lùi lại, vẫn chứa tuần hiện tại', () {
      final w = computeTimelineWindow(projectStart: '2025-01-06', projectEnd: '2026-11-15', today: _today);
      expect(w.weeks, 26);
      expect(w.end, '2026-11-15'); // Chủ nhật cuối của khoảng gốc
      expect(w.start, '2026-05-18');
      expect(w.contains(_today), isTrue);
    });

    test('26 tuần: chạm đầu thì bắt đầu đúng tại đầu khoảng gốc', () {
      final w = computeTimelineWindow(projectStart: '2026-09-28', projectEnd: '2027-12-31', today: _today);
      expect(w.start, '2026-09-28');
      expect(w.weeks, 26);
      expect(w.contains(_today), isTrue);
    });

    test('đúng 26 tuần thì giữ nguyên, không cắt', () {
      final w = computeTimelineWindow(projectStart: '2026-10-05', projectEnd: '2027-04-04', today: _today);
      expect(w.weeks, 26);
      expect(w.start, '2026-10-05');
      expect(w.end, '2027-04-04');
    });
  });

  group('timelineBar', () {
    final w = computeTimelineWindow(today: _today); // 2026-10-05 .. 2026-11-01

    test('hai ngày → thanh từ start đến due, tính theo ngày', () {
      expect(timelineBar('2026-10-06', '2026-10-09', w), const TimelineBar(offset: 1, length: 4));
    });

    test('một ngày (chỉ start hoặc chỉ due, hoặc start = due) → thanh 1 ngày', () {
      expect(timelineBar('2026-10-08', null, w), const TimelineBar(offset: 3, length: 1));
      expect(timelineBar(null, '2026-10-08', w), const TimelineBar(offset: 3, length: 1));
      expect(timelineBar('2026-10-08', '2026-10-08', w), const TimelineBar(offset: 3, length: 1));
    });

    test('start sau due → đổi chỗ', () {
      expect(timelineBar('2026-10-09', '2026-10-06', w), const TimelineBar(offset: 1, length: 4));
    });

    test('không có ngày nào → null', () {
      expect(timelineBar(null, null, w), isNull);
    });

    test('cắt theo cửa sổ ở hai đầu', () {
      expect(timelineBar('2026-09-28', '2026-10-07', w), const TimelineBar(offset: 0, length: 3, clippedStart: true));
      expect(timelineBar('2026-10-30', '2026-11-10', w), const TimelineBar(offset: 25, length: 3, clippedEnd: true));
      expect(
        timelineBar('2026-09-01', '2026-12-01', w),
        const TimelineBar(offset: 0, length: 28, clippedStart: true, clippedEnd: true),
      );
    });

    test('nằm hẳn ngoài cửa sổ → null (việc vẫn có dòng, không có thanh)', () {
      expect(timelineBar('2026-09-01', '2026-09-30', w), isNull);
      expect(timelineBar('2026-11-02', '2026-11-30', w), isNull);
      expect(timelineBar('2026-12-01', null, w), isNull);
    });

    test('ngày sát biên: ngày đầu và ngày cuối cửa sổ vẫn có thanh', () {
      expect(timelineBar('2026-10-05', null, w), const TimelineBar(offset: 0, length: 1));
      expect(timelineBar(null, '2026-11-01', w), const TimelineBar(offset: 27, length: 1));
    });
  });
}
