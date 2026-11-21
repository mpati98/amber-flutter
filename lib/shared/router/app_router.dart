import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/du_do/screens/du_do_screen.dart';
import '../../features/sinh_luc/screens/sinh_luc_screen.dart';
import '../../features/kieu_lau/screens/kieu_lau_screen.dart';
import '../../features/kieu_lau/screens/music_screen.dart';
import '../../features/nghi_su_duong/screens/finance_month_screen.dart';
import '../../features/nghi_su_duong/screens/hoc_tap_plan_detail_screen.dart';
import '../../features/nghi_su_duong/screens/hoc_tap_plan_screen.dart';
import '../../features/nghi_su_duong/screens/hoc_tap_schedule_screen.dart';
import '../../features/nghi_su_duong/screens/hoc_tap_stats_screen.dart';
import '../../features/nghi_su_duong/screens/nghi_su_duong_screen.dart';
import '../../features/nghi_su_duong/screens/project_detail_screen.dart';
import '../../features/tang_kinh_cac/screens/tang_kinh_cac_screen.dart';
import '../../features/tra_dinh/hoc_tap/models/study_enums.dart';
import '../../features/tra_dinh/hoc_tap/screens/card_import_screen.dart';
import '../../features/tra_dinh/hoc_tap/screens/card_insights_screen.dart';
import '../../features/tra_dinh/hoc_tap/screens/card_review_screen.dart';
import '../../features/tra_dinh/hoc_tap/screens/course_detail_screen.dart'
    as hoc_tap;
import '../../features/tra_dinh/hoc_tap/screens/course_list_screen.dart';
import '../../features/tra_dinh/hoc_tap/screens/trash_screen.dart';
import '../../features/tra_dinh/hoc_tap/screens/tra_dinh_hoc_tap_screen.dart';
import '../../features/tra_dinh/hoc_tap/screens/wishlist_screen.dart';
import '../../features/tra_dinh/screens/placement_test_screen.dart';
import '../../features/tra_dinh/screens/practice_chat_screen.dart';
import '../../features/tra_dinh/screens/tra_dinh_screen.dart';
import '../providers/auth_provider.dart';

const _login = '/login';
const _splash = '/splash';

/// Đích sau khi đăng nhập lấy từ `?from=` — chỉ nhận đường dẫn nội bộ.
String? _safeFrom(String? from) {
  if (from == null || !from.startsWith('/') || from.startsWith('//')) {
    return null;
  }
  if (from.startsWith(_login) || from.startsWith(_splash)) {
    return null;
  }
  return from;
}

String _withFrom(String path, String target) =>
    target == '/' ? path : '$path?from=${Uri.encodeComponent(target)}';

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
    return _withFrom(
      _login,
      atSplash ? (_safeFrom(from) ?? '/') : uri.toString(),
    );
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

/// Chuyển hướng liên kết cũ `/tra-dinh?tab=…`: schedule → /hoc-tap/lich (giữ view, date), stats → /hoc-tap/thong-ke (giữ range,
/// subject), library / thu-vien → /hoc-tap; tab khác hoặc không xác định (kể cả today / overview) → /tra-dinh bỏ các tham số của tab cũ
/// nhưng giữ `openLog` / `subjectId`. Không có `tab` → null (không chuyển hướng).
String? traDinhLegacyTabRedirect(Uri uri) {
  if (uri.path != '/tra-dinh') return null;
  final params = uri.queryParameters;
  final tab = params['tab'];
  if (tab == null) return null;
  String build(String path, Iterable<String> keep) {
    final q = {for (final k in keep) if (params[k] != null) k: params[k]!};
    return Uri(path: path, queryParameters: q.isEmpty ? null : q).toString();
  }

  return switch (tab) {
    'schedule' => build('/hoc-tap/lich', const ['view', 'date']),
    'stats' => build('/hoc-tap/thong-ke', const ['range', 'subject']),
    'library' || 'thu-vien' => '/hoc-tap',
    _ => build('/tra-dinh', const ['openLog', 'subjectId']),
  };
}

/// Màn danh sách riêng từng tầng cũ của Tàng Kinh Các → tầng tương ứng trên màn chính (3 tầng: Kế hoạch đọc nằm ở tầng Sách).
const tkcLegacyFloors = [('sach', 1), ('tai-lieu', 2), ('ke-hoach-doc', 1), ('du-lieu-huan-luyen', tkcTrainingFloor)];

