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

class _FakeApi extends TraDinhApi {
  _FakeApi() : super(Dio());

  Completer<String>? transcribeResult;
  Object? transcribeError;
  final transcribed = <({String path, String filename})>[];
  int sendCalls = 0;

  @override
  Future<PracticeSession> getSessionDetail(String id) async => PracticeSession(
    id: id,
    name: 'Buổi thử',
    mode: PracticeMode.conversation,
    createdAt: DateTime.utc(2026, 10, 2),
    messages: [
      PracticeMessage(id: 'm1', role: MessageRole.assistant, content: 'Hi!', createdAt: DateTime.utc(2026, 10, 2)),
    ],
  );

  @override
  Future<String> transcribe(String filePath, {String filename = 'recording.webm'}) {
    transcribed.add((path: filePath, filename: filename));
    if (transcribeError case final e?) return Future.error(e);
    return (transcribeResult ??= Completer<String>()).future;
  }

  @override
  Future<({PracticeMessage userMessage, PracticeMessage assistantMessage})> sendMessage(
    String sessionId, {
    required String content,
    String? audioUrl,
  }) async {
    sendCalls++;
    throw UnimplementedError();
  }
}

DioException _http(int status) {
  final req = RequestOptions(path: '/api/tra-dinh/transcribe');
  return DioException(
    requestOptions: req,
    type: DioExceptionType.badResponse,
    response: Response(requestOptions: req, statusCode: status, data: {'error': 'ai_unavailable'}),
  );
}

