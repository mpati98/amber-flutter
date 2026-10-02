import 'dart:async';

import 'package:amber_flutter/features/tra_dinh/models/practice_message.dart';
import 'package:amber_flutter/features/tra_dinh/models/practice_session.dart';
import 'package:amber_flutter/features/tra_dinh/screens/practice_chat_screen.dart';
import 'package:amber_flutter/features/tra_dinh/services/recording_service.dart';
import 'package:amber_flutter/features/tra_dinh/services/tra_dinh_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_recorder.dart';

PracticeMessage _msg(String id, MessageRole role, String content) =>
    PracticeMessage(id: id, role: role, content: content, createdAt: DateTime.utc(2026, 10, 2));

DioException _httpError(int status, String code) {
  final req = RequestOptions(path: '/api/tra-dinh/sessions/s1/messages');
  return DioException(
    requestOptions: req,
    type: DioExceptionType.badResponse,
    response: Response(requestOptions: req, statusCode: status, data: {'error': code}),
  );
}

/// TraDinhApi giả — không gọi mạng. [server] là "DB": như route thật, chỉ ghi
/// khi gửi thành công (lỗi, kể cả 502, không ghi gì).
class _FakeApi extends TraDinhApi {
  _FakeApi() : super(Dio());

  final server = <PracticeMessage>[_msg('m1', MessageRole.user, 'Hello'), _msg('m2', MessageRole.assistant, 'Hi!')];
  DateTime? archivedAt;
  String? summary;
  Object? failWith;
  Completer<void>? gate;
  int detailCalls = 0;

  @override
  Future<PracticeSession> getSessionDetail(String id) async {
    detailCalls++;
    return PracticeSession(
      id: id,
      name: 'Buổi thử',
      mode: PracticeMode.conversation,
      createdAt: DateTime.utc(2026, 10, 2),
      archivedAt: archivedAt,
      summary: summary,
      messages: List.of(server),
    );
  }

  @override
  Future<({PracticeMessage userMessage, PracticeMessage assistantMessage})> sendMessage(
    String sessionId, {
    required String content,
    String? audioUrl,
  }) async {
    await gate?.future;
    if (failWith case final e?) throw e;
    final user = _msg('u${server.length}', MessageRole.user, content);
    final ai = _msg('a${server.length}', MessageRole.assistant, 'Reply to: $content');
    server.addAll([user, ai]);
    return (userMessage: user, assistantMessage: ai);
  }
}

Future<void> _pump(WidgetTester tester, _FakeApi api) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        traDinhApiProvider.overrideWithValue(api),
        // Không tạo AudioRecorder thật (plugin) trong test.
        recordingServiceProvider.overrideWithValue(FakeRecorder()),
      ],
      child: MaterialApp(
        theme: ThemeData.dark(),
        home: const PracticeChatScreen(sessionId: 's1'),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _typeAndSend(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextField), text);
  await tester.pump();
  await tester.tap(find.widgetWithText(FilledButton, 'Gửi'));
  await tester.pump();
}

String _fieldText(WidgetTester tester) => tester.widget<TextField>(find.byType(TextField)).controller!.text;

void main() {
  testWidgets('gửi thành công: hiện tin đang gửi + "đang trả lời", rồi chèn cả 2 tin, không tải lại', (tester) async {
    final api = _FakeApi()..gate = Completer<void>();
    await _pump(tester, api);
    expect(find.text('Hello'), findsOneWidget);
    expect(find.text('Hi!'), findsOneWidget);

    await _typeAndSend(tester, 'How are you?');
    expect(find.text('How are you?'), findsOneWidget); // bong bóng mờ
    expect(find.text('Đang trả lời...'), findsOneWidget);
    expect(_fieldText(tester), isEmpty);

    api.gate!.complete();
    await tester.pumpAndSettle();
    expect(find.text('Đang trả lời...'), findsNothing);
    expect(find.text('How are you?'), findsOneWidget);
    expect(find.text('Reply to: How are you?'), findsOneWidget);
    expect(api.detailCalls, 1); // chèn vào state, không GET lại
  });

  testWidgets('lỗi mạng: SnackBar, trả chữ về ô nhập, không thêm tin', (tester) async {
    final api = _FakeApi()
      ..failWith = DioException(requestOptions: RequestOptions(), type: DioExceptionType.connectionError);
    await _pump(tester, api);

    await _typeAndSend(tester, 'Lost message');
    await tester.pumpAndSettle();
    expect(find.textContaining('Không gửi được tin nhắn'), findsOneWidget);
    expect(_fieldText(tester), 'Lost message');
    expect(find.widgetWithText(FilledButton, 'Gửi'), findsOneWidget);
    expect(api.server, hasLength(2));
  });

  testWidgets('502 AI lỗi: xử lý như mọi lỗi khác — SnackBar, trả chữ về ô, không tải lại', (tester) async {
    final api = _FakeApi()..failWith = _httpError(502, 'ai_unavailable');
    await _pump(tester, api);

    await _typeAndSend(tester, 'Retry me');
    await tester.pumpAndSettle();
    expect(find.textContaining('Không gửi được tin nhắn (502)'), findsOneWidget);
    expect(_fieldText(tester), 'Retry me');
    expect(find.text('Đang trả lời...'), findsNothing);
    expect(api.server, hasLength(2));
    expect(api.detailCalls, 1);
  });

  testWidgets('400 session_ended: báo, tải lại, ẩn ô nhập, hiện tóm tắt', (tester) async {
    final api = _FakeApi()..failWith = _httpError(400, 'session_ended');
    await _pump(tester, api);
    // Thiết bị khác kết thúc buổi trong lúc màn này đang mở.
    api
      ..archivedAt = DateTime.utc(2026, 10, 2, 12)
      ..summary = 'Tóm tắt từ server';

    await _typeAndSend(tester, 'Too late');
    await tester.pumpAndSettle();
    expect(find.textContaining('đã kết thúc'), findsWidgets);
    expect(find.byType(TextField), findsNothing);
    expect(find.text('Tóm tắt buổi luyện'), findsOneWidget);
    expect(find.text('Tóm tắt từ server'), findsOneWidget);
  });

  testWidgets('buổi đã kết thúc từ đầu: không có ô nhập, có khung tóm tắt', (tester) async {
    final api = _FakeApi()
      ..archivedAt = DateTime.utc(2026, 10, 1)
      ..summary = 'Đã luyện chào hỏi.';
    await _pump(tester, api);
    expect(find.byType(TextField), findsNothing);
    expect(find.text('Đã luyện chào hỏi.'), findsOneWidget);
    expect(find.text('Hello'), findsOneWidget);
  });
}
