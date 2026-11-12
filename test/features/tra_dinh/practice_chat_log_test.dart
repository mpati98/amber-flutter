import 'dart:async';
import 'dart:typed_data';

import 'package:amber_flutter/features/tra_dinh/hoc_tap/services/hoc_tap_api.dart';
import 'package:amber_flutter/features/tra_dinh/models/practice_message.dart';
import 'package:amber_flutter/features/tra_dinh/models/practice_session.dart';
import 'package:amber_flutter/features/tra_dinh/models/skill_score.dart';
import 'package:amber_flutter/features/tra_dinh/screens/practice_chat_screen.dart';
import 'package:amber_flutter/features/tra_dinh/services/recording_service.dart';
import 'package:amber_flutter/features/tra_dinh/services/tra_dinh_api.dart';
import 'package:amber_flutter/features/tra_dinh/services/tts_service.dart';
import 'package:amber_flutter/features/tra_dinh/widgets/practice_end_sheet.dart';
import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_recorder.dart';
import 'hoc_tap/hoc_tap_test_support.dart';

// Sheet cuối phiên luyện AI: "Luyện X phút" điền sẵn, sửa được, Lưu (POST /logs PRACTICE) / Bỏ qua.

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

final _t0 = DateTime.utc(2026, 11, 7, 9);

class _FakeApi extends TraDinhApi {
  _FakeApi({this.withMessages = true, this.endError}) : super(Dio());

  final bool withMessages;
  final Object? endError;

  PracticeSession _session({DateTime? archivedAt, bool messages = true}) => PracticeSession(
    id: 's1',
    name: 'Buổi thử',
    mode: PracticeMode.conversation,
    createdAt: _t0,
    archivedAt: archivedAt,
    summary: archivedAt == null ? null : 'Tóm tắt.',
    messages: messages && withMessages
        ? [
            PracticeMessage(id: 'u1', role: MessageRole.user, content: 'Hello', createdAt: _t0),
            PracticeMessage(id: 'a1', role: MessageRole.assistant, content: 'Hi!', createdAt: _t0.add(const Duration(seconds: 40))),
            // nghỉ 10 phút → chỉ tính 3 phút; rồi 30 giây trả lời
            PracticeMessage(id: 'u2', role: MessageRole.user, content: 'Next', createdAt: _t0.add(const Duration(minutes: 10, seconds: 40))),
            PracticeMessage(id: 'a2', role: MessageRole.assistant, content: 'Sure.', createdAt: _t0.add(const Duration(minutes: 11, seconds: 10))),
          ]
        : const [],
  );

  @override
  Future<PracticeSession> getSessionDetail(String id) async => _session();

  @override
  Future<PracticeSession> endSession(String sessionId) async {
    if (endError case final e?) throw e;
    return _session(archivedAt: _t0.add(const Duration(hours: 1)), messages: false);
  }

  @override
  Future<List<SkillScore>> getSkills() async => const [];

  @override
  Future<List<PracticeSession>> getSessions() async => const [];
}

DioException _http(int status, [Object? data]) {
  final req = RequestOptions(path: '/api/tra-dinh/hoc-tap/logs');
  return DioException(requestOptions: req, type: DioExceptionType.badResponse, response: Response(requestOptions: req, statusCode: status, data: data));
}

