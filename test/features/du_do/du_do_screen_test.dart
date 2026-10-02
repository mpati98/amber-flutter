import 'package:amber_flutter/features/du_do/screens/du_do_screen.dart';
import 'package:amber_flutter/features/kieu_lau/models/alert.dart';
import 'package:amber_flutter/features/kieu_lau/models/activity_log_entry.dart';
import 'package:amber_flutter/features/kieu_lau/providers/kieu_lau_provider.dart';
import 'package:amber_flutter/features/kieu_lau/services/kieu_lau_api.dart';
import 'package:amber_flutter/shared/widgets/scroll_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

Alert _alert(String id) => Alert(id: id, kind: 'TASK_DUE', title: 'Trễ hạn $id', href: '/du-an');

/// Dư Đồ + 4 đích giả: mỗi đích hiện đúng đường dẫn của nó để kiểm tra điều hướng.
Future<void> _pump(WidgetTester tester, Future<KieuLauNotifications> Function() notifications) async {
  Widget dest(String path) => Scaffold(appBar: AppBar(), body: Text('ĐÍCH $path'));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [notificationsProvider.overrideWith((ref) => notifications())],
      child: MaterialApp.router(
        theme: ThemeData.dark(),
        routerConfig: GoRouter(
          routes: [
            GoRoute(path: '/', builder: (_, _) => const DuDoScreen()),
            for (final p in ['/tang-kinh-cac', '/nghi-su-duong', '/kieu-lau', '/tra-dinh'])
              GoRoute(path: p, builder: (_, _) => dest(p)),
          ],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<KieuLauNotifications> _withAlerts(int n) async =>
    (alerts: [for (var i = 0; i < n; i++) _alert('$i')], recentActivity: const <ActivityLogEntry>[]);

void main() {
  testWidgets('tiêu đề + 4 tòa với đúng tên và mô tả (luôn hiện, không cần hover)', (tester) async {
    await _pump(tester, () => _withAlerts(0));
    expect(find.text('amber'), findsOneWidget);
    expect(find.text('Âm Dương Giới'), findsOneWidget);
    for (final (name, sub) in [
      ('Tàng Kinh Các', 'Lưu trữ & tri thức'),
      ('Nghị Sự Đường', 'Việc chính & thông báo'),
      ('Kiều Lâu', 'Thông báo & tin tức'),
      ('Trà Đình', 'Trò chuyện & luyện tập'),
    ]) {
      expect(find.text(name), findsWidgets, reason: name);
      expect(find.text(sub), findsOneWidget, reason: sub);
    }
  });

  for (final (name, path) in [
    ('Tàng Kinh Các', '/tang-kinh-cac'),
    ('Nghị Sự Đường', '/nghi-su-duong'),
    ('Trà Đình', '/tra-dinh'),
  ]) {
    testWidgets('bấm card $name → push $path, back về Dư Đồ', (tester) async {
      await _pump(tester, () => _withAlerts(0));
      await tester.tap(find.widgetWithText(ScrollCard, name));
      await tester.pumpAndSettle();
      expect(find.text('ĐÍCH $path'), findsOneWidget);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.byType(DuDoScreen), findsOneWidget);
    });
  }

  testWidgets('Kiều Lâu: cả card lẫn nút góc phải đều tới /kieu-lau', (tester) async {
    await _pump(tester, () => _withAlerts(0));
    await tester.tap(find.widgetWithText(ScrollCard, 'Kiều Lâu'));
    await tester.pumpAndSettle();
    expect(find.text('ĐÍCH /kieu-lau'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(OutlinedButton, 'Kiều Lâu'));
    await tester.pumpAndSettle();
    expect(find.text('ĐÍCH /kieu-lau'), findsOneWidget);
  });

  testWidgets('badge = số cảnh báo', (tester) async {
    await _pump(tester, () => _withAlerts(3));
    expect(tester.widget<Badge>(find.byType(Badge)).isLabelVisible, isTrue);
    expect(find.descendant(of: find.byType(Badge), matching: find.text('3')), findsOneWidget);
  });

  testWidgets('0 cảnh báo → ẩn badge', (tester) async {
    await _pump(tester, () => _withAlerts(0));
    expect(tester.widget<Badge>(find.byType(Badge)).isLabelVisible, isFalse);
  });

  testWidgets('API thông báo lỗi → im lặng không hiện badge (như web), màn vẫn dùng được', (tester) async {
    await _pump(tester, () => Future.error(Exception('offline')));
    expect(tester.widget<Badge>(find.byType(Badge)).isLabelVisible, isFalse);
    expect(find.text('Âm Dương Giới'), findsOneWidget);
  });

  testWidgets('Cài đặt → SnackBar "Chưa có màn Cài đặt"', (tester) async {
    await _pump(tester, () => _withAlerts(0));
    await tester.tap(find.widgetWithText(OutlinedButton, 'Cài đặt'));
    await tester.pump();
    expect(find.text('Chưa có màn Cài đặt'), findsOneWidget);
  });
}
