import 'package:amber_flutter/features/nghi_su_duong/models/routine.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_enums.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/services/hoc_tap_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

// Test hợp đồng với backend THẬT (amber-v4) cho Học tập của Trà Đình. Bị bỏ qua nếu thiếu --dart-define:
//
//   flutter test test/integration/hoc_tap_backend_contract_test.dart \
//     --dart-define=NSD_API_BASE_URL=http://localhost:3000 \
//     --dart-define=NSD_API_TOKEN=<access token HS256 của user>
//
// Đi hết luồng của app bằng đúng HocTapApi và model của app: tạo môn → dán mục lục → thêm khóa Đang học / Chờ học →
// đổi thứ tự → tick phần → Tổng quan → Muốn mua → Đã mua → routine STUDY. Ghi dữ liệu thật vào DB mà backend đang trỏ:
// chỉ chạy trên nhánh dev; môn thử được xoá ở cuối (cascade khóa, phần, log).

const _baseUrl = String.fromEnvironment('NSD_API_BASE_URL');
const _token = String.fromEnvironment('NSD_API_TOKEN');

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
        final created = await dio.post<Map<String, dynamic>>('/api/du-an/routines', data: {'name': 'Học tiếng Anh', 'kind': 'STUDY', 'studySubjectId': subjectId});
        final routine = Routine.fromJson(created.data!);
        routineId = routine.id;
        expect(routine.kind, RoutineKind.study);
        expect(routine.isStudy, isTrue);
        expect(routine.studySubjectId, subjectId);
        expect(routine.goalMinutes, 60);
        expect(routine.todayMinutes, 0);
        expect(routine.todayLog, isNull);
        expect(routine.pendingReasonDates, isEmpty);
        // Đang có routine STUDY trỏ tới → xoá môn bị chặn.
        await expectLater(api.deleteSubject(subjectId), throwsA(isA<DioException>().having((e) => (e.response?.data as Map)['error'], 'error', 'subject_in_use')));

        // 9. Chốt lại kế hoạch.
        final rebased = await api.rebaseline(subjectId);
        expect(rebased.first.id, tenses.course.id);
      } finally {
        if (routineId != null) await dio.delete<void>('/api/du-an/routines/$routineId');
        if (subjectId != null) await api.deleteSubject(subjectId);
      }
    },
    timeout: const Timeout(Duration(minutes: 5)),
    skip: missing ? 'thiếu --dart-define=NSD_API_BASE_URL / NSD_API_TOKEN' : false,
  );
}
