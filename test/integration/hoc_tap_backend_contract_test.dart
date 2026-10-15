import 'package:amber_flutter/features/nghi_su_duong/models/routine.dart';
import 'package:amber_flutter/features/nghi_su_duong/services/nghi_su_duong_api.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_enums.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_schedule.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/services/hoc_tap_api.dart';
import 'package:amber_flutter/shared/utils/vn_time.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

// Test hợp đồng với backend THẬT (amber-v4) cho Học tập của Trà Đình. Bị bỏ qua nếu thiếu --dart-define:
//
//   flutter test test/integration/hoc_tap_backend_contract_test.dart \
//     --dart-define=NSD_API_BASE_URL=http://localhost:3000 \
//     --dart-define=NSD_API_TOKEN=<access token HS256 của user>
//
// Đi hết luồng của app bằng đúng HocTapApi và model của app: tạo môn → dán mục lục → thêm khóa Đang học / Chờ học →
// đổi thứ tự → tick phần → Tổng quan → Muốn mua → Đã mua → routine STUDY → ghi buổi học (30 + 35 phút) → dừng + lý do →
// học thêm xoá lý do → lý do ngày đã qua → sửa / xoá buổi hôm nay → lịch (hôm nay có buổi thật, ngày làm việc kế tiếp có kế hoạch).
// Không có log hôm qua: test Flutter không chạm được DB (backend e2e chèn log quá khứ bằng SQL) nên `pendingReasonDates`
// của routine mới tạo luôn rỗng ở đây; ngày đã qua chỉ kiểm bằng PUT / DELETE lý do (server cho phép ngày không có log). Ghi dữ liệu thật vào DB mà backend đang trỏ:
// chỉ chạy trên nhánh dev; môn thử được xoá ở cuối (cascade khóa, phần, log).

const _baseUrl = String.fromEnvironment('NSD_API_BASE_URL');
const _token = String.fromEnvironment('NSD_API_TOKEN');

