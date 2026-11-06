import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/course.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/parsed_sections.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_card.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_card_queue.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_enums.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_log.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_overview.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_schedule.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_stats.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_subject.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/services/hoc_tap_api.dart';
import 'package:dio/dio.dart';

/// JSON thật lấy từ backend dev (test/fixtures/hoc_tap).
Object fixture(String name) => jsonDecode(File('test/fixtures/hoc_tap/$name.json').readAsStringSync()) as Object;

Map<String, dynamic> fixtureMap(String name) => fixture(name) as Map<String, dynamic>;
List<dynamic> fixtureList(String name) => fixture(name) as List<dynamic>;

DioException apiError(int status, Object data) {
  final req = RequestOptions(path: '/api/tra-dinh/hoc-tap/x');
  return DioException(requestOptions: req, type: DioExceptionType.badResponse, response: Response(requestOptions: req, statusCode: status, data: data));
}

/// API giả: dữ liệu lấy từ fixture, ghi lại các lệnh ghi, có thể chặn / báo lỗi.
class FakeHocTapApi extends HocTapApi {
  FakeHocTapApi({StudyOverview? overview, List<StudySubject>? subjects, List<CourseView>? courses, CourseDetail? detail})
    : overview = overview ?? StudyOverview.fromJson(fixtureMap('overview')),
      subjects = subjects ?? [for (final s in fixtureList('subjects')) StudySubject.fromJson(s as Map<String, dynamic>)],
      courses = courses ?? [for (final c in fixtureList('courses_list')) CourseView.fromJson(c as Map<String, dynamic>)],
      detail = detail ?? CourseDetail.fromJson(fixtureMap('course_detail')),
      super(Dio());

  StudyOverview overview;
  List<StudySubject> subjects;
  List<CourseView> courses;
  CourseDetail detail;

  final created = <Map<String, Object?>>[];
  final patches = <Map<String, Object?>>[];
  final moves = <({String id, bool up})>[];
  final sectionToggles = <({String sectionId, bool done})>[];
  final parsedTexts = <String>[];
  final puts = <List<SectionInput>>[];
  final subjectBodies = <Map<String, Object?>>[];
  final subjectPatches = <Map<String, Object?>>[];
  final subjectDeletes = <String>[];
  Object? subjectDeleteError;
  /// Các buổi học trả về cho getLogs (lọc theo môn + khoảng ngày như server).
  List<StudyLog> logs = [];
  final logCreates = <Map<String, Object?>>[];
  final logPatches = <Map<String, Object?>>[];
  final logDeletes = <String>[];
  final reasonPuts = <({String subjectId, String date, ReasonCode code, String? text})>[];
  Object? reasonError;
  Object? logError;
  late StudyLogResult logResult = StudyLogResult.fromJson(fixtureMap('log_created'));
  /// Lịch trả về cho getSchedule: khớp theo (from, to) nếu có trong [schedules], không thì [defaultSchedule] (hoặc tự dựng).
  final schedules = <String, StudySchedule>{};
  StudySchedule? defaultSchedule;
  final scheduleCalls = <({String subjectId, String from, String to})>[];
  Object? scheduleError;
  Completer<void>? scheduleGate;
  /// Thống kê trả về: khớp theo "range|all" (mọi môn) hoặc "range|one" (một môn); mặc định lấy fixture.
  final statsResponses = <String, StudyStats>{};
  final statsCalls = <({String? subjectId, String range})>[];
  Object? statsError;
  Object? coursesError;
  Object? detailError;
  int overviewCalls = 0;
  int rebaselines = 0;
  Object? toggleError;
  Completer<void>? toggleGate;
  Object? createError;
  Object? overviewError;

  @override
  Future<List<StudyLog>> getLogs({required String from, required String to, String? subjectId}) async => [
    for (final l in logs)
      if ((subjectId == null || l.subjectId == subjectId) && l.logDate.compareTo(from) >= 0 && l.logDate.compareTo(to) <= 0) l,
  ];

  @override
  Future<StudyLogResult> createLog(Map<String, Object?> body) async {
    logCreates.add(body);
    if (logError case final e?) throw e;
    return logResult;
  }

  @override
  Future<StudyLogResult> patchLog(String id, Map<String, Object?> patch) async {
    logPatches.add({'id': id, ...patch});
    if (logError case final e?) throw e;
    return logResult;
  }

  @override
  Future<TodaySummary> deleteLog(String id) async {
    logDeletes.add(id);
    if (logError case final e?) throw e;
    return logResult.today;
  }

