import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_enums.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_log.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_overview.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_schedule.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_stats.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/utils/log_labels.dart';
import 'package:flutter_test/flutter_test.dart';

import 'hoc_tap_test_support.dart';

// Hoạt động PRACTICE (luyện chat AI) và các trường mới của overview — JSON thật chụp từ backend dev (không phải production).

void main() {
  group('LogActivity', () {
    test('PRACTICE là giá trị thật, không rơi vào unknown; giá trị chưa biết vẫn unknown; thiếu → lesson', () {
      expect(LogActivity.fromApi('PRACTICE'), LogActivity.practice);
      expect(LogActivity.practice.api, 'PRACTICE');
      expect(LogActivity.fromApi('CARD_REVIEW'), LogActivity.cardReview);
      expect(LogActivity.fromApi('SOMETHING_NEW'), LogActivity.unknown);
      expect(LogActivity.fromApi(null), LogActivity.lesson);
    });

    test('logTitle: buổi luyện AI → "Luyện AI", không lấy tên khóa', () {
      expect(logTitle(activity: LogActivity.practice), 'Luyện AI');
      expect(logTitle(activity: LogActivity.practice, courseTitle: 'x'), 'Luyện AI');
    });
  });

  group('buổi học PRACTICE (JSON thật)', () {
    test('POST /logs: log có activity PRACTICE, không khóa, không phần; today đã gồm phút luyện AI', () {
      final r = StudyLogResult.fromJson(fixtureMap('log_practice_created'));
      expect(r.log.activity, LogActivity.practice);
      expect(r.log.courseId, isNull);
      expect(r.log.sections, isEmpty);
      expect(r.log.minutes, 15);
      expect(r.log.note, 'nói chuyện 15 phút');
      expect(r.course, isNull);
    });

    test('GET /logs hôm nay: đủ ba loại, PRACTICE không bị bỏ qua', () {
      final logs = [for (final l in fixtureList('logs_today_practice')) StudyLog.fromJson(l as Map<String, dynamic>)];
      expect(logs.map((l) => l.activity).toSet(), {LogActivity.lesson, LogActivity.cardReview, LogActivity.practice});
    });

    test('lịch: buổi PRACTICE được giữ (không còn bị bỏ như activity lạ)', () {
      final s = StudySchedule.fromJson(fixtureMap('schedule_practice'));
      final logs = s.days.expand((d) => d.logs).toList();
      expect(logs.where((l) => l.activity == LogActivity.practice).length, 1);
      expect(logs.length, 3);
    });

    test('thống kê: "Luyện AI" và "Ôn thẻ" là hai dòng riêng cùng courseId null, khoá không trùng', () {
      final s = StudyStats.fromJson(fixtureMap('stats_practice'));
      final titles = s.byCourse.map((c) => c.title).toList();
      expect(titles, containsAll(['Ôn tập', 'Luyện AI', 'Ôn thẻ']));
      expect(s.byCourse.where((c) => c.courseId == null).length, 3);
      final keys = statsCourseKeys(s.byCourse);
      expect(keys.toSet().length, keys.length);
      expect(keys[titles.indexOf('Luyện AI')], 'practice');
      expect(keys[titles.indexOf('Ôn thẻ')], 'cards');
      expect(keys[titles.indexOf('Ôn tập')], 'review');
    });
  });

  group('overview: trường mới', () {
    test('JSON thật: minutesByActivity, streak, pendingReasonDates, cards.total, next.minutes', () {
      final o = StudyOverview.fromJson(fixtureMap('overview_practice'));
      final s = o.subjects.first;
      expect(s.today.byActivity.hasData, isTrue);
      expect((s.today.byActivity.lesson, s.today.byActivity.cardReview, s.today.byActivity.practice), (20, 10, 15));
      expect(s.today.minutes, 45);
      expect(s.streak, 0);
      expect(s.pendingReasonDates, isEmpty);
      expect(s.cards!.total, 2);
      expect(s.next!.minutes, 25);
    });

    test('backend cũ (fixture overview.json không có các trường mới): mặc định / ẩn, không ném', () {
      final o = StudyOverview.fromJson(fixtureMap('overview'));
      final s = o.subjects.first;
      expect(s.today.byActivity.hasData, isFalse);
      expect(s.today.byActivity.practice, 0);
      expect(s.streak, isNull);
      expect(s.pendingReasonDates, isEmpty);
      expect(s.next!.minutes, isNull);
    });

    test('trường sai kiểu hoặc thiếu từng phần: chịu được', () {
      final base = Map<String, dynamic>.from(fixtureMap('overview_practice')['subjects'][0] as Map);
      final today = Map<String, dynamic>.from(base['today'] as Map);
      final s = SubjectOverview.fromJson({
        ...base,
        'today': {...today, 'minutesByActivity': 'hỏng'},
        'streak': 'x',
        'pendingReasonDates': [1, '2026-11-01', null],
        'cards': {'planned': 1},
        'next': {...Map<String, dynamic>.from(base['next'] as Map), 'minutes': null},
      });
      expect(s.today.byActivity.hasData, isFalse);
      expect(s.streak, isNull);
      expect(s.pendingReasonDates, ['2026-11-01']);
      expect(s.cards!.total, isNull);
      expect(s.next!.minutes, isNull);
      final partial = MinutesByActivity.fromJson({'PRACTICE': 7});
      expect((partial.lesson, partial.cardReview, partial.practice, partial.hasData), (0, 0, 7, true));
    });
  });
}