/// Màn trung gian cũ của Nghị Sự Đường (/du-an, /finance) → màn chính /nghi-su-duong. Chỉ đúng hai đường dẫn đó:
/// chi tiết (/du-an/:id, /finance/:id) là route riêng nên không đi qua đây.
String? nsdLegacyRedirect(BuildContext _, GoRouterState state) => '/nghi-su-duong';

/// Khung Kho thẻ của Trà Đình (`?kho=1`: điện thoại mở sẵn tab Kho thẻ) cho môn [subjectId] (null = môn đang chọn).
String traDinhCardsLocation(String? subjectId) =>
    Uri(path: '/tra-dinh', queryParameters: {'kho': '1', 'subjectId': ?subjectId}).toString();

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
    redirect: (context, state) => authRedirect(
      ref.read(authControllerProvider),
      _location(router, state),
    ),
    errorBuilder: (context, state) =>
        _NotFoundScreen(location: state.uri.toString()),
    // Đường dẫn khớp trang web (src/app/**/page.tsx) — alert.href của Kiều Lâu
    // (/du-an, /finance/<id>) dùng được thẳng với context.go.
    routes: [
      GoRoute(path: _splash, builder: (_, _) => const _SplashScreen()),
      GoRoute(path: _login, builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/', builder: (_, _) => const DuDoScreen()),
      // Giấc ngủ tự ghi (đầu vào chỉ số Sức khoẻ của màn chủ 3D) — mở từ bảng chi tiết của Amber
      GoRoute(path: '/sinh-luc', builder: (_, _) => const SinhLucScreen()),
      GoRoute(
        path: '/kieu-lau',
        builder: (_, _) => const KieuLauScreen(),
        routes: [GoRoute(path: 'nhac', builder: (_, _) => const MusicScreen())],
      ),
      // Tàng Kinh Các là MỘT màn: tầng + mục ở query (?tang=1..3&id=). Các màn danh sách riêng từng tầng và chi tiết
      // nhật ký huấn luyện cũ đã gộp vào đó; route cũ chỉ còn redirect để link cũ không gãy.
      GoRoute(
        path: '/tang-kinh-cac',
        // ?tang=4 (khi còn 4 tầng) → ?tang=3.
        redirect: (_, state) => tkcLegacyQueryRedirect(state.uri),
        builder: (_, state) => TangKinhCacScreen(
          tang: tkcFloorOf(state.uri.queryParameters['tang']),
          id: state.uri.queryParameters['id'],
        ),
        routes: [
          for (final (path, tang) in tkcLegacyFloors) GoRoute(path: path, redirect: (_, _) => tkcLocation(tang)),
          GoRoute(
            path: 'du-lieu-huan-luyen/:logId',
            redirect: (_, state) => tkcLocation(tkcTrainingFloor, id: state.pathParameters['logId']),
          ),
        ],
      ),
      GoRoute(
        path: '/nghi-su-duong',
        builder: (_, _) => const NghiSuDuongScreen(),
      ),
      // Nghị Sự Đường là MỘT màn (/nghi-su-duong). Hai màn trung gian cũ — /du-an ("Việc & dự án") và /finance
      // ("Tài chính cá nhân") — đã gộp vào đó; giữ route để link cũ (alert.href của backend, cảnh 3D bản cũ) không gãy.
      // Chi tiết dự án / tháng vẫn ở đường dẫn cũ, khai báo cấp gốc để không kéo màn cha (đã bỏ) vào stack.
      GoRoute(path: '/du-an', redirect: nsdLegacyRedirect),
      GoRoute(
        path: '/du-an/:projectId',
        builder: (_, state) => ProjectDetailScreen(
          projectId: state.pathParameters['projectId']!,
          // ?task=<id>: tự mở trang chi tiết của việc đó (từ khung "Cần chú ý").
          initialTaskId: state.uri.queryParameters['task'],
        ),
      ),
      GoRoute(path: '/finance', redirect: nsdLegacyRedirect),
      GoRoute(
        path: '/finance/:projectId',
        builder: (_, state) => FinanceMonthScreen(projectId: state.pathParameters['projectId']!),
      ),
      // Học tập ở Nghị Sự Đường (kế hoạch): cấp gốc như /du-an, /finance. Màn đích đều là màn Trà Đình.
      GoRoute(
        path: '/hoc-tap',
        builder: (_, _) => const HocTapPlanScreen(),
        routes: [
          GoRoute(path: 'chi-tiet', builder: (_, _) => const HocTapPlanDetailScreen()),
          GoRoute(
            path: 'lich',
            builder: (_, state) => HocTapScheduleScreen(view: state.uri.queryParameters['view'], date: state.uri.queryParameters['date']),
          ),
          GoRoute(
            path: 'thong-ke',
            builder: (_, state) => HocTapStatsScreen(range: state.uri.queryParameters['range'], subject: state.uri.queryParameters['subject']),
          ),
        ],
      ),
      GoRoute(
        path: '/tra-dinh',
        // Liên kết cũ /tra-dinh?tab=… (Trà Đình từng có tab Lịch / Thống kê) → màn mới ở Nghị Sự Đường.
        redirect: (_, state) => traDinhLegacyTabRedirect(state.uri),
        builder: (_, state) => TraDinhHocTapScreen(
          openLog: state.uri.queryParameters['openLog'] == '1',
          subjectId: state.uri.queryParameters['subjectId'],
          cards: state.uri.queryParameters['kho'] == '1',
        ),
        routes: [
          // Mọi route con cố định phải đứng trước ':sessionId', nếu không bị hiểu là 1 sessionId.
          GoRoute(
            path: 'luyen-tap',
            builder: (_, state) => TraDinhScreen(subjectId: state.uri.queryParameters['subjectId']),
          ),
          GoRoute(
            path: 'placement-test',
            builder: (_, _) => const PlacementTestScreen(),
          ),
          GoRoute(
            path: 'hoc-tap/courses',
            builder: (_, state) => CourseListScreen(
              subjectId: state.uri.queryParameters['subjectId'],
              statuses: [
                for (final s
                    in state.uri.queryParametersAll['status'] ??
                        const <String>[])
                  CourseStatus.fromApi(s),
              ].where((s) => s != CourseStatus.unknown).toList(),
            ),
          ),
          GoRoute(
            path: 'hoc-tap/courses/:courseId',
            builder: (_, state) => hoc_tap.CourseDetailScreen(
              courseId: state.pathParameters['courseId']!,
            ),
          ),
          GoRoute(
            path: 'hoc-tap/thung-rac',
            builder: (_, _) => const TrashScreen(),
          ),
          // Màn Thư viện đã gỡ: mọi mục của nó có đường vào mới (kế hoạch /hoc-tap, Chi tiết kế hoạch, Kho thẻ).
          GoRoute(path: 'hoc-tap/thu-vien', redirect: (_, _) => '/hoc-tap'),
          GoRoute(
            path: 'hoc-tap/wishlist',
            builder: (_, state) => WishlistScreen(
              subjectId: state.uri.queryParameters['subjectId'],
            ),
          ),
          // Kho thẻ từ vựng: route tĩnh, đứng trước ':sessionId'. Màn danh sách Kho thẻ riêng đã gộp vào khung "Kho thẻ"
          // của /tra-dinh — route cũ chỉ còn redirect (giữ môn).
          GoRoute(path: 'hoc-tap/the', redirect: (_, state) => traDinhCardsLocation(state.uri.queryParameters['subjectId'])),
          GoRoute(
            path: 'hoc-tap/the/on',
            builder: (_, state) => CardReviewScreen(subjectId: state.uri.queryParameters['subjectId']),
          ),
          GoRoute(
            path: 'hoc-tap/the/thong-ke',
            builder: (_, state) => CardInsightsScreen(subjectId: state.uri.queryParameters['subjectId']),
          ),
          GoRoute(
            path: 'hoc-tap/the/them',
            builder: (_, state) => CardImportScreen(subjectId: state.uri.queryParameters['subjectId']),
          ),
          GoRoute(
            path: ':sessionId',
            builder: (_, state) => PracticeChatScreen(
              sessionId: state.pathParameters['sessionId']!,
              subjectId: state.uri.queryParameters['subjectId'],
            ),
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
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
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
            Text(
              location,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
            ),
            FilledButton(
              onPressed: () => context.go('/'),
              child: const Text('Về trang chủ'),
            ),
          ],
        ),
      ),
    );
  }
}
