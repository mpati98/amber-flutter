import 'package:material_ui/material_ui.dart';

import '../theme/design_tokens.dart';

/// Loại thông báo: màu nhấn + icon + thời gian hiện mặc định.
/// Màu lấy từ [DesignColors] (đỏ theo DESIGN.md; xanh / cam / xanh lam chọn cùng độ sáng).
enum ToastType {
  success(DesignColors.success, Icons.check_circle_outline, Duration(seconds: 3)),
  error(DesignColors.danger, Icons.error_outline, Duration(seconds: 5)),
  warning(DesignColors.warning, Icons.warning_amber_rounded, Duration(seconds: 4)),
  info(DesignColors.info, Icons.info_outline, Duration(seconds: 3));

  const ToastType(this.color, this.icon, this.duration);

  final Color color;
  final IconData icon;
  final Duration duration;
}

/// Hiện toast ở đáy màn (nổi, rộng tối đa 420), thay toast đang hiện nếu có.
/// [actionLabel] + [onAction]: nút chữ bên phải (vd "Thử lại"). Trả về controller để chờ / đóng sớm nếu cần.
ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showToast(
  BuildContext context,
  String message, {
  ToastType type = ToastType.info,
  String? actionLabel,
  VoidCallback? onAction,
  Duration? duration,
}) {
  final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
  final screen = MediaQuery.sizeOf(context).width;
  return messenger.showSnackBar(
    SnackBar(
      key: ValueKey('toast-${type.name}'),
      content: ToastContent(message: message, type: type),
      behavior: SnackBarBehavior.floating,
      width: (screen - 32).clamp(0, 420).toDouble(),
      backgroundColor: DesignColors.panel,
      elevation: 8,
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
      duration: duration ?? type.duration,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: type.color.withValues(alpha: 0.55)),
      ),
      action: actionLabel == null
          ? null
          : SnackBarAction(label: actionLabel, textColor: type.color, onPressed: onAction ?? () {}),
    ),
  );
}

/// Phần thân toast: icon màu theo loại + nội dung (tách riêng để test và dùng lại).
class ToastContent extends StatelessWidget {
  const ToastContent({super.key, required this.message, required this.type});

  final String message;
  final ToastType type;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(type.icon, size: 20, color: type.color),
          ),
          Expanded(child: Text(message, style: DesignText.body)),
        ],
      ),
    );
  }
}