Future<void> _pump(WidgetTester tester, _FakeApi api, FakeHocTapApi hoc, {String? subjectId}) async {
  tester.view.physicalSize = const Size(390, 2600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        traDinhApiProvider.overrideWithValue(api),
        hocTapApiProvider.overrideWithValue(hoc),
        recordingServiceProvider.overrideWithValue(FakeRecorder()),
        ttsServiceProvider.overrideWithValue(_NoTts()),
      ],
      child: MaterialApp(theme: ThemeData.dark(), home: PracticeChatScreen(sessionId: 's1', subjectId: subjectId)),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _endSession(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(TextButton, 'Kết thúc buổi'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Kết thúc'));
  await tester.pumpAndSettle();
}

Finder _k(String key) => find.byKey(ValueKey(key));

void main() {
  late FakeHocTapApi hoc;
  late String subjectId;
  setUp(() {
    hoc = FakeHocTapApi();
    subjectId = hoc.subjects.first.id;
  });

  testWidgets('kết thúc thành công → sheet "Luyện 4 phút" (khoảng nghỉ 10 phút chỉ tính 3), điền sẵn', (tester) async {
    await _pump(tester, _FakeApi(), hoc, subjectId: subjectId);
    await _endSession(tester);
    expect(find.text('Luyện 4 phút'), findsOneWidget); // 40s + 3 phút + 30s = 250s → 4 phút
    expect(tester.widget<TextField>(_k('practice-end-minutes')).controller!.text, '4');
    expect(_k('practice-end-save'), findsOneWidget);
    expect(_k('practice-end-skip'), findsOneWidget);
    expect(hoc.logCreates, isEmpty, reason: 'không tự ghi');
  });

  testWidgets('Lưu → POST /logs PRACTICE kèm subjectId + practiceSessionId, không courseId/sections; hiện thông báo', (tester) async {
    final overviewBefore = hoc.overviewCalls;
    await _pump(tester, _FakeApi(), hoc, subjectId: subjectId);
    await _endSession(tester);
    await tester.enterText(_k('practice-end-minutes'), '25');
    await tester.pump();
    await tester.tap(_k('practice-end-save'));
    await tester.pumpAndSettle();
    expect(hoc.logCreates, [
      {'subjectId': subjectId, 'activity': 'PRACTICE', 'minutes': 25, 'practiceSessionId': 's1'},
    ]);
    expect(hoc.logCreates.single.containsKey('courseId'), isFalse);
    expect(hoc.logCreates.single.containsKey('sections'), isFalse);
    expect(_k('practice-end-minutes'), findsNothing, reason: 'sheet đã đóng');
    expect(find.textContaining('Đã ghi 25 phút luyện AI'), findsOneWidget);
    expect(hoc.overviewCalls, greaterThanOrEqualTo(overviewBefore), reason: 'createLog làm mới overview, lịch, thống kê, routines');
  });

  testWidgets('Bỏ qua → không ghi gì, sheet đóng', (tester) async {
    await _pump(tester, _FakeApi(), hoc, subjectId: subjectId);
    await _endSession(tester);
    await tester.tap(_k('practice-end-skip'));
    await tester.pumpAndSettle();
    expect(hoc.logCreates, isEmpty);
    expect(_k('practice-end-minutes'), findsNothing);
    expect(find.text('Tóm tắt buổi luyện'), findsOneWidget);
  });

  group('kiểm số phút', () {
    for (final (text, ok) in [('0', false), ('', false), ('1441', false), ('abc', false), ('1', true), ('1440', true)]) {
      testWidgets('"$text" → ${ok ? 'Lưu được' : 'nút Lưu bị khoá'}', (tester) async {
        await _pump(tester, _FakeApi(), hoc, subjectId: subjectId);
        await _endSession(tester);
        await tester.enterText(_k('practice-end-minutes'), text);
        await tester.pump();
        expect(tester.widget<FilledButton>(_k('practice-end-save')).onPressed != null, ok);
      });
    }
  });

  testWidgets('409 practice_already_logged → "Buổi này đã được ghi rồi", sheet còn mở để Bỏ qua', (tester) async {
    hoc.logError = _http(409, {'error': 'practice_already_logged'});
    await _pump(tester, _FakeApi(), hoc, subjectId: subjectId);
    await _endSession(tester);
    await tester.tap(_k('practice-end-save'));
    await tester.pumpAndSettle();
    expect(find.text('Buổi này đã được ghi rồi'), findsOneWidget);
    expect(tester.widget<FilledButton>(_k('practice-end-save')).onPressed, isNotNull, reason: 'nút Lưu mở lại sau lỗi');
    await tester.tap(_k('practice-end-skip'));
    await tester.pumpAndSettle();
    expect(_k('practice-end-minutes'), findsNothing);
  });

  for (final (name, error) in [
    ('500 kèm mã nội bộ', _http(500, {'error': 'internal_boom_xyz'})),
    ('404 practice_session_not_found', _http(404, {'error': 'practice_session_not_found'})),
    ('mạng', DioException(requestOptions: RequestOptions(path: '/x'), type: DioExceptionType.connectionError)),
  ]) {
    testWidgets('lỗi $name → câu tiếng Việt, không lộ lỗi kỹ thuật, sheet còn mở', (tester) async {
      hoc.logError = error;
      await _pump(tester, _FakeApi(), hoc, subjectId: subjectId);
      await _endSession(tester);
      await tester.tap(_k('practice-end-save'));
      await tester.pumpAndSettle();
      expect(find.textContaining('internal_boom'), findsNothing);
      expect(find.textContaining('DioException'), findsNothing);
      expect(find.textContaining('500'), findsNothing);
      expect(_k('practice-end-minutes'), findsOneWidget);
      expect(find.byType(TextField), findsWidgets);
    });
  }

  testWidgets('buổi không có tin nhắn nào → không hiện sheet', (tester) async {
    await _pump(tester, _FakeApi(withMessages: false), hoc, subjectId: subjectId);
    await _endSession(tester);
    expect(_k('practice-end-minutes'), findsNothing);
    expect(hoc.logCreates, isEmpty);
  });

  testWidgets('PATCH kết thúc lỗi → không hiện sheet (buổi vẫn mở)', (tester) async {
    await _pump(tester, _FakeApi(endError: _http(500)), hoc, subjectId: subjectId);
    await _endSession(tester);
    expect(_k('practice-end-minutes'), findsNothing);
    expect(find.textContaining('Không kết thúc được buổi'), findsOneWidget);
  });

  testWidgets('không truyền môn: lấy môn đầu tiên khi kết thúc; ghi vào môn đó', (tester) async {
    await _pump(tester, _FakeApi(), hoc);
    await _endSession(tester);
    await tester.tap(_k('practice-end-save'));
    await tester.pumpAndSettle();
    expect(hoc.logCreates.single['subjectId'], subjectId);
  });

  testWidgets('không có môn nào → không hiện sheet', (tester) async {
    await _pump(tester, _FakeApi(), FakeHocTapApi(subjects: const []));
    await _endSession(tester);
    expect(_k('practice-end-minutes'), findsNothing);
  });

  testWidgets('sheet không tràn ở 320 px, chữ x2.0 (cả khi có lỗi)', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    tester.view.physicalSize = const Size(320, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    hoc.logError = _http(409, {'error': 'practice_already_logged'});
    await tester.pumpWidget(
      ProviderScope(
        overrides: [hocTapApiProvider.overrideWithValue(hoc)],
        child: MaterialApp(
          theme: ThemeData.dark(),
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(onPressed: () => showPracticeEndSheet(context, sessionId: 's1', subjectId: subjectId, minutes: 12), child: const Text('mở')),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('mở'));
    await tester.pumpAndSettle();
    expect(find.text('Luyện 12 phút'), findsOneWidget);
    await tester.tap(_k('practice-end-save'));
    await tester.pumpAndSettle();
    expect(find.text('Buổi này đã được ghi rồi'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
