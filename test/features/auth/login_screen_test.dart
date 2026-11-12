import 'dart:async';

import 'package:amber_flutter/features/auth/screens/login_screen.dart';
import 'package:amber_flutter/features/auth/widgets/login_scene.dart';
import 'package:amber_flutter/shared/providers/auth_provider.dart';
import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Đăng nhập giả: ghi lại thông tin gửi đi, kết quả do [result] quyết định (null = thành công).
class _FakeAuth extends AuthController {
  _FakeAuth(this.result);

  final Object? Function() result;
  final calls = <(String, String)>[];
  Completer<void>? gate;

  @override
  Future<AuthState> build() async => Unauthenticated();

  @override
  Future<void> login(String email, String password) async {
    calls.add((email, password));
    await gate?.future;
    final error = result();
    state = error == null
        ? const AsyncData(Authenticated({'id': 'u', 'email': 'a@b.c', 'name': 'A'}))
        : AsyncError(error, StackTrace.empty);
  }
}

DioException _http(int code) {
  final req = RequestOptions(path: '/api/mobile/auth/login');
  return DioException(requestOptions: req, response: Response(requestOptions: req, statusCode: code));
}

Future<_FakeAuth> _pump(WidgetTester tester, {Object? Function()? result}) async {
  final fake = _FakeAuth(result ?? () => null);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [authControllerProvider.overrideWith(() => fake)],
      child: MaterialApp(theme: ThemeData.dark(), home: const LoginScreen()),
    ),
  );
  await tester.pumpAndSettle();
  return fake;
}

Future<void> _fill(WidgetTester tester) async {
  await tester.enterText(find.byKey(const ValueKey('login-email')), '  me@duangmai.io.vn ');
  await tester.enterText(find.byKey(const ValueKey('login-password')), 'bí mật');
}

void main() {
  testWidgets('bố cục: cảnh đêm + AMBER, Âm Dương Giới, Email, Mật khẩu, nút Đăng nhập; khung kính rộng tối đa 360', (tester) async {
    await _pump(tester);
    expect(find.byType(LoginScene), findsOneWidget);
    expect(find.byKey(const ValueKey('login-moon')), findsOneWidget);
    expect(find.text('AMBER'), findsOneWidget);
    expect(find.text('Âm Dương Giới'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Mật khẩu'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Đăng nhập'), findsOneWidget);
    // Màn 800 px: khung chặn ở 360, ô nhập trải hết bề ngang trong khung.
    expect(tester.getSize(find.byKey(const ValueKey('login-card'))).width, 360);
    expect(tester.getSize(find.byKey(const ValueKey('login-email'))).width, 360 - 2 * 28 - 2); // trừ padding + viền 1 px
    expect(find.descendant(of: find.byKey(const ValueKey('login-card')), matching: find.byType(BackdropFilter)), findsOneWidget);
    expect(tester.widget<TextField>(find.descendant(of: find.byKey(const ValueKey('login-password')), matching: find.byType(TextField))).obscureText, isTrue);
  });

  testWidgets('bấm Đăng nhập → gửi email đã bỏ khoảng trắng + mật khẩu nguyên văn', (tester) async {
    final fake = await _pump(tester);
    await _fill(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Đăng nhập'));
    await tester.pumpAndSettle();
    expect(fake.calls, [('me@duangmai.io.vn', 'bí mật')]);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('Enter ở ô mật khẩu cũng gửi; đang gửi thì khoá nút, không gửi lần 2', (tester) async {
    final fake = await _pump(tester);
    fake.gate = Completer();
    await _fill(tester);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(find.text('Đang đăng nhập...'), findsOneWidget);
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNull);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    fake.gate!.complete();
    await tester.pumpAndSettle();
    expect(fake.calls, hasLength(1));
  });

  testWidgets('401 → "Sai email hoặc mật khẩu."', (tester) async {
    await _pump(tester, result: () => _http(401));
    await _fill(tester);
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(find.text('Sai email hoặc mật khẩu.'), findsOneWidget);
    expect(find.byKey(const ValueKey('toast-error')), findsOneWidget);
    expect(find.text('Đăng nhập'), findsOneWidget); // nút mở lại
  });

  testWidgets('lỗi mạng → báo không kết nối được máy chủ', (tester) async {
    await _pump(tester, result: () => Exception('offline'));
    await _fill(tester);
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(find.textContaining('Không kết nối được máy chủ'), findsOneWidget);
  });

  testWidgets('320 px, chữ ×2,0, bàn phím mở: không tràn', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: 260);
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _pump(tester);
    expect(tester.takeException(), isNull);
  });
}
