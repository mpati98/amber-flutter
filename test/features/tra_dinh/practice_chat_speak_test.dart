import 'dart:async';
import 'dart:typed_data';

import 'package:amber_flutter/features/tra_dinh/models/practice_message.dart';
import 'package:amber_flutter/features/tra_dinh/models/practice_session.dart';
import 'package:amber_flutter/features/tra_dinh/screens/practice_chat_screen.dart';
import 'package:amber_flutter/features/tra_dinh/services/recording_service.dart';
import 'package:amber_flutter/features/tra_dinh/services/tra_dinh_api.dart';
import 'package:amber_flutter/features/tra_dinh/services/tts_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_recorder.dart';

/// Giả lập TtsService như AudioPlayer thật: play() treo tới khi phát hết
/// ([finishPlaying]) hoặc bị stop(); chỉ 1 bài phát tại 1 thời điểm.
class _FakeTts implements TtsService {
  final fetched = <String>[];
  final fetchGates = <String, Completer<Uint8List>>{};
  int stopCalls = 0;
  int playCalls = 0;
  Object? playError;
  Completer<void>? _playing;

  bool get isPlaying => _playing != null && !_playing!.isCompleted;

  @override
  Future<Uint8List> fetchSpeech(String text) {
    fetched.add(text);
    return (fetchGates[text] ??= Completer<Uint8List>()).future;
  }

  @override
  Future<void> play(Uint8List wav) {
    playCalls++;
    if (playError case final e?) return Future.error(e);
    _playing = Completer<void>();
    return _playing!.future;
  }

  void finishPlaying() => _playing?.complete();

  @override
  Future<void> stop() async {
    stopCalls++;
    if (isPlaying) _playing!.complete();
  }

  @override
  Future<void> dispose() async {}
}

class _FakeApi extends TraDinhApi {
  _FakeApi() : super(Dio());

  @override
  Future<PracticeSession> getSessionDetail(String id) async => PracticeSession(
    id: id,
    name: 'Buổi thử',
    mode: PracticeMode.conversation,
    createdAt: DateTime.utc(2026, 10, 2),
    messages: [
      PracticeMessage(id: 'u1', role: MessageRole.user, content: 'Hello', createdAt: DateTime.utc(2026, 10, 2)),
      PracticeMessage(
        id: 'a1',
        role: MessageRole.assistant,
        content: 'First reply',
        createdAt: DateTime.utc(2026, 10, 2),
      ),
      PracticeMessage(
        id: 'a2',
        role: MessageRole.assistant,
        content: 'Second reply',
        createdAt: DateTime.utc(2026, 10, 2),
      ),
    ],
  );
}

final _wav = Uint8List.fromList([1, 2, 3]);

DioException _http(int status) {
  final req = RequestOptions(path: '/api/tra-dinh/speak');
  return DioException(
    requestOptions: req,
    type: DioExceptionType.badResponse,
    response: Response(requestOptions: req, statusCode: status),
  );
}

