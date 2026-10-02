import 'dart:async';
import 'dart:typed_data';

import 'package:amber_flutter/features/tra_dinh/models/practice_message.dart';
import 'package:amber_flutter/features/tra_dinh/models/practice_session.dart';
import 'package:amber_flutter/features/tra_dinh/models/skill_score.dart';
import 'package:amber_flutter/features/tra_dinh/providers/tra_dinh_provider.dart';
import 'package:amber_flutter/features/tra_dinh/screens/practice_chat_screen.dart';
import 'package:amber_flutter/features/tra_dinh/services/recording_service.dart';
import 'package:amber_flutter/features/tra_dinh/services/tra_dinh_api.dart';
import 'package:amber_flutter/features/tra_dinh/services/tts_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_recorder.dart';

class _NoTts implements TtsService {
  @override
  Future<Uint8List> fetchSpeech(String text) => Completer<Uint8List>().future;
  @override
  Future<void> play(Uint8List wav) async {}
  @override
  Future<void> stop() async {}
  @override
  Future<void> dispose() async {}
}

class _FakeApi extends TraDinhApi {
  _FakeApi() : super(Dio());

  Completer<PracticeSession>? endResult;
  int endCalls = 0;
  int skillsCalls = 0;
  int sessionsCalls = 0;

  PracticeSession _session({DateTime? archivedAt, String? summary, bool withMessages = true}) => PracticeSession(
    id: 's1',
    name: 'Buổi thử',
    mode: PracticeMode.examPrep,
    createdAt: DateTime.utc(2026, 10, 2),
    archivedAt: archivedAt,
    summary: summary,
    messages: withMessages
        ? [
            PracticeMessage(id: 'u1', role: MessageRole.user, content: 'Hello', createdAt: DateTime.utc(2026, 10, 2)),
            PracticeMessage(
              id: 'a1',
              role: MessageRole.assistant,
              content: 'Hi!',
              createdAt: DateTime.utc(2026, 10, 2),
            ),
          ]
        : const [],
  );

  @override
  Future<PracticeSession> getSessionDetail(String id) async => _session();

  @override
  Future<PracticeSession> endSession(String sessionId) {
    endCalls++;
    return (endResult ??= Completer<PracticeSession>()).future;
  }

  /// Như response PATCH thật: có archivedAt + summary, KHÔNG kèm tin nhắn.
  PracticeSession endedResponse() =>
      _session(archivedAt: DateTime.utc(2026, 10, 2, 13), summary: 'Bạn chào hỏi tốt.', withMessages: false);

  @override
  Future<List<SkillScore>> getSkills() async {
    skillsCalls++;
    return const [];
  }

  @override
  Future<List<PracticeSession>> getSessions() async {
    sessionsCalls++;
    return const [];
  }
}

DioException _http(int status) {
  final req = RequestOptions(path: '/api/tra-dinh/sessions/s1');
  return DioException(
    requestOptions: req,
    type: DioExceptionType.badResponse,
    response: Response(requestOptions: req, statusCode: status),
  );
}

/// Container riêng + listen 2 provider của trang chính, như khi trang chính
/// còn nằm dưới màn chat — để đếm được việc invalidate.
Future<ProviderContainer> _pump(WidgetTester tester, _FakeApi api, {FakeRecorder? recorder}) async {
  final container = ProviderContainer(
    overrides: [
      traDinhApiProvider.overrideWithValue(api),
      recordingServiceProvider.overrideWithValue(recorder ?? FakeRecorder()),
      ttsServiceProvider.overrideWithValue(_NoTts()),
    ],
  );
  addTearDown(container.dispose);
  container
    ..listen(skillScoresProvider, (_, _) {})
    ..listen(practiceSessionsProvider, (_, _) {});
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: ThemeData.dark(),
        home: const PracticeChatScreen(sessionId: 's1'),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

final _endButton = find.widgetWithText(TextButton, 'Kết thúc buổi');

Future<void> _openDialogAndChoose(WidgetTester tester, String choice) async {
  await tester.tap(_endButton);
  await tester.pumpAndSettle();
  expect(find.text('Kết thúc buổi luyện?'), findsOneWidget);
  await tester.tap(find.text(choice));
  await tester.pump();
}

void main() {
  testWidgets('huỷ ở dialog → không gọi API, buổi vẫn mở', (tester) async {
    final api = _FakeApi();
    await _pump(tester, api);
    await _openDialogAndChoose(tester, 'Huỷ');
    await tester.pumpAndSettle();
    expect(api.endCalls, 0);
    expect(find.byType(TextField), findsOneWidget);
    expect(_endButton, findsOneWidget);
  });

  testWidgets(
    'xác nhận → đang kết thúc (khoá gửi/mic) → tóm tắt hiện, ô nhập mất, tin cũ giữ nguyên, trang chính được làm mới',
    (tester) async {
      final api = _FakeApi();
      await _pump(tester, api);
      final skillsBefore = api.skillsCalls, sessionsBefore = api.sessionsCalls;
      await tester.enterText(find.byType(TextField), 'draft');
      await tester.pump();

      await _openDialogAndChoose(tester, 'Kết thúc');
      expect(api.endCalls, 1);
      expect(find.widgetWithText(TextButton, 'Đang kết thúc...'), findsOneWidget);
      expect(tester.widget<TextButton>(find.widgetWithText(TextButton, 'Đang kết thúc...')).onPressed, isNull);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Gửi')).onPressed, isNull);
      expect(tester.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.mic_none)).onPressed, isNull);

      api.endResult!.complete(api.endedResponse());
      await tester.pumpAndSettle();
      expect(find.text('Tóm tắt buổi luyện'), findsOneWidget);
      expect(find.text('Bạn chào hỏi tốt.'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      expect(find.textContaining('Kết thúc buổi'), findsNothing);
      expect(find.text('Luyện thi · Đã kết thúc'), findsOneWidget);
      // Response PATCH không kèm tin nhắn — tin cũ vẫn phải còn.
      expect(find.text('Hello'), findsOneWidget);
      expect(find.text('Hi!'), findsOneWidget);
      expect(api.skillsCalls, skillsBefore + 1);
      expect(api.sessionsCalls, sessionsBefore + 1);
    },
  );

  testWidgets('lỗi PATCH → SnackBar, buổi vẫn mở, nút còn để thử lại, không làm mới trang chính', (tester) async {
    final api = _FakeApi();
    await _pump(tester, api);
    final skillsBefore = api.skillsCalls;

    await _openDialogAndChoose(tester, 'Kết thúc');
    api.endResult!.completeError(_http(500));
    await tester.pumpAndSettle();
    expect(find.textContaining('Không kết thúc được buổi (500)'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Tóm tắt buổi luyện'), findsNothing);
    expect(tester.widget<TextButton>(_endButton).onPressed, isNotNull);
    expect(api.skillsCalls, skillsBefore);

    // Thử lại được.
    api.endResult = null;
    await _openDialogAndChoose(tester, 'Kết thúc');
    expect(api.endCalls, 2);
    api.endResult!.complete(api.endedResponse());
    await tester.pumpAndSettle();
    expect(find.text('Bạn chào hỏi tốt.'), findsOneWidget);
  });

  testWidgets('đang ghi âm → nút kết thúc bị khoá', (tester) async {
    final api = _FakeApi();
    final rec = FakeRecorder();
    await _pump(tester, api, recorder: rec);

    await tester.tap(find.byTooltip('Ghi âm'));
    await tester.pump();
    expect(tester.widget<TextButton>(_endButton).onPressed, isNull);

    await tester.pumpWidget(const SizedBox()); // dọn timer ghi âm
  });
}
