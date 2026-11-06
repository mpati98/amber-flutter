import 'package:amber_flutter/features/nghi_su_duong/models/routine.dart';
import 'package:amber_flutter/features/nghi_su_duong/services/nghi_su_duong_api.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_card.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_card_queue.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_enums.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_schedule.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/providers/card_review_provider.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/services/hoc_tap_api.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/utils/card_format.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/utils/log_labels.dart';
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
// học thêm xoá lý do → lý do ngày đã qua → sửa / xoá buổi hôm nay → lịch (hôm nay có buổi thật, ngày làm việc kế tiếp có kế hoạch) → thống kê 7 ngày.
// Không có log hôm qua: test Flutter không chạm được DB (backend e2e chèn log quá khứ bằng SQL) nên `pendingReasonDates`
// của routine mới tạo luôn rỗng ở đây; ngày đã qua chỉ kiểm bằng PUT / DELETE lý do (server cho phép ngày không có log). Ghi dữ liệu thật vào DB mà backend đang trỏ:
// chỉ chạy trên nhánh dev; môn thử được xoá ở cuối (cascade khóa, phần, log).

const _baseUrl = String.fromEnvironment('NSD_API_BASE_URL');
const _token = String.fromEnvironment('NSD_API_TOKEN');

String _dayBefore(String iso, int days) {
  final d = DateTime.parse(iso).subtract(Duration(days: days));
  return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

/// Mã lỗi chuỗi của backend (`{error: 'duplicate_phrase'}`) hoặc null.
Matcher _apiError(int status, String code) => throwsA(isA<DioException>().having((e) => e.response?.statusCode, 'status', status).having((e) => (e.response?.data as Map)['error'], 'error', code));

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

        // 10c. Thống kê 7 ngày: đúng tổng phút và theo khóa của buổi còn lại (35' gắn English Tenses 101).
        final stats = await api.getStats(subjectId: subjectId, range: '7');
        expect(stats.totalMinutes, 35);
        expect(stats.logCount, 1);
        expect(stats.avgPerDay, 5); // 35 / 7
        expect(stats.series.length, 7);
        expect(stats.series.last.start, today);
        expect(stats.series.last.minutes, 35);
        expect(stats.bucket, 'day');
        expect(stats.byCourse.single.title, 'English Tenses 101');
        expect(stats.byCourse.single.minutes, 35);
        expect(stats.byCourse.single.logCount, 1);
        expect(stats.byCourse.single.courseId, tenses.course.id);
        expect(stats.longestDay?.minutes, 35);
        expect(stats.reasonCounts.total, 0);
        expect(stats.vsPlan.any((p) => p.courseId == tenses.course.id), isTrue);
        expect(stats.overallDeltaDays.single.subjectId, subjectId);
        final statsAll = await api.getStats(range: 'all');
        expect(statsAll.totalMinutes, greaterThanOrEqualTo(35));
        expect(statsAll.series, isNotEmpty);
        await expectLater(api.getStats(range: '14'), throwsA(isA<DioException>().having((e) => e.response?.statusCode, 'status', 400)));

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

  test(
    'Kho thẻ từ vựng: tạo → trùng → lọc → phân trang → sửa / tạm dừng → chủ đề → xem trước → nhập (thẻ đã có bị bỏ qua) → xoá (backend thật)',
    () async {
      final dio = Dio(BaseOptions(baseUrl: _baseUrl, headers: {'Authorization': 'Bearer $_token'}));
      final api = HocTapApi(dio);
      String? subjectId;

      try {
        subjectId = (await api.createSubject({'name': 'TEST Kho thẻ ${DateTime.now().millisecondsSinceEpoch}', 'dailyGoalMinutes': 60})).id;
        final sid = subjectId;

        // 1. Tạo thẻ: chuẩn hoá khoảng trắng / chữ thường; thẻ mới chưa có hạn.
        final c1 = await api.createCard({
          'subjectId': sid,
          'phrase': '  Look  Forward To ',
          'meaning': 'to be excited about something in the future',
          'example': 'I look forward to meeting you.',
          'note': 'followed by V-ing',
          'kind': 'PHRASAL_VERB',
          'topics': [' Daily Life ', 'work'],
        });
        expect(c1.phrase, 'Look  Forward To');
        expect(c1.kind, CardKind.phrasalVerb);
        expect(c1.topics, ['daily life', 'work']);
        expect((c1.stage, c1.dueAt, c1.reviewCount, c1.notYetCount, c1.suspended), (CardStage.newCard, null, 0, 0, false));
        expect(c1.subjectId, sid);
        final c2 = await api.createCard({'subjectId': sid, 'phrase': 'break the ice', 'meaning': 'to relax people', 'example': 'A joke broke the ice.', 'kind': 'IDIOM', 'topics': ['work']});
        final c3 = await api.createCard({'subjectId': sid, 'phrase': 'make a decision', 'meaning': 'to choose', 'example': 'We must make a decision.', 'kind': 'COLLOCATION'});

        // 2. Trùng cụm (khác hoa thường / khoảng trắng) → 409; một từ → 400 theo trường, app đọc ra câu tiếng Việt.
        await expectLater(
          api.createCard({'subjectId': sid, 'phrase': 'BREAK  the ICE', 'meaning': 'x', 'example': 'y', 'kind': 'IDIOM'}),
          _apiError(409, 'duplicate_phrase'),
        );
        try {
          await api.createCard({'subjectId': sid, 'phrase': 'hello', 'meaning': 'x', 'example': 'y', 'kind': 'IDIOM'});
          fail('phải báo lỗi');
        } on DioException catch (e) {
          expect(e.response?.statusCode, 400);
          expect(cardErrorMessage(e), 'Cụm từ phải có ít nhất 2 từ (kho không nhận từ đơn)');
        }

        // 3. Danh sách: mới nhất trước, số đếm cả môn; lọc theo giai đoạn / loại / chủ đề / từ khoá; số đếm không đổi khi lọc.
        final all = await api.getCards(subjectId: sid);
        expect(all.cards.map((c) => c.phrase), ['make a decision', 'break the ice', 'Look  Forward To']);
        expect((all.counts.total, all.counts.newCards, all.counts.weekly, all.counts.suspended), (3, 3, 0, 0));
        expect(all.nextCursor, isNull);
        expect((await api.getCards(subjectId: sid, kind: CardKind.idiom)).cards.map((c) => c.id), [c2.id]);
        expect((await api.getCards(subjectId: sid, topic: 'work')).cards.map((c) => c.id), [c2.id, c1.id]);
        expect((await api.getCards(subjectId: sid, topic: 'daily life')).cards.map((c) => c.id), [c1.id]);
        expect((await api.getCards(subjectId: sid, q: 'FORWARD')).cards.map((c) => c.id), [c1.id], reason: 'tìm không phân biệt hoa thường');
        expect((await api.getCards(subjectId: sid, q: 'relax')).cards.map((c) => c.id), [c2.id], reason: 'tìm cả trong nghĩa');
        final weekly = await api.getCards(subjectId: sid, stage: CardStage.weekly);
        expect(weekly.cards, isEmpty);
        expect(weekly.counts.total, 3);

        // 4. Phân trang bằng con trỏ: 2 + 1, không sót, không lặp.
        final p1 = await api.getCards(subjectId: sid, limit: 2);
        expect(p1.cards.length, 2);
        expect(p1.nextCursor, isNotNull);
        final p2 = await api.getCards(subjectId: sid, limit: 2, cursor: p1.nextCursor);
        expect(p2.cards.length, 1);
        expect(p2.nextCursor, isNull);
        expect([...p1.cards, ...p2.cards].map((c) => c.id), all.cards.map((c) => c.id));

        // 5. Xem một thẻ; sửa nội dung + tạm dừng; khoá lạ (stage) bị bỏ qua; đổi cụm thành cụm đã có → 409.
        expect((await api.getCard(c1.id)).example, 'I look forward to meeting you.');
        final patched = await api.patchCard(c1.id, {'meaning': 'new meaning', 'topics': ['travel'], 'suspended': true, 'stage': 'QUARTERLY'});
        expect(patched.meaning, 'new meaning');
        expect(patched.topics, ['travel']);
        expect(patched.suspended, isTrue);
        expect(patched.stage, CardStage.newCard, reason: 'giai đoạn chỉ đổi khi ôn thẻ');
        expect(cardDueLabel(patched), 'Tạm dừng');
        await expectLater(api.patchCard(c1.id, {'phrase': 'Break The Ice'}), _apiError(409, 'duplicate_phrase'));
        await expectLater(api.getCard('00000000-0000-4000-8000-000000000000'), _apiError(404, 'card_not_found'));
        expect((await api.getCards(subjectId: sid)).counts.suspended, 1);

        // 6. Chủ đề đang có (kể cả thẻ tạm dừng), nhiều thẻ trước.
        final topics = await api.getCardTopics(sid);
        expect(topics.map((t) => (t.topic, t.cards)), [('travel', 1), ('work', 1)]);

        // 7. Xem trước: thẻ mới, đã có trong kho, lặp trong đầu vào, lỗi — không lưu gì.
        final before = (await api.getCards(subjectId: sid)).counts.total;
        final parsed = await api.parseCards(
          sid,
          '[{"phrase":"Break the ice","meaning":"m","example":"e","kind":"IDIOM"},'
          '{"phrase":"pick up on","meaning":"to notice","example":"She picked up on it.","kind":"PHRASAL_VERB","topics":["Work"]},'
          '{"phrase":"PICK  UP on","meaning":"m","example":"e","kind":"PHRASAL_VERB"},'
          '{"phrase":"hello","meaning":"m","example":"e","kind":"WORD"}]',
        );
        expect(parsed.cards.map((c) => (c.index, c.phrase)), [(1, 'pick up on')]);
        expect(parsed.cards.single.topics, ['work']);
        expect(parsed.existing.map((e) => (e.index, e.phrase)), [(0, 'Break the ice')]);
        expect(parsed.duplicates.single.index, 2);
        expect(parsed.errors.map((e) => (e.index, e.field, e.reason)), [(3, 'phrase', 'single_word'), (3, 'kind', 'invalid')]);
        expect(parsed.hasErrors, isTrue);
        expect((await api.getCards(subjectId: sid)).counts.total, before, reason: 'xem trước không lưu');
        expect((await api.parseCards(sid, '[{')).errors.single.reason, 'invalid_json');

        // 8. Nhập thẻ có thẻ lỗi → 400 invalid_cards, không lưu gì; nhập thẻ mới + thẻ đã có → tạo 1, bỏ qua 1.
        await expectLater(
          api.importCards(sid, [parsed.cards.single.toImportJson(), {'phrase': 'oops', 'meaning': 'm', 'example': 'e', 'kind': 'IDIOM'}]),
          _apiError(400, 'invalid_cards'),
        );
        expect((await api.getCards(subjectId: sid)).counts.total, before);
        final imported = await api.importCards(sid, [
          parsed.cards.single.toImportJson(),
          {'phrase': 'break the ice', 'meaning': 'KHÁC', 'example': 'e', 'kind': 'IDIOM'},
        ]);
        expect((imported.created, imported.skipped), (1, 1));
        expect((await api.getCards(subjectId: sid)).counts.total, before + 1);
        expect((await api.getCard(c2.id)).meaning, 'to relax people', reason: 'thẻ đã có không bị ghi đè');
        final again = await api.importCards(sid, [parsed.cards.single.toImportJson()]);
        expect((again.created, again.skipped), (0, 1), reason: 'nhập lại thẻ vừa nhập thì bỏ qua');

        // 9. Xoá thẻ: lần sau không còn; xoá lại → 404.
        await api.deleteCard(c3.id);
        await expectLater(api.getCard(c3.id), _apiError(404, 'card_not_found'));
        await expectLater(api.deleteCard(c3.id), _apiError(404, 'card_not_found'));
        expect((await api.getCards(subjectId: sid)).cards.any((c) => c.id == c3.id), isFalse);

        // 10. Môn không tồn tại → 404 subject_not_found.
        await expectLater(api.getCards(subjectId: '00000000-0000-4000-8000-000000000000'), _apiError(404, 'subject_not_found'));
      } finally {
        if (subjectId != null) await api.deleteSubject(subjectId); // cascade xoá thẻ, lượt ôn
      }
    },
    timeout: const Timeout(Duration(minutes: 5)),
    skip: missing ? 'thiếu --dart-define=NSD_API_BASE_URL / NSD_API_TOKEN' : false,
  );

  test(
    'Ôn thẻ: hàng ôn → đánh giá → 409 → chờ thẻ quay lại → buổi CARD_REVIEW cộng vào ngày (backend thật)',
    () async {
      final dio = Dio(BaseOptions(baseUrl: _baseUrl, headers: {'Authorization': 'Bearer $_token'}));
      final api = HocTapApi(dio);
      String? subjectId;
      // NOT_YET hẹn quay lại sau 5 phút TRONG hôm nay: quá 23:50 giờ VN thì hạn rơi sang ngày mai (server coi là xong hôm nay).
      final vn = vnNow();
      if (vn.hour == 23 && vn.minute >= 50) {
        markTestSkipped('gần nửa đêm giờ VN: chạy lại sau 00:00');
        return;
      }

      try {
        subjectId = (await api.createSubject({'name': 'TEST Ôn thẻ ${DateTime.now().millisecondsSinceEpoch}', 'dailyGoalMinutes': 60})).id;
        final sid = subjectId;
        Future<StudyCard> mk(String phrase, String example) => api.createCard({'subjectId': sid, 'phrase': phrase, 'meaning': 'meaning of $phrase', 'example': example, 'kind': 'PHRASAL_VERB'});
        final c1 = await mk('look forward to', 'I look forward to meeting you.');
        final c2 = await mk('break the ice', 'A joke can break the ice.');
        final c3 = await mk('pick up on', 'She picks up on small things.');

        // 1. Hàng ôn: lần gọi đầu tạo kế hoạch (3 thẻ mới, theo thứ tự tạo); gọi lại không đổi.
        final q1 = await api.getCardQueue(sid);
        expect(q1.date, vnToday());
        expect(q1.quota, 20);
        expect(q1.cards.map((c) => c.id), [c1.id, c2.id, c3.id]);
        expect(q1.cards.every((c) => c.bucket == CardBucket.newCard), isTrue);
        expect((q1.progress.planned, q1.progress.finished, q1.progress.remaining), (3, 0, 3));
        expect(q1.progress.byBucket[CardBucket.newCard]!.planned, 3);
        expect(q1.soonestDueAt, isNull);
        expect(q1.counts.total, 3);
        for (final c in q1.cards) {
          expect(c.next.keys.toSet(), CardRating.values.toSet());
          expect(c.next[CardRating.notYet]!.stage, CardStage.learning);
          expect(c.next[CardRating.remembered]!.stage, CardStage.weekly);
          // thẻ MỚI (không phải ôn thêm) thì "Đã nhớ" tiến lên, không phải "Giữ lịch"
          expect(ratingDueLabel(card: c.card, rating: CardRating.remembered, next: c.next[CardRating.remembered]!), isNot('Giữ lịch'));
        }
        expect((await api.getCardQueue(sid)).cards.map((c) => c.id), [c1.id, c2.id, c3.id]);

        // 2. Đánh giá "Đã nhớ" (201): thẻ lên Hàng tuần, tiến độ tăng; ôn lại ngay → 409 already_finished_today.
        final r1 = await api.reviewCard(c1.id, CardRating.remembered);
        expect(r1.card.card.stage, CardStage.weekly);
        expect(r1.card.card.reviewCount, 1);
        expect(r1.card.card.dueAt, isNotNull);
        expect((r1.progress.finished, r1.progress.remaining), (1, 2));
        expect(r1.soonestDueAt, isNull);
        await expectLater(api.reviewCard(c1.id, CardRating.remembered), _apiError(409, 'already_finished_today'));

        // 3. "Chưa nhớ": về Đang học, hẹn ~5 phút; chưa tới hạn thì 409 not_due_yet; ra khỏi hàng, vào soonestDueAt.
        final r2 = await api.reviewCard(c2.id, CardRating.notYet);
        expect(r2.card.card.stage, CardStage.learning);
        expect(r2.card.card.notYetCount, 1);
        expect(r2.soonestDueAt, isNotNull);
        final waitMin = r2.soonestDueAt!.difference(DateTime.now()).inSeconds / 60;
        expect(waitMin, inInclusiveRange(3.5, 5.5), reason: 'hẹn quay lại sau 5 phút');
        expect(r2.progress.finished, 1, reason: 'Chưa nhớ chưa tính là xong');
        await expectLater(api.reviewCard(c2.id, CardRating.remembered), _apiError(409, 'not_due_yet'));
        final q2 = await api.getCardQueue(sid);
        expect(q2.cards.map((c) => c.id), [c3.id]);
        expect(q2.soonestDueAt, r2.soonestDueAt);
        expect((q2.progress.finished, q2.progress.remaining), (1, 2));

        // 4. "Cần ôn lại": tính là xong hôm nay, hạn sang đầu ngày mai giờ VN; nhãn nút là "Ngày mai".
        final r3 = await api.reviewCard(c3.id, CardRating.reviewAgain);
        expect(r3.card.card.stage, CardStage.learning);
        expect(r3.progress.finished, 2);
        final tomorrowStart = DateTime.parse('${_dayBefore(vnToday(), -1)}T00:00:00+07:00');
        expect(r3.card.card.dueAt!.isAtSameMomentAs(tomorrowStart), isTrue);
        expect(r3.card.card.notYetCount, 0);

        // 5. Hết thẻ hiện ngay mà còn thẻ đợi → trạng thái "chờ" của màn ôn.
        final q3 = await api.getCardQueue(sid);
        expect(q3.cards, isEmpty);
        expect(q3.soonestDueAt, isNotNull);
        expect(reviewPhaseFor(queue: q3.cards, progress: q3.progress, soonestDueAt: q3.soonestDueAt), ReviewPhase.waiting);
        expect(q3.progress.remaining - q3.cards.length, 1, reason: 'số thẻ đang đợi quay lại');

        // 6. Thẻ tạm dừng: bị loại khỏi tiến độ và hàng ôn; ôn nó → 409 card_suspended. Thẻ ngoài kế hoạch → 409 not_in_today_plan.
        final c4 = await mk('get along with', 'I get along with my coworkers.');
        final q4 = await api.getCardQueue(sid); // bù thêm c4 vào kế hoạch
        expect(q4.cards.map((c) => c.id), [c4.id]);
        expect(q4.progress.planned, 4);
        await api.patchCard(c4.id, {'suspended': true});
        await expectLater(api.reviewCard(c4.id, CardRating.remembered), _apiError(409, 'card_suspended'));
        final q5 = await api.getCardQueue(sid);
        expect(q5.cards, isEmpty);
        expect(q5.progress.planned, 3, reason: 'thẻ tạm dừng không tính vào kế hoạch');
        final c5 = await mk('come across', 'I came across an old photo.');
        await expectLater(api.reviewCard(c5.id, CardRating.remembered), _apiError(409, 'not_in_today_plan'));
        await expectLater(api.reviewCard('00000000-0000-4000-8000-000000000000', CardRating.remembered), _apiError(404, 'card_not_found'));

        // 7. Kết thúc phiên: lưu số phút thành buổi CARD_REVIEW (không khóa, không phần), cộng vào ngày; app đọc được activity.
        final logged = await api.createLog({'subjectId': sid, 'activity': 'CARD_REVIEW', 'minutes': 15});
        expect(logged.log.activity, LogActivity.cardReview);
        expect(logged.log.courseId, isNull);
        expect(logged.log.courseTitle, isNull);
        expect(logged.log.sections, isEmpty);
        expect(logged.log.minutes, 15);
        expect((logged.today.minutes, logged.today.goalMinutes, logged.today.done), (15, 60, false));
        final lesson = await api.createLog({'subjectId': sid, 'minutes': 45});
        expect(lesson.log.activity, LogActivity.lesson, reason: 'không gửi activity (như app cũ) = học bài');
        expect((lesson.today.minutes, lesson.today.done), (60, true), reason: '45 học bài + 15 ôn thẻ = đủ mục tiêu 60');
        final today = vnToday();
        final logs = await api.getLogs(from: today, to: today, subjectId: sid);
        expect(logs.where((l) => l.activity == LogActivity.cardReview).fold<int>(0, (n, l) => n + l.minutes), 15);
        expect(logs.where((l) => l.activity == LogActivity.lesson).fold<int>(0, (n, l) => n + l.minutes), 45);
        final ov = (await api.getOverview()).subjects.firstWhere((x) => x.subjectId == sid);
        expect((ov.today.minutes, ov.today.done), (60, true));
        await expectLater(api.createLog({'subjectId': sid, 'activity': 'CARD_REVIEW', 'minutes': 0}), throwsA(isA<DioException>().having((e) => e.response?.statusCode, 'status', 400)));
        await expectLater(api.createLog({'subjectId': sid, 'activity': 'CARD_REVIEW', 'minutes': 1441}), throwsA(isA<DioException>().having((e) => e.response?.statusCode, 'status', 400)));
        await expectLater(api.getCardQueue('00000000-0000-4000-8000-000000000000'), _apiError(404, 'subject_not_found'));
      } finally {
        if (subjectId != null) await api.deleteSubject(subjectId); // cascade xoá thẻ, lượt ôn, kế hoạch, buổi học
      }
    },
    timeout: const Timeout(Duration(minutes: 5)),
    skip: missing ? 'thiếu --dart-define=NSD_API_BASE_URL / NSD_API_TOKEN' : false,
  );

  test(
    'Buổi ôn thẻ (CARD_REVIEW): tạo → đọc lại activity → sửa phút → xoá; không gắn khóa / phần; hiện "Ôn thẻ" (backend thật)',
    () async {
      final dio = Dio(BaseOptions(baseUrl: _baseUrl, headers: {'Authorization': 'Bearer $_token'}));
      final api = HocTapApi(dio);
      String? subjectId;

      try {
        subjectId = (await api.createSubject({'name': 'TEST Buổi ôn thẻ ${DateTime.now().millisecondsSinceEpoch}', 'dailyGoalMinutes': 60})).id;
        final sid = subjectId;
        final today = vnToday();

        // 1. Tạo: server trả activity CARD_REVIEW, không khóa, không phần; phút cộng vào ngày.
        final created = await api.createLog({'subjectId': sid, 'activity': 'CARD_REVIEW', 'minutes': 15, 'note': 'ôn 10 thẻ'});
        expect(created.log.activity, LogActivity.cardReview);
        expect(created.log.courseId, isNull);
        expect(created.log.sections, isEmpty);
        expect((created.log.minutes, created.log.note), (15, 'ôn 10 thẻ'));
        expect(created.today.minutes, 15);
        expect(created.course, isNull);
        expect(logTitle(activity: created.log.activity, courseTitle: created.log.courseTitle), 'Ôn thẻ');

        // 2. Đọc lại bằng GET /logs: vẫn là CARD_REVIEW; một buổi học bài (không gửi activity) đi cùng thì là LESSON.
        final lesson = await api.createLog({'subjectId': sid, 'minutes': 30});
        expect(lesson.log.activity, LogActivity.lesson);
        final logs = await api.getLogs(from: today, to: today, subjectId: sid);
        expect(logs.length, 2);
        expect(logs.firstWhere((l) => l.id == created.log.id).activity, LogActivity.cardReview);
        expect(logs.firstWhere((l) => l.id == lesson.log.id).activity, LogActivity.lesson);
        expect(logTitle(activity: logs.firstWhere((l) => l.id == lesson.log.id).activity, courseTitle: null), 'Ôn tập');

        // 3. Lịch của ngày hôm nay cũng mang activity (để dòng lịch hiện "Ôn thẻ").
        final schedule = await api.getSchedule(subjectId: sid, from: today, to: today);
        final todayLogs = schedule.days.single.logs;
        expect(todayLogs.firstWhere((l) => l.id == created.log.id).activity, LogActivity.cardReview);
        expect(todayLogs.firstWhere((l) => l.id == lesson.log.id).activity, LogActivity.lesson);

        // 4. Sửa phút và ghi chú (chỉ hai trường này); tổng ngày đổi theo; activity không đổi.
        final patched = await api.patchLog(created.log.id, {'minutes': 25, 'note': null});
        expect(patched.log.minutes, 25);
        expect(patched.log.note, isNull);
        expect(patched.log.activity, LogActivity.cardReview);
        expect((patched.today.minutes, patched.today.done), (55, false));

        // 5. Server từ chối gắn khóa / phần / đổi loại vào buổi ôn thẻ (app không bao giờ gửi, nhưng hợp đồng phải chặn).
        Matcher bad(String code) => throwsA(isA<DioException>().having((e) => e.response?.statusCode, 'status', 400).having((e) => (e.response?.data as Map)['error'], 'error', code));
        await expectLater(api.patchLog(created.log.id, {'minutes': 5, 'courseId': '00000000-0000-4000-8000-000000000000'}), bad('card_review_no_course'));
        await expectLater(api.patchLog(created.log.id, {'sections': <Object>[]}), bad('card_review_no_sections'));
        await expectLater(api.patchLog(created.log.id, {'activity': 'LESSON', 'minutes': 5}), bad('activity_locked'));
        await expectLater(api.createLog({'subjectId': sid, 'activity': 'CARD_REVIEW', 'minutes': 5, 'courseId': '00000000-0000-4000-8000-000000000000'}), bad('card_review_no_course'));
        await expectLater(api.patchLog(created.log.id, {'minutes': 0}), throwsA(isA<DioException>().having((e) => e.response?.statusCode, 'status', 400)));
        expect((await api.getLogs(from: today, to: today, subjectId: sid)).firstWhere((l) => l.id == created.log.id).minutes, 25, reason: 'các yêu cầu bị từ chối không đổi gì');

        // 6. Xoá buổi ôn thẻ (hôm nay): biến mất, tổng ngày trừ phút của nó.
        final after = await api.deleteLog(created.log.id);
        expect(after.minutes, 30);
        final left = await api.getLogs(from: today, to: today, subjectId: sid);
        expect(left.map((l) => l.id), [lesson.log.id]);
        await expectLater(api.deleteLog(created.log.id), throwsA(isA<DioException>().having((e) => e.response?.statusCode, 'status', 404)));
      } finally {
        if (subjectId != null) await api.deleteSubject(subjectId); // cascade xoá buổi học
      }
    },
    timeout: const Timeout(Duration(minutes: 5)),
    skip: missing ? 'thiếu --dart-define=NSD_API_BASE_URL / NSD_API_TOKEN' : false,
  );
}
