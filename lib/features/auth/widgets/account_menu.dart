import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/providers/auth_provider.dart';
import '../../../shared/theme/design_tokens.dart';
import '../../../shared/widgets/amber_logo.dart';
import '../../../shared/widgets/app_toast.dart';

/// Logo Amber ở góc phải thanh trên; bấm mở menu tài khoản:
/// email (khi biết) · Cài đặt · Đăng xuất / Đăng nhập. Chat với Amber nằm ở nút nổi góc phải dưới (AmberChatDock).
class AccountMenu extends ConsumerWidget {
  const AccountMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider).value;
    final signedIn = auth != null && auth is! Unauthenticated;
    final email = auth is Authenticated ? auth.user['email'] as String? : null;

    return MenuAnchor(
      alignmentOffset: const Offset(0, 6),
      style: MenuStyle(
        backgroundColor: const WidgetStatePropertyAll(DesignColors.panel),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        elevation: const WidgetStatePropertyAll(8),
        padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 6)),
        minimumSize: const WidgetStatePropertyAll(Size(240, 0)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: DesignColors.panelBorder),
          ),
        ),
      ),
      builder: (context, controller, _) => Semantics(
        button: true,
        label: 'Tài khoản',
        child: InkResponse(
          key: const ValueKey('account-menu-button'),
          radius: 24,
          onTap: () => controller.isOpen ? controller.close() : controller.open(),
          child: const AmberLogo(),
        ),
      ),
      menuChildren: [
        if (email != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
            child: Text(email, style: DesignText.serif(fontSize: 13, color: DesignColors.muted)),
          ),
        _item(
          key: 'account-menu-settings',
          icon: Icons.settings_outlined,
          label: 'Cài đặt',
          onPressed: () => showToast(context, 'Chưa có màn Cài đặt'),
        ),
        const Divider(height: 9, color: DesignColors.rowDivider),
        if (signedIn)
          _item(
            key: 'account-menu-logout',
            icon: Icons.logout,
            label: 'Đăng xuất',
            color: DesignColors.danger,
            // Router tự về /login khi state thành Unauthenticated.
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          )
        else
          _item(
            key: 'account-menu-login',
            icon: Icons.login,
            label: 'Đăng nhập',
            onPressed: () => context.go('/login'),
          ),
      ],
    );
  }

  Widget _item({
    required String key,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color color = DesignColors.text,
    Widget? trailing,
  }) {
    return MenuItemButton(
      key: ValueKey(key),
      onPressed: onPressed,
      leadingIcon: Icon(icon, size: 18, color: color),
      trailingIcon: trailing,
      style: MenuItemButton.styleFrom(
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        textStyle: DesignText.serif(fontSize: 14),
      ),
      child: Text(label),
    );
  }
}
