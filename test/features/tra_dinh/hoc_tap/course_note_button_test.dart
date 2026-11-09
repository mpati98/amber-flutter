import 'dart:async';

import 'package:amber_flutter/features/tang_kinh_cac/models/document.dart';
import 'package:amber_flutter/features/tang_kinh_cac/providers/document_provider.dart';
import 'package:amber_flutter/features/tang_kinh_cac/services/document_api.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/screens/course_detail_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'hoc_tap_test_support.dart';
import 'hoc_tap_widget_support.dart';

class _CountingDocumentApi extends DocumentApi {
  _CountingDocumentApi() : super(Dio());

  int lists = 0;

  @override
  Future<List<Document>> getDocuments({
    DocumentType? type,
    String? search,
    bool? pinned,
    String? topicId,
  }) async {
    lists++;
    return [];
  }
}

Future<(FakeHocTapApi, _CountingDocumentApi)> _pump(
  WidgetTester tester, {
  FakeHocTapApi? api,
}) async {
  final hocTap = api ?? FakeHocTapApi();
  final docs = _CountingDocumentApi();
  await pumpHocTap(
    tester,
    CourseDetailScreen(courseId: hocTap.detail.course.id),
    api: hocTap,
    overrides: [documentApiProvider.overrideWithValue(docs)],
  );
  return (hocTap, docs);
}

Future<void> _tapNote(WidgetTester tester) async {
  await tester.ensureVisible(find.byKey(const ValueKey('course-note')));
  await tester.tap(find.byKey(const ValueKey('course-note')));
}

void main() {
  group('nút "Ghi chú khóa"', () {
    testWidgets(
      'là nút VIỀN cao ≥ 52, nằm giữa "Ghi buổi học" và khu "Nâng cao"; màn chỉ có một nút vàng',
      (tester) async {
        await _pump(tester);
        expect(find.text('Ghi chú khóa'), findsOneWidget);
        expect(
          tester.widget(find.byKey(const ValueKey('course-note'))),
          isA<OutlinedButton>(),
        );
        expect(
          tester.getSize(find.byKey(const ValueKey('course-note'))).height,
          greaterThanOrEqualTo(52),
        );
        expect(
          find.byType(FilledButton),
          findsOneWidget,
          reason: 'chỉ "Ghi buổi học" là nút vàng',
        );
        double y(String k) => tester.getTopLeft(find.byKey(ValueKey(k))).dy;
        expect(y('log-from-course'), lessThan(y('course-note')));
        expect(y('course-note'), lessThan(y('advanced-section')));
      },
    );

    testWidgets(
      '201 (vừa tạo): mở tài liệu trong màn xem và làm mới danh sách tài liệu',
      (tester) async {
        final (api, docs) = await _pump(tester);
        final container = ProviderScope.containerOf(
          tester.element(find.byType(CourseDetailScreen)),
        );
        container.listen(documentsProvider(null), (_, _) {});
        await container.read(documentsProvider(null).future);
        expect(docs.lists, 1);

        await _tapNote(tester);
        await tester.pumpAndSettle();
        expect(api.noteCalls, [api.detail.course.id]);
        expect(
          find.text('GHI CHÚ KHÓA'),
          findsOneWidget,
          reason: 'màn tài liệu đã mở',
        );
        expect(docs.lists, 2, reason: 'tạo mới → làm mới danh sách');
      },
    );

    testWidgets('200 (đã có): vẫn mở đúng tài liệu, không làm mới danh sách', (
      tester,
    ) async {
      final (api, docs) = await _pump(
        tester,
        api: FakeHocTapApi()..noteCreated = false,
      );
      final container = ProviderScope.containerOf(
        tester.element(find.byType(CourseDetailScreen)),
      );
      container.listen(documentsProvider(null), (_, _) {});
      await container.read(documentsProvider(null).future);

      await _tapNote(tester);
      await tester.pumpAndSettle();
      expect(api.noteCalls, hasLength(1));
      expect(find.text('GHI CHÚ KHÓA'), findsOneWidget);
      expect(docs.lists, 1);
    });

    testWidgets(
      'đang gọi: nút bị vô hiệu và hiện vòng chờ, bấm thêm không gọi lần hai',
      (tester) async {
        final gate = Completer<void>();
        final (api, _) = await _pump(
          tester,
          api: FakeHocTapApi()..noteGate = gate,
        );
        await _tapNote(tester);
        await tester.pump();
        final button = find.byKey(const ValueKey('course-note'));
        expect(tester.widget<OutlinedButton>(button).onPressed, isNull);
        expect(
          find.descendant(
            of: button,
            matching: find.byType(CircularProgressIndicator),
          ),
          findsOneWidget,
        );
        await tester.tap(button, warnIfMissed: false);
        await tester.pump();
        expect(api.noteCalls, hasLength(1));
        gate.complete();
        await tester.pumpAndSettle();
        expect(find.text('GHI CHÚ KHÓA'), findsOneWidget, reason: 'xong thì mở tài liệu');
      },
    );

    testWidgets('404 course_not_found: báo "Không tìm thấy khóa này"', (
      tester,
    ) async {
      final (api, _) = await _pump(
        tester,
        api: FakeHocTapApi()
          ..noteError = apiError(404, {'error': 'course_not_found'}),
      );
      await _tapNote(tester);
      await tester.pumpAndSettle();
      expect(find.text('Không tìm thấy khóa này'), findsOneWidget);
      expect(api.noteCalls, hasLength(1));
      expect(find.text('GHI CHÚ KHÓA'), findsNothing);
    });

    testWidgets(
      'lỗi khác: thông báo chung, màn giữ nguyên, nút dùng lại được',
      (tester) async {
        final (_, _) = await _pump(
          tester,
          api: FakeHocTapApi()..noteError = apiError(500, 'boom'),
        );
        await _tapNote(tester);
        await tester.pumpAndSettle();
        expect(find.text('Không mở được ghi chú, thử lại'), findsOneWidget);
        expect(
          find.text('English Tenses 101'),
          findsOneWidget,
          reason: 'màn chi tiết còn nguyên',
        );
        expect(
          tester
              .widget<OutlinedButton>(find.byKey(const ValueKey('course-note')))
              .onPressed,
          isNotNull,
        );
      },
    );
  });
}
