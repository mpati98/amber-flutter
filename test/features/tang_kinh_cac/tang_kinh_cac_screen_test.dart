import 'dart:async';

import 'package:amber_flutter/features/amber_brain/providers/brain_status_provider.dart';
import 'package:amber_flutter/features/du_lieu_huan_luyen/services/training_log_api.dart';
import 'package:amber_flutter/features/tang_kinh_cac/models/document.dart';
import 'package:amber_flutter/features/tang_kinh_cac/models/highlight.dart';
import 'package:amber_flutter/features/tang_kinh_cac/models/publication.dart';
import 'package:amber_flutter/features/tang_kinh_cac/models/reading_goal.dart';
import 'package:amber_flutter/features/tang_kinh_cac/providers/document_provider.dart';
import 'package:amber_flutter/features/tang_kinh_cac/providers/publication_provider.dart';
import 'package:amber_flutter/features/tang_kinh_cac/providers/tang_kinh_cac_provider.dart';
import 'package:amber_flutter/features/tang_kinh_cac/screens/tang_kinh_cac_screen.dart';
import 'package:amber_flutter/features/tang_kinh_cac/services/publication_api.dart';
import 'package:amber_flutter/features/tang_kinh_cac/services/reading_goal_api.dart';
import 'package:amber_flutter/features/tang_kinh_cac/utils/tkc_notices.dart';
import 'package:amber_flutter/features/tang_kinh_cac/widgets/book_view.dart';
import 'package:amber_flutter/features/tang_kinh_cac/widgets/document_viewer_modal.dart';
import 'package:amber_flutter/shared/router/app_router.dart' show tkcLegacyFloors;
import 'package:amber_flutter/shared/theme/design_tokens.dart';
import 'package:amber_flutter/shared/widgets/list_frame.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../amber_brain/fake_brain.dart';
import '../du_lieu_huan_luyen/screens_test.dart' as training show FakeApi;

Publication _book(String id, PublicationStatus status, {int? current, int? total, String? author, String? review, DateTime? added}) =>
    Publication(
      id: id,
      title: 'Sách $id',
      author: author,
      format: PublicationFormat.physical,
      status: status,
      currentPage: current,
      totalPages: total,
      review: review,
      tags: const [],
      dateAdded: added ?? DateTime(2026),
    );

/// Thứ tự server: mới thêm trước — "a" là mục mới nhất.
final _books = [
  _book('a', PublicationStatus.reading, current: 120, total: 300, author: 'Tác giả A', review: 'Rất hay'),
  _book('b', PublicationStatus.read),
  _book('c', PublicationStatus.toRead, author: 'Người viết C'),
  _book('d', PublicationStatus.toRead),
];

