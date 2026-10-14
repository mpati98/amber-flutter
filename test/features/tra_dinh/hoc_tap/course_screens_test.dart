import 'dart:async';

import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/course.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_enums.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/providers/hoc_tap_provider.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/screens/course_detail_screen.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/screens/course_list_screen.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/screens/wishlist_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'hoc_tap_test_support.dart';
import 'hoc_tap_widget_support.dart';

bool _checked(WidgetTester tester, String sectionId) => tester.widget<Checkbox>(find.byKey(ValueKey('check-$sectionId'))).value ?? false;

void main() {
  group('chi tiết khóa', () {
    testWidgets('hiển thị tiến độ, phần "Đang học", buổi gần đây', (tester) async {
      final api = FakeHocTapApi();
      await pumpHocTap(tester, CourseDetailScreen(courseId: api.detail.course.id), api: api);

      expect(find.text('English Tenses 101'), findsOneWidget);
      expect(find.text('Đang học'), findsNWidgets(2)); // chip trạng thái + nhãn phần kế tiếp
      expect(find.byKey(const ValueKey('now-label')), findsOneWidget);
      expect(find.text('1/4 phần · 14%'), findsOneWidget);
      expect(find.text('Video còn 4h 41p'), findsOneWidget);
      expect(find.textContaining('Dự kiến xong 23/10'), findsOneWidget);
      expect(find.text('Cô Lan · Udemy'), findsOneWidget);
      expect(find.byKey(const ValueKey('open-course')), findsOneWidget);
      expect(find.text('Xong phần cơ bản'), findsOneWidget);
      expect(_checked(tester, api.detail.sections[0].id), isTrue);
      expect(_checked(tester, api.detail.sections[1].id), isFalse);
    });

    testWidgets('tick phần cập nhật lạc quan, thành công thì giữ', (tester) async {
      final api = FakeHocTapApi();
      final gate = Completer<void>();
      api.toggleGate = gate;
      await pumpHocTap(tester, CourseDetailScreen(courseId: api.detail.course.id), api: api);
      final id = api.detail.sections[1].id;

      await tester.tap(find.byKey(ValueKey('check-$id')));
      await tester.pump();
      expect(_checked(tester, id), isTrue, reason: 'đổi ngay, chưa chờ server');
      expect(find.text('2/4 phần · 42%'), findsOneWidget);

      gate.complete();
      await tester.pumpAndSettle();
      expect(_checked(tester, id), isTrue);
      expect(api.sectionToggles.single, (sectionId: id, done: true));
    });

    testWidgets('API lỗi → checkbox hoàn tác và báo lỗi', (tester) async {
      final api = FakeHocTapApi();
      final gate = Completer<void>();
      api.toggleGate = gate;
      api.toggleError = apiError(500, {'error': 'boom'});
      await pumpHocTap(tester, CourseDetailScreen(courseId: api.detail.course.id), api: api);
      final id = api.detail.sections[1].id;

      await tester.tap(find.byKey(ValueKey('check-$id')));
      await tester.pump();
      expect(_checked(tester, id), isTrue);

      gate.complete();
      await tester.pumpAndSettle();
      expect(_checked(tester, id), isFalse, reason: 'hoàn tác khi API lỗi');
      expect(find.text('1/4 phần · 14%'), findsOneWidget);
      expect(find.textContaining('Không cập nhật được phần học'), findsOneWidget);
    });

    testWidgets('menu chỉ hiện đổi trạng thái hợp lệ (ACTIVE: không có "Bắt đầu học")', (tester) async {
      final api = FakeHocTapApi();
      await pumpHocTap(tester, CourseDetailScreen(courseId: api.detail.course.id), api: api);
      await tester.tap(find.byKey(const ValueKey('course-menu')));
      await tester.pumpAndSettle();
      expect(find.text('Về hàng chờ'), findsOneWidget);
      expect(find.text('Đánh dấu xong'), findsOneWidget);
      expect(find.text('Chuyển sang Muốn mua'), findsOneWidget);
      expect(find.text('Bắt đầu học'), findsNothing);
      expect(find.text('Chốt lại kế hoạch của môn'), findsOneWidget);
      expect(find.text('Sửa các phần'), findsOneWidget);
      expect(find.text('Xoá khóa học'), findsOneWidget);

      await tester.tap(find.text('Về hàng chờ'));
      await tester.pumpAndSettle();
      expect(api.patches.single, {'id': api.detail.course.id, 'status': 'QUEUED'});
    });

    test('statusChoices theo trạng thái', () {
      expect(statusChoices(CourseStatus.queued).map((e) => e.$2), [CourseStatus.active, CourseStatus.done, CourseStatus.wishlist]);
      expect(statusChoices(CourseStatus.wishlist).map((e) => e.$2), [CourseStatus.active, CourseStatus.queued]);
      expect(statusChoices(CourseStatus.done).map((e) => e.$2), [CourseStatus.active, CourseStatus.queued]);
      expect(statusChoices(CourseStatus.unknown), isEmpty);
    });

    testWidgets('chốt lại kế hoạch có xác nhận', (tester) async {
      final api = FakeHocTapApi();
      await pumpHocTap(tester, CourseDetailScreen(courseId: api.detail.course.id), api: api);
      await tester.tap(find.byKey(const ValueKey('course-menu')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Chốt lại kế hoạch của môn'));
      await tester.pumpAndSettle();
      expect(api.rebaselines, 0, reason: 'chưa xác nhận thì chưa gọi');
      await tester.tap(find.text('Chốt lại'));
      await tester.pumpAndSettle();
      expect(api.rebaselines, 1);
    });

    testWidgets('buổi học gần đây hiện các phần (xong đánh dấu); nút "Ghi buổi học" mở sheet chọn sẵn khóa', (tester) async {
      final detail = CourseDetail.fromJson(fixtureMap('course_detail_logs'));
      final api = FakeHocTapApi(detail: detail);
      await pumpHocTap(tester, CourseDetailScreen(courseId: detail.course.id), api: api);

      final log = detail.recentLogs.single;
      expect(find.byKey(ValueKey('recent-sections-${log.id}')), findsOneWidget);
      expect(find.text('Basics ✓ xong · First English Sentences'), findsOneWidget);

      await tester.ensureVisible(find.byKey(const ValueKey('log-from-course')));
      await tester.tap(find.byKey(const ValueKey('log-from-course')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Chỉ ghi cho hôm nay.'), findsOneWidget);
    });

    testWidgets('khóa DONE hiện ngày xong thay cho dự kiến', (tester) async {
      final done = CourseDetail.fromJson({...fixtureMap('course_detail'), 'status': 'DONE', 'finishedAt': '2026-10-12T05:00:00.000Z'});
      final api = FakeHocTapApi(detail: done);
      await pumpHocTap(tester, CourseDetailScreen(courseId: done.course.id), api: api);
      expect(find.text('Xong ngày 12/10'), findsOneWidget);
      expect(find.byKey(const ValueKey('course-forecast')), findsNothing);
    });
  });

  group('danh sách khóa', () {
    testWidgets('Chờ học: có số thứ tự, lên/xuống đổi thứ tự (gọi move)', (tester) async {
      final api = FakeHocTapApi();
      await pumpHocTap(tester, CourseListScreen(subjectId: api.subjects.first.id, statuses: const [CourseStatus.queued]), api: api);
      final queued = api.courses.where((c) => c.status == CourseStatus.queued).toList();
      expect(find.text('Complete English Course'), findsOneWidget);
      expect(find.text('Master Native English'), findsOneWidget);
      expect(find.text('English Tenses 101'), findsNothing);
      expect(find.byKey(ValueKey('order-${queued[0].id}')), findsOneWidget);
      expect(tester.widget<IconButton>(find.byKey(ValueKey('up-${queued[0].id}'))).onPressed, isNull, reason: 'đầu hàng: không lên được');
      expect(tester.widget<IconButton>(find.byKey(ValueKey('down-${queued[1].id}'))).onPressed, isNull, reason: 'cuối hàng: không xuống được');

      await tester.tap(find.byKey(ValueKey('down-${queued[0].id}')));
      await tester.pumpAndSettle();
      expect(api.moves.single, (id: queued[0].id, up: false));
      // sau khi tải lại, thứ tự đổi
      expect(tester.getTopLeft(find.text('Master Native English')).dy, lessThan(tester.getTopLeft(find.text('Complete English Course')).dy));
    });

    testWidgets('Đã xong: không có nút lên/xuống; bấm dòng → chi tiết', (tester) async {
      final api = FakeHocTapApi();
      await pumpHocTap(tester, CourseListScreen(subjectId: api.subjects.first.id, statuses: const [CourseStatus.done]), api: api);
      expect(find.text('Grammar Basics'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_upward), findsNothing);
      await tester.tap(find.text('Grammar Basics'));
      await tester.pumpAndSettle();
      expect(visited.last, startsWith('/tra-dinh/hoc-tap/courses/'));
    });
  });

  group('Muốn mua', () {
    testWidgets('thẻ có giá định mua, ghi chú; "Đã mua" chuyển sang Chờ học', (tester) async {
      final api = FakeHocTapApi();
      await pumpHocTap(tester, WishlistScreen(subjectId: api.subjects.first.id), api: api);
      final wish = api.courses.firstWhere((c) => c.status == CourseStatus.wishlist);
      expect(find.text('IELTS Masterclass'), findsOneWidget);
      expect(find.text('Thầy Nam · Coursera · Chưa có phần'), findsOneWidget);
      expect(find.text('Giá định mua: 499.000đ'), findsOneWidget);
      expect(find.text('Chờ giảm giá'), findsOneWidget);
      expect(find.text('Mở link'), findsNothing, reason: 'khóa fixture không có url');

      await tester.tap(find.byKey(ValueKey('bought-${wish.id}')));
      await tester.pumpAndSettle();
      expect(api.patches.single, {'id': wish.id, 'status': 'QUEUED'});
      expect(find.text('IELTS Masterclass'), findsNothing, reason: 'rời danh sách Muốn mua sau khi tải lại');
    });
  });

  test('CourseQuery so sánh theo giá trị (family cache đúng, không phụ thuộc thứ tự trạng thái)', () {
    final a = CourseQuery(subjectId: 's', statuses: const [CourseStatus.queued, CourseStatus.done]);
    final b = CourseQuery(subjectId: 's', statuses: const [CourseStatus.done, CourseStatus.queued]);
    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(a == CourseQuery(subjectId: 's', statuses: const [CourseStatus.done]), isFalse);
    expect(a == CourseQuery(subjectId: 'x', statuses: const [CourseStatus.queued, CourseStatus.done]), isFalse);
  });
}
