import 'package:amber_flutter/features/du_lieu_huan_luyen/screens/training_logs_screen.dart';
import 'package:amber_flutter/features/du_lieu_huan_luyen/models/training_log.dart';
import 'package:amber_flutter/features/du_lieu_huan_luyen/services/training_log_api.dart';
import 'package:amber_flutter/features/tang_kinh_cac/screens/tang_kinh_cac_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'screens_test.dart' show FakeApi;

void main() {
  testWidgets('Tàng Kinh Các có mục "Dữ liệu huấn luyện" riêng, hiện số mẫu đủ điều kiện và mở danh sách log', (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final router = GoRouter(initialLocation: '/tang-kinh-cac', routes: [
      GoRoute(path: '/tang-kinh-cac', builder: (_, _) => const TangKinhCacScreen(), routes: [
        GoRoute(path: 'du-lieu-huan-luyen', builder: (_, _) => const TrainingLogsScreen()),
      ]),
    ]);
    // Các mục sách/tài liệu/kế hoạch đọc không được stub: lỗi mạng của chúng không được làm hỏng mục mới.
    await tester.pumpWidget(ProviderScope(
      overrides: [trainingLogApiProvider.overrideWithValue(FakeApi())],
      child: MaterialApp.router(theme: ThemeData.dark(), routerConfig: router),
    ));
    await tester.pumpAndSettle();

    for (final other in ['Sách', 'Tài liệu', 'Kế hoạch đọc']) {
      expect(find.text(other), findsOneWidget);   // 3 mục cũ còn nguyên
    }
    expect(find.text('Dữ liệu huấn luyện'), findsOneWidget);
    expect(find.text('3 mẫu đủ điều kiện · 5 dòng'), findsOneWidget);

    await tester.ensureVisible(find.text('Dữ liệu huấn luyện'));
    await tester.tap(find.text('Dữ liệu huấn luyện'));
    await tester.pumpAndSettle();
    expect(find.byType(TrainingLogsScreen), findsOneWidget);
    expect(find.text('3 mẫu đủ điều kiện train · 5 dòng nhật ký'), findsOneWidget);
  });

  testWidgets('thống kê lỗi thì thẻ báo "Không tải được số liệu" và vẫn bấm vào được', (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final api = _FailingStats();
    await tester.pumpWidget(ProviderScope(
      overrides: [trainingLogApiProvider.overrideWithValue(api)],
      child: const MaterialApp(home: TangKinhCacScreen()),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Dữ liệu huấn luyện'), findsOneWidget);
    expect(find.text('Không tải được số liệu'), findsWidgets);
  });
}

class _FailingStats extends FakeApi {
  @override
  Future<TrainingStats> stats() async => throw StateError('offline');
}
