import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/theme/design_tokens.dart';
import '../../../shared/widgets/design_page.dart';
import '../../../shared/widgets/list_frame.dart';
import '../../../shared/widgets/overview_block.dart';
import '../widgets/today_rows.dart';

/// 4 tòa theo design/ref/home.html: chữ Hán trong vòng tròn vàng + tên + mô tả.
const _buildings = [
  (path: '/tang-kinh-cac', name: 'Tàng Kinh Các', sub: 'Lưu trữ & tri thức', glyph: '藏'),
  (path: '/nghi-su-duong', name: 'Nghị Sự Đường', sub: 'Việc & tiền bạc', glyph: '事'),
  (path: '/kieu-lau', name: 'Kiều Lâu', sub: 'Thông báo & tin tức', glyph: '樓'),
  (path: '/tra-dinh', name: 'Trà Đình', sub: 'Học tập & luyện tập', glyph: '茶'),
];

/// Trang chủ "/" (Âm Dương Giới): thanh trên → "Cập nhật hôm nay" (số liệu thật) → khung 4 tòa.
/// Logo Amber góc phải mở menu tài khoản ([AccountMenu]); nút tròn góc phải dưới mở chat Amber ([AmberChatDock]).
///
/// Responsive theo [DesignLayout]: điện thoại đúng bản mẫu (xếp dọc, 2 cột); máy tính bảng rộng 760, 4 tòa một hàng;
/// web rộng (≥ 1024) đặt tổng quan bên trái, khung 4 tòa (2×2, ô lớn) bên phải.
class DuDoScreen extends StatelessWidget {
  const DuDoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DesignPage(
      title: 'Âm Dương Giới',
      backFallback: null,
      overview: const OverviewBlock(title: 'Cập nhật hôm nay', rows: [NewsRow(), SpendingRow(), TaskRow()]),
      content: (context, size) => ListFrame(
        child: _BuildingGrid(columns: size == DesignSize.medium ? 4 : 2, large: size == DesignSize.wide),
      ),
      hint: 'Chạm vào một tòa nhà để vào',
    );
  }
}

/// Lưới tòa nhà, cách nhau 10. [large]: ô lớn hơn cho web rộng. Khung quá hẹp (chữ phóng to trên máy nhỏ) thì 1 cột.
class _BuildingGrid extends StatelessWidget {
  const _BuildingGrid({required this.columns, this.large = false});

  final int columns;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final n = constraints.maxWidth < 240 ? 1 : columns;
        final tiles = [for (final b in _buildings) _BuildingTile(building: b, large: large)];
        return Column(
          spacing: 10,
          children: [
            for (var i = 0; i < tiles.length; i += n)
              IntrinsicHeight(
                child: Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var j = i; j < i + n; j++)
                      Expanded(child: j < tiles.length ? tiles[j] : const SizedBox.shrink()),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _BuildingTile extends StatelessWidget {
  const _BuildingTile({required this.building, this.large = false});

  final ({String path, String name, String sub, String glyph}) building;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final b = building;
    return FrameTile(
      key: ValueKey('building-${b.path}'),
      semanticLabel: b.name,
      onTap: () => context.push(b.path),
      padding: EdgeInsets.all(large ? 20 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: large ? 12 : 6),
            child: GlyphCircle(b.glyph, size: large ? 48 : 36),
          ),
          Text(b.name, style: large ? DesignText.bold.copyWith(fontSize: 17) : DesignText.bold),
          Text(b.sub, style: large ? DesignText.muted.copyWith(fontSize: 14) : DesignText.muted),
        ],
      ),
    );
  }
}