  @override
  Future<DayReasonEntry> putReason(String subjectId, String date, {required ReasonCode code, String? text}) async {
    reasonPuts.add((subjectId: subjectId, date: date, code: code, text: text));
    if (reasonError case final e?) throw e;
    return DayReasonEntry(date: date, code: code, text: text);
  }

  @override
  Future<StudySchedule> getSchedule({required String subjectId, required String from, required String to}) async {
    scheduleCalls.add((subjectId: subjectId, from: from, to: to));
    await scheduleGate?.future;
    if (scheduleError case final e?) throw e;
    return schedules['$from|$to'] ?? defaultSchedule ?? const StudySchedule(days: [], summary: ScheduleSummary(minutes: 0, plannedMinutes: 0));
  }

  @override
  Future<StudyOverview> getOverview() async {
    overviewCalls++;
    if (overviewError case final e?) throw e;
    return overview;
  }

  @override
  Future<StudyStats> getStats({String? subjectId, String range = '30'}) async {
    statsCalls.add((subjectId: subjectId, range: range));
    if (statsError case final e?) throw e;
    final key = '$range|${subjectId == null ? 'all' : 'one'}';
    if (statsResponses[key] case final r?) return r;
    final file = subjectId == null ? 'stats_all_subjects' : {'7': 'stats_7', '30': 'stats_30', 'all': 'stats_all'}[range]!;
    return StudyStats.fromJson(fixtureMap(file));
  }

  @override
  Future<List<StudySubject>> getSubjects() async => subjects;

  @override
  Future<StudySubject> createSubject(Map<String, Object?> body) async {
    subjectBodies.add(body);
    return subjects.first;
  }

  @override
  Future<StudySubject> updateSubject(String id, Map<String, Object?> patch) async {
    subjectPatches.add({'id': id, ...patch});
    return subjects.first;
  }

  @override
  Future<void> deleteSubject(String id) async {
    subjectDeletes.add(id);
    if (subjectDeleteError case final e?) throw e;
  }

  @override
  Future<List<CourseView>> getCourses({String? subjectId, Iterable<CourseStatus> statuses = const []}) async {
    if (coursesError case final e?) throw e;
    return [
    for (final c in courses)
      if ((subjectId == null || c.subjectId == subjectId) && (statuses.isEmpty || statuses.contains(c.status))) c,
    ];
  }

  @override
  Future<CourseDetail> getCourseDetail(String id) async {
    if (detailError case final e?) throw e;
    return detail;
  }

  @override
  Future<CourseDetail> setSectionDone(String courseId, String sectionId, bool done) async {
    sectionToggles.add((sectionId: sectionId, done: done));
    await toggleGate?.future;
    if (toggleError case final e?) throw e;
    detail = detail.withSectionDone(sectionId, done);
    return detail.copyWith(recentLogs: const []);
  }

  @override
  Future<ParsedSections> parseSections(String text) async {
    parsedTexts.add(text);
    final sections = <ParsedSection>[];
    final skipped = <SkippedLine>[];
    final lines = text.split('\n');
    for (final (i, line) in lines.indexed) {
      if (line.trim().isEmpty) continue;
      final m = RegExp(r'^(.*?)\s*(\d+)min$').firstMatch(line.trim());
      if (m == null || m.group(1)!.isEmpty) {
        skipped.add(SkippedLine(line: i + 1, text: line.trim()));
      } else {
        sections.add(ParsedSection(title: m.group(1)!, durationMinutes: int.parse(m.group(2)!)));
      }
    }
    return ParsedSections(sections: sections, skipped: skipped, totalMinutes: sections.fold(0, (n, s) => n + s.durationMinutes));
  }

  @override
  Future<CourseDetail> createCourse(Map<String, Object?> body) async {
    created.add(body);
    if (createError case final e?) throw e;
    return detail;
  }

  @override
  Future<CourseView> patchCourse(String id, Map<String, Object?> patch) async {
    patches.add({'id': id, ...patch});
    final old = courses.firstWhere((c) => c.id == id);
    if (patch['status'] case final String s) {
      courses = [
        for (final c in courses)
          if (c.id == id)
            CourseView(id: c.id, subjectId: c.subjectId, title: c.title, status: CourseStatus.fromApi(s), progress: c.progress)
          else
            c,
      ];
    }
    return old;
  }

