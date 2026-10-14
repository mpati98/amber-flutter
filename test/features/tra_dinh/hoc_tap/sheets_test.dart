import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/course.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/widgets/sections_editor_sheet.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/widgets/subject_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'hoc_tap_test_support.dart';
import 'hoc_tap_widget_support.dart';

Widget _opener(void Function(BuildContext) open) => Scaffold(body: Builder(builder: (c) => TextButton(onPressed: () => open(c), child: const Text('mở'))));

void main() {
  group('sheet môn học', () {
    testWidgets('tạo môn: gửi tên, mục tiêu, video, ngày ôn (mặc định Chủ nhật)', (tester) async {
      final api = FakeHocTapApi();
      await pumpHocTap(tester, _opener((c) => showSubjectSheet(c)), api: api);
      await tester.tap(find.text('mở'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const ValueKey('subject-name')), 'Tiếng Anh');
      await tester.enterText(find.byKey(const ValueKey('subject-goal')), '60');
      await tester.tap(find.byKey(const ValueKey('review-6'))); // thêm T7
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('subject-save')));
      await tester.pumpAndSettle();

      expect(api.subjectBodies.single, {'name': 'Tiếng Anh', 'dailyGoalMinutes': 60, 'videoMinutesPerDay': 40, 'reviewWeekdays': [6, 7]});
    });

    testWidgets('mục tiêu ngoài 1–1440 bị chặn trước khi gọi API', (tester) async {
      final api = FakeHocTapApi();
      await pumpHocTap(tester, _opener((c) => showSubjectSheet(c)), api: api);
      await tester.tap(find.text('mở'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const ValueKey('subject-name')), 'X');
      await tester.enterText(find.byKey(const ValueKey('subject-goal')), '5000');
      await tester.tap(find.byKey(const ValueKey('subject-save')));
      await tester.pumpAndSettle();
      expect(find.textContaining('từ 1 đến 1440'), findsOneWidget);
      expect(api.subjectBodies, isEmpty);
    });

    testWidgets('sửa môn: điền sẵn, xoá mục tiêu gửi null', (tester) async {
      final api = FakeHocTapApi();
      await pumpHocTap(tester, _opener((c) => showSubjectSheet(c, subjectId: api.subjects.first.id)), api: api);
      await tester.tap(find.text('mở'));
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(find.byKey(const ValueKey('subject-name'))).controller!.text, 'Tiếng Anh');
      expect(tester.widget<TextField>(find.byKey(const ValueKey('subject-goal'))).controller!.text, '60');

      await tester.enterText(find.byKey(const ValueKey('subject-goal')), '');
      await tester.tap(find.byKey(const ValueKey('subject-save')));
      await tester.pumpAndSettle();
      expect(api.subjectPatches.single['dailyGoalMinutes'], isNull);
      expect(api.subjectPatches.single.containsKey('dailyGoalMinutes'), isTrue);
    });

    testWidgets('xoá môn đang gắn routine → báo subject_in_use bằng tiếng Việt', (tester) async {
      final api = FakeHocTapApi()..subjectDeleteError = apiError(409, {'error': 'subject_in_use'});
      await pumpHocTap(tester, _opener((c) => showSubjectSheet(c, subjectId: api.subjects.first.id)), api: api);
      await tester.tap(find.text('mở'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('subject-delete')));
      await tester.tap(find.byKey(const ValueKey('subject-delete')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Xoá'));
      await tester.pumpAndSettle();
      expect(api.subjectDeletes, [api.subjects.first.id]);
      expect(find.textContaining('việc hằng ngày'), findsOneWidget);
    });
  });

  group('sheet sửa các phần', () {
    testWidgets('giữ id khi đổi thứ tự / sửa / xoá, thêm dòng mới không có id', (tester) async {
      final api = FakeHocTapApi();
      final sections = api.detail.sections;
      await pumpHocTap(tester, _opener((c) => showSectionsEditorSheet(c, courseId: api.detail.course.id, sections: sections)), api: api);
      await tester.tap(find.text('mở'));
      await tester.pumpAndSettle();

      expect(tester.widget<TextField>(find.byKey(const ValueKey('row-title-0'))).controller!.text, 'Basics');
      // sửa phút dòng 0, đưa dòng 1 lên đầu, xoá dòng cuối
      await tester.enterText(find.byKey(const ValueKey('row-minutes-0')), '50');
      await tester.tap(find.byTooltip('Lên').at(1));
      await tester.pump();
      await tester.tap(find.byTooltip('Xoá phần').last);
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('add-row')));
      await tester.pump();
      await tester.enterText(find.byKey(const ValueKey('row-title-3')), 'Phần mới');
      await tester.enterText(find.byKey(const ValueKey('row-minutes-3')), '15');

      await tester.ensureVisible(find.byKey(const ValueKey('sections-save')));
      await tester.tap(find.byKey(const ValueKey('sections-save')));
      await tester.pumpAndSettle();

      final put = api.puts.single;
      expect([for (final s in put) s.id], [sections[1].id, sections[0].id, sections[2].id, null]);
      expect([for (final s in put) s.title], ['First English Sentences', 'Basics', 'Present Tenses', 'Phần mới']);
      expect(put[1].durationMinutes, 50);
      expect(put[3].durationMinutes, 15);
    });

    testWidgets('dòng thiếu tên / phút không hợp lệ → báo lỗi, không gọi API', (tester) async {
      final api = FakeHocTapApi();
      await pumpHocTap(tester, _opener((c) => showSectionsEditorSheet(c, courseId: 'c', sections: [const CourseSection(id: 's1', position: 0, title: 'A', durationMinutes: 5, done: false)])), api: api);
      await tester.tap(find.text('mở'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const ValueKey('row-minutes-0')), 'abc');
      await tester.tap(find.byKey(const ValueKey('sections-save')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Mỗi phần cần có tên'), findsOneWidget);
      expect(api.puts, isEmpty);
    });

    testWidgets('Dán thêm: parse rồi nối vào cuối danh sách', (tester) async {
      final api = FakeHocTapApi();
      await pumpHocTap(tester, _opener((c) => showSectionsEditorSheet(c, courseId: 'c', sections: [const CourseSection(id: 's1', position: 0, title: 'A', durationMinutes: 5, done: true)])), api: api);
      await tester.tap(find.text('mở'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('paste-more')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const ValueKey('sections-text')), 'B 10min\nC 20min');
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('append-parsed')));
      await tester.tap(find.byKey(const ValueKey('append-parsed')));
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(find.byKey(const ValueKey('row-title-2'))).controller!.text, 'C');
      expect(tester.widget<TextField>(find.byKey(const ValueKey('row-minutes-1'))).controller!.text, '10');
    });
  });
}
