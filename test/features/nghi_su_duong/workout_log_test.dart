import 'dart:async';

import 'package:amber_flutter/features/nghi_su_duong/models/routine.dart';
import 'package:amber_flutter/features/nghi_su_duong/services/nghi_su_duong_api.dart';
import 'package:amber_flutter/features/nghi_su_duong/utils/workout_form.dart';
import 'package:amber_flutter/features/nghi_su_duong/widgets/routines_card.dart';
import 'package:amber_flutter/shared/services/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'detail_test_support.dart';

// Ghi buổi tập trong "Việc hằng ngày": model, validate form, sheet, thẻ, form loại việc. API giả.

DioException _error(int status, Object data) {
  final req = RequestOptions(path: '/api/du-an/routines/x/logs/2026-10-08');
  return DioException(requestOptions: req, type: DioExceptionType.badResponse, response: Response(requestOptions: req, statusCode: status, data: data));
}

const _squat = Exercise(name: 'Squat', measure: ExerciseMeasure.setsReps, sets: 3, reps: 15);
const _pushup = Exercise(name: 'Chống đẩy', measure: ExerciseMeasure.reps, reps: 20);
const _plank = Exercise(name: 'Plank', measure: ExerciseMeasure.duration, durationSeconds: 60);

Future<FakeApi> _pump(WidgetTester tester, List<Routine> routines, {double width = 390}) async {
  final api = FakeApi(project: mkProject(), tasks: [])..routines = [...routines];
  tester.view.physicalSize = Size(width, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [apiClientProvider.overrideWithValue(offlineDio()), nghiSuDuongApiProvider.overrideWithValue(api)],
      child: MaterialApp(theme: ThemeData.dark(), home: const Scaffold(body: SingleChildScrollView(child: RoutinesCard()))),
    ),
  );
  await tester.pumpAndSettle();
  return api;
}

Finder _open(String id) => find.byKey(ValueKey('workout-open-$id'));
Finder _field(String key) => find.byKey(ValueKey(key));
Finder _saveButton() => find.byType(FilledButton).last;
Finder _sheetText(String text) => find.descendant(of: find.byType(Dialog).last, matching: find.text(text));

Routine _workout({TodayLog? log, List<Exercise>? last, bool due = true}) => mkRoutine(
      'w',
      'Tập thể dục',
      kind: RoutineKind.workout,
      dueToday: due,
      done: log == null ? const {} : const {6},
      todayLog: log,
      lastWorkout: last,
    );

