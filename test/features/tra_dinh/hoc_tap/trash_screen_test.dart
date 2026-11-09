import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/course.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/providers/hoc_tap_provider.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/screens/course_detail_screen.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/screens/course_list_screen.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/screens/trash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'hoc_tap_test_support.dart';
import 'hoc_tap_widget_support.dart';

const _subjectId = '291d6fb1-6c9b-4820-a1f2-8763f05e9e3b'; // "Tiếng Anh" trong fixture subjects

CourseView _trashed(
  String id,
  String title,
  int daysLeft, {
  String status = 'QUEUED',
}) => CourseView.fromJson({
  'id': id,
  'subjectId': _subjectId,
  'title': title,
  'status': status,
  'progress': {
    'doneSections': 0,
    'totalSections': 1,
    'doneMinutes': 0,
    'totalMinutes': 30,
  },
  'deletedAt': '2026-11-01T03:00:00.000Z',
  'daysLeft': daysLeft,
});

BoxDecoration _chipDecoration(WidgetTester tester, String id) =>
    tester.widget<Container>(find.byKey(ValueKey('trash-chip-$id'))).decoration!
        as BoxDecoration;

void main() {
  group('Thùng rác', () {
    testWidgets('rỗng: hiện "Thùng rác trống" cùng dòng phụ và chú thích', (
      tester,
    ) async {
      final api = FakeHocTapApi();
      await pumpHocTap(tester, const TrashScreen(), api: api);
      expect(find.text('Thùng rác'), findsOneWidget, reason: 'tiêu đề');
      expect(
        find.text('Khóa đã xoá được giữ 30 ngày, sau đó tự xoá hẳn.'),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('trash-empty')), findsOneWidget);
      expect(find.text('Thùng rác trống'), findsOneWidget);
      expect(find.byKey(const ValueKey('trash-footnote')), findsOneWidget);
    });

    testWidgets(
      'hai thẻ: tên khóa, "<môn> · xoá ngày dd/MM", chip "Còn N ngày"; chip đỏ khi còn ≤ 10 ngày',
      (tester) async {
        final api = FakeHocTapApi()
          ..trash = [
            _trashed('a', 'Khóa nhiều ngày', 25),
            _trashed('b', 'Khóa sắp mất', 10),
          ];
        await pumpHocTap(tester, const TrashScreen(), api: api);

        expect(find.text('Khóa nhiều ngày'), findsOneWidget);
        expect(find.text('Khóa sắp mất'), findsOneWidget);
        expect(find.text('Tiếng Anh · xoá ngày 01/11'), findsNWidgets(2));
        expect(find.text('Còn 25 ngày'), findsOneWidget);
        expect(find.text('Còn 10 ngày'), findsOneWidget);

        final scheme = Theme.of(tester.element(find.byType(TrashScreen)))
            .colorScheme;
        final calm = _chipDecoration(tester, 'a'),
            urgent = _chipDecoration(tester, 'b');
        expect((calm.border! as Border).top.color, isNot(scheme.error));
        expect((urgent.border! as Border).top.color, scheme.error);
        expect(urgent.color, isNotNull, reason: 'nền chip cảnh báo');
        expect(
          tester.widget<Text>(find.text('Còn 10 ngày')).style!.color,
          scheme.error,
        );
        expect(
          tester.widget<Text>(find.text('Còn 25 ngày')).style!.color,
          isNot(scheme.error),
        );
        // Khôi phục: nút vàng đầy khi còn nhiều ngày; viền khi sắp hết hạn.
        expect(
          find.descendant(
            of: find.byKey(const ValueKey('trash-a')),
            matching: find.byType(FilledButton),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byKey(const ValueKey('trash-b')),
            matching: find.byType(OutlinedButton),
          ),
          findsOneWidget,
        );
        expect(find.text('Xoá hẳn'), findsNWidgets(2));
      },
    );

    testWidgets('thiếu daysLeft / môn không rõ: không lỗi, coi như 0 ngày', (
      tester,
    ) async {
      final api = FakeHocTapApi()
        ..trash = [
          CourseView.fromJson({
            'id': 'x',
            'subjectId': 'môn-lạ',
            'title': 'Khóa lạ',
            'status': 'MỚI',
          }),
        ];
      await pumpHocTap(tester, const TrashScreen(), api: api);
      expect(find.text('Khóa lạ'), findsOneWidget);
      expect(find.text('Còn 0 ngày'), findsOneWidget);
    });

    testWidgets(
      'Khôi phục: gọi restore, danh sách làm mới, báo "Đã khôi phục"',
      (tester) async {
        final api = FakeHocTapApi()
          ..trash = [_trashed('a', 'Khóa A', 25), _trashed('b', 'Khóa B', 20)];
        await pumpHocTap(tester, const TrashScreen(), api: api);
        await tester.tap(find.byKey(const ValueKey('restore-a')));
        await tester.pumpAndSettle();
        expect(api.restores, ['a']);
        expect(find.text('Đã khôi phục'), findsOneWidget);
        expect(find.byKey(const ValueKey('trash-a')), findsNothing);
        expect(find.byKey(const ValueKey('trash-b')), findsOneWidget);
      },
    );

    testWidgets(
      'Khôi phục gặp 404: báo "Khóa này không còn trong Thùng rác" và làm mới danh sách',
      (tester) async {
        final api = FakeHocTapApi()
          ..trash = [_trashed('a', 'Khóa A', 3)]
          ..restoreError = apiError(404, {'error': 'course_not_found'});
        await pumpHocTap(tester, const TrashScreen(), api: api);
        api.trash = []; // phía server khóa đã bị xoá hẳn
        await tester.tap(find.byKey(const ValueKey('restore-a')));
        await tester.pumpAndSettle();
        expect(find.text('Khóa này không còn trong Thùng rác'), findsOneWidget);
        expect(find.byKey(const ValueKey('trash-a')), findsNothing);
        expect(find.byKey(const ValueKey('trash-empty')), findsOneWidget);
      },
    );

    testWidgets(
      'Xoá hẳn: mở sheet mật khẩu đúng nội dung, gọi purge kèm mật khẩu rồi bỏ thẻ',
      (tester) async {
        final api = FakeHocTapApi()..trash = [_trashed('a', 'Khóa A', 25)];
        await pumpHocTap(tester, const TrashScreen(), api: api);
        await tester.tap(find.byKey(const ValueKey('purge-a')));
        await tester.pumpAndSettle();
        expect(find.text('Xoá hẳn khóa này?'), findsOneWidget);
        expect(
          find.text(
            'Không thể khôi phục sau khi xoá hẳn. Buổi học đã ghi vẫn còn trong lịch sử, các thẻ vẫn giữ.',
          ),
          findsOneWidget,
        );
        expect(api.purges, isEmpty, reason: 'chưa nhập mật khẩu thì chưa gọi');

        await tester.enterText(
          find.byKey(const ValueKey('pw-field')),
          'mk-đúng',
        );
        await tester.pump();
        await tester.tap(find.byKey(const ValueKey('pw-submit')));
        await tester.pumpAndSettle();
        expect(api.purges.single, (id: 'a', password: 'mk-đúng'));
        expect(find.byKey(const ValueKey('trash-a')), findsNothing);
      },
    );

    testWidgets('Xoá hẳn sai mật khẩu: sheet ở lại, báo lỗi, khóa còn', (
      tester,
    ) async {
      final api = FakeHocTapApi()
        ..trash = [_trashed('a', 'Khóa A', 25)]
        ..deleteError = apiError(403, {'error': 'wrong_password'});
      await pumpHocTap(tester, const TrashScreen(), api: api);
      await tester.tap(find.byKey(const ValueKey('purge-a')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const ValueKey('pw-field')), 'sai');
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('pw-submit')));
      await tester.pumpAndSettle();
      expect(find.text('Mật khẩu chưa đúng'), findsOneWidget);
      expect(api.trash, hasLength(1));
    });

    testWidgets('lỗi tải: hiện lỗi + Thử lại', (tester) async {
      final api = FakeHocTapApi();
      await pumpHocTap(
        tester,
        const TrashScreen(),
        api: api,
        overrides: [
          studyTrashProvider.overrideWith((ref) => throw apiError(500, 'x')),
        ],
      );
      expect(find.text('Không tải được Thùng rác.'), findsOneWidget);
      expect(find.text('Thử lại'), findsOneWidget);
    });
  });

  group('lối vào Thùng rác và xoá khóa', () {
    testWidgets(
      'danh sách khóa không còn hàng "Thùng rác" (lối vào đã dời sang Chi tiết kế hoạch), kể cả khi rỗng',
      (tester) async {
        await pumpHocTap(
          tester,
          const CourseListScreen(statuses: []),
          api: FakeHocTapApi(),
        );
        expect(find.byKey(const ValueKey('trash-entry')), findsNothing);
        expect(find.text('Thùng rác'), findsNothing);
        await pumpHocTap(
          tester,
          const CourseListScreen(statuses: []),
          api: FakeHocTapApi(courses: []),
        );
        expect(find.byKey(const ValueKey('trash-entry')), findsNothing);
      },
    );

    testWidgets(
      'chi tiết khóa: nút "Xoá khóa" nằm trong khu "Nâng cao" thu gọn, viền đỏ, không phải nút vàng',
      (tester) async {
        final api = FakeHocTapApi();
        await pumpHocTap(
          tester,
          CourseDetailScreen(courseId: api.detail.course.id),
          api: api,
        );
        expect(find.text('Nâng cao'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('delete-course')).hitTestable(),
          findsNothing,
          reason: 'thu gọn',
        );
        await tester.ensureVisible(find.text('Nâng cao'));
        await tester.tap(find.text('Nâng cao'));
        await tester.pumpAndSettle();
        final button = tester.widget<OutlinedButton>(
          find.byKey(const ValueKey('delete-course')),
        );
        final error = Theme.of(tester.element(find.byType(CourseDetailScreen)))
            .colorScheme
            .error;
        expect(button.style!.foregroundColor!.resolve({}), error);
        expect(button.style!.backgroundColor!.resolve({}), Colors.transparent);
      },
    );

    testWidgets(
      'xoá khóa: sheet đúng nội dung → mật khẩu → gọi API, thoát về /tra-dinh, báo "Đã chuyển vào Thùng rác"',
      (tester) async {
        final api = FakeHocTapApi();
        await pumpHocTap(
          tester,
          CourseDetailScreen(courseId: api.detail.course.id),
          api: api,
        );
        await tester.ensureVisible(find.text('Nâng cao'));
        await tester.tap(find.text('Nâng cao'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byKey(const ValueKey('delete-course')));
        await tester.tap(find.byKey(const ValueKey('delete-course')));
        await tester.pumpAndSettle();

        expect(find.text('Xoá khóa này?'), findsOneWidget);
        expect(find.text(api.detail.course.title), findsWidgets);
        expect(
          find.text(
            'Khóa vào Thùng rác 30 ngày. Khôi phục được bất cứ lúc nào, sau đó xoá hẳn.',
          ),
          findsOneWidget,
        );
        expect(
          find.text('Các buổi học đã ghi vẫn tính vào chuỗi ngày.'),
          findsOneWidget,
        );
        expect(
          find.text('Ghi chú khóa ở Tàng Kinh Các được giữ nguyên.'),
          findsOneWidget,
        );

        await tester.enterText(find.byKey(const ValueKey('pw-field')), 'mk');
        await tester.pump();
        await tester.tap(find.byKey(const ValueKey('pw-submit')));
        await tester.pumpAndSettle();
        expect(api.deletes.single, (id: api.detail.course.id, password: 'mk'));
        expect(visited, contains('/tra-dinh'));
        expect(find.text('Đã chuyển vào Thùng rác'), findsOneWidget);
      },
    );

    testWidgets('xoá khóa sai mật khẩu: ở lại màn khóa, không báo thành công', (
      tester,
    ) async {
      final api = FakeHocTapApi()
        ..deleteError = apiError(403, {'error': 'wrong_password'});
      await pumpHocTap(
        tester,
        CourseDetailScreen(courseId: api.detail.course.id),
        api: api,
      );
      await tester.ensureVisible(find.text('Nâng cao'));
      await tester.tap(find.text('Nâng cao'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('delete-course')));
      await tester.tap(find.byKey(const ValueKey('delete-course')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const ValueKey('pw-field')), 'sai');
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('pw-submit')));
      await tester.pumpAndSettle();
      expect(find.text('Mật khẩu chưa đúng'), findsOneWidget);
      expect(visited, isNot(contains('/tra-dinh')));
      expect(find.text('Đã chuyển vào Thùng rác'), findsNothing);
    });

    testWidgets(
      'xoá khóa làm mới các provider khóa (tổng quan, thùng rác) khi thành công',
      (tester) async {
        final api = FakeHocTapApi();
        late WidgetRef ref;
        await pumpHocTap(
          tester,
          Consumer(
            builder: (context, r, _) {
              ref = r;
              return const SizedBox();
            },
          ),
          api: api,
        );
        await ref.read(studyOverviewProvider.future);
        expect(api.overviewCalls, 1);
        await ref.read(hocTapActionsProvider).deleteCourse('c', password: 'mk');
        await ref.read(studyOverviewProvider.future);
        expect(
          api.overviewCalls,
          2,
          reason: 'tổng quan bị invalidate nên tải lại',
        );
      },
    );
  });
}
