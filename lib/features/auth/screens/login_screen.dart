import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/auth_provider.dart';
import '../../../shared/services/api_client.dart';

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
        MaterialPageRoute<void>(builder: (_) => const _LoggedInScreen()),
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

// TODO: màn tạm để xác nhận token lưu được và request sau có Bearer — xoá khi có màn thật.
class _LoggedInScreen extends ConsumerStatefulWidget {
  const _LoggedInScreen();

  @override
  ConsumerState<_LoggedInScreen> createState() => _LoggedInScreenState();
}

class _LoggedInScreenState extends ConsumerState<_LoggedInScreen> {
  String? _probeResult;

  Future<void> _probeApi() async {
    setState(() => _probeResult = 'Đang gọi...');
    String result;
    try {
      final res = await ref.read(apiClientProvider).get<Map<String, dynamic>>('/api/kieu-lau/notifications');
      final alerts = res.data!['alerts'] as List<dynamic>;
      result = '${res.statusCode} — ${alerts.length} cảnh báo';
    } on DioException catch (e) {
      result = 'Lỗi ${e.response?.statusCode ?? '${e.type.name}: ${e.error}'}';
    }
    if (mounted) setState(() => _probeResult = result);
  }

  Future<void> _logout() async {
    await ref.read(authControllerProvider.notifier).logout();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider).value;
    final user = auth is Authenticated ? auth.user : null;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            Text('Đã đăng nhập', style: Theme.of(context).textTheme.titleLarge),
            if (user != null) Text('${user['name'] ?? ''} <${user['email']}>'),
            OutlinedButton(onPressed: _probeApi, child: const Text('Gọi thử GET /api/kieu-lau/notifications')),
            if (_probeResult != null) Text(_probeResult!),
            TextButton(onPressed: _logout, child: const Text('Đăng xuất')),
          ],
        ),
      ),
    );
  }
}
