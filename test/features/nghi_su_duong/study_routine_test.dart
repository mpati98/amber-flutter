import 'package:amber_flutter/features/nghi_su_duong/models/routine.dart';
import 'package:amber_flutter/features/nghi_su_duong/services/nghi_su_duong_api.dart';
import 'package:amber_flutter/features/nghi_su_duong/widgets/routine_form.dart';
import 'package:amber_flutter/features/nghi_su_duong/widgets/routines_card.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_subject.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/services/hoc_tap_api.dart';
import 'package:amber_flutter/shared/services/api_client.dart';
import 'package:amber_flutter/shared/widgets/progress_ring.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../tra_dinh/hoc_tap/hoc_tap_test_support.dart';
import 'detail_test_support.dart';

// Routine kind STUDY (Trà Đình): thẻ đầy đủ (vòng tiến độ, chuỗi, cảnh báo thiếu lý do), form việc hằng ngày chọn môn.

Routine _study({int minutes = 30, int goal = 60, int streak = 0, List<String> pending = const [], String subjectId = 's1'}) {
  final base = mkRoutine('st', 'Học tiếng Anh', kind: RoutineKind.study, done: minutes >= goal ? const {6} : const {});
  return Routine(
    id: base.id,
    name: base.name,
    weekdays: base.weekdays,
    dueToday: true,
    doneToday: minutes >= goal,
    streak: streak,
    last7: base.last7,
    kind: RoutineKind.study,
    studySubjectId: subjectId,
    studySubjectName: 'Tiếng Anh',
    todayMinutes: minutes,
    goalMinutes: goal,
    pendingReasonDates: pending,
  );
}

final _visited = <String>[];