Document _doc(String id, DocumentType type, {bool pinned = false, String? content}) => Document(
  id: id,
  title: 'Tài liệu $id',
  type: type,
  content: content,
  tags: const [],
  pinned: pinned,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

/// Thứ tự server: mới cập nhật trước — "1" là mục mới nhất.
final _docs = [
  _doc('1', DocumentType.text, pinned: true, content: '# Tiêu đề\n- [ ] việc một'),
  _doc('2', DocumentType.text, content: 'Ghi chú về Flutter'),
  _doc('3', DocumentType.checklist),
];

class _FakePublicationApi extends PublicationApi {
  _FakePublicationApi() : super(Dio());
  final deleted = <String>[];

  @override
  Future<void> deletePublication(String id) async => deleted.add(id);
}

class _FakeGoalApi extends ReadingGoalApi {
  _FakeGoalApi() : super(Dio());

  final saved = <(int?, String?)>[];
  bool fail = false;

  @override
  Future<ReadingGoal> upsertReadingGoal(int year, {int? targetBooks, int? targetPages, String? note}) async {
    if (fail) throw DioException(requestOptions: RequestOptions(path: '/x'));
    saved.add((targetBooks, note));
    return ReadingGoal(year: year, booksRead: 2, pagesRead: 0, targetBooks: targetBooks, note: note);
  }
}

class _Harness {
  _Harness(this.router, this.publications);

  final GoRouter router;
  final _FakePublicationApi publications;

  String get location => router.routeInformationProvider.value.uri.toString();
}

/// Route giống app_router: /tang-kinh-cac đọc ?tang & ?id; route cũ của từng tầng redirect.
Future<_Harness> _pump(
  WidgetTester tester, {
  String location = '/tang-kinh-cac',
  Size size = const Size(1280, 720),
  ReadingGoal Function(int year)? goal,
  /// Highlight "Ôn lại" (null = chưa có highlight nào → Nội dung là mục mới nhất).
  ResurfacedHighlight? Function()? resurface,
  List<Override> extra = const [],
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final pubs = _FakePublicationApi();
  final router = GoRouter(
    initialLocation: location,
    routes: [
      GoRoute(path: '/', builder: (_, _) => const Scaffold(body: Text('HOME'))),
      GoRoute(
        path: '/tang-kinh-cac',
        redirect: (_, s) => tkcLegacyQueryRedirect(s.uri),
        builder: (_, s) => TangKinhCacScreen(tang: tkcFloorOf(s.uri.queryParameters['tang']), id: s.uri.queryParameters['id']),
        routes: [
          for (final (path, tang) in tkcLegacyFloors) GoRoute(path: path, redirect: (_, _) => tkcLocation(tang)),
          GoRoute(path: 'du-lieu-huan-luyen/:logId', redirect: (_, s) => tkcLocation(tkcTrainingFloor, id: s.pathParameters['logId'])),
        ],
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        brainStatusProvider.overrideWith(() => FixedBrainStatus()),
        publicationsProvider.overrideWith((ref, status) async => status == null ? _books : _books.where((b) => b.status == status).toList()),
        documentsProvider.overrideWith((ref, type) async => type == null ? _docs : _docs.where((d) => d.type == type).toList()),
        bookHighlightsProvider.overrideWith((ref, id) async => const []),
        resurfacedHighlightProvider.overrideWith((ref) async => resurface?.call()),
        readingGoalProvider.overrideWith(
          (ref, y) async => goal?.call(y) ?? ReadingGoal(year: y, booksRead: 2, pagesRead: 340, targetBooks: 12, note: 'Đọc chậm'),
        ),
        publicationApiProvider.overrideWithValue(pubs),
        trainingLogApiProvider.overrideWithValue(training.FakeApi()),
        ...extra,
      ],
      child: MaterialApp.router(theme: ThemeData.dark(), routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
  return _Harness(router, pubs);
}

final _list = find.byKey(const ValueKey('zone-frame-Danh sách'));
final _content = find.byKey(const ValueKey('zone-frame-Nội dung'));
Finder _inList(Finder f) => find.descendant(of: _list, matching: f);
Finder _inContent(Finder f) => find.descendant(of: _content, matching: f);

Future<void> _tapVisible(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

/// Mọi Scrollable DỌC phải nằm trong một ZoneFrame (khung thường hoặc modal mở rộng) — trang không cuộn.
void _expectNoPageScroll(WidgetTester tester) {
  final frames = find.byWidgetPredicate((w) => w.key is ValueKey<String> && (w.key! as ValueKey<String>).value.startsWith('zone-frame-'));
  var vertical = 0;
  for (final e in find.byType(Scrollable).evaluate()) {
    final s = e.widget as Scrollable;
    if (axisDirectionToAxis(s.axisDirection) != Axis.vertical) continue;
    vertical++;
    expect(find.ancestor(of: find.byWidget(s), matching: frames), findsWidgets, reason: 'Scrollable dọc ngoài ZoneFrame');
  }
  expect(vertical, greaterThan(0));
}

void main() {
  group('bố cục một màn', () {
    for (final size in const [Size(1920, 1080), Size(1280, 720), Size(800, 1000)]) {
      testWidgets('${size.width.toInt()}×${size.height.toInt()}: Danh sách | Nội dung tỉ lệ 2 / 3, mọi tầng không tràn, không cuộn trang', (tester) async {
        await _pump(tester, size: size);
        for (final n in [2, 1, 3]) {
          await _tapVisible(tester, find.byKey(ValueKey('tkc-tang-$n')));
          expect(tester.takeException(), isNull, reason: 'tầng $n');
          _expectNoPageScroll(tester);
          final l = tester.getRect(_list);
          final c = tester.getRect(_content);
          expect(l.left, 16);
          expect(c.right, closeTo(size.width - 16, 0.01));
          expect(c.width / l.width, closeTo(1.5, 0.05), reason: 'tầng $n');
          expect(c.bottom, l.bottom);
          expect(l.bottom, lessThanOrEqualTo(size.height - 16));
        }
      });
    }

    testWidgets('390×844: chỉ Danh sách; chạm một mục → Nội dung toàn màn (push), ← về danh sách', (tester) async {
      final h = await _pump(tester, size: const Size(390, 844), location: '/tang-kinh-cac?tang=1');
      expect(_list, findsOneWidget);
      expect(_content, findsNothing);
      expect(tester.widget<FrameTile>(find.byKey(const ValueKey('book-a'))).borderColor, isNot(DesignColors.gold), reason: 'điện thoại: không có mục "đang mở"');
      _expectNoPageScroll(tester);

      await tester.tap(find.byKey(const ValueKey('book-c')));
      await tester.pumpAndSettle();
      // push của go_router không đổi URL hiển thị — kiểm qua tham số của màn trên cùng.
      final top = tester.widget<TangKinhCacScreen>(find.byType(TangKinhCacScreen));
      expect((top.tang, top.id), (1, 'c'));
      expect(h.router.canPop(), isTrue, reason: 'điện thoại: push, ← quay lại danh sách');
      expect(_content, findsOneWidget);
      expect(_list, findsNothing);
      expect(find.byKey(const ValueKey('tkc-tang-1')), findsNothing, reason: 'Nội dung toàn màn không có thanh chọn tầng');
      expect(_inContent(find.byKey(const ValueKey('book-view-c'))), findsOneWidget);
      expect(tester.getRect(_content).bottom, closeTo(844 - 16, 0.5));
      expect(tester.takeException(), isNull);
      _expectNoPageScroll(tester);

      await tester.tap(find.byKey(const ValueKey('design-top-bar-back')));
      await tester.pumpAndSettle();
      expect(_list, findsOneWidget);
      expect(h.router.canPop(), isFalse);
      expect(h.location, '/tang-kinh-cac?tang=1');
    });

    testWidgets('390: mở thẳng link có ?id → Nội dung toàn màn; ← về danh sách của tầng (không có trang để pop)', (tester) async {
      final h = await _pump(tester, size: const Size(390, 844), location: '/tang-kinh-cac?tang=2&id=3');
      expect(_inContent(find.byType(DocumentViewerModal)), findsOneWidget);
      expect(tester.widget<DocumentViewerModal>(find.byType(DocumentViewerModal)).doc.id, '3');
      await tester.tap(find.byKey(const ValueKey('design-top-bar-back')));
      await tester.pumpAndSettle();
      expect(h.location, '/tang-kinh-cac?tang=2');
      expect(_list, findsOneWidget);
    });

    testWidgets('320 px, chữ ×2,0: mọi tầng (danh sách + nội dung) không tràn', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      for (final (tang, id) in const [(1, 'a'), (2, '1'), (3, 'l1')]) {
        await tester.pumpWidget(const SizedBox());
        await _pump(tester, size: const Size(320, 640), location: tkcLocation(tang));
        expect(tester.takeException(), isNull, reason: 'danh sách tầng $tang');
        await tester.pumpWidget(const SizedBox());
        await _pump(tester, size: const Size(320, 640), location: tkcLocation(tang, id: id));
        expect(tester.takeException(), isNull, reason: 'nội dung tầng $tang');
      }
    });
  });

  group('tầng và mục qua query', () {
    test('tkcFloorOf: 1–3 hợp lệ, còn lại về tầng 2; ?tang=4 cũ → ?tang=3 (giữ id)', () {
      expect([for (final r in ['1', '2', '3', '4', '0', 'x', null]) tkcFloorOf(r)], [1, 2, 3, 2, 2, 2, 2]);
      expect(tkcLocation(3, id: 'l1'), '/tang-kinh-cac?tang=3&id=l1');
      String? r(String u) => tkcLegacyQueryRedirect(Uri.parse(u));
      expect(r('/tang-kinh-cac?tang=4'), '/tang-kinh-cac?tang=3');
      expect(r('/tang-kinh-cac?tang=4&id=l2'), '/tang-kinh-cac?tang=3&id=l2');
      expect(r('/tang-kinh-cac?tang=3'), isNull, reason: '?tang=3 mới = Huấn luyện');
      expect(r('/tang-kinh-cac?tang=1&id=a'), isNull);
    });

    testWidgets('mặc định tầng 2; chưa chọn → Nội dung là tài liệu mới nhất', (tester) async {
      await _pump(tester);
      expect(find.byKey(const ValueKey('doc-1')), findsOneWidget);
      expect(tester.widget<DocumentViewerModal>(_inContent(find.byType(DocumentViewerModal))).doc.id, '1');
      expect(tester.widget<FrameRow>(find.byKey(const ValueKey('doc-1'))).borderColor, DesignColors.gold);
    });

    testWidgets('?tang=1&id=c mở đúng cuốn; ?tang=3&id=l2 mở đúng dòng nhật ký', (tester) async {
      await _pump(tester, location: '/tang-kinh-cac?tang=1&id=c');
      expect(_inContent(find.byKey(const ValueKey('book-view-c'))), findsOneWidget);
      expect(tester.widget<FrameTile>(find.byKey(const ValueKey('book-c'))).borderColor, DesignColors.gold);
      expect(tester.widget<FrameTile>(find.byKey(const ValueKey('book-a'))).borderColor, isNot(DesignColors.gold));

      await tester.pumpWidget(const SizedBox());
      await _pump(tester, location: '/tang-kinh-cac?tang=3&id=l2');
      expect(_inContent(find.byKey(const ValueKey('log-view-l2'))), findsOneWidget);
    });

    testWidgets('?id không có → câu báo trong Nội dung, danh sách vẫn dùng được', (tester) async {
      await _pump(tester, location: '/tang-kinh-cac?tang=1&id=khong-co');
      expect(_inContent(find.text('Không tìm thấy cuốn sách này.')), findsOneWidget);
      expect(find.byKey(const ValueKey('book-a')), findsOneWidget);
    });

    testWidgets('chọn một mục → ?id= đổi tại chỗ (go), Nội dung đổi theo', (tester) async {
      final h = await _pump(tester, location: '/tang-kinh-cac?tang=1');
      expect(_inContent(find.byKey(const ValueKey('book-view-a'))), findsOneWidget, reason: 'mục mới nhất');
      await tester.tap(find.byKey(const ValueKey('book-b')));
      await tester.pumpAndSettle();
      expect(h.location, '/tang-kinh-cac?tang=1&id=b');
      expect(_inContent(find.byKey(const ValueKey('book-view-b'))), findsOneWidget);
      expect(h.router.canPop(), isFalse, reason: 'màn rộng không chồng trang');
    });

    testWidgets('đổi tầng: đúng danh sách từng tầng; quay lại giữ chip lọc và ô tìm của tầng đó', (tester) async {
      final h = await _pump(tester, location: '/tang-kinh-cac?tang=1');
      await _tapVisible(tester, find.byKey(const ValueKey('chip-Muốn đọc')));
      expect(_inList(find.byType(BookRow)), findsNWidgets(2));
      await tester.enterText(find.byKey(const ValueKey('tkc-search')), 'người viết');
      await tester.pumpAndSettle();
      expect(_inList(find.byType(BookRow)), findsOneWidget);

      await _tapVisible(tester, find.byKey(const ValueKey('tkc-tang-2')));
      expect(h.location, '/tang-kinh-cac?tang=2');
      expect(_inList(find.byType(BookRow)), findsNothing);
      expect(_inList(find.byKey(const ValueKey('doc-2'))), findsOneWidget);
      expect(tester.widget<TextField>(find.byKey(const ValueKey('tkc-search'))).controller!.text, '', reason: 'ô tìm riêng từng tầng');

      await _tapVisible(tester, find.byKey(const ValueKey('tkc-tang-3')));
      expect(_inList(find.byKey(const ValueKey('log-l1'))), findsOneWidget);
      expect(_inList(find.byKey(const ValueKey('doc-2'))), findsNothing);

      await _tapVisible(tester, find.byKey(const ValueKey('tkc-tang-1')));
      expect(_inList(find.byKey(const ValueKey('book-c'))), findsOneWidget);
      expect(_inList(find.byType(BookRow)), findsOneWidget, reason: 'giữ chip "Muốn đọc" + ô tìm "người viết"');
    });

    testWidgets('tìm tài liệu theo nội dung; chip Checklist lọc còn 1', (tester) async {
      await _pump(tester);
      await tester.enterText(find.byKey(const ValueKey('tkc-search')), 'flutter');
      await tester.pumpAndSettle();
      expect(_inList(find.byKey(const ValueKey('doc-2'))), findsOneWidget);
      expect(_inList(find.byKey(const ValueKey('doc-1'))), findsNothing);
      await tester.enterText(find.byKey(const ValueKey('tkc-search')), '');
      await _tapVisible(tester, find.byKey(const ValueKey('chip-Checklist')));
      expect(_inList(find.byKey(const ValueKey('doc-3'))), findsOneWidget);
      expect(_inList(find.byKey(const ValueKey('doc-2'))), findsNothing);
    });
  });

  group('Sách (tầng 1)', () {
    testWidgets('Nội dung: tên, tác giả, trạng thái, tiến độ trang, review; "Sửa" mở form có sẵn', (tester) async {
      await _pump(tester, location: '/tang-kinh-cac?tang=1&id=a');
      final v = find.byKey(const ValueKey('book-view-a'));
      expect(find.descendant(of: v, matching: find.text('Tác giả A')), findsOneWidget);
      expect(find.descendant(of: v, matching: find.text('120 / 300 trang')), findsOneWidget);
      expect(find.descendant(of: v, matching: find.text('Rất hay')), findsOneWidget);
      expect(find.descendant(of: v, matching: find.text('Chưa có highlight nào.')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('book-edit')));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'Sách a'), findsOneWidget, reason: 'form BookDetailModal');
    });

    testWidgets('Xoá: hỏi lại; đồng ý → gọi API, bỏ ?id (Nội dung về mục mới nhất)', (tester) async {
      final h = await _pump(tester, location: '/tang-kinh-cac?tang=1&id=c');
      await tester.tap(find.byKey(const ValueKey('book-delete')));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Huỷ'));
      await tester.pumpAndSettle();
      expect(h.publications.deleted, isEmpty);
      await tester.tap(find.byKey(const ValueKey('book-delete')));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Xóa'));
      await tester.pumpAndSettle();
      expect(h.publications.deleted, ['c']);
      expect(h.location, '/tang-kinh-cac?tang=1');
    });

    testWidgets('"+ Thêm" ở tầng 1 mở form Thêm sách, ở tầng 2 mở form lưu tài liệu; tầng 3 không có', (tester) async {
      await _pump(tester, location: '/tang-kinh-cac?tang=1');
      await tester.tap(find.byKey(const ValueKey('tkc-add')));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'Thêm sách'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await _pump(tester);
      await tester.tap(find.byKey(const ValueKey('tkc-add')));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'Lưu tài liệu mới'), findsOneWidget);

      for (final n in [3]) {
        await tester.pumpWidget(const SizedBox());
        await _pump(tester, location: tkcLocation(n));
        expect(find.byKey(const ValueKey('tkc-add')), findsNothing, reason: 'tầng $n');
      }
    });
  });

  group('Tài liệu (tầng 2)', () {
    testWidgets('Nội dung là trình xem tài liệu nhúng (không có nút đóng); mở rộng toàn màn, Esc đóng', (tester) async {
      await _pump(tester, location: '/tang-kinh-cac?tang=2&id=1');
      expect(_inContent(find.byTooltip('Đóng')), findsNothing);
      expect(_inContent(find.text('Bỏ ghim')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('zone-expand-Nội dung')));
      await tester.pumpAndSettle();
      final modal = find.byKey(const ValueKey('zone-expanded-Nội dung'));
      expect(find.descendant(of: modal, matching: find.byType(DocumentViewerModal)), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(modal, findsNothing);
    });
  });

  group('mục tiêu đọc ở đầu tầng Sách (trước là tầng Kế hoạch đọc)', () {
    testWidgets('đầu cố định khung Danh sách tầng Sách: "2 / 12 sách" + thanh, trang + ghi chú, nút "Sửa mục tiêu"; tầng khác không có', (tester) async {
      await _pump(tester, location: '/tang-kinh-cac?tang=1');
      final strip = _inList(find.byKey(const ValueKey('reading-goal-strip')));
      expect(strip, findsOneWidget);
      expect(tester.getTopLeft(strip).dy, lessThan(tester.getTopLeft(find.byKey(const ValueKey('tkc-search'))).dy), reason: 'trên ô tìm');
      expect(find.ancestor(of: strip, matching: find.byWidgetPredicate((w) => w is SingleChildScrollView && w.padding == const EdgeInsets.only(right: 8, bottom: 8))), findsOneWidget,
          reason: 'nằm trong phần đầu cố định của khung, không trong vùng cuộn danh sách');
      expect(tester.widget<Text>(find.byKey(const ValueKey('goal-progress'))).data, '2 / 12 sách');
      expect(find.descendant(of: strip, matching: find.byType(DesignProgressBar)), findsOneWidget);
      expect(tester.widget<Text>(find.byKey(const ValueKey('goal-pages'))).data, '340 trang đã đọc · Đọc chậm');
      expect(find.text('Sửa mục tiêu'), findsOneWidget);
      for (final n in [2, 3]) {
        await _tapVisible(tester, find.byKey(ValueKey('tkc-tang-$n')));
        expect(find.byKey(const ValueKey('reading-goal-strip')), findsNothing, reason: 'tầng $n');
      }
    });

    testWidgets('chưa đặt mục tiêu: không có thanh, nút "Đặt mục tiêu"', (tester) async {
      await _pump(tester, location: '/tang-kinh-cac?tang=1', goal: (y) => ReadingGoal(year: y, booksRead: 3, pagesRead: 0));
      expect(tester.widget<Text>(find.byKey(const ValueKey('goal-progress'))).data, '3 sách · chưa đặt mục tiêu');
      expect(find.descendant(of: find.byKey(const ValueKey('reading-goal-strip')), matching: find.byType(DesignProgressBar)), findsNothing);
      expect(find.text('Đặt mục tiêu'), findsOneWidget);
    });

    testWidgets('nút mở form (modal) điền sẵn; Lưu → gửi số sách + ghi chú (rỗng = null), toast, đóng form; lỗi → toast, form còn mở', (tester) async {
      final api = _FakeGoalApi();
      await _pump(
        tester,
        location: '/tang-kinh-cac?tang=1',
        goal: (y) => ReadingGoal(year: y, booksRead: 0, pagesRead: 0, targetBooks: 12, note: 'Đọc chậm'),
        extra: [readingGoalApiProvider.overrideWithValue(api)],
      );
      await tester.tap(find.byKey(const ValueKey('goal-edit')));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'Mục tiêu đọc ${DateTime.now().year}'), findsOneWidget);
      expect(find.text('12'), findsOneWidget, reason: 'điền sẵn số sách');
      await tester.enterText(find.byKey(const ValueKey('goal-books')), '20');
      await tester.enterText(find.byKey(const ValueKey('goal-note')), '');
      await tester.tap(find.byKey(const ValueKey('goal-save')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 750));
      expect(api.saved, [(20, null)]);
      expect(find.byKey(const ValueKey('toast-success')), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('goal-save')), findsNothing, reason: 'lưu xong đóng form');

      api.fail = true;
      await tester.tap(find.byKey(const ValueKey('goal-edit')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('goal-save')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 750));
      // SnackBar của ScaffoldMessenger vẽ trên mọi Scaffold đang có (form toàn màn + màn bên dưới) — người dùng thấy cái trên cùng.
      expect(find.text('Không lưu được mục tiêu, thử lại nhé.'), findsWidgets);
      expect(find.byKey(const ValueKey('goal-save')), findsOneWidget);
    });
  });

  group('"Ôn lại" khi chưa chọn mục', () {
    final quote = ResurfacedHighlight.fromJson({
      'id': 'h1',
      'publicationId': 'c',
      'quote': 'Đọc sách là sống thêm nhiều đời',
      'page': 42,
      'createdAt': '2026-11-01T00:00:00.000Z',
      'publication': {'title': 'Sách c', 'author': 'Người viết C'},
    });

    testWidgets('có highlight: Nội dung là câu trích + nguồn (thay mục mới nhất), danh sách không đánh dấu mục nào', (tester) async {
      await _pump(tester, resurface: () => quote);
      final card = _inContent(find.byKey(const ValueKey('tkc-resurface')));
      expect(card, findsOneWidget);
      expect(find.textContaining('Đọc sách là sống thêm nhiều đời'), findsOneWidget);
      expect(find.text('— Sách c, Người viết C · trang 42'), findsOneWidget);
      expect(_inContent(find.byType(DocumentViewerModal)), findsNothing);
      expect(tester.widget<FrameRow>(find.byKey(const ValueKey('doc-1'))).borderColor, isNot(DesignColors.gold));
    });

    testWidgets('chạm câu trích → mở cuốn gốc ở tầng Sách; "Highlight khác" rút lại', (tester) async {
      var calls = 0;
      final h = await _pump(tester, resurface: () { calls++; return quote; });
      expect(calls, 1);
      await tester.tap(find.byKey(const ValueKey('resurface-next')));
      await tester.pumpAndSettle();
      expect(calls, 2);
      await tester.tap(find.byKey(const ValueKey('resurface-open')));
      await tester.pumpAndSettle();
      expect(h.location, '/tang-kinh-cac?tang=1&id=c');
      expect(_inContent(find.byKey(const ValueKey('book-view-c'))), findsOneWidget);
    });

    testWidgets('đã chọn mục (?id) hoặc tầng Huấn luyện → không có "Ôn lại"', (tester) async {
      await _pump(tester, location: '/tang-kinh-cac?tang=2&id=3', resurface: () => quote);
      expect(find.byKey(const ValueKey('tkc-resurface')), findsNothing);
      await tester.pumpWidget(const SizedBox());
      await _pump(tester, location: '/tang-kinh-cac?tang=3', resurface: () => quote);
      expect(find.byKey(const ValueKey('tkc-resurface')), findsNothing);
      expect(_inContent(find.byKey(const ValueKey('log-view-l1'))), findsOneWidget);
    });

    testWidgets('chưa có highlight nào → mục mới nhất như cũ', (tester) async {
      await _pump(tester, location: '/tang-kinh-cac?tang=1');
      expect(find.byKey(const ValueKey('tkc-resurface')), findsNothing);
      expect(_inContent(find.byKey(const ValueKey('book-view-a'))), findsOneWidget);
    });
  });

  group('route cũ redirect (go và push)', () {
    for (final (old, to) in const [
      ('/tang-kinh-cac/sach', '/tang-kinh-cac?tang=1'),
      ('/tang-kinh-cac/tai-lieu', '/tang-kinh-cac?tang=2'),
      ('/tang-kinh-cac/ke-hoach-doc', '/tang-kinh-cac?tang=1'),
      ('/tang-kinh-cac/du-lieu-huan-luyen', '/tang-kinh-cac?tang=3'),
      ('/tang-kinh-cac/du-lieu-huan-luyen/l2', '/tang-kinh-cac?tang=3&id=l2'),
      ('/tang-kinh-cac?tang=4', '/tang-kinh-cac?tang=3'),
      ('/tang-kinh-cac?tang=4&id=l2', '/tang-kinh-cac?tang=3&id=l2'),
    ]) {
      testWidgets('$old → $to', (tester) async {
        final h = await _pump(tester, location: '/');
        h.router.go(old);
        await tester.pumpAndSettle();
        expect(h.location, to, reason: 'go');
        expect(find.byType(TangKinhCacScreen), findsOneWidget);

        h.router.go('/');
        await tester.pumpAndSettle();
        unawaited(h.router.push(old));
        await tester.pumpAndSettle();
        final screen = tester.widget<TangKinhCacScreen>(find.byType(TangKinhCacScreen));
        final want = Uri.parse(to).queryParameters;
        expect((screen.tang, screen.id), (int.parse(want['tang']!), want['id']), reason: 'push');
      });
    }
  });

  group('popup Tàng Kinh Các trên cảnh 3D', () {
    test('buildTkcNotices: mục mới 7 ngày, mục tiêu năm, cuốn đang đọc; thiếu nguồn thì bỏ phần đó', () {
      final now = DateTime(2026, 11, 21);
      final n = buildTkcNotices(
        now: now,
        books: [
          _book('a', PublicationStatus.reading, current: 120, total: 300, added: DateTime(2026, 11, 19)),
          _book('b', PublicationStatus.read, added: DateTime(2026, 10, 1)),
        ],
        docs: [Document(id: 'x', title: 'X', type: DocumentType.text, tags: const [], pinned: false, createdAt: DateTime(2026, 11, 20), updatedAt: now)],
        goal: const ReadingGoal(year: 2026, booksRead: 3, pagesRead: 0, targetBooks: 12),
      );
      expect(n, [
        {'text': '2 mục mới tuần này', 'lvl': 'ok'},
        {'text': 'Đọc 3 / 12 sách năm 2026', 'lvl': 'info'},
        {'text': 'Đang đọc: Sách a · 120/300 trang', 'lvl': 'info'},
      ]);
      expect(buildTkcNotices(now: now, goal: const ReadingGoal(year: 2026, booksRead: 0, pagesRead: 0)), [
        {'text': 'Chưa đặt mục tiêu đọc năm 2026', 'lvl': 'warn'},
      ]);
      expect(buildTkcNotices(now: now), isEmpty);
    });
  });
}
