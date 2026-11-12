import 'package:amber_flutter/features/amber_brain/providers/brain_status_provider.dart';
import 'package:amber_flutter/features/tang_kinh_cac/models/document.dart';
import 'package:amber_flutter/features/tang_kinh_cac/models/publication.dart';
import 'package:amber_flutter/features/tang_kinh_cac/models/reading_goal.dart';
import 'package:amber_flutter/features/tang_kinh_cac/providers/document_provider.dart';
import 'package:amber_flutter/features/tang_kinh_cac/providers/publication_provider.dart';
import 'package:amber_flutter/features/tang_kinh_cac/providers/tang_kinh_cac_provider.dart';
import 'package:amber_flutter/features/tang_kinh_cac/screens/ke_hoach_doc_screen.dart';
import 'package:amber_flutter/features/tang_kinh_cac/screens/sach_screen.dart';
import 'package:amber_flutter/features/tang_kinh_cac/screens/tai_lieu_screen.dart';
import 'package:amber_flutter/features/tang_kinh_cac/services/reading_goal_api.dart';
import 'package:amber_flutter/shared/theme/design_tokens.dart';
import 'package:amber_flutter/shared/widgets/list_frame.dart';
import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../amber_brain/fake_brain.dart';

Publication _book(String id, PublicationStatus status, {int? current, int? total, String? author}) => Publication(
  id: id,
  title: 'Sách $id',
  author: author,
  format: PublicationFormat.physical,
  status: status,
  currentPage: current,
  totalPages: total,
  tags: const [],
  dateAdded: DateTime(2026),
);

