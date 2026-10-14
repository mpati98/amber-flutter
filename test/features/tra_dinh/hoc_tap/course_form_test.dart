import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_enums.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/widgets/course_form_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'hoc_tap_test_support.dart';
import 'hoc_tap_widget_support.dart';

bool _saveEnabled(WidgetTester tester) => tester.widget<FilledButton>(find.byKey(const ValueKey('course-save'))).onPressed != null;

void main() {
  late FakeHocTapApi api;
  String subjectId() => api.subjects.first.id;

  Future<void> pump(WidgetTester tester, {CourseStatus status = CourseStatus.queued}) async {
    api = FakeHocTapApi();
    await pumpHocTap(
      tester,
      Scaffold(
        body: Builder(
          builder: (context) => TextButton(onPressed: () => showCourseFormSheet(context, subjectId: subjectId(), initialStatus: status), child: const Text('mở')),
        ),
      ),
      api: api,
    );
    await tester.tap(find.text('mở'));
    await tester.pumpAndSettle();
  }

  testWidgets('dán mục lục: debounce 500ms, hiện phần đọc được + tổng, dòng bỏ qua tô đỏ → tắt nút lưu', (tester) async {
    await pump(tester);
    await tester.enterText(find.byKey(const ValueKey('course-title')), 'Khóa thử');
    await tester.pump();
    expect(_saveEnabled(tester), isTrue); // chưa dán gì: lưu được (khóa chưa có phần)

    await tester.enterText(find.byKey(const ValueKey('sections-text')), 'Intro 10min\nKhông có giờ\nBài 2 30min');
    await tester.pump(const Duration(milliseconds: 100));
    expect(api.parsedTexts, isEmpty, reason: 'chưa tới 500ms thì chưa gọi parse');
    expect(_saveEnabled(tester), isFalse, reason: 'đang chờ parse thì chặn lưu');

    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(api.parsedTexts.length, 1);
    expect(find.byKey(const ValueKey('parsed-list')), findsOneWidget);
    expect(find.text('Intro'), findsOneWidget);
    expect(find.text('2 phần · 40p'), findsOneWidget);
    expect(find.byKey(const ValueKey('skipped-2')), findsOneWidget);
    expect(find.textContaining('Dòng 2 chưa đọc được'), findsOneWidget);
    expect(_saveEnabled(tester), isFalse, reason: 'còn dòng bị bỏ qua thì nút lưu tắt');

    // Sửa dòng lỗi → bật lại.
    await tester.enterText(find.byKey(const ValueKey('sections-text')), 'Intro 10min\nBài 2 30min');
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('skipped-2')), findsNothing);
    expect(_saveEnabled(tester), isTrue);
  });

  testWidgets('lưu: gửi sections đã parse, status và môn', (tester) async {
    await pump(tester, status: CourseStatus.active);
    await tester.enterText(find.byKey(const ValueKey('course-title')), 'English Tenses');
    await tester.enterText(find.byKey(const ValueKey('course-platform')), 'Udemy');
    await tester.enterText(find.byKey(const ValueKey('sections-text')), 'A 10min\nB 20min');
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('course-save')));
    await tester.pumpAndSettle();

    expect(api.created.length, 1);
    final body = api.created.single;
    expect(body['subjectId'], subjectId());
    expect(body['title'], 'English Tenses');
    expect(body['platform'], 'Udemy');
    expect(body['status'], 'ACTIVE');
    expect(body['sections'], [
      {'title': 'A', 'durationMinutes': 10},
      {'title': 'B', 'durationMinutes': 20},
    ]);
    expect(body.containsKey('targetPrice'), isFalse);
  });

  testWidgets('Muốn mua hiện giá định mua + ghi chú và gửi kèm', (tester) async {
    await pump(tester, status: CourseStatus.wishlist);
    expect(find.byKey(const ValueKey('course-price')), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('course-title')), 'IELTS');
    await tester.enterText(find.byKey(const ValueKey('course-price')), '499k');
    await tester.enterText(find.byKey(const ValueKey('course-note')), 'chờ sale');
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('course-save')));
    await tester.pumpAndSettle();
    expect(api.created.single['status'], 'WISHLIST');
    expect(api.created.single['targetPrice'], '499k');
    expect(api.created.single['note'], 'chờ sale');
  });

  testWidgets('Chờ học không hiện ô giá định mua', (tester) async {
    await pump(tester);
    expect(find.byKey(const ValueKey('course-price')), findsNothing);
  });

  testWidgets('active_exists → câu tiếng Việt, form còn mở', (tester) async {
    await pump(tester, status: CourseStatus.active);
    api.createError = apiError(409, {'error': 'active_exists'});
    await tester.enterText(find.byKey(const ValueKey('course-title')), 'X');
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('course-save')));
    await tester.pumpAndSettle();
    expect(find.text('Môn này đã có khóa đang học'), findsOneWidget);
    expect(find.byKey(const ValueKey('course-save')), findsOneWidget);
  });
}
