import 'package:amber_flutter/features/amber_brain/providers/brain_status_provider.dart';
import 'package:amber_flutter/features/auth/screens/login_screen.dart';
import 'package:amber_flutter/features/du_do/screens/du_do_screen.dart';
import 'package:amber_flutter/features/du_lieu_huan_luyen/screens/training_log_detail_screen.dart';
import 'package:amber_flutter/features/du_lieu_huan_luyen/screens/training_logs_screen.dart';
import 'package:amber_flutter/features/du_lieu_huan_luyen/services/training_log_api.dart';
import 'package:amber_flutter/features/kieu_lau/models/alert.dart';
import 'package:amber_flutter/features/kieu_lau/models/activity_log_entry.dart';
import 'package:amber_flutter/features/kieu_lau/providers/kieu_lau_provider.dart';
import 'package:amber_flutter/shared/providers/auth_provider.dart';
import 'package:amber_flutter/shared/router/app_router.dart';
import 'package:amber_flutter/shared/services/token_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../features/amber_brain/fake_brain.dart';
import '../../features/du_lieu_huan_luyen/screens_test.dart' show FakeApi;

const _loading = AsyncLoading<AuthState>();
const _signedOut = AsyncData<AuthState>(Unauthenticated());
const _hasToken = AsyncData<AuthState>(AuthInitial());
const _signedIn = AsyncData<AuthState>(Authenticated({'id': 'u1'}));

String? _redirect(AsyncValue<AuthState> auth, String location) => authRedirect(auth, Uri.parse(location));

class _MemStorage implements TokenStorage {
  _MemStorage(this.access);
  String? access;
  @override
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async => access = accessToken;
  @override
  Future<String?> readAccessToken() async => access;
  @override
  Future<String?> readRefreshToken() async => null;
  @override
  Future<void> clear() async => access = null;
}