Future<void> _pump(WidgetTester tester, _FakeTts tts) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        traDinhApiProvider.overrideWithValue(_FakeApi()),
        recordingServiceProvider.overrideWithValue(FakeRecorder()),
        ttsServiceProvider.overrideWithValue(tts),
      ],
      child: MaterialApp(
        theme: ThemeData.dark(),
        home: const PracticeChatScreen(sessionId: 's1'),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Nhãn nút đọc của 1 tin ('Phát' / 'Đang tải...' / 'Dừng'), hoặc null nếu không có nút.
String? _label(WidgetTester tester, String messageId) {
  final buttons = find.descendant(of: find.byKey(ValueKey(messageId)), matching: find.byType(TextButton));
  if (buttons.evaluate().isEmpty) return null;
  final text = find.descendant(of: buttons, matching: find.byType(Text));
  return tester.widget<Text>(text.first).data;
}

Future<void> _tapSpeak(WidgetTester tester, String messageId) async {
  await tester.tap(find.descendant(of: find.byKey(ValueKey(messageId)), matching: find.byType(TextButton)));
  await tester.pump();
}

void main() {
  testWidgets('chỉ tin AI có nút; nghỉ → đang tải → dừng(đang phát) → phát xong về nghỉ', (tester) async {
    final tts = _FakeTts();
    await _pump(tester, tts);
    expect(_label(tester, 'u1'), isNull);
    expect(_label(tester, 'a1'), 'Phát');

    await _tapSpeak(tester, 'a1');
    expect(_label(tester, 'a1'), 'Đang tải...');
    expect(tts.fetched, ['First reply']);

    tts.fetchGates['First reply']!.complete(_wav);
    await tester.pump();
    expect(_label(tester, 'a1'), 'Dừng');
    expect(tts.isPlaying, isTrue);

    tts.finishPlaying();
    await tester.pumpAndSettle();
    expect(_label(tester, 'a1'), 'Phát');
  });

  testWidgets('bấm tin khác khi đang phát → tin trước tự dừng, chỉ 1 tin phát', (tester) async {
    final tts = _FakeTts();
    await _pump(tester, tts);
    await _tapSpeak(tester, 'a1');
    tts.fetchGates['First reply']!.complete(_wav);
    await tester.pump();
    expect(_label(tester, 'a1'), 'Dừng');

    await _tapSpeak(tester, 'a2');
    expect(tts.isPlaying, isFalse); // a1 đã bị stop
    expect(_label(tester, 'a1'), 'Phát');
    expect(_label(tester, 'a2'), 'Đang tải...');

    tts.fetchGates['Second reply']!.complete(_wav);
    await tester.pump();
    expect(_label(tester, 'a2'), 'Dừng');
    expect(_label(tester, 'a1'), 'Phát'); // a1 kết thúc muộn không ghi đè trạng thái a2
    tts.finishPlaying();
    await tester.pumpAndSettle();
  });

  testWidgets('bấm lại khi đang phát → dừng, không phát lại từ đầu', (tester) async {
    final tts = _FakeTts();
    await _pump(tester, tts);
    await _tapSpeak(tester, 'a1');
    tts.fetchGates['First reply']!.complete(_wav);
    await tester.pump();

    await _tapSpeak(tester, 'a1');
    await tester.pumpAndSettle();
    expect(_label(tester, 'a1'), 'Phát');
    expect(tts.isPlaying, isFalse);
    expect(tts.fetched, hasLength(1));
    expect(tts.playCalls, 1);
  });

  testWidgets('bấm lại khi đang tải → huỷ, tải xong cũng không phát', (tester) async {
    final tts = _FakeTts();
    await _pump(tester, tts);
    await _tapSpeak(tester, 'a1');
    await _tapSpeak(tester, 'a1');
    expect(_label(tester, 'a1'), 'Phát');

    tts.fetchGates['First reply']!.complete(_wav);
    await tester.pumpAndSettle();
    expect(tts.playCalls, 0);
    expect(_label(tester, 'a1'), 'Phát');
  });

  testWidgets('/speak lỗi 502 → SnackBar, nút về nghỉ (không kẹt "Đang tải")', (tester) async {
    final tts = _FakeTts();
    await _pump(tester, tts);
    await _tapSpeak(tester, 'a1');
    tts.fetchGates['First reply']!.completeError(_http(502));
    await tester.pumpAndSettle();
    expect(find.textContaining('Không tải được giọng đọc (502)'), findsOneWidget);
    expect(_label(tester, 'a1'), 'Phát');
  });

  testWidgets('/speak 400 (tin > 2000 ký tự) → báo quá dài', (tester) async {
    final tts = _FakeTts();
    await _pump(tester, tts);
    await _tapSpeak(tester, 'a1');
    tts.fetchGates['First reply']!.completeError(_http(400));
    await tester.pumpAndSettle();
    expect(find.textContaining('quá dài để đọc'), findsOneWidget);
    expect(_label(tester, 'a1'), 'Phát');
  });

  testWidgets('lỗi khi phát (giải mã/player) → SnackBar, nút về nghỉ (không kẹt "Dừng")', (tester) async {
    final tts = _FakeTts()..playError = Exception('decode failed');
    await _pump(tester, tts);
    await _tapSpeak(tester, 'a1');
    tts.fetchGates['First reply']!.complete(_wav);
    await tester.pumpAndSettle();
    expect(find.textContaining('Không phát được âm thanh'), findsOneWidget);
    expect(_label(tester, 'a1'), 'Phát');
  });
}
