import 'package:amber_flutter/features/tang_kinh_cac/models/document.dart';
import 'package:amber_flutter/features/tang_kinh_cac/services/document_api.dart';
import 'package:amber_flutter/features/tang_kinh_cac/widgets/document_viewer_modal.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/services/hoc_tap_api.dart';
import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../tra_dinh/hoc_tap/hoc_tap_test_support.dart';

Map<String, dynamic> _json({
  Object? courseId = 'c1',
  Object? courseTitle = 'English Tenses 101',
  String type = 'TEXT',
  String content = '# English Tenses 101\n\n',
}) => {
  'id': 'doc-1',
  'title': 'English Tenses 101 — Ghi chú',
  'type': type,
  'content': content,
  'tags': <String>[],
  'pinned': false,
  'createdAt': '2026-11-09 10:00:00',
  'updatedAt': '2026-11-09 10:00:00',
  'studyCourseId': ?courseId,
  'studyCourseTitle': ?courseTitle,
  'trườngLạ': 1,
};

class _FakeDocumentApi extends DocumentApi {
  _FakeDocumentApi() : super(Dio());

  final updates = <({String id, String? content})>[];
  Object? updateError;

  @override
  Future<Document> updateDocument(
    String id, {
    String? title,
    String? content,
    String? attachmentUrl,
    List<String>? tags,
    bool? pinned,
    String? sourceUrl,
    String? topicId,
  }) async {
    updates.add((id: id, content: content));
    if (updateError case final e?) throw e;
    return Document.fromJson(_json(content: content ?? ''));
  }

  @override
  Future<List<Document>> getDocuments({
    DocumentType? type,
    String? search,
    bool? pinned,
    String? topicId,
  }) async => [];
}

Future<_FakeDocumentApi> _openViewer(
  WidgetTester tester,
  Document doc, {
  FakeHocTapApi? hocTap,
}) async {
  tester.view.physicalSize = const Size(390, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final docs = _FakeDocumentApi();
  final visited = <String>[];
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, _) => Scaffold(
          body: TextButton(
            key: const ValueKey('open'),
            onPressed: () => showDocumentViewerModal(context, doc),
            child: const Text('mở'),
          ),
        ),
      ),
      GoRoute(
        path: '/tra-dinh/hoc-tap/courses/:id',
        builder: (_, state) {
          visited.add(state.uri.toString());
          return Scaffold(body: Text('stub ${state.uri}'));
        },
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        documentApiProvider.overrideWithValue(docs),
        hocTapApiProvider.overrideWithValue(hocTap ?? FakeHocTapApi()),
      ],
      child: MaterialApp.router(theme: ThemeData.dark(), routerConfig: router),
    ),
  );
  await tester.tap(find.byKey(const ValueKey('open')));
  await tester.pumpAndSettle();
  _visited = visited;
  return docs;
}

List<String> _visited = [];

