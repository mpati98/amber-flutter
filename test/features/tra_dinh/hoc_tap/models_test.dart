import 'package:amber_flutter/features/nghi_su_duong/models/routine.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/course.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/parsed_sections.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_enums.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_overview.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_subject.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/utils/hoc_tap_errors.dart';
import 'package:flutter_test/flutter_test.dart';

import 'hoc_tap_test_support.dart';

// fromJson với JSON thật của backend (test/fixtures/hoc_tap) + giá trị enum lạ.

void main() {
  test('StudySubject.fromJson', () {
    final list = [for (final s in fixtureList('subjects')) StudySubject.fromJson(s as Map<String, dynamic>)];
    expect(list.map((s) => s.name), ['Tiếng Anh', 'Lập trình']);
    expect(list[0].dailyGoalMinutes, 60);
    expect(list[0].videoMinutesPerDay, 40);
    expect(list[0].reviewWeekdays, [7]);
    expect(list[1].dailyGoalMinutes, isNull);
  });

  test('CourseView.fromJson: danh sách khóa, trạng thái, hàng chờ', () {
    final list = [for (final c in fixtureList('courses_list')) CourseView.fromJson(c as Map<String, dynamic>)];
    expect(list.map((c) => c.status), [CourseStatus.active, CourseStatus.queued, CourseStatus.queued, CourseStatus.wishlist, CourseStatus.done]);
    expect(list.where((c) => c.status == CourseStatus.queued).map((c) => c.queuePosition), [1, 2]);
    final wish = list.firstWhere((c) => c.status == CourseStatus.wishlist);
    expect(wish.targetPrice, '499.000đ');
    expect(wish.byline, 'Thầy Nam · Coursera');
    expect(list.first.progress.totalSections, 4);
    expect(list.first.nextSection?.title, isNotNull);
  });

  test('CourseDetail.fromJson: phần, tiến độ, recentLogs', () {
    final d = CourseDetail.fromJson(fixtureMap('course_detail'));
    expect(d.course.title, 'English Tenses 101');
    expect(d.course.url, 'https://example.com/tenses');
    expect(d.sections.length, 4);
    expect(d.sections.first.done, isTrue);
    expect(d.sections.map((s) => s.durationMinutes), [46, 91, 125, 65]);
    expect(d.course.progress.doneMinutes, 46);
    expect(d.course.progress.totalMinutes, 327);
    expect(d.course.progress.percent, 14);
    expect(d.course.progress.remainingMinutes, 281);
    expect(d.course.nextSection?.id, d.sections[1].id);
    expect(d.recentLogs.map((l) => l.minutes), [30, 45]);
    expect(d.recentLogs.first.note, 'Xong phần cơ bản');
    expect(d.course.deltaDays, 0);
  });

  test('CourseDetail.withSectionDone: tính lại tiến độ và phần kế tiếp', () {
    final d = CourseDetail.fromJson(fixtureMap('course_detail'));
    final next = d.withSectionDone(d.sections[1].id, true);
    expect(next.course.progress.doneSections, 2);
    expect(next.course.progress.doneMinutes, 46 + 91);
    expect(next.course.nextSection?.id, d.sections[2].id);
    final back = next.withSectionDone(d.sections[0].id, false);
    expect(back.course.nextSection?.id, d.sections[0].id);
    final all = d.sections.fold(d, (acc, s) => acc.withSectionDone(s.id, true));
    expect(all.course.nextSection, isNull);
    expect(all.course.progress.percent, 100);
  });

  test('ParsedSections.fromJson (có dòng bị bỏ qua)', () {
    final p = ParsedSections.fromJson(fixtureMap('sections_parse'));
    expect(p.sections.map((s) => s.title), ['Intro', 'Bài 2']);
    expect(p.totalMinutes, 100);
    expect(p.skipped.map((s) => s.line), [3, 4]);
    expect(p.skipped.first.text, 'không có giờ');
  });

  test('StudyOverview.fromJson: tuần, môn, hôm nay, khóa đang học', () {
    final o = StudyOverview.fromJson(fixtureMap('overview'));
    expect(o.week.days.length, 7);
    expect(o.week.goalMinutes, 420);
    expect(o.week.bySubject.single.goalMinutes, 420);
    expect(o.week.suggestedPerDay, greaterThan(0));
    expect(o.subjects.map((s) => s.name), ['Tiếng Anh', 'Lập trình']);
    expect(o.subjects[1].goalMinutes, isNull);
    final s = o.subjects.first;
    expect(s.name, 'Tiếng Anh');
    expect(s.today.minutes, 30);
    expect(s.today.logCount, 1);
    expect(s.today.reason, isNull);
    expect(s.next?.courseTitle, 'English Tenses 101');
    expect(s.activeCourse?.status, CourseStatus.active);
    expect(s.counts.queued, 2);
    expect(s.counts.done, 1);
    expect(s.counts.wishlist, 1);
    expect(s.vsBaseline, 0);
  });

  test('giá trị enum lạ không làm hỏng', () {
    final json = Map<String, dynamic>.from(fixtureList('courses_list').first as Map<String, dynamic>)..['status'] = 'ARCHIVED_LATER';
    expect(CourseView.fromJson(json).status, CourseStatus.unknown);
    expect(CourseStatus.fromApi(null), CourseStatus.unknown);
    expect(CourseStatus.fromApi('QUEUED'), CourseStatus.queued);
    expect(ReasonCode.fromApi('SICK'), ReasonCode.unknown);
    expect(ReasonCode.fromApi('BUSY'), ReasonCode.busy);
    expect(DayReason.fromJson({'code': 'WHATEVER', 'text': null}).code, ReasonCode.unknown);
    expect(DayReason.fromJson({'code': 'OTHER', 'text': 'đi khám'}).label, 'Khác: đi khám');
  });

  test('Routine.fromJson: routine STUDY đọc thêm các trường học tập; CHECK không có', () {
    final routines = [for (final r in fixtureList('routines')) Routine.fromJson(r as Map<String, dynamic>)];
    final study = routines.firstWhere((r) => r.kind == RoutineKind.study);
    expect(study.isStudy, isTrue);
    expect(study.studySubjectName, 'Tiếng Anh');
    expect(study.goalMinutes, 60);
    expect(study.todayMinutes, 30);
    expect(study.todayLog, isNull);
    expect(study.pendingReasonDates, isEmpty);
    final check = routines.firstWhere((r) => r.kind == RoutineKind.check);
    expect(check.studySubjectId, isNull);
    expect(check.todayMinutes, isNull);
    expect(RoutineKind.fromApi('SOMETHING_NEW'), RoutineKind.check);
  });

  test('hocTapErrorMessage: mã đã biết → tiếng Việt, mã lạ / không phải API → câu chung', () {
    expect(hocTapErrorMessage(apiError(409, {'error': 'active_exists'})), 'Môn này đã có khóa đang học');
    expect(hocTapErrorMessage(apiError(409, {'error': 'subject_in_use'})), contains('việc hằng ngày'));
    expect(hocTapErrorMessage(apiError(400, {'error': 'sections_unparsed'})), contains('chưa đọc được'));
    expect(hocTapErrorMessage(apiError(400, {'error': 'a_new_code'})), 'Có lỗi, thử lại');
    expect(hocTapErrorMessage(StateError('x')), 'Có lỗi, thử lại');
  });
}
