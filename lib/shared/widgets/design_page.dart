import 'package:material_ui/material_ui.dart';

import '../../features/amber_brain/widgets/amber_chat_dock.dart';
import '../../features/auth/widgets/account_menu.dart';
import '../theme/design_tokens.dart';
import 'design_top_bar.dart';

/// Cỡ màn theo [DesignLayout]: điện thoại / máy tính bảng / web rộng.
enum DesignSize {
  compact,
  medium,
  wide;

  static DesignSize of(double width) =>
      width >= DesignLayout.wide ? wide : (width >= DesignLayout.medium ? medium : compact);
}

/// Khung chung của mọi màn theo bộ thiết kế mới: thanh trên (← + tên + menu tài khoản) → [overview] → [content] → [hint].
///
/// - Nền [DesignBackground], chat Amber nổi góc phải dưới ([AmberChatDock]).
/// - Responsive: điện thoại / máy tính bảng xếp dọc; web rộng (≥ 1024) đặt tổng quan rộng 380 bên trái, nội dung bên phải.
/// - [content] nhận [DesignSize] để tự đổi số cột / cỡ ô.
/// - [backFallback] null = không có nút quay lại (Home); các tòa truyền '/'.
/// - Feature (menu tài khoản, chat) nằm trong khung chung này để mọi màn mới có sẵn, không phải gắn lại từng màn.
class DesignPage extends StatelessWidget {
  const DesignPage({
    super.key,
    required this.title,
    required this.overview,
    required this.content,
    this.backFallback = '/',
    this.hint,
    this.footer,
    this.onRefresh,
    this.bottomBar,
  });

  final String title;
  final String? backFallback;
  final Widget overview;
  final Widget Function(BuildContext context, DesignSize size) content;

  /// Dòng chữ phụ căn giữa dưới khung (vd "Chạm vào một mục để vào").
  final String? hint;

  /// Phần thêm dưới [hint] (vd nút "+ Ghi buổi học thủ công").
  final Widget? footer;

  /// Kéo xuống để tải lại.
  final Future<void> Function()? onRefresh;

  /// Thanh cố định dưới đáy (vd trình phát nhạc mini của Kiều Lâu).
  final Widget? bottomBar;

  @override
  Widget build(BuildContext context) {
    final body = LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final size = DesignSize.of(w);
        final gutter = DesignLayout.gutter(w);
        final hintText = hint == null
            ? null
            : Text(hint!, key: const ValueKey('design-page-hint'), textAlign: TextAlign.center, style: DesignText.muted);
        final main = [content(context, size), ?hintText, ?footer];

        final Widget column = size == DesignSize.wide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 20,
                children: [
                  SizedBox(width: 380, child: overview),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 14, children: main),
                  ),
                ],
              )
            : Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 14, children: [overview, ...main]);

        Widget list = ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          // Đáy chừa chỗ cho nút chat nổi.
          padding: EdgeInsets.fromLTRB(gutter, size == DesignSize.compact ? 14 : 24, gutter, 88),
          children: [column],
        );
        if (onRefresh != null) list = RefreshIndicator(onRefresh: onRefresh!, color: DesignColors.gold, child: list);

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: DesignLayout.maxContentWidth(w)),
            child: list,
          ),
        );
      },
    );

    return Scaffold(
      backgroundColor: DesignColors.bgTop,
      appBar: DesignTopBar(title: title, backFallback: backFallback, trailing: const AccountMenu()),
      body: DesignBackground(
        child: Column(
          children: [
            Expanded(child: AmberChatDock(child: body)),
            ?bottomBar,
          ],
        ),
      ),
    );
  }
}
