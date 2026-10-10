import 'dart:async';

import 'package:amber_flutter/features/amber_brain/providers/brain_chat_provider.dart';
import 'package:amber_flutter/features/amber_brain/providers/brain_status_provider.dart';
import 'package:amber_flutter/features/amber_brain/screens/amber_brain_screen.dart';
import 'package:amber_flutter/features/amber_brain/services/brain_api.dart';
import 'package:amber_flutter/shared/services/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_brain.dart';

Future<void> _pump(WidgetTester tester, FakeBrain brain, {Dio? dio}) async {
  final d = dio ?? (Dio(BaseOptions(baseUrl: 'http://brain.test'))..httpClientAdapter = brain);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [brainDioProvider.overrideWithValue(d)],
      child: MaterialApp(theme: ThemeData.dark(), home: const AmberBrainScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

/// Gỡ cây widget để provider hủy Timer.periodic của status — test không còn timer treo.
Future<void> _unmount(WidgetTester tester) => tester.pumpWidget(const SizedBox());

bool _inputEnabled(WidgetTester tester) =>
    tester.widget<TextField>(find.byKey(const Key('brain-input'))).enabled ?? true;

Future<void> _type(WidgetTester tester, String text) async {
  await tester.enterText(find.byKey(const Key('brain-input')), text);
  await tester.pump();
  await tester.tap(find.widgetWithText(FilledButton, 'Gửi'));
}

FakeBrain _brain() => FakeBrain()..script['/v1/status'] = [(200, statusJson())];

void main() {
  test('lỗi mạng trên web gợi ý cho phép truy cập mạng nội bộ', () {
    final e = DioException.connectionError(
      requestOptions: RequestOptions(path: '/v1/chat'),
      reason: 'blocked',
    );
    expect(describeBrainError(e, web: true), allOf(contains('mạng nội bộ'), contains('Cài đặt trang web')));
    expect(describeBrainError(e, web: false), isNot(contains('mạng nội bộ')));
  });

  testWidgets('ngoại tuyến: báo "Amber đang ngoại tuyến" và khóa ô nhập', (tester) async {
    final brain = _brain()..offline = true;
    await _pump(tester, brain);
    expect(find.text('Amber đang ngoại tuyến'), findsOneWidget);
    expect(_inputEnabled(tester), isFalse);
    expect(find.widgetWithText(FilledButton, 'Gửi').evaluate().isNotEmpty, isTrue);
    expect(tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Gửi')).onPressed, isNull);

    // Brain bật lại: bấm "Thử lại" → mở khóa.
    brain.offline = false;
    await tester.tap(find.text('Thử lại'));
    await tester.pumpAndSettle();
    expect(find.text('Amber đang ngoại tuyến'), findsNothing);
    expect(_inputEnabled(tester), isTrue);
    await _unmount(tester);
  });

  testWidgets('lệch môi trường: cảnh báo, khóa ô nhập, vẫn hiện nhãn của brain', (tester) async {
    final brain = FakeBrain()..script['/v1/status'] = [(200, statusJson(env: 'PROD', host: 'amber.duangmai.io.vn'))];
    await _pump(tester, brain);
    expect(find.textContaining('Lệch môi trường'), findsOneWidget);
    expect(find.textContaining('amber.duangmai.io.vn'), findsWidgets);
    expect(find.text('PROD'), findsOneWidget);
    expect(_inputEnabled(tester), isFalse);
    await _unmount(tester);
  });

  testWidgets('cùng môi trường: nhãn DEV, ô nhập mở; 127.0.0.1 và localhost coi như một', (tester) async {
    await _pump(tester, _brain());
    expect(find.text('DEV'), findsOneWidget);
    expect(find.textContaining('Lệch môi trường'), findsNothing);
    expect(_inputEnabled(tester), isTrue);
    expect(hostKey('http://127.0.0.1:3000'), hostKey('localhost:3000'));
    expect(hostKey('https://amber.x'), hostKey('amber.x'));
    await _unmount(tester);
  });

  testWidgets('chat thường: bong bóng đang gõ, khóa ô nhập khi chờ, rồi hiện câu trả lời', (tester) async {
    final brain = _brain()
      ..chatGate = Completer<void>()
      ..script['/v1/chat'] = [(200, replyJson(reply: 'You have 118,792 VND in Momo.'))];
    await _pump(tester, brain);
    await _type(tester, 'how much in Momo');
    await tester.pump();
    expect(find.text('how much in Momo'), findsOneWidget);
    expect(find.text('Amber đang trả lời...'), findsOneWidget);
    expect(_inputEnabled(tester), isFalse);

    brain.chatGate!.complete();
    await tester.pumpAndSettle();
    expect(find.text('Amber đang trả lời...'), findsNothing);
    expect(find.text('You have 118,792 VND in Momo.'), findsOneWidget);
    expect(_inputEnabled(tester), isTrue);
    expect(brain.requests.last.data, {'text': 'how much in Momo'});
    await _unmount(tester);
  });

  Future<FakeBrain> draftFlow(WidgetTester tester) async {
    final brain = _brain()
      ..script['/v1/chat'] = [(200, replyJson(reply: 'Please confirm...', state: 'awaiting_confirm', draft: draftJson))]
      ..script['/v1/confirm'] = [
        (200, replyJson(action: 'recorded', transactionId: 'tx-1', balance: 113792)),
        (200, replyJson(action: 'deleted', transactionId: 'tx-1', balance: 158792)),
      ]
      ..script['/v1/undo'] = [(200, replyJson(state: 'awaiting_undo', undoTarget: undoTargetJson))]
      ..script['/v1/cancel'] = [(200, replyJson(reply: 'Cancelled. Nothing was saved.'))];
    await _pump(tester, brain);
    await _type(tester, 'chi 45k ăn trưa bằng Momo');
    await tester.pumpAndSettle();
    return brain;
  }

  testWidgets('thẻ xác nhận vẽ từ draft; Xác nhận → ghi, hiện số dư mới + nút Hoàn tác', (tester) async {
    final brain = await draftFlow(tester);
    expect(find.text('Xác nhận ghi giao dịch'), findsOneWidget);
    for (final t in ['Chi tiêu', '45.000₫', 'Momo', 'Ăn uống', '10/10/2026 (hôm nay)', 'ăn trưa']) {
      expect(find.text(t), findsOneWidget, reason: t);
    }
    expect(find.text('Please confirm...'), findsNothing); // không hiện câu tiếng Anh của brain
    expect(brain.count('/v1/confirm'), 0); // chưa ghi trước khi bấm

    await tester.tap(find.widgetWithText(FilledButton, 'Xác nhận'));
    await tester.pumpAndSettle();
    expect(brain.requests.last.path, '/v1/confirm');
    expect(brain.requests.last.data, {'conversationId': 'c1', 'accept': true});
    expect(find.textContaining('Đã ghi chi tiêu 45.000₫ vào ví Momo.'), findsOneWidget);
    expect(find.textContaining('Số dư mới: 113.792₫'), findsOneWidget);
    expect(find.text('Đã xác nhận'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Xác nhận'), findsNothing);
    expect(find.widgetWithText(OutlinedButton, 'Hoàn tác'), findsOneWidget);
    await _unmount(tester);
  });

  testWidgets('Hủy → /v1/cancel, thẻ chuyển "Đã hủy", không ghi gì', (tester) async {
    final brain = await draftFlow(tester);
    await tester.tap(find.widgetWithText(OutlinedButton, 'Hủy'));
    await tester.pumpAndSettle();
    expect(brain.requests.last.path, '/v1/cancel');
    expect(brain.count('/v1/confirm'), 0);
    expect(find.text('Đã hủy'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Xác nhận'), findsNothing);
    await _unmount(tester);
  });

  testWidgets('Hoàn tác: /v1/undo → thẻ từ undoTarget → xác nhận rồi mới xóa', (tester) async {
    final brain = await draftFlow(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Xác nhận'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(OutlinedButton, 'Hoàn tác'));
    await tester.pumpAndSettle();
    expect(brain.requests.last.path, '/v1/undo');
    expect(find.text('Hoàn tác giao dịch này?'), findsOneWidget);
    expect(find.text('45.000₫'), findsWidgets);
    expect(brain.count('/v1/confirm'), 1); // mới đề nghị, chưa xóa

    await tester.tap(find.widgetWithText(FilledButton, 'Xóa giao dịch'));
    await tester.pumpAndSettle();
    expect(brain.count('/v1/confirm'), 2);
    expect(find.textContaining('Đã xóa giao dịch chi tiêu 45.000₫ (ví Momo).'), findsOneWidget);
    expect(find.textContaining('Số dư mới: 158.792₫'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Hoàn tác'), findsNothing); // đã hoàn tác xong
    await _unmount(tester);
  });

  testWidgets('hoàn tác khi không có gì để xóa: báo tiếng Việt', (tester) async {
    final brain = await draftFlow(tester);
    brain.script['/v1/undo'] = [(200, replyJson(reply: 'Nothing to undo: ...'))];
    await tester.tap(find.widgetWithText(FilledButton, 'Xác nhận'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Hoàn tác'));
    await tester.pumpAndSettle();
    expect(find.text('Không có giao dịch nào do Amber ghi để hoàn tác.'), findsOneWidget);
    await _unmount(tester);
  });

  testWidgets('404 ở confirm (brain khởi động lại): "Phiên đã hết, hãy gõ lại."', (tester) async {
    final brain = await draftFlow(tester);
    brain.script['/v1/confirm'] = [
      (404, {'error': 'conversation_not_found', 'message': 'Unknown or expired conversation.'}),
    ];
    await tester.tap(find.widgetWithText(FilledButton, 'Xác nhận'));
    await tester.pumpAndSettle();
    expect(find.text('Phiên đã hết, hãy gõ lại.'), findsOneWidget);
    expect(find.text('Đã bỏ qua'), findsOneWidget); // thẻ không còn bấm được
    expect(find.widgetWithText(FilledButton, 'Xác nhận'), findsNothing);
    // Gõ lại: mở hội thoại mới (không gửi id cũ).
    await _type(tester, 'chi 45k ăn trưa bằng Momo');
    await tester.pumpAndSettle();
    expect(brain.requests.where((r) => r.path == '/v1/chat').last.data, {'text': 'chi 45k ăn trưa bằng Momo'});
    await _unmount(tester);
  });

  testWidgets('409 busy: báo đang xử lý, thẻ vẫn bấm lại được', (tester) async {
    final brain = await draftFlow(tester);
    brain.script['/v1/confirm'] = [
      (409, {'error': 'busy', 'message': 'busy'}),
      (200, replyJson(action: 'recorded', balance: 1)),
    ];
    await tester.tap(find.widgetWithText(FilledButton, 'Xác nhận'));
    await tester.pumpAndSettle();
    expect(find.textContaining('đang xử lý'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Xác nhận'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Xác nhận'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Đã ghi chi tiêu'), findsOneWidget);
    await _unmount(tester);
  });

  testWidgets('lỗi mạng giữa chừng: báo không nối được rồi mở khóa nhập', (tester) async {
    final brain = _brain();
    await _pump(tester, brain);
    brain.offline = true;
    await _type(tester, 'hello');
    await tester.pumpAndSettle();
    expect(find.textContaining('Không nối được Amber'), findsOneWidget);
    expect(_inputEnabled(tester), isTrue);
    await _unmount(tester);
  });

  testWidgets('401 → refresh token → gửi lại đúng request đó một lần', (tester) async {
    final brain = _brain()
      ..requiredToken = 'new'
      ..script['/v1/chat'] = [(200, replyJson(reply: 'Hi there'))];
    final refreshBackend = FakeBrain()
      ..script['/api/mobile/auth/refresh'] = [
        (200, {'accessToken': 'new', 'refreshToken': 'r2'}),
      ];
    final storage = MemoryTokenStorage(access: 'old', refresh: 'r1');
    final refresher = TokenRefresher(
      storage,
      dio: Dio(BaseOptions(baseUrl: 'http://api.test'))..httpClientAdapter = refreshBackend,
    );
    final dio = createBrainClient(storage, refresher, baseUrl: 'http://brain.test')..httpClientAdapter = brain;

    await _pump(tester, brain, dio: dio);
    await _type(tester, 'hello');
    await tester.pumpAndSettle();

    final chats = brain.requests.where((r) => r.path == '/v1/chat').toList();
    expect(chats.length, 2); // lần đầu 401, gửi lại 1 lần
    expect(brain.authsOf('/v1/chat'), ['Bearer old', 'Bearer new']);
    expect(chats.last.data, chats.first.data);
    expect(refreshBackend.count('/api/mobile/auth/refresh'), 1);
    expect(storage.refresh, 'r2');
    expect(find.text('Hi there'), findsOneWidget);
    // /v1/status không gắn Bearer (không cần token).
    expect(brain.authsOf('/v1/status').every((a) => a == null), isTrue);
    await _unmount(tester);
  });

  testWidgets('refresh bị từ chối: lỗi phiên đăng nhập, không gửi lại', (tester) async {
    final brain = _brain()
      ..requiredToken = 'new'
      ..script['/v1/chat'] = [(200, replyJson(reply: 'x'))];
    final refreshBackend = FakeBrain()
      ..script['/api/mobile/auth/refresh'] = [
        (401, {'error': 'invalid_refresh_token'}),
      ];
    final storage = MemoryTokenStorage(access: 'old', refresh: 'r1');
    final refresher = TokenRefresher(
      storage,
      dio: Dio(BaseOptions(baseUrl: 'http://api.test'))..httpClientAdapter = refreshBackend,
    );
    final dio = createBrainClient(storage, refresher, baseUrl: 'http://brain.test')..httpClientAdapter = brain;
    await _pump(tester, brain, dio: dio);
    await _type(tester, 'hello');
    await tester.pumpAndSettle();
    expect(brain.count('/v1/chat'), 1);
    expect(find.textContaining('đăng nhập'), findsOneWidget);
    expect(storage.access, isNull);
    await _unmount(tester);
  });

  testWidgets('status gọi khi mở và mỗi 20 giây; dừng khi app ẩn, gọi lại khi quay lại', (tester) async {
    final brain = _brain();
    await _pump(tester, brain);
    expect(brain.count('/v1/status'), 1);
    await tester.pump(brainPollInterval);
    expect(brain.count('/v1/status'), 2);
    await tester.pump(brainPollInterval);
    expect(brain.count('/v1/status'), 3);

    for (final st in [AppLifecycleState.inactive, AppLifecycleState.hidden, AppLifecycleState.paused]) {
      tester.binding.handleAppLifecycleStateChanged(st);
    }
    await tester.pump(brainPollInterval * 3);
    expect(brain.count('/v1/status'), 3);

    for (final st in [AppLifecycleState.hidden, AppLifecycleState.inactive, AppLifecycleState.resumed]) {
      tester.binding.handleAppLifecycleStateChanged(st);
    }
    await tester.pumpAndSettle();
    expect(brain.count('/v1/status'), 4);
    await _unmount(tester);
  });
}
