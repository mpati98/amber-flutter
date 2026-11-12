import 'dart:ui' show ImageFilter;

import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/auth_provider.dart';
import '../../../shared/services/api_client.dart';
import '../../../shared/theme/design_tokens.dart';
import '../../../shared/widgets/app_toast.dart';
import '../widgets/login_scene.dart';

// Màu riêng của form đăng nhập trong design/ref/login.html.
const _line = Color(0xFFC9CDE6); // gạch chân ô nhập + chữ gợi ý
const _fieldBg = Color(0x8C050816); // rgba(5,8,22,.55)
const _button = Color(0xFFE8C987);
final _style = DesignText.serif(fontSize: 15);

/// Màn đăng nhập: cảnh đêm Âm Dương Giới + khung kính mờ ở giữa (rộng tối đa 360) chứa AMBER, tiêu đề, Email, Mật khẩu, nút.
/// Bản mẫu để form 200 px không khung; trên màn lớn quá nhỏ nên phóng to tỉ lệ và thêm khung.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    await ref.read(authControllerProvider.notifier).login(_email.text.trim(), _password.text);
    if (!mounted) return;
    setState(() => _submitting = false);

    final auth = ref.read(authControllerProvider);
    // Thành công: router tự chuyển (redirect /login → đích trong ?from= hoặc '/').
    if (auth.value is Authenticated) return;
    final error = auth.error;
    final message = error is DioException && error.response?.statusCode == 401
        ? 'Sai email hoặc mật khẩu.'
        : 'Không kết nối được máy chủ ($apiBaseUrl).';
    showToast(context, message, type: ToastType.error);
  }

  @override
  Widget build(BuildContext context) {
    // Cảnh nằm ngoài Scaffold: bàn phím chỉ thu nhỏ phần form, núi và trăng không nhảy.
    return Stack(
      children: [
        const Positioned.fill(child: LoginScene()),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: _GlassCard(child: _form()),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _form() {
    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'AMBER',
            textAlign: TextAlign.center,
            style: _style.copyWith(fontSize: 12, letterSpacing: 4, color: DesignColors.muted),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Text(
              'Âm Dương Giới',
              textAlign: TextAlign.center,
              style: _style.copyWith(fontSize: 26, color: DesignColors.text),
            ),
          ),
          _LoginField(
            key: const ValueKey('login-email'),
            controller: _email,
            hint: 'Email',
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            textInputAction: TextInputAction.next,
          ),
          _LoginField(
            key: const ValueKey('login-password'),
            controller: _password,
            hint: 'Mật khẩu',
            obscureText: true,
            autofillHints: const [AutofillHints.password],
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 6),
          FilledButton(
            onPressed: _submitting ? null : _submit,
            style: FilledButton.styleFrom(
              backgroundColor: _button,
              foregroundColor: const Color(0xFF1A1A1A),
              disabledBackgroundColor: _button.withValues(alpha: 0.6),
              disabledForegroundColor: const Color(0xFF1A1A1A),
              padding: const EdgeInsets.symmetric(vertical: 14),
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              textStyle: _style,
            ),
            child: Text(_submitting ? 'Đang đăng nhập...' : 'Đăng nhập'),
          ),
        ],
      ),
    );
  }
}

/// Ô nhập: nền tối mờ, chỉ gạch chân, chữ trắng; gợi ý trong ô (placeholder), không có nhãn nổi.
class _LoginField extends StatelessWidget {
  const _LoginField({
    super.key,
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.obscureText = false,
    this.autofillHints,
    this.textInputAction,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Iterable<String>? autofillHints;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    const underline = UnderlineInputBorder(borderSide: BorderSide(color: _line));
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        autofillHints: autofillHints,
        textInputAction: textInputAction,
        onSubmitted: onSubmitted,
        cursorColor: Colors.white,
        style: _style.copyWith(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: _style.copyWith(color: _line),
          filled: true,
          fillColor: _fieldBg,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          border: underline,
          enabledBorder: underline,
          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: DesignColors.gold)),
        ),
      ),
    );
  }
}

/// Khung kính mờ: làm mờ cảnh phía sau, nền tối trong suốt, viền sáng mảnh, bo 16.
class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);
    return DecoratedBox(
      key: const ValueKey('login-card'),
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 32, offset: Offset(0, 12))],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
            decoration: BoxDecoration(
              color: DesignColors.panel.withValues(alpha: 0.45),
              borderRadius: radius,
              border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
