import 'package:material_ui/material_ui.dart';

import '../theme/design_tokens.dart';
import 'amber_logo.dart';
import 'app_bar_back.dart';

/// Thanh trên của bố cục mới: cao 52, nền panel, kẻ dưới; [‹ quay lại] + tên màn + [trailing] bên phải.
///
/// [backFallback] null = không có nút quay lại (màn Home). Có giá trị thì bấm ← dùng [goBackOr] như [AppBarBack].
/// [trailing] mặc định là logo Amber tĩnh; các màn đã đăng nhập truyền `AccountMenu` (logo bấm ra menu tài khoản).
/// Nội dung thanh căn theo cùng cột với thân màn ([DesignLayout]) để trên web rộng không bị dạt ra hai mép.
class DesignTopBar extends StatelessWidget implements PreferredSizeWidget {
  const DesignTopBar({super.key, required this.title, this.backFallback, this.trailing});

  final String title;
  final String? backFallback;
  final Widget? trailing;

  static const height = 52.0;

  @override
  Size get preferredSize => const Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final fallback = backFallback;
    final width = MediaQuery.sizeOf(context).width;
    return Material(
      color: DesignColors.panel,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: height,
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: DesignColors.topBarBorder)),
          ),
          alignment: Alignment.center,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: DesignLayout.maxContentWidth(width)),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: DesignLayout.gutter(width)),
              child: Row(
                children: [
                  if (fallback != null)
                    IconButton(
                      key: const ValueKey('design-top-bar-back'),
                      tooltip: 'Quay lại',
                      onPressed: () => goBackOr(context, fallback),
                      icon: const Icon(Icons.arrow_back, color: DesignColors.gold, size: 20), // ← vàng như bản mẫu
                      visualDensity: VisualDensity.compact,
                    ),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: DesignText.serif(fontSize: 16, fontWeight: FontWeight.w700, color: DesignColors.text, height: 1.45),
                    ),
                  ),
                  trailing ?? const AmberLogo(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