Future<({FakeApi api, FakeHocTapApi hoc})> _pump(WidgetTester tester, List<Routine> routines, {Widget? body, FakeHocTapApi? hoc}) async {
  _visited.clear();
  final api = FakeApi(project: mkProject(), tasks: [])..routines = [...routines];
  final hocApi = hoc ?? FakeHocTapApi();
  tester.view.physicalSize = const Size(390, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => Scaffold(body: SingleChildScrollView(child: body ?? const RoutinesCard()))),
      GoRoute(
        path: '/tra-dinh',
        builder: (_, state) {
          _visited.add(state.uri.toString());
          return const Scaffold(body: Text('trà đình'));
        },
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [apiClientProvider.overrideWithValue(offlineDio()), nghiSuDuongApiProvider.overrideWithValue(api), hocTapApiProvider.overrideWithValue(hocApi)],
      child: MaterialApp.router(theme: ThemeData.dark(), routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
  return (api: api, hoc: hocApi);
}

Future<({FakeApi api, FakeHocTapApi hoc})> _openForm(WidgetTester tester, Routine? routine, {List<Routine> existing = const [], FakeHocTapApi? hoc}) async {
  final r = await _pump(tester, existing, hoc: hoc, body: Builder(builder: (c) => TextButton(onPressed: () => showRoutineForm(c, routine: routine), child: const Text('mở form'))));
  await tester.tap(find.text('mở form'));
  await tester.pumpAndSettle();
  return r;
}

bool _saveEnabled(WidgetTester tester) => tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Lưu')).onPressed != null;

void main() {
  test('RoutineKind.study: có trong enum, "lạ" vẫn rơi về CHECK', () {
    expect(RoutineKind.fromApi('STUDY'), RoutineKind.study);
    expect(RoutineKind.study.api, 'STUDY');
    expect(RoutineKind.study.label, 'Học');
    expect(RoutineKind.fromApi('NOPE'), RoutineKind.check);
  });

  group('thẻ routine STUDY', () {
    testWidgets('không có nút tick; hiện vòng, "X / Y phút · chuỗi N ngày", tên môn, ghi chú tự tính', (tester) async {
      await _pump(tester, [_study(minutes: 30, goal: 60, streak: 4), mkRoutine('c', 'Uống nước')]);

      expect(find.text('30 / 60 phút · chuỗi 4 ngày'), findsOneWidget);
      expect(find.text('Tiếng Anh'), findsOneWidget);
      expect(find.text('Tự tính từ buổi học ở Trà Đình'), findsOneWidget);
      expect(find.byKey(const ValueKey('study-ring-st')), findsOneWidget);
      expect(tester.widget<ProgressRing>(find.byType(ProgressRing)).value, 30);
      expect(find.text('50%'), findsOneWidget);
      // Chỉ routine CHECK có ô tick.
      expect(find.byType(Checkbox), findsOneWidget);
      expect(find.descendant(of: find.byKey(const ValueKey('routine-st')), matching: find.byType(Checkbox)), findsNothing);
      expect(find.byKey(const ValueKey('workout-open-st')), findsNothing);
      // Chưa thiếu lý do → không có hàng cảnh báo.
      expect(find.byKey(const ValueKey('study-pending-st')), findsNothing);
    });

    testWidgets('vượt 100%: vòng đầy (kẹp ở 100%), chữ vẫn hiện "90 / 60 phút"', (tester) async {
      await _pump(tester, [_study(minutes: 90, goal: 60, streak: 2)]);
      expect(find.text('90 / 60 phút · chuỗi 2 ngày'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
      final ring = tester.widget<ProgressRing>(find.byType(ProgressRing));
      expect((ring.value, ring.max), (90.0, 60.0));
      expect(find.byType(Checkbox), findsNothing);
    });

    testWidgets('bấm thẻ → /tra-dinh?openLog=1&subjectId=<môn>', (tester) async {
      final r = await _pump(tester, [_study(subjectId: 'mon-123')]);
      await tester.tap(find.byKey(const ValueKey('study-open-st')));
      await tester.pumpAndSettle();
      expect(_visited, ['/tra-dinh?openLog=1&subjectId=mon-123']);
      expect(r.api.routineUpdates, isEmpty);
    });

    testWidgets('có pendingReasonDates → hàng cảnh báo (mới nhất trước); bấm mở sheet lý do, đi qua 2 ngày', (tester) async {
      final hoc = FakeHocTapApi();
      final subjectId = hoc.subjects.first.id;
      await _pump(tester, [_study(subjectId: subjectId, pending: ['2026-10-12', '2026-10-13'])], hoc: hoc);

      expect(find.text('Thiếu lý do: 13/10, 12/10'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('study-pending-st')));
      await tester.pumpAndSettle();
      expect(find.textContaining('12/10 · đã học 0/60 phút'), findsOneWidget, reason: 'ngày cũ trước');

      await tester.tap(find.byKey(const ValueKey('reason-BUSY')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('reason-save')));
      await tester.pumpAndSettle();
      expect(find.textContaining('13/10 · đã học 0/60 phút'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('reason-AWAY')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('reason-save')));
      await tester.pumpAndSettle();
      expect(hoc.reasonPuts.map((p) => (p.date, p.code.api)), [('2026-10-12', 'BUSY'), ('2026-10-13', 'AWAY')]);
      expect(find.byKey(const ValueKey('reason-save')), findsNothing, reason: 'xong hết thì đóng sheet');
    });
  });

  group('form việc hằng ngày', () {
    testWidgets('có loại "Học"; chọn Học → chỉ liệt kê môn có mục tiêu; lưu gửi môn + mặc định cả 7 ngày', (tester) async {
      final r = await _openForm(tester, null);
      expect(find.text('Việc thường'), findsOneWidget);
      expect(find.text('Tập thể dục'), findsOneWidget);
      expect(find.text('Học'), findsOneWidget);
      expect(find.byType(Checkbox), findsNothing);

      await tester.enterText(find.byType(TextField).first, 'Học tiếng Anh');
      await tester.tap(find.text('Học'));
      await tester.pumpAndSettle();
      final eligible = r.hoc.subjects.where((s) => s.dailyGoalMinutes != null).toList();
      final others = r.hoc.subjects.where((s) => s.dailyGoalMinutes == null);
      expect(eligible, isNotEmpty);
      for (final s in eligible) {
        expect(find.byKey(ValueKey('study-subject-${s.id}')), findsOneWidget);
      }
      for (final s in others) {
        expect(find.byKey(ValueKey('study-subject-${s.id}')), findsNothing, reason: 'môn không mục tiêu không chọn được');
      }
      expect(_saveEnabled(tester), isFalse, reason: 'chưa chọn môn');

      await tester.tap(find.byKey(ValueKey('study-subject-${eligible.first.id}')));
      await tester.pump();
      expect(_saveEnabled(tester), isTrue);
      await tester.tap(find.widgetWithText(FilledButton, 'Lưu'));
      await tester.pumpAndSettle();
      expect(r.api.routineCreates.single, {'name': 'Học tiếng Anh', 'weekdays': [1, 2, 3, 4, 5, 6, 7], 'kind': 'STUDY', 'studySubjectId': eligible.first.id});
    });

    testWidgets('môn đã có routine STUDY không còn trong danh sách; không môn nào phù hợp → hướng dẫn + nút "Mở Trà Đình"', (tester) async {
      final hoc = FakeHocTapApi();
      final taken = hoc.subjects.firstWhere((s) => s.dailyGoalMinutes != null);
      final r = await _openForm(tester, null, hoc: hoc, existing: [_study(subjectId: taken.id)]);
      await tester.tap(find.text('Học'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('no-eligible-subject')), findsOneWidget);
      expect(find.textContaining('Chưa có môn nào phù hợp'), findsOneWidget);
      expect(r.api.routineCreates, isEmpty);

      await tester.tap(find.byKey(const ValueKey('open-tra-dinh')));
      await tester.pumpAndSettle();
      expect(_visited, ['/tra-dinh']);
    });

    testWidgets('sửa routine STUDY: loại bị khoá, vẫn đổi môn được', (tester) async {
      final hoc = FakeHocTapApi();
      hoc.subjects = [
        ...hoc.subjects,
        const StudySubject(id: 'other', name: 'Lập trình có mục tiêu', dailyGoalMinutes: 30, videoMinutesPerDay: 40, reviewWeekdays: [7], position: 5),
      ];
      final current = _study(subjectId: hoc.subjects.first.id);
      final r = await _openForm(tester, current, hoc: hoc, existing: [current]);
      expect(find.textContaining('Loại: Học'), findsOneWidget);
      expect(find.text('Việc thường'), findsNothing);
      expect(find.text('Tập thể dục'), findsNothing);
      expect(_saveEnabled(tester), isFalse, reason: 'chưa đổi gì');

      await tester.tap(find.byKey(const ValueKey('study-subject-other')));
      await tester.pump();
      expect(_saveEnabled(tester), isTrue);
      await tester.tap(find.widgetWithText(FilledButton, 'Lưu'));
      await tester.pumpAndSettle();
      expect(r.api.routineUpdates.single['studySubjectId'], 'other');
      expect(r.api.routineUpdates.single.containsKey('kind'), isFalse);
    });

    testWidgets('lỗi study_routine_exists từ server → câu tiếng Việt', (tester) async {
      final r = await _openForm(tester, null);
      r.api.routineError = apiError(409, {'error': 'study_routine_exists'});
      await tester.enterText(find.byType(TextField).first, 'Việc học');
      await tester.tap(find.widgetWithText(ChoiceChip, 'Học'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(ValueKey('study-subject-${r.hoc.subjects.first.id}')));
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Lưu'));
      await tester.pumpAndSettle();
      expect(find.text('Môn này đã có việc hằng ngày học tập.'), findsOneWidget);
    });
  });
}