Future<void> _pump(WidgetTester tester, _FakeApi api, FakeRecorder recorder) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [traDinhApiProvider.overrideWithValue(api), recordingServiceProvider.overrideWithValue(recorder)],
      child: MaterialApp(
        theme: ThemeData.dark(),
        home: const PracticeChatScreen(sessionId: 's1'),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

final _mic = find.byTooltip('Ghi âm');
final _stop = find.byTooltip('Dừng ghi');
final _transcribing = find.byTooltip('Đang chuyển giọng nói thành chữ');
String _field(WidgetTester t) => t.widget<TextField>(find.byType(TextField)).controller!.text;
FilledButton _sendButton(WidgetTester t) => t.widget<FilledButton>(find.widgetWithText(FilledButton, 'Gửi'));

/// Bấm mic → đang ghi; pump từng giây vì đồng hồ dùng Timer.periodic.
Future<void> _startRecording(WidgetTester tester) async {
  await tester.tap(_mic);
  await tester.pump();
}

void main() {
  testWidgets('từ chối quyền: SnackBar rõ ràng, nút vẫn ở trạng thái nghỉ', (tester) async {
    final rec = FakeRecorder()..startError = const RecordingException('Chưa có quyền dùng micro — hãy cho phép.');
    await _pump(tester, _FakeApi(), rec);

    await _startRecording(tester);
    await tester.pump();
    expect(find.text('Chưa có quyền dùng micro — hãy cho phép.'), findsOneWidget);
    expect(_mic, findsOneWidget);
    expect(_stop, findsNothing);
  });

  testWidgets('ghi → đếm giây, khoá Gửi → dừng → spinner → điền chữ (không tự gửi) → xoá file', (tester) async {
    final api = _FakeApi();
    final rec = FakeRecorder();
    await _pump(tester, api, rec);
    await tester.enterText(find.byType(TextField), 'Well,');
    await tester.pump();
    expect(_sendButton(tester).onPressed, isNotNull);

    await _startRecording(tester);
    expect(_stop, findsOneWidget);
    expect(find.text('0:00'), findsOneWidget);
    expect(_sendButton(tester).onPressed, isNull); // đang ghi thì chưa gửi được
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('0:02'), findsOneWidget);

    await tester.tap(_stop);
    await tester.pump();
    expect(_transcribing, findsOneWidget);
    expect(api.transcribed.single, (path: '/tmp/tra-dinh-test.webm', filename: 'recording.webm'));
    expect(rec.deleted, isEmpty); // chưa xoá khi đang gửi

    api.transcribeResult!.complete('  I think so.  ');
    await tester.pumpAndSettle();
    expect(_field(tester), 'Well, I think so.'); // nối vào chữ đang có
    expect(api.sendCalls, 0);
    expect(rec.deleted, ['/tmp/tra-dinh-test.webm']);
    expect(_mic, findsOneWidget);
    expect(_sendButton(tester).onPressed, isNotNull);
  });

  testWidgets('transcribe lỗi 502: SnackBar, ô nhập giữ nguyên, file vẫn bị xoá', (tester) async {
    final api = _FakeApi()..transcribeError = _http(502);
    final rec = FakeRecorder();
    await _pump(tester, api, rec);

    await _startRecording(tester);
    await tester.tap(_stop);
    await tester.pumpAndSettle();
    expect(find.textContaining('Không chuyển giọng nói thành chữ được (502)'), findsOneWidget);
    expect(_field(tester), isEmpty);
    expect(rec.deleted, ['/tmp/tra-dinh-test.webm']);
    expect(_mic, findsOneWidget);
  });

  testWidgets('dừng mà không có bản ghi: SnackBar, không gọi transcribe', (tester) async {
    final api = _FakeApi();
    final rec = FakeRecorder()..stopResult = null;
    await _pump(tester, api, rec);

    await _startRecording(tester);
    await tester.tap(_stop);
    await tester.pumpAndSettle();
    expect(find.textContaining('Không lấy được bản ghi âm'), findsOneWidget);
    expect(api.transcribed, isEmpty);
    expect(_mic, findsOneWidget);
  });

  testWidgets('Whisper trả rỗng (im lặng): báo không nghe rõ, ô nhập không đổi', (tester) async {
    final api = _FakeApi()..transcribeResult = (Completer<String>()..complete('   '));
    final rec = FakeRecorder();
    await _pump(tester, api, rec);

    await _startRecording(tester);
    await tester.tap(_stop);
    await tester.pumpAndSettle();
    expect(find.textContaining('Không nghe rõ'), findsOneWidget);
    expect(_field(tester), isEmpty);
    expect(rec.deleted, hasLength(1));
  });

  testWidgets('rời màn khi đang ghi: huỷ bản ghi, dừng đồng hồ', (tester) async {
    final rec = FakeRecorder();
    await _pump(tester, _FakeApi(), rec);

    await _startRecording(tester);
    expect(_stop, findsOneWidget);
    await tester.pumpWidget(const SizedBox()); // gỡ màn hình
    expect(rec.cancelCalls, 1);
    // Timer.periodic còn chạy sẽ làm test báo "Timer is still pending".
  });

  group('tự dừng sau 3 phút', () {
    const autoStopText = 'Đã tự dừng ghi âm sau 3 phút';

    testWidgets('chưa ghi thì không có timer; ghi đủ 3 phút → tự dừng, báo, chuyển chữ', (tester) async {
      final api = _FakeApi();
      final rec = FakeRecorder();
      await _pump(tester, api, rec);

      // Đang nghỉ: không có timer nào chạy.
      await tester.pump(maxRecordingDuration);
      expect(api.transcribed, isEmpty);

      await _startRecording(tester);
      await tester.pump(maxRecordingDuration - const Duration(seconds: 1));
      expect(_stop, findsOneWidget); // 2:59 vẫn đang ghi
      expect(find.text('2:59'), findsOneWidget);
      expect(api.transcribed, isEmpty);

      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
      expect(find.text(autoStopText), findsOneWidget);
      expect(_transcribing, findsOneWidget);
      expect(api.transcribed, hasLength(1));

      // Kết quả không bị bỏ: chữ vẫn được điền như khi tự bấm dừng.
      api.transcribeResult!.complete('Long answer.');
      await tester.pumpAndSettle();
      expect(_field(tester), 'Long answer.');
      expect(rec.deleted, hasLength(1));
      expect(_mic, findsOneWidget);
    });

    testWidgets('bấm dừng trước → timer tự dừng bị huỷ, không chạy lần 2', (tester) async {
      final api = _FakeApi();
      final rec = FakeRecorder();
      await _pump(tester, api, rec);

      await _startRecording(tester);
      await tester.pump(const Duration(seconds: 10));
      await tester.tap(_stop);
      await tester.pump();
      api.transcribeResult!.complete('Short.');
      await tester.pumpAndSettle();

      await tester.pump(maxRecordingDuration); // quá mốc 3 phút tính từ lúc bắt đầu
      expect(find.text(autoStopText), findsNothing);
      expect(api.transcribed, hasLength(1));
      expect(_mic, findsOneWidget);
    });

    testWidgets('rời màn khi đang ghi → timer tự dừng bị huỷ, không chạy sau dispose', (tester) async {
      final api = _FakeApi();
      final rec = FakeRecorder();
      await _pump(tester, api, rec);

      await _startRecording(tester);
      await tester.pump(const Duration(seconds: 30));
      await tester.pumpWidget(const SizedBox());
      await tester.pump(maxRecordingDuration);
      expect(rec.cancelCalls, 1);
      expect(api.transcribed, isEmpty);
      // Còn Timer nào chưa huỷ thì flutter_test báo "A Timer is still pending" và fail.
    });
  });
}
