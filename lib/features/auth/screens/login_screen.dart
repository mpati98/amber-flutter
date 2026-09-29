import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/auth_provider.dart';
import '../../../shared/services/api_client.dart';
import '../../kieu_lau/screens/kieu_lau_screen.dart';

// Màn login tối thiểu để test luồng JWT thật — làm lại UI khi có router.
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
    setState(() => _submitting = true);
    await ref.read(authControllerProvider.notifier).login(_email.text.trim(), _password.text);
    if (!mounted) return;
    setState(() => _submitting = false);

    final auth = ref.read(authControllerProvider);
    if (auth.value is Authenticated) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const KieuLauScreen()),
      );
      return;
    }
    final error = auth.error;
    final message = error is DioException && error.response?.statusCode == 401
        ? 'Sai email hoặc mật khẩu.'
        : 'Không kết nối được máy chủ ($apiBaseUrl).';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: _password,
                  obscureText: true,
                  autofillHints: const [AutofillHints.password],
                  decoration: const InputDecoration(labelText: 'Mật khẩu'),
                  onSubmitted: (_) => _submitting ? null : _submit(),
                ),
                const SizedBox(height: 4),
                FilledButton(
                  onPressed: _submitting ? null : _submit,
                  child: Text(_submitting ? 'Đang đăng nhập...' : 'Đăng nhập'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