void main() {
  group('model', () {
    test('Routine.fromJson: kind, todayLog, lastWorkout (WORKOUT)', () {
      final r = Routine.fromJson({
        'id': 'w', 'name': 'Tập', 'kind': 'WORKOUT', 'weekdays': [1, 2], 'dueToday': true, 'doneToday': true, 'streak': 1,
        'last7': [for (var i = 0; i < 7; i++) {'date': '2026-10-0${i + 2}', 'due': true, 'done': i == 6}],
        'todayLog': {
          'durationMinutes': 30,
          'exercises': [
            {'position': 0, 'name': 'Chống đẩy', 'measure': 'REPS', 'sets': null, 'reps': 20, 'durationSeconds': null},
            {'position': 1, 'name': 'Squat', 'measure': 'SETS_REPS', 'sets': 3, 'reps': 15, 'durationSeconds': null},
            {'position': 2, 'name': 'Plank', 'measure': 'DURATION', 'sets': null, 'reps': null, 'durationSeconds': 60},
          ],
        },
        'lastWorkout': [
          {'position': 0, 'name': 'Squat', 'measure': 'SETS_REPS', 'sets': 2, 'reps': 10, 'durationSeconds': null},
        ],
      });
      expect(r.kind, RoutineKind.workout);
      expect(r.isWorkout, isTrue);
      expect(r.todayLog!.durationMinutes, 30);
      expect(r.todayLog!.exercises.map((e) => e.measure), [ExerciseMeasure.reps, ExerciseMeasure.setsReps, ExerciseMeasure.duration]);
      expect(r.todayLog!.exercises.map((e) => e.amountLabel), ['20 lần', '3 × 15', '1 phút']);
      expect(r.lastWorkout!.single.sets, 2);
    });

    test('Routine.fromJson: CHECK và backend cũ (không có kind/todayLog/lastWorkout)', () {
      final base = {
        'id': 'c', 'name': 'N', 'weekdays': [1], 'dueToday': true, 'doneToday': false, 'streak': 0,
        'last7': [for (var i = 0; i < 7; i++) {'date': '2026-10-0${i + 2}', 'due': true, 'done': false}],
      };
      final old = Routine.fromJson(base);
      expect((old.kind, old.todayLog, old.lastWorkout), (RoutineKind.check, null, null));
      final check = Routine.fromJson({...base, 'kind': 'CHECK', 'todayLog': {'durationMinutes': null, 'exercises': []}});
      expect(check.kind, RoutineKind.check);
      expect(check.todayLog!.durationMinutes, isNull);
      expect(check.todayLog!.exercises, isEmpty);
      expect(Routine.fromJson({...base, 'kind': 'WORKOUT', 'lastWorkout': null}).lastWorkout, isNull);
    });

    test('Exercise.toJson chỉ gửi trường thuộc kiểu đo', () {
      expect(_pushup.toJson(), {'name': 'Chống đẩy', 'measure': 'REPS', 'reps': 20});
      expect(_squat.toJson(), {'name': 'Squat', 'measure': 'SETS_REPS', 'sets': 3, 'reps': 15});
      expect(_plank.toJson(), {'name': 'Plank', 'measure': 'DURATION', 'durationSeconds': 60});
    });

    test('amountLabel thời lượng: chẵn phút thì ghi phút', () {
      expect(const Exercise(name: 'a', measure: ExerciseMeasure.duration, durationSeconds: 120).amountLabel, '2 phút');
      expect(const Exercise(name: 'a', measure: ExerciseMeasure.duration, durationSeconds: 90).amountLabel, '90 giây');
    });

    test('workoutSummary: "30 phút · 4 bài", bỏ vế thiếu', () {
      expect(workoutSummary(TodayLog(durationMinutes: 30, exercises: const [_pushup, _squat, _plank, _pushup])), '30 phút · 4 bài');
      expect(workoutSummary(const TodayLog(durationMinutes: 45)), '45 phút');
      expect(workoutSummary(null), 'Đã tập');
    });

    test('withDoneToday(false) xoá todayLog; giữ kind và lastWorkout', () {
      final r = _workout(log: const TodayLog(durationMinutes: 30, exercises: [_squat]), last: const [_plank]).withDoneToday(false);
      expect((r.todayLog, r.kind, r.lastWorkout!.length), (null, RoutineKind.workout, 1));
    });
  });

  group('validateWorkoutForm', () {
    WorkoutFormResult v(String minutes, List<ExerciseDraft> rows) => validateWorkoutForm(minutesText: minutes, rows: rows);
    const ok = ExerciseDraft(name: 'Chống đẩy', reps: '20');

    test('số phút bắt buộc, 1–1440', () {
      for (final bad in ['', '0', '1441', 'abc', '-5', '1.5']) {
        expect(v(bad, const []).minutesError, isNotNull, reason: bad);
      }
      for (final good in ['1', '30', '1440', ' 45 ']) {
        expect(v(good, const []).minutesError, isNull, reason: good);
      }
    });

    test('hợp lệ: ba kiểu đo, chuẩn hoá số + tên, chỉ mang trường cần', () {
      final r = v('30', const [
        ExerciseDraft(name: ' Chống đẩy ', reps: '20', sets: '9', seconds: '9'), // trường thừa của kiểu khác bị bỏ
        ExerciseDraft(name: 'Squat', measure: ExerciseMeasure.setsReps, sets: '3', reps: '15'),
        ExerciseDraft(name: 'Plank', measure: ExerciseMeasure.duration, seconds: '60'),
      ]);
      expect(r.isValid, isTrue);
      expect(r.minutes, 30);
      expect(r.exercises.map((e) => e.toJson()), [
        {'name': 'Chống đẩy', 'measure': 'REPS', 'reps': 20},
        {'name': 'Squat', 'measure': 'SETS_REPS', 'sets': 3, 'reps': 15},
        {'name': 'Plank', 'measure': 'DURATION', 'durationSeconds': 60},
      ]);
    });

    test('mỗi kiểu thiếu số của nó thì lỗi theo chỉ số dòng', () {
      final r = v('10', const [
        ExerciseDraft(name: 'a'), // REPS thiếu lần
        ExerciseDraft(name: 'b', measure: ExerciseMeasure.setsReps, reps: '5'), // thiếu hiệp
        ExerciseDraft(name: 'c', measure: ExerciseMeasure.setsReps, sets: '3'), // thiếu lần
        ExerciseDraft(name: 'd', measure: ExerciseMeasure.duration), // thiếu giây
        ExerciseDraft(name: 'e', measure: ExerciseMeasure.duration, seconds: '0'),
        ExerciseDraft(reps: '5'), // thiếu tên
        ok,
      ]);
      expect(r.isValid, isFalse);
      expect(r.rowErrors.keys, [0, 1, 2, 3, 4, 5]);
      expect(r.exercises.length, 1, reason: 'chỉ dòng hợp lệ vào payload');
    });

    test('dòng trống hoàn toàn bị bỏ qua; danh sách rỗng hợp lệ; tên quá dài và quá 50 bài bị chặn', () {
      expect(v('10', const [ExerciseDraft(), ok, ExerciseDraft()]).exercises.length, 1);
      expect(v('10', const [ExerciseDraft()]).isValid, isTrue);
      expect(v('10', [ExerciseDraft(name: 'x' * 101, reps: '1')]).rowErrors, isNotEmpty);
      expect(v('10', [for (var i = 0; i < 51; i++) ok]).listError, isNotNull);
      expect(v('10', [for (var i = 0; i < 50; i++) ok]).isValid, isTrue);
    });

    test('chặn số quá lớn theo giới hạn backend', () {
      expect(v('10', const [ExerciseDraft(name: 'a', reps: '10001')]).isValid, isFalse);
      expect(v('10', const [ExerciseDraft(name: 'a', measure: ExerciseMeasure.setsReps, sets: '1001', reps: '1')]).isValid, isFalse);
      expect(v('10', const [ExerciseDraft(name: 'a', measure: ExerciseMeasure.duration, seconds: '86401')]).isValid, isFalse);
    });
  });

  group('routineErrorMessage', () {
    test('mã lỗi backend → câu tiếng Việt', () {
      expect(routineErrorMessage(_error(400, {'error': 'not_today'}), 'x'), 'Chỉ ghi được buổi tập của hôm nay.');
      expect(routineErrorMessage(_error(400, {'error': 'not_scheduled'}), 'x'), 'Hôm nay không phải ngày của việc này.');
      expect(routineErrorMessage(_error(400, {'error': 'future_date'}), 'x'), 'Không ghi được cho ngày chưa tới.');
      expect(routineErrorMessage(_error(409, {'error': 'kind_locked'}), 'x'), 'Việc này đã có lịch sử nên không đổi loại được.');
      expect(routineErrorMessage(_error(404, {'error': 'routine_not_found'}), 'x'), 'Không tìm thấy việc này, có thể đã bị xoá.');
    });

    test('validate zod (error là object) → câu riêng; lỗi mạng → fallback', () {
      final zod = _error(400, {'error': {'formErrors': [], 'fieldErrors': {'durationMinutes': ['Required']}}});
      expect(routineErrorMessage(zod, 'x'), 'Dữ liệu buổi tập chưa hợp lệ, kiểm tra lại số phút và các bài.');
      expect(routineErrorMessage(DioException(requestOptions: RequestOptions(path: '/x'), error: 'down'), 'fallback'), 'fallback');
    });
  });

  group('thẻ Việc hằng ngày — WORKOUT', () {
    testWidgets('chưa tập: biểu tượng tạ, không có ô tick; đã tập: hiện "30 phút · 4 bài"; CHECK giữ ô tick', (tester) async {
      await _pump(tester, [
        _workout(),
        mkRoutine('w2', 'Chạy bộ', kind: RoutineKind.workout, done: const {6}, todayLog: const TodayLog(durationMinutes: 30, exercises: [_pushup, _squat, _plank, _pushup])),
        mkRoutine('c', 'Uống nước'),
      ]);
      expect(find.byIcon(Icons.fitness_center_outlined), findsOneWidget);
      expect(find.byKey(const ValueKey('workout-summary-w')), findsNothing);
      expect(find.text('30 phút · 4 bài'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.descendant(of: find.byKey(const ValueKey('routine-w')), matching: find.byType(Checkbox)), findsNothing);
      expect(find.descendant(of: find.byKey(const ValueKey('routine-c')), matching: find.byType(Checkbox)), findsOneWidget);
      expect(tester.widget<Text>(find.text('Chạy bộ')).style?.decoration, isNull, reason: 'WORKOUT không gạch ngang');
      expect(find.text('1 / 3 hôm nay'), findsOneWidget);
    });

    testWidgets('không đến hạn hôm nay: không mở được sheet', (tester) async {
      await _pump(tester, [_workout(due: false)]);
      expect(tester.widget<IconButton>(_open('w')).onPressed, isNull);
    });

    testWidgets('mở sheet: chưa có log → điền bài từ lastWorkout, để trống số phút, không có nút Xoá', (tester) async {
      await _pump(tester, [_workout(last: const [_squat, _plank])]);
      await tester.tap(_open('w'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'Ghi buổi tập hôm nay'), findsOneWidget);
      expect(tester.widget<TextField>(_field('workout-minutes')).controller!.text, '');
      expect(tester.widget<TextField>(_field('exercise-name-0')).controller!.text, 'Squat');
      expect(tester.widget<TextField>(_field('exercise-sets-0')).controller!.text, '3');
      expect(tester.widget<TextField>(_field('exercise-reps-0')).controller!.text, '15');
      expect(tester.widget<TextField>(_field('exercise-name-1')).controller!.text, 'Plank');
      expect(tester.widget<TextField>(_field('exercise-seconds-1')).controller!.text, '60');
      expect(_field('exercise-sets-1'), findsNothing, reason: 'DURATION chỉ có ô giây');
      expect(find.text('Xoá buổi tập'), findsNothing);
    });

    testWidgets('mở sheet: đã có log → điền cả số phút và bài của hôm nay (bỏ qua lastWorkout), có nút Xoá', (tester) async {
      await _pump(tester, [_workout(log: const TodayLog(durationMinutes: 40, exercises: [_pushup]), last: const [_squat])]);
      await tester.tap(_open('w'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'Sửa buổi tập hôm nay'), findsOneWidget);
      expect(tester.widget<TextField>(_field('workout-minutes')).controller!.text, '40');
      expect(tester.widget<TextField>(_field('exercise-name-0')).controller!.text, 'Chống đẩy');
      expect(_field('exercise-name-1'), findsNothing);
      expect(find.text('Xoá buổi tập'), findsOneWidget);
    });

    testWidgets('validate: thiếu số phút / thiếu số của kiểu đo bị chặn, không gọi API; sửa xong thì hết lỗi ngay', (tester) async {
      final api = await _pump(tester, [_workout()]);
      await tester.tap(_open('w'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('workout-add-row')));
      await tester.pump();
      await tester.enterText(_field('exercise-name-0'), 'Squat');
      await tester.tap(find.text('Hiệp × lần'));
      await tester.pump();
      await tester.enterText(_field('exercise-sets-0'), '3');
      await tester.tap(_saveButton());
      await tester.pumpAndSettle();
      expect(_sheetText('Nhập tổng số phút từ 1 đến 1440.'), findsOneWidget);
      expect(_sheetText('Nhập số hiệp và số lần (số nguyên từ 1).'), findsOneWidget);
      expect(api.workoutSaves, isEmpty);

      await tester.enterText(_field('workout-minutes'), '30');
      await tester.enterText(_field('exercise-reps-0'), '15');
      await tester.pump();
      expect(_sheetText('Nhập tổng số phút từ 1 đến 1440.'), findsNothing);
      expect(_sheetText('Nhập số hiệp và số lần (số nguyên từ 1).'), findsNothing);
    });

    testWidgets('lưu: PUT hôm nay với đúng payload, đóng sheet, thẻ hiện tóm tắt; thêm / xoá dòng; dòng trống bị bỏ', (tester) async {
      final api = await _pump(tester, [_workout(last: const [_pushup])]);
      await tester.tap(_open('w'));
      await tester.pumpAndSettle();
      await tester.enterText(_field('workout-minutes'), '30');
      // thêm 2 dòng: Squat 3×15 và một dòng trống; xoá dòng Chống đẩy được điền sẵn
      await tester.tap(find.byKey(const ValueKey('workout-add-row')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('workout-add-row')));
      await tester.pump();
      await tester.tap(find.byTooltip('Xoá bài 1'));
      await tester.pumpAndSettle();
      expect(_field('exercise-name-2'), findsNothing);
      await tester.enterText(_field('exercise-name-0'), 'Squat');
      await tester.tap(find.text('Hiệp × lần').first); // dòng 0 (còn dòng 1 trống)
      await tester.pump();
      await tester.enterText(_field('exercise-sets-0'), '3');
      await tester.enterText(_field('exercise-reps-0'), '15');
      await tester.tap(_saveButton());
      await tester.pumpAndSettle();

      expect(api.workoutSaves, hasLength(1));
      final save = api.workoutSaves.single;
      expect(save['id'], 'w');
      expect(save['date'], matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));
      expect(save['durationMinutes'], 30);
      expect(save['exercises'], [
        {'name': 'Squat', 'measure': 'SETS_REPS', 'sets': 3, 'reps': 15},
      ]);
      expect(find.byType(Dialog), findsNothing);
      expect(find.text('30 phút · 1 bài'), findsOneWidget);
    });

    testWidgets('bấm Lưu hai lần liên tiếp chỉ gửi một lần', (tester) async {
      final api = await _pump(tester, [_workout()]);
      api.routineGate = Completer();
      await tester.tap(_open('w'));
      await tester.pumpAndSettle();
      await tester.enterText(_field('workout-minutes'), '20');
      await tester.tap(_saveButton());
      await tester.pump();
      await tester.tap(_saveButton(), warnIfMissed: false);
      await tester.pump();
      expect(api.workoutSaves, hasLength(1));
      api.routineGate!.complete();
      await tester.pumpAndSettle();
      expect(api.workoutSaves, hasLength(1));
    });

    testWidgets('lỗi not_today / validate từ server: câu tiếng Việt trong sheet, sheet vẫn mở', (tester) async {
      final api = await _pump(tester, [_workout()]);
      await tester.tap(_open('w'));
      await tester.pumpAndSettle();
      await tester.enterText(_field('workout-minutes'), '20');
      api.routineError = _error(400, {'error': 'not_today'});
      await tester.tap(_saveButton());
      await tester.pumpAndSettle();
      expect(_sheetText('Chỉ ghi được buổi tập của hôm nay.'), findsOneWidget);
      expect(find.byType(Dialog), findsOneWidget);
      expect(tester.widget<FilledButton>(_saveButton()).onPressed, isNotNull, reason: 'mở khoá để thử lại');

      api.routineError = _error(400, {'error': {'fieldErrors': {}}});
      await tester.tap(_saveButton());
      await tester.pumpAndSettle();
      expect(_sheetText('Dữ liệu buổi tập chưa hợp lệ, kiểm tra lại số phút và các bài.'), findsOneWidget);
    });

    testWidgets('xoá buổi tập: hỏi xác nhận, Huỷ không xoá, Xoá gọi DELETE log và đóng sheet', (tester) async {
      final api = await _pump(tester, [_workout(log: const TodayLog(durationMinutes: 30, exercises: [_squat]))]);
      await tester.tap(_open('w'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(OutlinedButton, 'Xoá buổi tập'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Huỷ'));
      await tester.pumpAndSettle();
      expect(api.routineMarks, isEmpty);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Xoá buổi tập'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Xoá'));
      await tester.pumpAndSettle();
      expect(api.routineMarks, ['DELETE w']);
      expect(find.byType(Dialog), findsNothing);
      expect(find.text('30 phút · 1 bài'), findsNothing);
      expect(find.byIcon(Icons.fitness_center_outlined), findsOneWidget);
    });

    testWidgets('không tràn ở bề rộng 390 khi bàn phím mở và có nhiều dòng', (tester) async {
      await _pump(tester, [_workout(last: const [_squat, _plank, _pushup])]);
      await tester.tap(_open('w'));
      await tester.pumpAndSettle();
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('form việc hằng ngày — loại việc', () {
    Future<void> openAdd(WidgetTester tester) async {
      await tester.tap(find.text('Thêm'));
      await tester.pumpAndSettle();
    }

    testWidgets('thêm: mặc định "Việc thường"; chọn "Tập thể dục" thì gửi kind WORKOUT', (tester) async {
      final api = await _pump(tester, const []);
      await openAdd(tester);
      expect(tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Việc thường')).selected, isTrue);
      await tester.enterText(find.widgetWithText(TextField, 'Tên việc'), 'Tập sáng');
      await tester.tap(find.widgetWithText(ChoiceChip, 'Tập thể dục'));
      await tester.pump();
      await tester.tap(_saveButton());
      await tester.pumpAndSettle();
      expect(api.routineCreates.single['kind'], 'WORKOUT');
      expect(find.byIcon(Icons.fitness_center_outlined), findsOneWidget, reason: 'routine mới là WORKOUT');
    });

    testWidgets('thêm: không chọn loại thì gửi CHECK', (tester) async {
      final api = await _pump(tester, const []);
      await openAdd(tester);
      await tester.enterText(find.widgetWithText(TextField, 'Tên việc'), 'Đọc sách');
      await tester.tap(_saveButton());
      await tester.pumpAndSettle();
      expect(api.routineCreates.single['kind'], 'CHECK');
    });

    testWidgets('sửa việc chưa có log: đổi được loại, patch chỉ gồm kind', (tester) async {
      final api = await _pump(tester, [mkRoutine('a', 'Uống nước')]);
      await tester.tap(find.byTooltip('Sửa việc hằng ngày'));
      await tester.pumpAndSettle();
      expect(tester.widget<FilledButton>(_saveButton()).onPressed, isNull);
      await tester.tap(find.widgetWithText(ChoiceChip, 'Tập thể dục'));
      await tester.pump();
      await tester.tap(_saveButton());
      await tester.pumpAndSettle();
      expect(api.routineUpdates.single, {'id': 'a', 'kind': 'WORKOUT'});
    });

    testWidgets('sửa việc đã có log: không có lựa chọn loại, chỉ hiện loại hiện tại', (tester) async {
      await _pump(tester, [mkRoutine('a', 'Uống nước', done: const {3, 6})]);
      await tester.tap(find.byTooltip('Sửa việc hằng ngày'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(ChoiceChip, 'Tập thể dục'), findsNothing);
      expect(find.text('Loại: Việc thường (đã có lịch sử nên không đổi được)'), findsOneWidget);
    });

    testWidgets('server trả 409 kind_locked (log cũ hơn 7 ngày app không thấy): báo câu tiếng Việt', (tester) async {
      final api = await _pump(tester, [mkRoutine('a', 'Uống nước')]);
      await tester.tap(find.byTooltip('Sửa việc hằng ngày'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ChoiceChip, 'Tập thể dục'));
      await tester.pump();
      api.routineError = _error(409, {'error': 'kind_locked'});
      await tester.tap(_saveButton());
      await tester.pumpAndSettle();
      expect(find.text('Việc này đã có lịch sử nên không đổi loại được.'), findsOneWidget);
    });
  });
}
