import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_enums.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_log.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_schedule.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_subject.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/screens/overview_tab.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/widgets/log_sheet.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/widgets/schedule_day_row.dart';
import 'package:amber_flutter/shared/utils/vn_time.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'hoc_tap_test_support.dart';
import 'hoc_tap_widget_support.dart';

// Buổi luyện AI (PRACTICE): hiện "Luyện AI · N phút", sửa minutes + note bằng form của buổi chỉ-phút, xoá được.

Finder _k(String key) => find.byKey(ValueKey(key));

void main() {
  late FakeHocTapApi api;
  String subjectId() => api.subjects.first.id;

  StudyLog practiceLog({int minutes = 15, String? note = 'nói 15 phút'}) =>
      StudyLog(id: 'prac-1', subjectId: subjectId(), logDate: vnToday(), minutes: minutes, note: note, createdAt: DateTime.now(), activity: LogActivity.practice);

  Future<void> open(WidgetTester tester, StudyLog editing) async {
    await pumpHocTap(
      tester,
      Scaffold(body: Builder(builder: (c) => TextButton(onPressed: () => showLogSheet(c, subjectId: subjectId(), editing: editing), child: const Text('mở')))),
      api: api,
    );
    await tester.tap(find.text('mở'));
    await tester.pumpAndSettle();
  }

  setUp(() => api = FakeHocTapApi());

  group('sửa một buổi luyện AI', () {
    testWidgets('tiêu đề "Luyện AI"; chỉ có phút + ghi chú điền sẵn, không khóa / phần / mục tiêu / dừng / đổi loại', (tester) async {
      await open(tester, practiceLog());
      expect(find.text('Luyện AI'), findsWidgets);
      expect(find.textContaining('Luyện AI'), findsWidgets);
      expect(tester.widget<TextField>(_k('log-minutes')).controller!.text, '15');
      expect(tester.widget<TextField>(_k('log-note')).controller!.text, 'nói 15 phút');
      expect(find.byType(DropdownButtonFormField<String?>), findsNothing);
      expect(find.byType(Checkbox), findsNothing);
      expect(_k('total-block'), findsNothing);
      expect(_k('stop-switch'), findsNothing);
      expect(_k('log-activity'), findsNothing);
      expect(find.text('Số phút luyện AI'), findsOneWidget, reason: 'nhãn ô nhập riêng cho buổi luyện AI, không phải "ôn thẻ"');
      expect(find.textContaining('ôn thẻ'), findsNothing);
      expect(_k('log-delete'), findsOneWidget);
    });

    testWidgets('lưu bằng PATCH chỉ gồm minutes và note — KHÔNG gửi courseId, sections, activity, stopForToday', (tester) async {
      await open(tester, practiceLog());
      await tester.enterText(_k('log-minutes'), '30');
      await tester.enterText(_k('log-note'), 'sửa lại');
      await tester.pump();
      await tester.tap(_k('log-save'));
      await tester.pumpAndSettle();
      final patch = api.logPatches.single;
      expect(patch, {'id': 'prac-1', 'minutes': 30, 'note': 'sửa lại'});
      for (final k in ['courseId', 'sections', 'stopForToday', 'activity', 'subjectId']) {
        expect(patch.containsKey(k), isFalse, reason: k);
      }
      expect(api.logCreates, isEmpty);
      expect(find.textContaining('Đã cập nhật buổi luyện AI'), findsOneWidget);
    });

    testWidgets('số phút phải từ 1 đến 1440', (tester) async {
      await open(tester, practiceLog());
      for (final (v, ok) in [('0', false), ('1441', false), ('', false), ('1', true), ('1440', true)]) {
        await tester.enterText(_k('log-minutes'), v);
        await tester.pump();
        expect(tester.widget<FilledButton>(_k('log-save')).onPressed != null, ok, reason: v);
      }
    });

    testWidgets('xoá có hỏi lại (riêng cho buổi luyện AI), xoá xong báo "Đã xoá buổi luyện AI"', (tester) async {
      await open(tester, practiceLog());
      await tester.tap(_k('log-delete'));
      await tester.pumpAndSettle();
      expect(find.text('Xoá buổi luyện AI?'), findsOneWidget);
      expect(find.textContaining('Phần đã đánh dấu xong'), findsNothing);
      await tester.tap(find.text('Xoá'));
      await tester.pumpAndSettle();
      expect(api.logDeletes, ['prac-1']);
      expect(find.text('Đã xoá buổi luyện AI'), findsOneWidget);
    });

    testWidgets('lỗi server báo tiếng Việt, sheet vẫn mở', (tester) async {
      api.logError = apiError(400, {'error': 'not_today'});
      await open(tester, practiceLog());
      await tester.tap(_k('log-save'));
      await tester.pumpAndSettle();
      expect(find.text('Chỉ sửa hoặc xoá được buổi học của hôm nay'), findsOneWidget);
      expect(_k('log-minutes'), findsOneWidget);
    });
  });

  testWidgets('"Việc hôm nay": buổi đã ghi hiện "Luyện AI · …", bấm → sheet sửa của buổi luyện AI', (tester) async {
    api.logs = [practiceLog()];
    await pumpHocTap(tester, const Scaffold(body: OverviewTab()), api: api);
    expect(find.descendant(of: _k('today-log-prac-1'), matching: find.text('Luyện AI')), findsOneWidget);
    expect(find.descendant(of: _k('today-log-prac-1'), matching: find.text('15p')), findsOneWidget);
    await tester.tap(_k('today-log-prac-1'));
    await tester.pumpAndSettle();
    expect(find.text('Sửa buổi học'), findsNothing, reason: 'không rơi vào form học bài');
    expect(_k('log-delete'), findsOneWidget);
    expect(tester.widget<TextField>(_k('log-minutes')).controller!.text, '15');
  });

  testWidgets('lịch (JSON thật): dòng ngày hiện buổi "Luyện AI" kèm 15p', (tester) async {
    final sc = StudySchedule.fromJson(fixtureMap('schedule_practice'));
    final day = sc.days.firstWhere((d) => d.logs.any((l) => l.activity == LogActivity.practice));
    final subject = StudySubject.fromJson({'id': 's', 'name': 'Tiếng Anh', 'dailyGoalMinutes': 60, 'videoMinutesPerDay': 40, 'reviewWeekdays': [7], 'position': 0});
    await pumpHocTap(tester, Scaffold(body: SingleChildScrollView(child: ScheduleDayRow(day: day, subject: subject))), api: FakeHocTapApi());
    expect(find.text('Luyện AI'), findsOneWidget);
    expect(find.text('15p'), findsOneWidget);
    expect(find.text('Ôn thẻ'), findsOneWidget);
  });
}
