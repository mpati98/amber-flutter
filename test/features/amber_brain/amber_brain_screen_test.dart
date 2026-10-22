import 'dart:async';

import 'package:amber_flutter/features/amber_brain/providers/brain_chat_provider.dart';
import 'package:amber_flutter/features/amber_brain/providers/brain_status_provider.dart';
import 'package:amber_flutter/features/amber_brain/screens/amber_brain_screen.dart';
import 'package:amber_flutter/features/amber_brain/services/brain_api.dart';
import 'package:amber_flutter/shared/services/api_client.dart';
import 'package:amber_flutter/shared/utils/currency.dart';
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
  await tester.tap(find.widgetWithText(FilledButton, 'Send'));
}

String? _hint(WidgetTester tester) => tester.widget<TextField>(find.byKey(const Key('brain-input'))).decoration?.hintText;

FakeBrain _brain() => FakeBrain()..script['/v1/status'] = [(200, statusJson())];

void main() {
  test('network error on web suggests allowing local-network access', () {
    final e = DioException.connectionError(
      requestOptions: RequestOptions(path: '/v1/chat'),
      reason: 'blocked',
    );
    expect(describeBrainError(e, web: true), allOf(contains('local-network'), contains('Site settings')));
    expect(describeBrainError(e, web: false), isNot(contains('local-network')));
  });

  testWidgets('offline: shows "Amber is offline" and locks the input', (tester) async {
    final brain = _brain()..offline = true;
    await _pump(tester, brain);
    expect(find.text('Amber is offline'), findsOneWidget);
    expect(_inputEnabled(tester), isFalse);
    expect(find.widgetWithText(FilledButton, 'Send').evaluate().isNotEmpty, isTrue);
    expect(tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Send')).onPressed, isNull);
    expect(_hint(tester), "Amber isn't ready");

    // Brain is back: tap "Retry" → unlocked.
    brain.offline = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Amber is offline'), findsNothing);
    expect(_inputEnabled(tester), isTrue);
    await _unmount(tester);
  });

  testWidgets('environment mismatch: warning, input locked, brain label still shown', (tester) async {
    final brain = FakeBrain()..script['/v1/status'] = [(200, statusJson(env: 'PROD', host: 'amber.duangmai.io.vn'))];
    await _pump(tester, brain);
    expect(find.textContaining('Environment mismatch'), findsOneWidget);
    expect(find.textContaining('amber.duangmai.io.vn'), findsWidgets);
    expect(find.text('PROD'), findsOneWidget);
    expect(_inputEnabled(tester), isFalse);
    await _unmount(tester);
  });

  testWidgets('same environment: DEV label, input open; 127.0.0.1 and localhost count as one', (tester) async {
    await _pump(tester, _brain());
    expect(find.text('DEV'), findsOneWidget);
    expect(find.textContaining('Environment mismatch'), findsNothing);
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
    expect(find.text('Amber is replying...'), findsOneWidget);
    expect(_inputEnabled(tester), isFalse);

    brain.chatGate!.complete();
    await tester.pumpAndSettle();
    expect(find.text('Amber is replying...'), findsNothing);
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
    expect(find.text('Recorded an expense of 45,000₫ to Momo. New balance: 113,792₫.'), findsOneWidget);
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
    expect(find.text('Deleted the expense of 45,000₫ (Momo). New balance: 158,792₫.'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Hoàn tác'), findsNothing); // đã hoàn tác xong
    await _unmount(tester);
  });

  testWidgets('undo with nothing to delete: English notice', (tester) async {
    final brain = await draftFlow(tester);
    brain.script['/v1/undo'] = [(200, replyJson(reply: 'Nothing to undo: ...'))];
    await tester.tap(find.widgetWithText(FilledButton, 'Xác nhận'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Hoàn tác'));
    await tester.pumpAndSettle();
    expect(find.text('There is no transaction recorded by Amber to undo.'), findsOneWidget);
    await _unmount(tester);
  });

  testWidgets('404 on confirm (brain restarted): "The session expired. Please type it again."', (tester) async {
    final brain = await draftFlow(tester);
    brain.script['/v1/confirm'] = [
      (404, {'error': 'conversation_not_found', 'message': 'Unknown or expired conversation.'}),
    ];
    await tester.tap(find.widgetWithText(FilledButton, 'Xác nhận'));
    await tester.pumpAndSettle();
    expect(find.text('The session expired. Please type it again.'), findsOneWidget);
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
    expect(find.textContaining('still handling'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Xác nhận'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Xác nhận'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Recorded an expense of'), findsOneWidget);
    await _unmount(tester);
  });

  testWidgets('network error mid-chat: says it cannot reach Amber, then unlocks the input', (tester) async {
    final brain = _brain();
    await _pump(tester, brain);
    brain.offline = true;
    await _type(tester, 'hello');
    await tester.pumpAndSettle();
    expect(find.textContaining("Can't reach Amber"), findsOneWidget);
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
    expect(find.textContaining('sign in again'), findsOneWidget);
    expect(storage.access, isNull);
    await _unmount(tester);
  });

  group('English input chrome and fixed error line', () {
    testWidgets('ready: "Type a message..." hint and "Send" button; no Vietnamese chrome left', (tester) async {
      await _pump(tester, _brain());
      expect(_hint(tester), 'Type a message...');
      expect(find.widgetWithText(FilledButton, 'Send'), findsOneWidget);
      expect(find.text('Gửi'), findsNothing);
      expect(find.text('Nhập tin nhắn...'), findsNothing);
      await _unmount(tester);
    });

    testWidgets('environment mismatch locks the input with the "isn\'t ready" hint', (tester) async {
      final brain = FakeBrain()..script['/v1/status'] = [(200, statusJson(host: 'api.other.test'))];
      await _pump(tester, brain);
      expect(_inputEnabled(tester), isFalse);
      expect(_hint(tester), "Amber isn't ready");
      await _unmount(tester);
    });

    testWidgets('while waiting: input locked, button shows "..." and the hint stays English', (tester) async {
      final gate = Completer<void>();
      final brain = _brain()
        ..chatGate = gate
        ..script['/v1/chat'] = [(200, replyJson(reply: 'ok'))];
      await _pump(tester, brain);
      await _type(tester, 'hello');
      await tester.pump();
      expect(_inputEnabled(tester), isFalse);
      expect(_hint(tester), 'Type a message...');
      expect(find.widgetWithText(FilledButton, '...'), findsOneWidget);
      gate.complete();
      await tester.pumpAndSettle();
      expect(find.widgetWithText(FilledButton, 'Send'), findsOneWidget);
      await _unmount(tester);
    });

    test('an unexpected exception gives the fixed line and goes to the log instead', () {
      final logged = <String>[];
      final old = debugPrint;
      debugPrint = (String? m, {int? wrapWidth}) => logged.add(m ?? '');
      addTearDown(() => debugPrint = old);
      for (final e in [StateError('secret internal detail'), const FormatException('bad json'), TypeError()]) {
        expect(describeBrainError(e), 'Something went wrong. Please try again.');
        expect(describeBrainError(e, web: true), isNot(contains('secret')));
      }
      expect(logged.length, 6);
      expect(logged.first, contains('secret internal detail'));
      expect(logged[2], contains('bad json'));
    });

    testWidgets('a malformed reply shows the fixed line in the chat, not the exception', (tester) async {
      final logged = <String>[];
      final old = debugPrint;
      debugPrint = (String? m, {int? wrapWidth}) => logged.add(m ?? '');
      final brain = _brain()..script['/v1/chat'] = [(200, {'unexpected': 'shape'})];
      await _pump(tester, brain);
      await _type(tester, 'hello');
      await tester.pumpAndSettle();
      debugPrint = old; // the binding checks this before tearDown callbacks run
      expect(find.text('Something went wrong. Please try again.'), findsOneWidget);
      expect(find.textContaining('type '), findsNothing);
      expect(find.textContaining('Exception'), findsNothing);
      expect(find.textContaining('is not a subtype'), findsNothing);
      expect(logged.where((l) => l.startsWith('Amber brain chat error')), isNotEmpty);
      expect(_inputEnabled(tester), isTrue);
      await _unmount(tester);
    });
  });

  group('English chat result lines', () {
    final vietnamese = RegExp(r'[àáảãạăằắẳẵặâầấẩẫậèéẻẽẹêềếểễệìíỉĩịòóỏõọôồốổỗộơờớởỡợùúủũụưừứửữựỳýỷỹỵđ]', caseSensitive: false);

    test('formatVndEn uses commas, formatVnd keeps dots for the cards', () {
      expect(formatVndEn(2813000), '2,813,000₫');
      expect(formatVndEn(35000), '35,000₫');
      expect(formatVndEn(999), '999₫');
      expect(formatVndEn(0), '0₫');
      expect(formatVndEn(-1500), '-1,500₫');
      expect(formatVnd(2813000), '2.813.000₫');
    });

    test('recorded: expense and income, with and without balance', () {
      expect(
        recordedMessage(income: false, amount: 35000, account: 'Cash', balance: 2813000),
        'Recorded an expense of 35,000₫ to Cash. New balance: 2,813,000₫.',
      );
      expect(
        recordedMessage(income: true, amount: 5000000, account: 'Momo', balance: 5083792),
        'Recorded income of 5,000,000₫ to Momo. New balance: 5,083,792₫.',
      );
      expect(recordedMessage(income: false, amount: 35000, account: 'Cash'), 'Recorded an expense of 35,000₫ to Cash.');
    });

    test('deleted: expense and income, with and without balance', () {
      expect(
        deletedMessage(income: false, amount: 15000, account: 'Momo', balance: 83792),
        'Deleted the expense of 15,000₫ (Momo). New balance: 83,792₫.',
      );
      expect(
        deletedMessage(income: true, amount: 5000000, account: 'Momo', balance: 83792),
        'Deleted the income of 5,000,000₫ (Momo). New balance: 83,792₫.',
      );
      expect(deletedMessage(income: false, amount: 15000, account: 'Momo'), 'Deleted the expense of 15,000₫ (Momo).');
    });

    test('wallet names from the user data are kept as they are', () {
      expect(recordedMessage(income: false, amount: 1000, account: 'Tiền mặt'), 'Recorded an expense of 1,000₫ to Tiền mặt.');
    });

    test('every error line the chat can show is English', () {
      final ro = RequestOptions(path: '/v1/chat');
      DioException http(int status, [Object? data]) => DioException(
        requestOptions: ro,
        response: Response(requestOptions: ro, statusCode: status, data: data),
        type: DioExceptionType.badResponse,
      );
      final errors = <DioException>[
        http(404, {'error': 'conversation_not_found'}),
        http(409, {'error': 'busy'}),
        http(409, {'error': 'invalid_state'}),
        http(401),
        http(502),
        http(500),
        DioException.receiveTimeout(timeout: const Duration(seconds: 60), requestOptions: ro),
        DioException.connectionTimeout(timeout: const Duration(seconds: 60), requestOptions: ro),
        DioException.connectionError(requestOptions: ro, reason: 'refused'),
      ];
      for (final e in errors) {
        for (final web in [true, false]) {
          final msg = describeBrainError(e, web: web);
          expect(msg, isNotEmpty);
          expect(vietnamese.hasMatch(msg), isFalse, reason: msg);
        }
      }
      expect(vietnamese.hasMatch(describeBrainError(StateError('boom'))), isFalse);
    });

    testWidgets('income draft → "Recorded income of …", then undo → "Deleted the income of …"', (tester) async {
      final income = {...draftJson, 'kind': 'INCOME', 'amount': 5000000};
      final target = {...undoTargetJson, 'kind': 'INCOME', 'amount': 5000000};
      final brain = _brain()
        ..script['/v1/chat'] = [(200, replyJson(reply: 'x', state: 'awaiting_confirm', draft: income))]
        ..script['/v1/confirm'] = [
          (200, replyJson(action: 'recorded', transactionId: 'tx-1', balance: 5083792)),
          (200, replyJson(action: 'deleted', transactionId: 'tx-1', balance: 83792)),
        ]
        ..script['/v1/undo'] = [(200, replyJson(state: 'awaiting_undo', undoTarget: target))];
      await _pump(tester, brain);
      await _type(tester, 'salary 5m to Momo');
      await tester.pumpAndSettle();
      expect(find.text('Thu nhập'), findsOneWidget); // card label stays Vietnamese
      await tester.tap(find.widgetWithText(FilledButton, 'Xác nhận'));
      await tester.pumpAndSettle();
      expect(find.text('Recorded income of 5,000,000₫ to Momo. New balance: 5,083,792₫.'), findsOneWidget);
      await tester.tap(find.widgetWithText(OutlinedButton, 'Hoàn tác'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Xóa giao dịch'));
      await tester.pumpAndSettle();
      expect(find.text('Deleted the income of 5,000,000₫ (Momo). New balance: 83,792₫.'), findsOneWidget);
      await _unmount(tester);
    });

    testWidgets('cancel and the empty-state hint are English; the cards keep Vietnamese labels', (tester) async {
      final brain = await draftFlow(tester);
      expect(find.text('Xác nhận ghi giao dịch'), findsOneWidget);
      await tester.tap(find.widgetWithText(OutlinedButton, 'Hủy'));
      await tester.pumpAndSettle();
      expect(find.text('Cancelled. Nothing was changed.'), findsOneWidget);
      expect(find.text('Đã hủy'), findsOneWidget); // the card status is a card label
      expect(brain.count('/v1/cancel'), 1);
      await _unmount(tester);

      final fresh = _brain();
      await _pump(tester, fresh);
      expect(find.textContaining('spent 45k on lunch with Momo'), findsOneWidget);
      await _unmount(tester);
    });
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