String _dayBefore(String iso, int days) {
  final d = DateTime.parse(iso).subtract(Duration(days: days));
  return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

const _pasted = 'Basics1 lecture • 46min\nFirst English Sentences9 lectures • 1hr 31min\nPresent Tenses12 lectures • 2h 5m';

void main() {
  final missing = _baseUrl.isEmpty || _token.isEmpty;

  test(
    'Học tập: môn → khóa → thứ tự → tick phần → tổng quan → Muốn mua → routine STUDY (backend thật)',
    () async {
      final dio = Dio(BaseOptions(baseUrl: _baseUrl, headers: {'Authorization': 'Bearer $_token'}));
      final api = HocTapApi(dio);
      String? subjectId;
      String? routineId;
      String? secondSubjectId;
      final routinesApi = NghiSuDuongApi(dio);

      try {
        // 1. Môn Tiếng Anh: 60 phút/ngày, 40 phút video, ôn Chủ nhật.
        final subject = await api.createSubject({'name': 'TEST Tiếng Anh ${DateTime.now().millisecondsSinceEpoch}', 'dailyGoalMinutes': 60, 'videoMinutesPerDay': 40, 'reviewWeekdays': [7]});
        subjectId = subject.id;
        expect(subject.dailyGoalMinutes, 60);
        expect(subject.reviewWeekdays, [7]);
        expect((await api.getSubjects()).any((s) => s.id == subjectId), isTrue);

        // 2. Dán mục lục kiểu Udemy → parse → thêm khóa Đang học.
        final parsed = await api.parseSections('$_pasted\nkhông có giờ');
        expect(parsed.sections.map((s) => s.title), ['Basics', 'First English Sentences', 'Present Tenses']);
        expect(parsed.sections.map((s) => s.durationMinutes), [46, 91, 125]);
        expect(parsed.skipped.single.line, 4);

        final tenses = await api.createCourse({
          'subjectId': subjectId,
          'title': 'English Tenses 101',
          'status': 'ACTIVE',
          'sections': [for (final s in parsed.sections) {'title': s.title, 'durationMinutes': s.durationMinutes}],
        });
        expect(tenses.course.status, CourseStatus.active);
        expect(tenses.sections.length, 3);
        expect(tenses.course.progress.totalMinutes, 262);
        expect(tenses.course.baselineFinishDate, isNotNull, reason: 'vào ACTIVE lần đầu → chốt mốc');

        // 3. Hai khóa Chờ học, rồi đổi thứ tự.
        final a = await api.createCourse({'subjectId': subjectId, 'title': 'Complete English Course', 'status': 'QUEUED', 'sections': [{'title': 'U1', 'durationMinutes': 30}]});
        final b = await api.createCourse({'subjectId': subjectId, 'title': 'Master Native English', 'status': 'QUEUED', 'sections': [{'title': 'P1', 'durationMinutes': 60}]});
        var queued = await api.getCourses(subjectId: subjectId, statuses: [CourseStatus.queued]);
        expect(queued.map((c) => c.title), ['Complete English Course', 'Master Native English']);
        await api.moveCourse(b.course.id, up: true);
        queued = await api.getCourses(subjectId: subjectId, statuses: [CourseStatus.queued]);
        expect(queued.map((c) => c.title), ['Master Native English', 'Complete English Course']);
        expect(queued.map((c) => c.queuePosition), [1, 2]);

        // 4. Hai khóa ACTIVE → active_exists.
        await expectLater(
          api.patchCourse(a.course.id, {'status': 'ACTIVE'}),
          throwsA(isA<DioException>().having((e) => (e.response?.data as Map)['error'], 'error', 'active_exists')),
        );

        // 5. Tick phần đầu.
        final ticked = await api.setSectionDone(tenses.course.id, tenses.sections.first.id, true);
        expect(ticked.course.progress.doneSections, 1);
        expect(ticked.course.progress.doneMinutes, 46);
        expect(ticked.course.nextSection?.title, 'First English Sentences');
        final detail = await api.getCourseDetail(tenses.course.id);
        expect(detail.sections.first.done, isTrue);
        expect(detail.recentLogs, isEmpty);

        // 6. Tổng quan.
        final overview = await api.getOverview();
        final ov = overview.subjects.firstWhere((s) => s.subjectId == subjectId);
        expect(ov.goalMinutes, 60);
        expect(ov.today.minutes, 0);
        expect(ov.activeCourse?.id, tenses.course.id);
        expect(ov.next?.sectionTitle, 'First English Sentences');
        expect(ov.counts.queued, 2);
        expect(overview.week.days.length, 7);
        expect(overview.week.bySubject.any((s) => s.subjectId == subjectId && s.goalMinutes == 420), isTrue);

        // 7. Muốn mua → Đã mua.
        final wish = await api.createCourse({'subjectId': subjectId, 'title': 'IELTS Masterclass', 'status': 'WISHLIST', 'targetPrice': '499k', 'note': 'chờ sale'});
        expect(wish.course.status, CourseStatus.wishlist);
        expect(wish.course.targetPrice, '499k');
        expect((await api.getOverview()).subjects.firstWhere((s) => s.subjectId == subjectId).counts.wishlist, 1);
        await api.patchCourse(wish.course.id, {'status': 'QUEUED'});
        expect((await api.getCourseDetail(wish.course.id)).course.status, CourseStatus.queued);

        // 8. Routine STUDY: app đọc được các trường học tập.
        final routine = await routinesApi.createRoutine(name: 'Học tiếng Anh', kind: RoutineKind.study, studySubjectId: subjectId);
        routineId = routine.id;
        expect(routine.kind, RoutineKind.study);
        expect(routine.isStudy, isTrue);
        expect(routine.studySubjectId, subjectId);
        expect(routine.goalMinutes, 60);
        expect(routine.todayMinutes, 0);
        expect(routine.doneToday, isFalse);
        expect(routine.weekdays, [1, 2, 3, 4, 5, 6, 7], reason: 'STUDY mặc định cả 7 ngày');
        expect(routine.todayLog, isNull);
        expect(routine.pendingReasonDates, isEmpty);
        // Đang có routine STUDY trỏ tới → xoá môn bị chặn.
        await expectLater(api.deleteSubject(subjectId), throwsA(isA<DioException>().having((e) => (e.response?.data as Map)['error'], 'error', 'subject_in_use')));

        // 9. Ghi buổi học: 30' rồi 35' (có tick xong phần 2) → đủ mục tiêu → routine done.
        final secondSection = ticked.sections[1];
        final l1 = await api.createLog({'subjectId': subjectId, 'courseId': tenses.course.id, 'minutes': 30, 'note': 'buổi 1'});
        expect(l1.today.minutes, 30);
        expect(l1.today.done, isFalse);
        expect(l1.course?.id, tenses.course.id);
        final l2 = await api.createLog({
          'subjectId': subjectId,
          'courseId': tenses.course.id,
          'minutes': 35,
          'sections': [{'sectionId': secondSection.id, 'markDone': true}],
        });
        expect(l2.today.minutes, 65);
        expect(l2.today.done, isTrue);
        expect(l2.log.sections.single.markedDone, isTrue);
        expect(l2.course?.progress.doneSections, 2);
        final afterLogs = (await routinesApi.getRoutines()).firstWhere((r) => r.id == routineId);
        expect(afterLogs.doneToday, isTrue);
        expect(afterLogs.todayMinutes, 65);
        expect(afterLogs.streak, greaterThanOrEqualTo(1));
        expect(afterLogs.todayLog, isNull);
        final today = vnToday();
        final todayLogs = await api.getLogs(from: today, to: today, subjectId: subjectId);
        expect(todayLogs.length, 2);
        expect(todayLogs.map((l) => l.minutes).toSet(), {30, 35});
        final withSections = (await api.getCourseDetail(tenses.course.id)).recentLogs.firstWhere((l) => l.id == l2.log.id);
        expect(withSections.sections.single.title, secondSection.title);
        expect(withSections.sections.single.markedDone, isTrue);

        // 10. Sửa / xoá buổi của hôm nay.
        final patched = await api.patchLog(l1.log.id, {'minutes': 25, 'note': null});
        expect(patched.log.minutes, 25);
        expect(patched.log.note, isNull);
        expect(patched.today.minutes, 60);
        expect(patched.today.done, isTrue);
        final afterDelete = await api.deleteLog(l1.log.id);
        expect(afterDelete.minutes, 35);
        expect(afterDelete.done, isFalse);
        expect((await api.getLogs(from: today, to: today, subjectId: subjectId)).length, 1);

        // 10b. Lịch: hôm nay có buổi thật, ngày làm việc kế tiếp có kế hoạch (hôm nay đã có buổi → bắt đầu từ ngày mai).
        final schedule = await api.getSchedule(subjectId: subjectId, from: today, to: _dayBefore(today, -7));
        expect(schedule.days.length, 8);
        final todayDay = schedule.days.first;
        expect(todayDay.date, today);
        expect(todayDay.kind, ScheduleKind.today);
        expect(todayDay.minutes, 35);
        expect(todayDay.logs.single.minutes, 35);
        expect(todayDay.logs.single.sections.single.markedDone, isTrue);
        expect(todayDay.plannedItems, isNull, reason: 'hôm nay đã có buổi → không còn kế hoạch của hôm nay');
        final tomorrow = _dayBefore(today, -1);
        final tomorrowDay = schedule.days[1];
        expect(tomorrowDay.date, tomorrow);
        expect(tomorrowDay.kind, ScheduleKind.planned);
        if (!tomorrowDay.isReviewDay) {
          expect(tomorrowDay.plannedItems, isNotEmpty, reason: 'ngày mai (không phải ngày ôn) có kế hoạch');
        } else {
          expect(tomorrowDay.plannedItems, isEmpty);
        }
        final nextStudyDay = schedule.days.skip(1).firstWhere((d) => !d.isReviewDay);
        expect(nextStudyDay.plannedItems, isNotEmpty);
        expect(nextStudyDay.plannedItems!.first.courseTitle, 'English Tenses 101');
        expect(schedule.summary.minutes, 35);
        expect(schedule.summary.plannedMinutes, greaterThan(0));
        expect(schedule.summary.vsBaseline.any((b) => b.courseId == tenses.course.id), isTrue);
        await expectLater(
          api.getSchedule(subjectId: subjectId, from: _dayBefore(today, 70), to: today),
          throwsA(isA<DioException>().having((e) => (e.response?.data as Map)['error'], 'error', 'range_too_large')),
        );

        // 11. Môn thứ hai: 45' + dừng (BUSY) → lý do lưu; học thêm 15' → lý do tự xoá.
        secondSubjectId = (await api.createSubject({'name': 'TEST Lập trình ${DateTime.now().millisecondsSinceEpoch}', 'dailyGoalMinutes': 60})).id;
        final stopped = await api.createLog({
          'subjectId': secondSubjectId,
          'minutes': 45,
          'stopForToday': {'code': 'BUSY'},
        });
        expect(stopped.log.courseId, isNull, reason: 'không gắn khóa = ôn tập');
        expect(stopped.today.done, isFalse);
        expect(stopped.today.reason?.code, ReasonCode.busy);
        final ovStopped = (await api.getOverview()).subjects.firstWhere((s) => s.subjectId == secondSubjectId);
        expect(ovStopped.today.reason?.code, ReasonCode.busy);
        final topUp = await api.createLog({'subjectId': secondSubjectId, 'minutes': 15});
        expect(topUp.today.done, isTrue);
        expect(topUp.today.reason, isNull);

        // 12. Lý do ngày đã qua: môn chưa đủ mục tiêu hôm đó → ghi được; ghi lại thì thay; xoá được.
        final yesterday = _dayBefore(today, 1);
        final reason = await api.putReason(subjectId, yesterday, code: ReasonCode.other, text: 'Đi khám');
        expect((reason.date, reason.code, reason.text), (yesterday, ReasonCode.other, 'Đi khám'));
        final changed = await api.putReason(subjectId, yesterday, code: ReasonCode.tired);
        expect(changed.code, ReasonCode.tired);
        await expectLater(
          api.putReason(subjectId, _dayBefore(today, -1), code: ReasonCode.busy),
          throwsA(isA<DioException>().having((e) => (e.response?.data as Map)['error'], 'error', 'future_date')),
        );
        await expectLater(
          api.putReason(subjectId, yesterday, code: ReasonCode.other),
          throwsA(isA<DioException>().having((e) => (e.response?.data as Map)['error'], 'error', 'reason_text_required')),
        );
        await api.deleteReason(subjectId, yesterday);

        // 13. Routine STUDY không tick tay.
        await expectLater(
          dio.put<Map<String, dynamic>>('/api/du-an/routines/$routineId/logs/$today'),
          throwsA(isA<DioException>().having((e) => (e.response?.data as Map)['error'], 'error', 'study_routine_auto')),
        );

        // 14. Chốt lại kế hoạch.
        final rebased = await api.rebaseline(subjectId);
        expect(rebased.first.id, tenses.course.id);
      } finally {
        if (routineId != null) await dio.delete<void>('/api/du-an/routines/$routineId');
        if (secondSubjectId != null) await api.deleteSubject(secondSubjectId);
        if (subjectId != null) await api.deleteSubject(subjectId);
      }
    },
    timeout: const Timeout(Duration(minutes: 5)),
    skip: missing ? 'thiếu --dart-define=NSD_API_BASE_URL / NSD_API_TOKEN' : false,
  );
}
