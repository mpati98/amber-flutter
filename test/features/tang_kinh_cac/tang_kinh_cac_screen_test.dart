import 'package:amber_flutter/features/amber_brain/providers/brain_status_provider.dart';
import 'package:amber_flutter/features/du_lieu_huan_luyen/models/training_log.dart';
import 'package:amber_flutter/features/du_lieu_huan_luyen/providers/training_log_provider.dart';
import 'package:amber_flutter/features/tang_kinh_cac/models/document.dart';
import 'package:amber_flutter/features/tang_kinh_cac/models/highlight.dart';
import 'package:amber_flutter/features/tang_kinh_cac/models/publication.dart';
import 'package:amber_flutter/features/tang_kinh_cac/models/reading_goal.dart';
import 'package:amber_flutter/features/tang_kinh_cac/providers/document_provider.dart';
import 'package:amber_flutter/features/tang_kinh_cac/providers/publication_provider.dart';
import 'package:amber_flutter/features/tang_kinh_cac/providers/tang_kinh_cac_provider.dart';
import 'package:amber_flutter/features/tang_kinh_cac/screens/tang_kinh_cac_screen.dart';
import 'package:amber_flutter/shared/widgets/list_frame.dart';
import 'package:amber_flutter/shared/widgets/overview_block.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../amber_brain/fake_brain.dart';

final _highlight = ResurfacedHighlight(
  highlight: Highlight(id: 'h1', publicationId: 'b1', quote: 'Đọc để sống chậm lại.', createdAt: DateTime(2026, 11)),
  source: const HighlightSource(title: 'Sách A', author: 'Tác giả B'),
);

Future<void> _pump(WidgetTester tester, {ResurfacedHighlight? highlight, Size size = const Size(390, 1400)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final router = GoRouter(
    initialLocation: '/tang-kinh-cac',
    routes: [
      GoRoute(
        path: '/tang-kinh-cac',
        builder: (_, _) => const TangKinhCacScreen(),
        routes: [
          for (final p in ['sach', 'tai-lieu', 'ke-hoach-doc', 'du-lieu-huan-luyen'])
            GoRoute(path: p, builder: (_, _) => Scaffold(body: Text('ĐÍCH $p'))),
        ],
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        brainStatusProvider.overrideWith(() => FixedBrainStatus()),
        resurfacedHighlightProvider.overrideWith((ref) async => highlight),
        publicationsProvider.overrideWith((ref, _) async => const <Publication>[]),
        documentsProvider.overrideWith((ref, _) async => const <Document>[]),
        readingGoalProvider.overrideWith((ref, year) async => ReadingGoal(year: year, booksRead: 2, pagesRead: 0, targetBooks: 12)),
        trainingStatsProvider.overrideWith((ref) async => const TrainingStats(total: 5, eligible: 3, byAgent: [])),
      ],
      child: MaterialApp.router(theme: ThemeData.dark(), routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('bố cục: Tổng quan (Sách, Tài liệu, Kế hoạch đọc, Huấn luyện) → khung 4 tầng đúng thứ tự → gợi ý', (tester) async {
    await _pump(tester);
    expect(find.text('Tàng Kinh Các'), findsOneWidget);
    expect(find.byType(OverviewRow), findsNWidgets(4));
    expect(find.text('0 đang đọc · 0 đã đọc · 0 muốn đọc'), findsOneWidget);
    expect(find.text('0 tài liệu đã lưu'), findsOneWidget);
    expect(find.text('2/12 sách năm ${DateTime.now().year}'), findsOneWidget);
    expect(find.text('3 mẫu đủ điều kiện · 5 dòng'), findsOneWidget);

    var lastY = 0.0;
    for (final (i, key) in ['sach', 'tai-lieu', 'ke-hoach-doc', 'du-lieu-huan-luyen'].indexed) {
      final floor = find.byKey(ValueKey('tkc-$key'));
      expect(find.descendant(of: find.byType(ListFrame), matching: floor), findsOneWidget);
      expect(find.descendant(of: floor, matching: find.text('TẦNG')), findsOneWidget);
      expect(find.descendant(of: floor, matching: find.text('${i + 1}')), findsOneWidget);
      final y = tester.getTopLeft(floor).dy;
      expect(y, greaterThan(lastY));
      lastY = y;
    }
    expect(find.text('Nhật ký amber-brain: xem, đánh giá đúng/sai'), findsOneWidget);
    expect(find.text('Chạm vào một tầng để vào'), findsOneWidget);
  });

  testWidgets('có highlight → thêm dòng "Ôn lại" với câu trích + nguồn; không có thì ẩn', (tester) async {
    await _pump(tester);
    expect(find.byKey(const ValueKey('tkc-resurface')), findsNothing);

    await tester.pumpWidget(const SizedBox());
    await _pump(tester, highlight: _highlight);
    final row = find.byKey(const ValueKey('tkc-resurface'));
    expect(row, findsOneWidget);
    final text = tester.widget<RichText>(find.descendant(of: row, matching: find.byType(RichText)).last).text.toPlainText();
    expect(text, '"Đọc để sống chậm lại." — Sách A, Tác giả B');
  });

  for (final key in ['sach', 'tai-lieu', 'ke-hoach-doc', 'du-lieu-huan-luyen']) {
    testWidgets('bấm tầng $key → /tang-kinh-cac/$key', (tester) async {
      await _pump(tester);
      await tester.tap(find.byKey(ValueKey('tkc-$key')));
      await tester.pumpAndSettle();
      expect(find.text('ĐÍCH $key'), findsOneWidget);
    });
  }

  testWidgets('320 px, chữ ×2,0, có highlight: không tràn', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _pump(tester, highlight: _highlight, size: const Size(320, 2000));
    expect(tester.takeException(), isNull);
  });
}