  @override
  Future<List<CourseView>> moveCourse(String id, {required bool up}) async {
    moves.add((id: id, up: up));
    final queued = courses.where((c) => c.status == CourseStatus.queued).toList();
    final i = queued.indexWhere((c) => c.id == id);
    final j = up ? i - 1 : i + 1;
    if (i >= 0 && j >= 0 && j < queued.length) {
      final a = queued[i], b = queued[j];
      courses = [for (final c in courses) c.id == a.id ? b : (c.id == b.id ? a : c)];
    }
    return courses;
  }

  @override
  Future<void> deleteCourse(String id) async {}

  @override
  Future<CourseDetail> putSections(String courseId, List<SectionInput> sections) async {
    puts.add(sections);
    return detail;
  }

  @override
  Future<List<CourseView>> rebaseline(String subjectId) async {
    rebaselines++;
    return courses;
  }

  // ---- Kho thẻ từ vựng ----

  /// Thẻ của server giả (mặc định: fixture thật `cards_list`). Thêm / sửa / xoá tác động lên danh sách này.
  List<StudyCard> cards = [for (final c in fixtureMap('cards_list')['cards'] as List) StudyCard.fromJson(c as Map<String, dynamic>)];
  List<TopicCount> topics = [for (final t in fixtureMap('cards_topics')['topics'] as List) TopicCount.fromJson(t as Map<String, dynamic>)];
  final cardQueries = <({String subjectId, CardStage? stage, CardKind? kind, String? topic, String? q, String? cursor})>[];
  final cardCreates = <Map<String, Object?>>[];
  final cardPatches = <Map<String, Object?>>[];
  final cardDeletes = <String>[];
  final cardParseTexts = <String>[];
  final cardImports = <List<Map<String, Object?>>>[];
  Object? cardsError;
  Object? cardsMoreError;
  Object? cardCreateError;
  Object? cardPatchError;
  Object? cardDeleteError;
  Object? cardParseError;
  Object? cardImportError;
  Object? topicsError;
  Completer<void>? cardsGate;

  /// Số thẻ tối đa mỗi trang (nhỏ hơn `limit` của app) để thử cuộn vô hạn với ít thẻ.
  int? cardPageSize;

  /// Kết quả xem trước trả về (mặc định: fixture thật `cards_parse`) và kết quả nhập.
  ParsedCards parsedResult = ParsedCards.fromJson(fixtureMap('cards_parse'));
  ImportResult importResult = const ImportResult(created: 2, skipped: 0);

  @override
  Future<CardListPage> getCards({required String subjectId, CardStage? stage, CardKind? kind, String? topic, String? q, int limit = 50, String? cursor}) async {
    cardQueries.add((subjectId: subjectId, stage: stage, kind: kind, topic: topic, q: q, cursor: cursor));
    await cardsGate?.future;
    if (cardsError case final e?) throw e;
    if (cursor != null && cardsMoreError != null) throw cardsMoreError!;
    final mine = cards; // mọi thẻ coi như của môn được hỏi; môn được ghi lại trong cardQueries
    final needle = q?.trim().toLowerCase();
    final filtered = [
      for (final c in mine)
        if ((stage == null || c.stage == stage) &&
            (kind == null || c.kind == kind) &&
            (topic == null || c.topics.contains(topic)) &&
            (needle == null || needle.isEmpty || c.phrase.toLowerCase().contains(needle) || c.meaning.toLowerCase().contains(needle)))
          c,
    ];
    final start = cursor == null ? 0 : int.parse(cursor);
    final size = cardPageSize == null ? limit : (cardPageSize! < limit ? cardPageSize! : limit);
    final end = start + size < filtered.length ? start + size : filtered.length;
    int n(CardStage s) => mine.where((c) => c.stage == s).length;
    return CardListPage(
      cards: filtered.sublist(start, end),
      counts: CardCounts(
        newCards: n(CardStage.newCard),
        learning: n(CardStage.learning),
        weekly: n(CardStage.weekly),
        monthly: n(CardStage.monthly),
        quarterly: n(CardStage.quarterly),
        total: mine.length,
        suspended: mine.where((c) => c.suspended).length,
      ),
      nextCursor: end < filtered.length ? '$end' : null,
    );
  }

  @override
  Future<StudyCard> createCard(Map<String, Object?> body) async {
    cardCreates.add(body);
    if (cardCreateError case final e?) throw e;
    final c = StudyCard(
      id: 'new-${cards.length}',
      subjectId: body['subjectId'] as String,
      phrase: body['phrase'] as String,
      meaning: body['meaning'] as String,
      example: body['example'] as String,
      note: body['note'] as String?,
      kind: CardKind.fromApi(body['kind']),
      topics: [for (final t in (body['topics'] as List? ?? const [])) t as String],
    );
    cards = [c, ...cards];
    return c;
  }

