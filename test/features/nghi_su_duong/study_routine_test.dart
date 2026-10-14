import 'package:amber_flutter/features/nghi_su_duong/models/routine.dart';
import 'package:amber_flutter/features/nghi_su_duong/services/nghi_su_duong_api.dart';
import 'package:amber_flutter/features/nghi_su_duong/widgets/routine_form.dart';
import 'package:amber_flutter/features/nghi_su_duong/widgets/routines_card.dart';
import 'package:amber_flutter/shared/services/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'detail_test_support.dart';

// Routine kind STUDY (Trà Đình): thẻ tạm thời không tick, bấm vào → /tra-dinh; không còn rơi về CHECK.

Routine _study({int minutes = 30, int goal = 60}) {
  final base = mkRoutine('st', 'Học tiếng Anh', kind: RoutineKind.study, done: minutes >= goal ? const {6} : const {});
  return Routine(
    id: base.id,
    name: base.name,
    weekdays: base.weekdays,
    dueToday: true,
    doneToday: minutes >= goal,
    streak: 0,
    last7: base.last7,
    kind: RoutineKind.study,
    studySubjectId: 's1',
    studySubjectName: 'Tiếng Anh',
    todayMinutes: minutes,
    goalMinutes: goal,
  );
}

final _visited = <String>[];

Future<FakeApi> _pump(WidgetTester tester, List<Routine> routines, {Widget? body}) async {
  _visited.clear();
  final api = FakeApi(project: mkProject(), tasks: [])..routines = [...routines];
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
      overrides: [apiClientProvider.overrideWithValue(offlineDio()), nghiSuDuongApiProvider.overrideWithValue(api)],
      child: MaterialApp.router(theme: ThemeData.dark(), routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
  return api;
}

Future<void> _openForm(WidgetTester tester, Routine? routine) async {
  await _pump(tester, [], body: Builder(builder: (c) => TextButton(onPressed: () => showRoutineForm(c, routine: routine), child: const Text('mở form'))));
  await tester.tap(find.text('mở form'));
  await tester.pumpAndSettle();
}

void main() {
  test('RoutineKind.study: có trong enum, "lạ" vẫn rơi về CHECK', () {
    expect(RoutineKind.fromApi('STUDY'), RoutineKind.study);
    expect(RoutineKind.study.api, 'STUDY');
    expect(RoutineKind.fromApi('NOPE'), RoutineKind.check);
  });

  testWidgets('thẻ routine STUDY: không có nút tick, hiện "X / Y phút"', (tester) async {
    await _pump(tester, [_study(minutes: 30, goal: 60), mkRoutine('c', 'Uống nước')]);

    expect(find.byKey(const ValueKey('study-progress-st')), findsOneWidget);
    expect(find.text('30 / 60 phút'), findsOneWidget);
    // Chỉ routine CHECK có ô tick; routine STUDY không có Checkbox lẫn nút ghi buổi tập.
    expect(find.byType(Checkbox), findsOneWidget);
    expect(find.descendant(of: find.byKey(const ValueKey('routine-st')), matching: find.byType(Checkbox)), findsNothing);
    expect(find.byKey(const ValueKey('workout-open-st')), findsNothing);
    expect(find.byKey(const ValueKey('study-icon-st')), findsOneWidget);
  });

  testWidgets('routine STUDY đủ mục tiêu: icon đã xong, vẫn không tick', (tester) async {
    await _pump(tester, [_study(minutes: 70, goal: 60)]);
    expect(find.text('70 / 60 phút'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(find.byType(Checkbox), findsNothing);
  });

  testWidgets('bấm vào routine STUDY → /tra-dinh', (tester) async {
    final api = await _pump(tester, [_study()]);
    await tester.tap(find.byKey(const ValueKey('study-open-st')));
    await tester.pumpAndSettle();
    expect(_visited, ['/tra-dinh']);
    expect(find.text('trà đình'), findsOneWidget);
    expect(api.routineUpdates, isEmpty);
  });

  testWidgets('form việc hằng ngày không cho chọn loại Học tập khi tạo', (tester) async {
    await _openForm(tester, null);
    expect(find.text('Việc thường'), findsOneWidget);
    expect(find.text('Tập thể dục'), findsOneWidget);
    expect(find.text('Học tập'), findsNothing);
  });

  testWidgets('sửa routine STUDY: loại bị khoá, không có lựa chọn loại', (tester) async {
    await _openForm(tester, _study());
    expect(find.textContaining('Loại: Học tập'), findsOneWidget);
    expect(find.text('Việc thường'), findsNothing);
    expect(find.text('Tập thể dục'), findsNothing);
  });
}
