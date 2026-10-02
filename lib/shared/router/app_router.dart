import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/du_do/screens/du_do_screen.dart';
import '../../features/kieu_lau/screens/kieu_lau_screen.dart';
import '../../features/nghi_su_duong/screens/course_detail_screen.dart';
import '../../features/nghi_su_duong/screens/du_an_screen.dart';
import '../../features/nghi_su_duong/screens/finance_month_screen.dart';
import '../../features/nghi_su_duong/screens/finance_screen.dart';
import '../../features/nghi_su_duong/screens/hoc_tap_screen.dart';
import '../../features/nghi_su_duong/screens/nghi_su_duong_screen.dart';
import '../../features/tang_kinh_cac/screens/ke_hoach_doc_screen.dart';
import '../../features/tang_kinh_cac/screens/sach_screen.dart';
import '../../features/tang_kinh_cac/screens/tai_lieu_screen.dart';
import '../../features/tang_kinh_cac/screens/tang_kinh_cac_screen.dart';
import '../../features/tra_dinh/screens/placement_test_screen.dart';
import '../../features/tra_dinh/screens/practice_chat_screen.dart';
import '../../features/tra_dinh/screens/tra_dinh_screen.dart';
import '../providers/auth_provider.dart';

const _login = '/login';
const _splash = '/splash';

/// Đích sau khi đăng nhập lấy từ `?from=` — chỉ nhận đường dẫn nội bộ.
String? _safeFrom(String? from) {
  if (from == null || !from.startsWith('/') || from.startsWith('//')) return null;
  if (from.startsWith(_login) || from.startsWith(_splash)) return null;
  return from;
}

String _withFrom(String path, String target) => target == '/' ? path : '$path?from=${Uri.encodeComponent(target)}';

/// Quyết định chuyển hướng theo trạng thái đăng nhập. Tách ra để test được.
///
/// - Lần đầu mở app (đang đọc token, chưa có giá trị) → /splash, nhớ đích.
/// - Chưa đăng nhập → /login (nhớ đích để đăng nhập xong quay lại đúng chỗ).
/// - Đã đăng nhập, hoặc AuthInitial (còn token đã lưu, để API tự xác nhận) mà
///   đang ở /login hay /splash → về đích đã nhớ hoặc '/'.
///
/// [location] là vị trí đang/sắp hiển thị, kể cả trang mở bằng push — xem
/// [_location].
String? authRedirect(AsyncValue<AuthState> auth, Uri location) {
  final uri = location;
  final atLogin = uri.path == _login;
  final atSplash = uri.path == _splash;
  final from = uri.queryParameters['from'];
  final value = auth.value; // Riverpod 3: giữ giá trị trước khi đang loading/lỗi, null nếu chưa có.

  if (value == null && auth.isLoading) {
    // KHÔNG đá khỏi /login: login() cũng đặt AsyncLoading trong lúc gọi API.
    return atSplash || atLogin ? null : _withFrom(_splash, uri.toString());
  }

  final signedIn = value is Authenticated || value is AuthInitial;
  if (!signedIn) {
    if (atLogin) return null;
    return _withFrom(_login, atSplash ? (_safeFrom(from) ?? '/') : uri.toString());
  }
  if (atLogin || atSplash) return _safeFrom(from) ?? '/';
  return null;
}

/// Vị trí để quyết định redirect. Thường là [GoRouterState.uri] (đích đang điều
/// hướng tới). Riêng khi redirect chạy lại TẠI CHỖ (auth đổi, vd mất phiên),
/// state.uri chỉ là của màn gốc trong stack — trang mở bằng push không được
/// tính (go_router mặc định không đưa push vào URL) — nên lấy trang trên cùng
/// để nhớ đúng trang người dùng đang xem.
Uri _location(GoRouter router, GoRouterState state) {
  final current = router.routerDelegate.currentConfiguration;
  if (current.isNotEmpty && state.uri == current.uri) return router.state.uri;
  return state.uri;
}

/// Tạo 1 lần cho cả app — KHÔNG watch authControllerProvider ở đây (dựng lại
/// GoRouter sẽ mất toàn bộ stack điều hướng). Đổi trạng thái đăng nhập chỉ
/// kích hoạt chạy lại redirect qua [GoRouter.refreshListenable].
final routerProvider = Provider<GoRouter>((ref) {
  final authChanged = ValueNotifier<int>(0);
  ref.listen(authControllerProvider, (_, _) => authChanged.value++);

  late final GoRouter router;
  router = GoRouter(
    initialLocation: '/',
    refreshListenable: authChanged,
    redirect: (context, state) => authRedirect(ref.read(authControllerProvider), _location(router, state)),
    errorBuilder: (context, state) => _NotFoundScreen(location: state.uri.toString()),
    // Đường dẫn khớp trang web (src/app/**/page.tsx) — alert.href của Kiều Lâu
    // (/du-an, /finance/<id>, /hoc-tap/<id>) dùng được thẳng với context.go.
    routes: [
      GoRoute(path: _splash, builder: (_, _) => const _SplashScreen()),
      GoRoute(path: _login, builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/', builder: (_, _) => const DuDoScreen()),
      GoRoute(path: '/kieu-lau', builder: (_, _) => const KieuLauScreen()),
      GoRoute(
        path: '/tang-kinh-cac',
        builder: (_, _) => const TangKinhCacScreen(),
        routes: [
          GoRoute(path: 'sach', builder: (_, _) => const SachScreen()),
          GoRoute(path: 'tai-lieu', builder: (_, _) => const TaiLieuScreen()),
          GoRoute(path: 'ke-hoach-doc', builder: (_, _) => const KeHoachDocScreen()),
        ],
      ),
      GoRoute(path: '/nghi-su-duong', builder: (_, _) => const NghiSuDuongScreen()),
      // 3 mảng của Nghị Sự Đường nằm ở CẤP GỐC như web, không dưới /nghi-su-duong.
      GoRoute(path: '/du-an', builder: (_, _) => const DuAnScreen()),
      GoRoute(
        path: '/finance',
        builder: (_, _) => const FinanceScreen(),
        routes: [
          GoRoute(
            path: ':projectId',
            builder: (_, state) => FinanceMonthScreen(projectId: state.pathParameters['projectId']!),
          ),
        ],
      ),
      GoRoute(
        path: '/hoc-tap',
        builder: (_, _) => const HocTapScreen(),
        routes: [
          GoRoute(
            path: ':courseId',
            builder: (_, state) => CourseDetailScreen(courseId: state.pathParameters['courseId']!),
          ),
        ],
      ),
      GoRoute(
        path: '/tra-dinh',
        builder: (_, _) => const TraDinhScreen(),
        routes: [
          // Phải đứng trước ':sessionId', nếu không "placement-test" bị hiểu là 1 sessionId.
          GoRoute(path: 'placement-test', builder: (_, _) => const PlacementTestScreen()),
          GoRoute(
            path: ':sessionId',
            builder: (_, state) => PracticeChatScreen(sessionId: state.pathParameters['sessionId']!),
          ),
        ],
      ),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    authChanged.dispose();
  });
  return router;
});

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: CircularProgressIndicator()));
}

class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen({required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Không tìm thấy trang')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            Text(location, style: TextStyle(color: Colors.white.withValues(alpha: 0.5))),
            FilledButton(onPressed: () => context.go('/'), child: const Text('Về trang chủ')),
          ],
        ),
      ),
    );
  }
}