final _books = [
  _book('a', PublicationStatus.reading, current: 120, total: 300, author: 'Tác giả A'),
  _book('b', PublicationStatus.read),
  _book('c', PublicationStatus.toRead),
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

final _docs = [
  _doc('1', DocumentType.text, pinned: true, content: '# Tiêu đề\n- [ ] việc một'),
  _doc('2', DocumentType.text),
  _doc('3', DocumentType.checklist),
];

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

Future<void> _pump(
  WidgetTester tester,
  Widget screen, {
  List<Object> overrides = const [],
  Size size = const Size(390, 1400),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final router = GoRouter(
    initialLocation: '/x',
    routes: [
      GoRoute(path: '/tang-kinh-cac', builder: (_, _) => const Scaffold(body: Text('TÀNG KINH CÁC'))),
      GoRoute(path: '/x', builder: (_, _) => screen),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [brainStatusProvider.overrideWith(() => FixedBrainStatus()), ...overrides.cast()],
      child: MaterialApp.router(theme: ThemeData.dark(), routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

/// Lọc ở client như backend: null = tất cả.
final _bookOverride = publicationsProvider.overrideWith(
  (ref, status) async => status == null ? _books : _books.where((b) => b.status == status).toList(),
);
final _docOverride = documentsProvider.overrideWith(
  (ref, type) async => type == null ? _docs : _docs.where((d) => d.type == type).toList(),
);

Future<void> _chip(WidgetTester tester, String label) async {
  await tester.ensureVisible(find.byKey(ValueKey('chip-$label')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(ValueKey('chip-$label')));
  await tester.pumpAndSettle();
}

void main() {
  group('Sách', () {
    testWidgets('tổng quan đếm toàn tủ + cuốn đang đọc; khung có chip, "+ Thêm sách", mỗi cuốn một dòng', (tester) async {
      await _pump(tester, const SachScreen(), overrides: [_bookOverride]);
      expect(find.text('1 đang đọc · 1 đã đọc · 2 muốn đọc'), findsOneWidget);
      expect(find.text('Sách a · 120/300 trang'), findsOneWidget);
      expect(find.byKey(const ValueKey('add-book')), findsOneWidget);
      for (final id in ['a', 'b', 'c', 'd']) {
        expect(find.byKey(ValueKey('book-$id')), findsOneWidget);
      }
      // Cuốn đang đọc: nhãn vàng + thanh tiến độ + số trang.
      final a = find.byKey(const ValueKey('book-a'));
      expect(find.descendant(of: a, matching: find.byType(DesignProgressBar)), findsOneWidget);
      expect(find.descendant(of: a, matching: find.text('120 / 300 trang')), findsOneWidget);
      final pill = tester.widget<DesignPill>(find.descendant(of: a, matching: find.byType(DesignPill)));
      expect((pill.text, pill.color), ('Đang đọc', DesignColors.gold));
    });

    testWidgets('chip "Muốn đọc" chỉ còn 2 cuốn; tổng quan vẫn đếm cả tủ', (tester) async {
      await _pump(tester, const SachScreen(), overrides: [_bookOverride]);
      await _chip(tester, 'Muốn đọc');
      expect(find.byKey(const ValueKey('book-a')), findsNothing);
      expect(find.byKey(const ValueKey('book-c')), findsOneWidget);
      expect(find.byKey(const ValueKey('book-d')), findsOneWidget);
      expect(find.text('1 đang đọc · 1 đã đọc · 2 muốn đọc'), findsOneWidget);
    });

    testWidgets('chưa có sách trong mục → câu báo; ← về Tàng Kinh Các', (tester) async {
      await _pump(tester, const SachScreen(), overrides: [publicationsProvider.overrideWith((ref, _) async => const <Publication>[])]);
      expect(find.text('Chưa có sách nào trong mục này.'), findsOneWidget);
      expect(find.text('Chưa đọc cuốn nào'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('design-top-bar-back')));
      await tester.pumpAndSettle();
      expect(find.text('TÀNG KINH CÁC'), findsOneWidget);
    });
  });

  group('Tài liệu', () {
    testWidgets('tổng quan: tổng + đã ghim, theo loại; dòng có chữ Hán theo loại, xem trước bỏ ký hiệu markdown', (tester) async {
      await _pump(tester, const TaiLieuScreen(), overrides: [_docOverride]);
      expect(find.text('3 tài liệu · 1 đã ghim'), findsOneWidget);
      expect(find.text('2 ghi chú · 1 checklist'), findsOneWidget);
      final first = find.byKey(const ValueKey('doc-1'));
      expect(find.descendant(of: first, matching: find.text('文')), findsOneWidget);
      expect(find.descendant(of: first, matching: find.text('Tiêu đề việc một')), findsOneWidget);
      expect(find.descendant(of: first, matching: find.text('📌 ghim')), findsOneWidget);
      expect(find.descendant(of: find.byKey(const ValueKey('doc-3')), matching: find.text('單')), findsOneWidget);
      expect(find.byKey(const ValueKey('add-document')), findsOneWidget);
    });

    testWidgets('chip Checklist lọc còn 1 tài liệu', (tester) async {
      await _pump(tester, const TaiLieuScreen(), overrides: [_docOverride]);
      await _chip(tester, 'Checklist');
      expect(find.byKey(const ValueKey('doc-1')), findsNothing);
      expect(find.byKey(const ValueKey('doc-3')), findsOneWidget);
    });
  });

  group('Kế hoạch đọc', () {
    testWidgets('có mục tiêu: "2 / 12 sách" + thanh tiến độ, trang, ghi chú; form điền sẵn', (tester) async {
      await _pump(
        tester,
        const KeHoachDocScreen(),
        overrides: [
          readingGoalProvider.overrideWith(
            (ref, y) async => ReadingGoal(year: y, booksRead: 2, pagesRead: 340, targetBooks: 12, note: 'Đọc chậm'),
          ),
        ],
      );
      expect(tester.widget<Text>(find.byKey(const ValueKey('goal-progress'))).data, '2 / 12 sách');
      expect(find.byType(DesignProgressBar), findsOneWidget);
      expect(find.text('340 trang đã đọc'), findsOneWidget);
      expect(find.text('Đọc chậm'), findsNWidgets(2)); // tổng quan + ô ghi chú
      expect(find.text('12'), findsOneWidget); // ô số sách
    });

    testWidgets('chưa đặt mục tiêu: không có thanh tiến độ', (tester) async {
      await _pump(
        tester,
        const KeHoachDocScreen(),
        overrides: [readingGoalProvider.overrideWith((ref, y) async => ReadingGoal(year: y, booksRead: 3, pagesRead: 0))],
      );
      expect(tester.widget<Text>(find.byKey(const ValueKey('goal-progress'))).data, '3 sách · chưa đặt mục tiêu');
      expect(find.byType(DesignProgressBar), findsNothing);
    });

    testWidgets('Lưu → gửi số sách + ghi chú (rỗng = null), toast thành công; lỗi → toast lỗi', (tester) async {
      final api = _FakeGoalApi();
      await _pump(
        tester,
        const KeHoachDocScreen(),
        overrides: [
          readingGoalApiProvider.overrideWithValue(api),
          readingGoalProvider.overrideWith((ref, y) async => ReadingGoal(year: y, booksRead: 0, pagesRead: 0)),
        ],
      );
      await tester.enterText(find.byKey(const ValueKey('goal-books')), '20');
      await tester.tap(find.byKey(const ValueKey('goal-save')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 750));
      expect(api.saved, [(20, null)]);
      expect(find.byKey(const ValueKey('toast-success')), findsOneWidget);

      api.fail = true;
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('goal-save')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 750));
      expect(find.text('Không lưu được mục tiêu, thử lại nhé.'), findsOneWidget);
    });
  });

  testWidgets('320 px, chữ ×2,0: Sách, Tài liệu, Kế hoạch đọc không tràn', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    for (final screen in const [SachScreen(), TaiLieuScreen(), KeHoachDocScreen()]) {
      await tester.pumpWidget(const SizedBox());
      await _pump(
        tester,
        screen,
        size: const Size(320, 2400),
        overrides: [
          _bookOverride,
          _docOverride,
          readingGoalProvider.overrideWith((ref, y) async => ReadingGoal(year: y, booksRead: 2, pagesRead: 10, targetBooks: 5)),
        ],
      );
      expect(tester.takeException(), isNull, reason: '$screen');
    }
  });
}