void main() {
  group('Document: studyCourseId / studyCourseTitle', () {
    test('có cả hai (và bỏ qua trường lạ)', () {
      final d = Document.fromJson(_json());
      expect(
        (d.studyCourseId, d.studyCourseTitle),
        ('c1', 'English Tenses 101'),
      );
    });

    test('null → tài liệu thường', () {
      final d = Document.fromJson({
        ..._json(),
        'studyCourseId': null,
        'studyCourseTitle': null,
      });
      expect((d.studyCourseId, d.studyCourseTitle), (null, null));
    });

    test('backend cũ thiếu hai trường → null, không lỗi', () {
      final d = Document.fromJson(_json(courseId: null, courseTitle: null));
      expect((d.studyCourseId, d.studyCourseTitle), (null, null));
    });
  });

  group('màn tài liệu', () {
    testWidgets(
      'tài liệu thường: không nhãn, không chip, không nút Sửa / Thêm tóm tắt video',
      (tester) async {
        await _openViewer(
          tester,
          Document.fromJson(_json(courseId: null, courseTitle: null)),
        );
        expect(find.byKey(const ValueKey('course-label')), findsNothing);
        expect(find.byKey(const ValueKey('course-chip')), findsNothing);
        expect(find.byKey(const ValueKey('add-video-summary')), findsNothing);
        expect(find.byKey(const ValueKey('note-edit')), findsNothing);
      },
    );

    testWidgets(
      'tài liệu gắn khóa: nhãn "GHI CHÚ KHÓA" và chip "<tên khóa> ›" ở đầu màn',
      (tester) async {
        await _openViewer(tester, Document.fromJson(_json()));
        expect(find.text('GHI CHÚ KHÓA'), findsOneWidget);
        expect(find.text('English Tenses 101 ›'), findsOneWidget);
        expect(
          tester.getTopLeft(find.byKey(const ValueKey('course-label'))).dy,
          lessThan(
            tester.getTopLeft(find.text('English Tenses 101 — Ghi chú')).dy,
          ),
        );
      },
    );

    testWidgets('bấm chip: đóng sheet, mở chi tiết khóa', (tester) async {
      await _openViewer(tester, Document.fromJson(_json()));
      await tester.tap(find.byKey(const ValueKey('course-chip')));
      await tester.pumpAndSettle();
      expect(_visited, ['/tra-dinh/hoc-tap/courses/c1']);
      expect(find.text('GHI CHÚ KHÓA'), findsNothing);
    });

    testWidgets(
      'khóa không còn truy cập được (404): báo "Khóa này đã được xoá", ở lại màn tài liệu, không điều hướng',
      (tester) async {
        final hocTap = FakeHocTapApi()
          ..detailError = apiError(404, {'error': 'course_not_found'});
        await _openViewer(tester, Document.fromJson(_json()), hocTap: hocTap);
        await tester.tap(find.byKey(const ValueKey('course-chip')));
        await tester.pumpAndSettle();
        expect(find.text('Khóa này đã được xoá'), findsOneWidget);
        expect(_visited, isEmpty);
        expect(
          find.text('GHI CHÚ KHÓA'),
          findsOneWidget,
          reason: 'sheet vẫn mở, không kẹt màn trắng',
        );
      },
    );

    testWidgets('title khóa thiếu nhưng có id: chip hiện nhãn trung tính', (
      tester,
    ) async {
      await _openViewer(tester, Document.fromJson(_json(courseTitle: null)));
      expect(find.text('Khóa học ›'), findsOneWidget);
    });

    testWidgets(
      '"Thêm tóm tắt video": vào chế độ sửa, nối đúng đề mục, con trỏ ở cuối, KHÔNG tự lưu; Lưu gửi đúng nội dung',
      (tester) async {
        final docs = await _openViewer(tester, Document.fromJson(_json()));
        await tester.tap(find.byKey(const ValueKey('add-video-summary')));
        await tester.pumpAndSettle();
        const expected = '# English Tenses 101\n\n\n\n## Module _ · Video _ — ';
        final field = tester.widget<TextField>(
          find.byKey(const ValueKey('note-editor')),
        );
        expect(field.controller!.text, expected);
        expect(
          field.controller!.selection,
          const TextSelection.collapsed(offset: expected.length),
        );
        expect(docs.updates, isEmpty, reason: 'không tự lưu');
        expect(
          find.byKey(const ValueKey('add-video-summary')),
          findsNothing,
          reason: 'đang sửa',
        );

        await tester.enterText(
          find.byKey(const ValueKey('note-editor')),
          '$expected tóm tắt',
        );
        await tester.tap(find.byKey(const ValueKey('note-save')));
        await tester.pumpAndSettle();
        expect(docs.updates.single, (
          id: 'doc-1',
          content: '$expected tóm tắt',
        ));
        expect(find.byKey(const ValueKey('note-editor')), findsNothing);
        expect(
          find.textContaining('tóm tắt', findRichText: true),
          findsWidgets,
        );
      },
    );

    testWidgets(
      'chỉ một nút vàng ("Sửa"); "Thêm tóm tắt video" là nút viền; Sửa mở editor với con trỏ ở cuối nội dung',
      (tester) async {
        await _openViewer(tester, Document.fromJson(_json()));
        expect(find.byType(FilledButton), findsOneWidget);
        expect(find.byKey(const ValueKey('note-edit')), findsOneWidget);
        expect(
          find.descendant(
            of: find.byKey(const ValueKey('add-video-summary')),
            matching: find.text('Thêm tóm tắt video'),
          ),
          findsOneWidget,
        );
        expect(
          tester.widget(find.byKey(const ValueKey('add-video-summary'))),
          isA<OutlinedButton>(),
        );
        await tester.tap(find.byKey(const ValueKey('note-edit')));
        await tester.pumpAndSettle();
        final c = tester
            .widget<TextField>(find.byKey(const ValueKey('note-editor')))
            .controller!;
        expect(c.selection.baseOffset, c.text.length);
        await tester.tap(find.byKey(const ValueKey('note-cancel')));
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('note-editor')), findsNothing);
      },
    );

    testWidgets('lưu lỗi: báo lỗi, giữ chế độ sửa và nội dung đang gõ', (
      tester,
    ) async {
      final docs = await _openViewer(tester, Document.fromJson(_json()));
      docs.updateError = apiError(500, 'x');
      await tester.tap(find.byKey(const ValueKey('note-edit')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('note-editor')),
        'đang gõ dở',
      );
      await tester.tap(find.byKey(const ValueKey('note-save')));
      await tester.pumpAndSettle();
      expect(find.text('Không lưu được ghi chú.'), findsOneWidget);
      expect(
        tester
            .widget<TextField>(find.byKey(const ValueKey('note-editor')))
            .controller!
            .text,
        'đang gõ dở',
      );
    });
  });
}