  @override
  Future<StudyCard> patchCard(String id, Map<String, Object?> patch) async {
    cardPatches.add({'id': id, ...patch});
    if (cardPatchError case final e?) throw e;
    final old = cards.firstWhere((c) => c.id == id);
    final next = StudyCard(
      id: old.id,
      subjectId: old.subjectId,
      phrase: patch['phrase'] as String? ?? old.phrase,
      meaning: patch['meaning'] as String? ?? old.meaning,
      example: patch['example'] as String? ?? old.example,
      note: patch.containsKey('note') ? patch['note'] as String? : old.note,
      kind: patch['kind'] == null ? old.kind : CardKind.fromApi(patch['kind']),
      topics: patch['topics'] == null ? old.topics : [for (final t in patch['topics'] as List) t as String],
      stage: old.stage,
      dueAt: old.dueAt,
      reviewCount: old.reviewCount,
      notYetCount: old.notYetCount,
      suspended: patch['suspended'] as bool? ?? old.suspended,
    );
    cards = [for (final c in cards) c.id == id ? next : c];
    return next;
  }

  @override
  Future<void> deleteCard(String id) async {
    cardDeletes.add(id);
    if (cardDeleteError case final e?) throw e;
    cards = [for (final c in cards) if (c.id != id) c];
  }

  @override
  Future<ParsedCards> parseCards(String subjectId, String text) async {
    cardParseTexts.add(text);
    if (cardParseError case final e?) throw e;
    return parsedResult;
  }

  @override
  Future<ImportResult> importCards(String subjectId, List<Map<String, Object?>> cards, {String? logId}) async {
    cardImports.add(cards);
    if (cardImportError case final e?) throw e;
    return importResult;
  }

  @override
  Future<List<TopicCount>> getCardTopics(String subjectId) async {
    if (topicsError case final e?) throw e;
    return topics;
  }

  // ---- Hàng ôn thẻ ----

  /// Hàng ôn của server giả (mặc định: fixture thật `card_queue`, 3 thẻ mới). [reviewCard] mô phỏng server: bỏ thẻ khỏi hàng,
  /// tăng finished (trừ NOT_YET: thẻ ra khỏi hàng và hẹn quay lại sau 5 phút).
  CardQueue cardQueue = CardQueue.fromJson(fixtureMap('card_queue'));
  final queueCalls = <String>[];
  final reviewCalls = <({String id, CardRating rating})>[];
  Object? queueError;
  Object? reviewError;
  Completer<void>? queueGate;
  Completer<void>? reviewGate;

  /// Thay cách trả lời của [reviewCard] (vd dựng 409 theo từng lần gọi).
  Future<ReviewResult> Function(String id, CardRating rating)? reviewHandler;

  @override
  Future<CardQueue> getCardQueue(String subjectId) async {
    queueCalls.add(subjectId);
    await queueGate?.future;
    if (queueError case final e?) throw e;
    return cardQueue;
  }

  @override
  Future<ReviewResult> reviewCard(String id, CardRating rating) async {
    reviewCalls.add((id: id, rating: rating));
    await reviewGate?.future;
    if (reviewError case final e?) throw e;
    if (reviewHandler case final h?) return h(id, rating);
    final c = cardQueue.cards.firstWhere((c) => c.id == id);
    final notYet = rating == CardRating.notYet;
    final p = cardQueue.progress;
    final finished = p.finished + (notYet ? 0 : 1);
    final by = {
      for (final e in p.byBucket.entries)
        e.key: BucketProgress(planned: e.value.planned, finished: e.value.finished + (e.key == c.bucket && !notYet ? 1 : 0)),
    };
    final progress = CardProgress(planned: p.planned, finished: finished, remaining: p.planned - finished, byBucket: by);
    final soonest = notYet ? DateTime.now().add(const Duration(minutes: 5)) : cardQueue.soonestDueAt;
    cardQueue = CardQueue(date: cardQueue.date, quota: cardQueue.quota, cards: [for (final x in cardQueue.cards) if (x.id != id) x], progress: progress, counts: cardQueue.counts, soonestDueAt: soonest);
    return ReviewResult(card: c, progress: progress, soonestDueAt: soonest);
  }
}
