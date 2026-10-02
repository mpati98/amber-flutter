import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/scroll_card.dart';
import '../../kieu_lau/providers/kieu_lau_provider.dart';

/// 4 tòa, đúng thứ tự + tên + mô tả + màu glow của amber-v3/src/lib/buildings.ts.
const _buildings = [
  (path: '/tang-kinh-cac', name: 'Tàng Kinh Các', sub: 'Lưu trữ & tri thức', emoji: '🏛️', glow: ScrollCardGlow.yugen),
  (
    path: '/nghi-su-duong',
    name: 'Nghị Sự Đường',
    sub: 'Việc chính & thông báo',
    emoji: '💼',
    glow: ScrollCardGlow.shuiro,
  ),
  (path: '/kieu-lau', name: 'Kiều Lâu', sub: 'Thông báo & tin tức', emoji: '📰', glow: ScrollCardGlow.yugen),
  (path: '/tra-dinh', name: 'Trà Đình', sub: 'Trò chuyện & luyện tập', emoji: '🍵', glow: ScrollCardGlow.kincha),
];

/// Trang chủ "/" — port HomeScene (Âm Dương Giới). Web đặt 4 ảnh tòa nhà lên
/// cảnh 1920×1080 kiểu "cover" (màn dọc mất 2/4 tòa, tên chỉ hiện khi hover);
/// ở đây giữ nền cảnh đêm nhưng 4 tòa là card luôn hiện tên + mô tả.
/// Không dùng 4 ảnh .webp của web — chưa xác nhận được nguồn/bản quyền.
class DuDoScreen extends ConsumerWidget {
  const DuDoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Như web: lỗi thì im lặng không hiện badge.
    final alertCount = ref.watch(notificationsProvider).value?.alerts.length ?? 0;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: CustomPaint(painter: _NightScenePainter())),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      spacing: 8,
                      children: [
                        _KieuLauButton(alertCount: alertCount),
                        _SceneButton(
                          label: 'Cài đặt',
                          onPressed: () => ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(const SnackBar(content: Text('Chưa có màn Cài đặt'))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    const _Title(),
                    const SizedBox(height: 32),
                    const _BuildingGrid(),
                    const SizedBox(height: 20),
                    Text(
                      'chạm vào công trình để vào từng khu vực',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, letterSpacing: 0.3, color: Colors.white.withValues(alpha: 0.55)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const _shadow = [Shadow(color: Color(0xB3000000), blurRadius: 14, offset: Offset(0, 2))];

class _Title extends StatelessWidget {
  const _Title();

  @override
  Widget build(BuildContext context) {
    final serif = Theme.of(context).textTheme.headlineMedium;
    return Column(
      children: [
        Text(
          'amber',
          style: serif?.copyWith(
            fontSize: 12,
            fontStyle: FontStyle.italic,
            letterSpacing: 12 * 0.3, // tracking-[0.3em]
            color: AppColors.kincha400.withValues(alpha: 0.9),
            shadows: _shadow,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Âm Dương Giới',
          textAlign: TextAlign.center,
          style: serif?.copyWith(fontWeight: FontWeight.w600, color: Colors.white, shadows: _shadow),
        ),
      ],
    );
  }
}

/// 2 cột; màn quá hẹp thì 1 cột.
class _BuildingGrid extends StatelessWidget {
  const _BuildingGrid();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < 340 ? 1 : 2;
        final cards = [for (final b in _buildings) _BuildingCard(building: b)];
        return Column(
          spacing: 12,
          children: [
            for (var i = 0; i < cards.length; i += columns)
              IntrinsicHeight(
                child: Row(
                  spacing: 12,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var j = i; j < i + columns; j++)
                      Expanded(child: j < cards.length ? cards[j] : const SizedBox.shrink()),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _BuildingCard extends StatelessWidget {
  const _BuildingCard({required this.building});

  final ({String path, String name, String sub, String emoji, ScrollCardGlow glow}) building;

  @override
  Widget build(BuildContext context) {
    final b = building;
    return Semantics(
      button: true,
      label: b.name,
      child: GestureDetector(
        onTap: () => context.push(b.path),
        behavior: HitTestBehavior.opaque,
        child: ScrollCard(
          glow: b.glow,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 6,
            children: [
              Text(b.emoji, style: const TextStyle(fontSize: 28)),
              Text(
                b.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 16, color: AppColors.kincha400),
              ),
              Text(b.sub, style: const TextStyle(fontSize: 11, letterSpacing: 0.3, color: AppColors.yugen300)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Nút viền mờ góc trên phải như web (border white/15, chữ white/70).
class _SceneButton extends StatelessWidget {
  const _SceneButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white.withValues(alpha: 0.7),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
        backgroundColor: AppColors.ink950.withValues(alpha: 0.35),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.darkRadius)),
        textStyle: const TextStyle(fontSize: 14),
      ),
      child: Text(label),
    );
  }
}

/// Kiều Lâu kèm badge đỏ = số cảnh báo hiện có (không phải "chưa đọc" — hệ
/// thống không lưu trạng thái đã đọc), như nút góc phải bên web.
class _KieuLauButton extends StatelessWidget {
  const _KieuLauButton({required this.alertCount});

  final int alertCount;

  @override
  Widget build(BuildContext context) {
    return Badge(
      isLabelVisible: alertCount > 0,
      label: Text('$alertCount'),
      backgroundColor: AppColors.shuiro500,
      textColor: Colors.white,
      offset: const Offset(4, -4),
      child: _SceneButton(label: 'Kiều Lâu', onPressed: () => context.push('/kieu-lau')),
    );
  }
}

/// Nền tĩnh port từ SceneBackground.tsx: trời đêm, sao, trăng, 2 dãy núi, mặt
/// nước. Toạ độ theo % khung như CSS bên web (bỏ sương trôi + quầng trăng
/// nhấp nháy — bản đầu chỉ cần tĩnh).
class _NightScenePainter extends CustomPainter {
  const _NightScenePainter();

  // linear-gradient(180deg, ...) của bầu trời.
  static const _skyStops = [0.0, 0.24, 0.44, 0.56, 0.62, 0.66, 0.78, 1.0];
  static const _skyColors = [
    Color(0xFF05070F),
    Color(0xFF0C1128),
    Color(0xFF18204A),
    Color(0xFF2B3462),
    Color(0xFF3C4470),
    Color(0xFF252D4E),
    Color(0xFF111731),
    Color(0xFF070A15),
  ];

  // (x%, y%, bán kính px, độ đục) — 10 sao như web.
  static const _stars = [
    (0.12, 0.08, 1.4, 0.75),
    (0.31, 0.15, 1.2, 0.5),
    (0.47, 0.06, 1.6, 0.7),
    (0.63, 0.13, 1.2, 0.45),
    (0.78, 0.07, 1.5, 0.65),
    (0.88, 0.18, 1.2, 0.4),
    (0.22, 0.24, 1.3, 0.3),
    (0.70, 0.27, 1.4, 0.3),
    (0.55, 0.21, 1.2, 0.3),
    (0.40, 0.11, 1.3, 0.4),
  ];

  // clip-path polygon (% của khối núi), lấy nguyên từ web.
  static const _farRange = [
    (0, 100), (0, 62), (7, 48), (13, 55), (21, 33), (28, 46), (34, 30), (42, 52), //
    (50, 40), (58, 58), (68, 46), (79, 64), (90, 54), (100, 70), (100, 100),
  ];
  static const _nearRange = [
    (0, 100), (0, 74), (10, 58), (19, 68), (27, 44), (36, 60), (45, 38), (54, 56), //
    (64, 42), (74, 62), (85, 50), (100, 66), (100, 100),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final rect = Offset.zero & size;

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _skyColors,
          stops: _skyStops,
        ).createShader(rect),
    );

    for (final (x, y, r, o) in _stars) {
      canvas.drawCircle(Offset(x * w, y * h), r, Paint()..color = Colors.white.withValues(alpha: o));
    }

    // Trăng: hình tròn + quầng sáng, góc trên trái (bên phải là 2 nút, giữa là
    // tiêu đề). Kích thước theo cạnh ngắn để màn dọc không quá to.
    final moonR = (w < h ? w : h) * 0.07;
    final moonC = Offset(0.06 * w + moonR, 0.035 * h + moonR);
    canvas.drawCircle(
      moonC,
      moonR * 2.6,
      Paint()
        ..shader = RadialGradient(colors: [const Color(0xFFE9D6AA).withValues(alpha: 0.22), const Color(0x00E9D6AA)])
            .createShader(Rect.fromCircle(center: moonC, radius: moonR * 2.6)),
    );
    canvas.drawCircle(
      moonC,
      moonR,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.24, -0.32), // circle at 38% 34%
          colors: [Color(0xFFFDF6E3), Color(0xFFF2E3BF), Color(0xFFD6C396)],
          stops: [0, 0.55, 1],
        ).createShader(Rect.fromCircle(center: moonC, radius: moonR)),
    );

    // Khối núi giữ tỉ lệ cao/rộng như trên sân khấu 1920×1080 của web (núi xa
    // 1229×389, núi gần 1229×335), chân núi đặt ở chân trời 66% — nếu lấy %
    // chiều cao màn dọc thì núi bị kéo thành răng cưa.
    final rangeW = 0.64 * w;
    final farH = rangeW * 389 / 1229, nearH = rangeW * 335 / 1229;
    _range(canvas, Rect.fromLTWH(-0.06 * w, 0.66 * h - farH, rangeW, farH), _farRange, const [
      Color(0xFF1A2447),
      Color(0xFF131A34),
    ], 0.9);
    _range(canvas, Rect.fromLTWH(w - 0.56 * w, 0.66 * h - nearH, rangeW, nearH), _nearRange, const [
      Color(0xFF1D2649),
      Color(0xFF141B36),
    ], 0.8);

    // Mặt nước từ 65% xuống đáy + đường chân trời sáng mờ.
    final water = Rect.fromLTWH(0, 0.65 * h, w, 0.35 * h);
    canvas.drawRect(
      water,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF303A63), Color(0xFF1A2242), Color(0xFF0B1020), Color(0xFF070A14)],
          stops: [0, 0.3, 0.72, 1],
        ).createShader(water),
    );
    final horizon = Rect.fromLTWH(0, 0.647 * h, w, 2);
    canvas.drawRect(
      horizon,
      Paint()
        ..shader = LinearGradient(
          colors: [const Color(0x00D2DCF5), const Color(0xFFD2DCF5).withValues(alpha: 0.4), const Color(0x00D2DCF5)],
          stops: const [0, 0.45, 1],
        ).createShader(horizon),
    );
  }

  void _range(Canvas canvas, Rect box, List<(int, int)> points, List<Color> colors, double opacity) {
    final path = Path();
    for (final (i, (px, py)) in points.indexed) {
      final p = Offset(box.left + box.width * px / 100, box.top + box.height * py / 100);
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    path.close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [for (final c in colors) c.withValues(alpha: opacity)],
        ).createShader(box),
    );
  }

  @override
  bool shouldRepaint(_NightScenePainter oldDelegate) => false;
}