void main() {
  group('authRedirect', () {
    test('mở app, chưa đọc xong token → /splash, nhớ đích (cả URL trực tiếp)', () {
      expect(_redirect(_loading, '/'), '/splash');
      expect(_redirect(_loading, '/tra-dinh/abc'), '/splash?from=%2Ftra-dinh%2Fabc');
      expect(_redirect(_loading, '/splash?from=%2Fdu-an'), isNull);
    });

    test('đang đăng nhập (login() đặt AsyncLoading) → KHÔNG đá khỏi /login', () {
      expect(_redirect(_loading, '/login'), isNull);
      expect(_redirect(_loading, '/login?from=%2Fdu-an'), isNull);
    });

    test('còn token đã lưu (mở lại app) → vào thẳng, không bắt đăng nhập lại', () {
      expect(_redirect(_hasToken, '/splash'), '/');
      expect(_redirect(_hasToken, '/splash?from=%2Ftra-dinh%2Fabc'), '/tra-dinh/abc');
      expect(_redirect(_hasToken, '/tang-kinh-cac/sach'), isNull);
    });

    test('chưa đăng nhập + URL trực tiếp → /login nhớ đích; đăng nhập xong quay lại đúng chỗ', () {
      expect(_redirect(_signedOut, '/'), '/login');
      expect(_redirect(_signedOut, '/finance/p1'), '/login?from=%2Ffinance%2Fp1');
      expect(_redirect(_signedOut, '/splash?from=%2Ffinance%2Fp1'), '/login?from=%2Ffinance%2Fp1');
      expect(_redirect(_signedOut, '/login?from=%2Ffinance%2Fp1'), isNull);
      expect(_redirect(_signedIn, '/login?from=%2Ffinance%2Fp1'), '/finance/p1');
      expect(_redirect(_signedIn, '/login'), '/');
    });

    test('mất phiên giữa chừng (Unauthenticated khi đang ở trong app) → /login nhớ trang đang xem', () {
      expect(_redirect(_signedOut, '/hoc-tap/c1'), '/login?from=%2Fhoc-tap%2Fc1');
    });

    test('from không phải đường dẫn nội bộ → bỏ qua, về /', () {
      expect(_redirect(_signedIn, '/login?from=https%3A%2F%2Fevil.com'), '/');
      expect(_redirect(_signedIn, '/login?from=%2F%2Fevil.com'), '/');
      expect(_redirect(_signedIn, '/login?from=%2Flogin'), '/');
    });
  });

  group('routerProvider (router thật)', () {
    Future<ProviderContainer> pumpApp(WidgetTester tester, {String? token, List<Override> extra = const []}) async {
      final container = ProviderContainer(
        overrides: [
          tokenStorageProvider.overrideWithValue(_MemStorage(token)),
          ...extra,
          // Nút Amber ở Dư Đồ — không tạo Timer/Dio thật trong test.
          brainStatusProvider.overrideWith(FixedBrainStatus.new),
          // Dư Đồ đọc số cảnh báo cho badge — không gọi mạng trong test.
          notificationsProvider.overrideWith(
            (ref) async => (alerts: const <Alert>[], recentActivity: const <ActivityLogEntry>[]),
          ),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: Consumer(
            builder: (_, ref, _) =>
                MaterialApp.router(theme: ThemeData.dark(), routerConfig: ref.watch(routerProvider)),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return container;
    }

    String location(ProviderContainer c) => c.read(routerProvider).routeInformationProvider.value.uri.toString();

    testWidgets('Tàng Kinh Các: /du-lieu-huan-luyen và /:logId là route thật (không rơi vào trang 404)', (tester) async {
      final c = await pumpApp(tester, token: 'saved-access', extra: [trainingLogApiProvider.overrideWithValue(FakeApi())]);
      c.read(routerProvider).go('/tang-kinh-cac/du-lieu-huan-luyen');
      await tester.pumpAndSettle();
      expect(find.byType(TrainingLogsScreen), findsOneWidget);
      c.read(routerProvider).go('/tang-kinh-cac/du-lieu-huan-luyen/l1');
      await tester.pumpAndSettle();
      expect(find.byType(TrainingLogDetailScreen), findsOneWidget);
      expect(find.text('chi 45k ăn trưa Momo'), findsOneWidget);
    });

    testWidgets('mở app còn token → vào thẳng Dư Đồ', (tester) async {
      final c = await pumpApp(tester, token: 'saved-access');
      expect(find.byType(DuDoScreen), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
      expect(location(c), '/');
    });

    testWidgets('mở app không có token → /login', (tester) async {
      final c = await pumpApp(tester);
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(location(c), '/login');
    });

    testWidgets('đang ở trong app, phiên hết hạn → tự về /login, nhớ trang đang xem', (tester) async {
      final c = await pumpApp(tester, token: 'saved-access');
      c.read(routerProvider).push('/tang-kinh-cac/sach');
      await tester.pump();
      c.read(authControllerProvider.notifier).sessionExpired();
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(location(c), '/login?from=%2Ftang-kinh-cac%2Fsach');
    });

    testWidgets('đường dẫn không tồn tại → trang báo lỗi có nút về trang chủ', (tester) async {
      final c = await pumpApp(tester, token: 'saved-access');
      c.read(routerProvider).go('/khong-co');
      await tester.pumpAndSettle();
      expect(find.text('Không tìm thấy trang'), findsOneWidget);
      await tester.tap(find.text('Về trang chủ'));
      await tester.pumpAndSettle();
      expect(find.byType(DuDoScreen), findsOneWidget);
    });

    testWidgets('/tra-dinh/placement-test không bị hiểu là sessionId', (tester) async {
      final c = await pumpApp(tester, token: 'saved-access');
      final match = c.read(routerProvider).configuration.findMatch(Uri.parse('/tra-dinh/placement-test'));
      expect(match.last.route, isA<GoRoute>().having((r) => r.path, 'path', 'placement-test'));
    });

    testWidgets('các route Học tập của Trà Đình đứng trước :sessionId', (tester) async {
      final c = await pumpApp(tester, token: 'saved-access');
      String? routePath(String location) {
        final match = c.read(routerProvider).configuration.findMatch(Uri.parse(location));
        return match.last.route.path;
      }

      expect(routePath('/tra-dinh'), '/tra-dinh');
      expect(routePath('/tra-dinh?tab=stats'), '/tra-dinh');
      expect(routePath('/tra-dinh/luyen-tap'), 'luyen-tap');
      expect(routePath('/tra-dinh/hoc-tap/courses?subjectId=s&status=QUEUED'), 'hoc-tap/courses');
      expect(routePath('/tra-dinh/hoc-tap/courses/abc'), 'hoc-tap/courses/:courseId');
      expect(routePath('/tra-dinh/hoc-tap/wishlist'), 'hoc-tap/wishlist');
      expect(routePath('/tra-dinh/placement-test'), 'placement-test');
      expect(routePath('/tra-dinh/một-id-buổi-luyện'), ':sessionId');
    });
  });
}
