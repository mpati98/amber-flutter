import 'package:amber_flutter/features/du_lieu_huan_luyen/models/training_log.dart';
import 'package:amber_flutter/features/du_lieu_huan_luyen/screens/training_log_detail_screen.dart';
import 'package:amber_flutter/features/du_lieu_huan_luyen/screens/training_logs_screen.dart';
import 'package:amber_flutter/features/du_lieu_huan_luyen/services/training_log_api.dart';
import 'package:amber_flutter/features/amber_brain/models/brain_models.dart';
import 'package:amber_flutter/features/amber_brain/providers/brain_status_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'models_test.dart' show summaryJson;
import '../amber_brain/fake_brain.dart' show FixedBrainStatus;

class FakeApi extends TrainingLogApi {
  FakeApi() : super(Dio());

  /// Mỗi phần tử = một trang (con trỏ = chỉ số trang kế).
  List<List<Map<String, dynamic>>> pages = [
    [summaryJson(id: 'l1', outcome: 'accepted'), summaryJson(id: 'l2', toolOk: false)],
  ];
  Map<String, dynamic> detailJson = {
    ...summaryJson(id: 'l1', outcome: 'corrected'),
    'parsedOutput': {'category': 'Ăn uống'},
    'correctedOutput': {'category': 'Xăng'},
    'correctedAt': '2026-10-11T01:00:00.000Z',
    'messages': [
      {'role': 'user', 'content': 'NOI-DUNG-MESSAGES'}
    ],
    'tools': [
      {'type': 'function', 'name': 'NOI-DUNG-TOOLS'}
    ],
    'rawOutput': 'NOI-DUNG-RAW',
    'error': 'parse hỏng',
    'latencyMs': 1234,
    'promptTokens': 400,
    'completionTokens': 17,
  };
  TrainingStats statsValue = const TrainingStats(total: 5, eligible: 3, byAgent: [
    AgentStat(agent: 'chat', total: 1, eligible: 1, outcomes: {'accepted': 1}),
    AgentStat(agent: 'expense', total: 4, eligible: 2, outcomes: {'unknown': 4}),
  ]);
  bool failList = false, failActions = false, failMore = false;
  int statsCalls = 0;
  final listCalls = <({String? agent, LogOutcome? outcome, String? cursor})>[];
  final calls = <String>[];

  @override
  Future<TrainingLogPage> list({String? agent, LogOutcome? outcome, String? cursor, int limit = 30}) async {
    listCalls.add((agent: agent, outcome: outcome, cursor: cursor));
    if (failList || (failMore && cursor != null)) throw DioException(requestOptions: RequestOptions());
    final i = cursor == null ? 0 : int.parse(cursor);
    return TrainingLogPage(
      items: [for (final j in pages[i]) TrainingLogSummary.fromJson(j)],
      nextCursor: i + 1 < pages.length ? '${i + 1}' : null,
    );
  }

  @override
  Future<TrainingLogDetail> detail(String id) async => TrainingLogDetail.fromJson(detailJson);

  @override
  Future<TrainingStats> stats() async {
    statsCalls++;
    return statsValue;
  }

  @override
  Future<void> feedback(String id, {required bool correct}) async {
    calls.add('feedback:$id:$correct');
    if (failActions) throw DioException(requestOptions: RequestOptions());
    detailJson = {...detailJson, 'outcome': correct ? 'accepted' : 'rejected'};
  }

  @override
  Future<void> setExcluded(String id, bool excluded) async {
    calls.add('exclude:$id:$excluded');
    if (failActions) throw DioException(requestOptions: RequestOptions());
    detailJson = {...detailJson, 'excludeFromTraining': excluded};
  }
}

const base = '/tang-kinh-cac/du-lieu-huan-luyen';

/// Cùng cấu trúc route như app_router.dart; [at] là phần sau [base] ('' = danh sách, '/l1' = chi tiết).
Future<void> pumpScreens(WidgetTester tester, FakeApi api, {String at = '', BrainConnection? connection}) async {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final router = GoRouter(initialLocation: base + at, routes: [
    GoRoute(path: base, builder: (_, _) => const TrainingLogsScreen(), routes: [
      GoRoute(path: ':logId', builder: (_, s) => TrainingLogDetailScreen(logId: s.pathParameters['logId']!)),
    ]),
  ]);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      trainingLogApiProvider.overrideWithValue(api),
      if (connection != null) brainStatusProvider.overrideWith(() => FixedBrainStatus(connection)),
    ],
    child: MaterialApp.router(theme: ThemeData.dark(), routerConfig: router),
  ));
  await tester.pumpAndSettle();
}

Finder inRow(String id, String text) => find.descendant(of: find.byKey(ValueKey('log-$id')), matching: find.text(text));

void main() {
  group('màn danh sách', () {
    testWidgets('log-push auth warning is shown in Vietnamese', (tester) async {
      await pumpScreens(
        tester,
        FakeApi(),
        connection: BrainConnection(
          link: BrainLink.online,
          status: BrainStatus(
            serverEnv: 'DEV',
            serverHost: 'localhost:3000',
            ollama: 'up',
            model: 'amber-gemma4',
            logPush: LogPushStatus.fromJson({'pending': 1, 'lastError': 'auth'}),
          ),
        ),
      );
      expect(find.byKey(const ValueKey('log-push-banner')), findsOneWidget);
      expect(find.text('Vui lòng đăng nhập lại để đồng bộ nhật ký.'), findsOneWidget);
      expect(find.text('auth'), findsNothing);
    });

    testWidgets('pending-only warning uses Vietnamese count; old status stays quiet', (tester) async {
      await pumpScreens(
        tester,
        FakeApi(),
        connection: BrainConnection(
          link: BrainLink.online,
          status: BrainStatus(
            serverEnv: 'DEV',
            serverHost: 'localhost:3000',
            ollama: 'up',
            model: 'amber-gemma4',
            logPush: LogPushStatus.fromJson({'pending': 5}),
          ),
        ),
      );
      expect(find.text('Còn 5 dòng nhật ký đang chờ gửi.'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await pumpScreens(tester, FakeApi());
      expect(find.byKey(const ValueKey('log-push-banner')), findsNothing);
    });

    testWidgets('thống kê trên đầu + từng dòng: giờ VN, câu gõ, outcome, tool OK/lỗi', (tester) async {
      await pumpScreens(tester, FakeApi());
      expect(find.text('3 mẫu đủ điều kiện train · 5 dòng nhật ký'), findsOneWidget);
      expect(find.text('Trò chuyện: 1 · Thu chi: 2'), findsOneWidget);
      expect(find.textContaining('10/10 17:30'), findsNWidgets(2));   // 10:30Z = 17:30 giờ VN
      expect(inRow('l1', 'chi 45k ăn trưa Momo'), findsOneWidget);
      expect(inRow('l1', 'Thu chi'), findsOneWidget);
      expect(inRow('l1', 'Đúng'), findsOneWidget);
      expect(inRow('l1', 'Tool OK'), findsOneWidget);
      expect(inRow('l2', 'Chưa rõ'), findsOneWidget);
      expect(inRow('l2', 'Tool lỗi'), findsOneWidget);
    });

    testWidgets('bộ lọc agent và outcome gọi lại API với đúng tham số', (tester) async {
      final api = FakeApi();
      await pumpScreens(tester, api);
      expect(api.listCalls.last, (agent: null, outcome: null, cursor: null));
      await tester.tap(find.widgetWithText(ChoiceChip, 'Trò chuyện'));
      await tester.pumpAndSettle();
      expect(api.listCalls.last, (agent: 'chat', outcome: null, cursor: null));
      await tester.tap(find.widgetWithText(ChoiceChip, 'Sai / bị xóa'));
      await tester.pumpAndSettle();
      expect(api.listCalls.last, (agent: 'chat', outcome: LogOutcome.rejected, cursor: null));
      await tester.tap(find.widgetWithText(ChoiceChip, 'Mọi agent'));
      await tester.pumpAndSettle();
      expect(api.listCalls.last, (agent: null, outcome: LogOutcome.rejected, cursor: null));
    });

    testWidgets('Tải thêm nối trang sau; lỗi tải thêm giữ nguyên danh sách', (tester) async {
      final api = FakeApi()
        ..pages = [
          [summaryJson(id: 'l1')],
          [summaryJson(id: 'l1'), summaryJson(id: 'l3')],   // l1 trùng: không hiện lặp
        ]
        ..failMore = true;
      await pumpScreens(tester, api);
      await tester.tap(find.text('Tải thêm'));
      await tester.pumpAndSettle();
      expect(find.text('Không tải thêm được — thử lại'), findsOneWidget);
      expect(find.byKey(const ValueKey('log-l1')), findsOneWidget);
      api.failMore = false;
      await tester.tap(find.text('Không tải thêm được — thử lại'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('log-l1')), findsOneWidget);
      expect(find.byKey(const ValueKey('log-l3')), findsOneWidget);
      expect(find.textContaining('Tải thêm'), findsNothing);
      expect(api.listCalls.last.cursor, '1');
    });

    testWidgets('lỗi tải → nút thử lại; rỗng → thông báo', (tester) async {
      final api = FakeApi()..failList = true;
      await pumpScreens(tester, api);
      expect(find.text('Không tải được nhật ký.'), findsOneWidget);
      api
        ..failList = false
        ..pages = [[]];
      await tester.tap(find.text('Thử lại'));
      await tester.pumpAndSettle();
      expect(find.text('Chưa có dòng nhật ký nào khớp bộ lọc.'), findsOneWidget);
    });

    testWidgets('thống kê lỗi thì danh sách vẫn dùng được', (tester) async {
      final api = FakeApi();
      await pumpScreens(tester, api..statsValue = const TrainingStats(total: 0, eligible: 0, byAgent: []));
      expect(find.text('0 mẫu đủ điều kiện train · 0 dòng nhật ký'), findsOneWidget);
      expect(find.byKey(const ValueKey('log-l1')), findsOneWidget);
    });

    testWidgets('bấm một dòng mở chi tiết', (tester) async {
      await pumpScreens(tester, FakeApi());
      await tester.tap(find.byKey(const ValueKey('log-l1')));
      await tester.pumpAndSettle();
      expect(find.text('Chi tiết nhật ký'), findsOneWidget);
    });
  });

  group('màn chi tiết', () {
    testWidgets('câu gốc, đề xuất, bản đã sửa, lỗi, độ trễ và token', (tester) async {
      await pumpScreens(tester, FakeApi(), at: '/l1');
      expect(find.text('chi 45k ăn trưa Momo'), findsOneWidget);
      expect(find.textContaining('Ăn uống'), findsOneWidget);   // đề xuất của model
      expect(find.textContaining('Xăng'), findsOneWidget);       // bản đã sửa
      expect(find.text('BẢN ĐÃ SỬA'), findsOneWidget);
      expect(find.text('parse hỏng'), findsOneWidget);
      expect(find.textContaining('1234 ms'), findsOneWidget);
      expect(find.textContaining('vào 400 · ra 17'), findsOneWidget);
    });

    testWidgets('không có bản sửa/lỗi thì ẩn khối đó', (tester) async {
      final api = FakeApi();
      api.detailJson = {...summaryJson(id: 'l1'), 'parsedOutput': 'Hello', 'error': null};
      await pumpScreens(tester, api, at: '/l1');
      expect(find.text('BẢN ĐÃ SỬA'), findsNothing);
      expect(find.text('LỖI'), findsNothing);
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('messages, tools, raw_output thu gọn, bấm mới mở', (tester) async {
      await pumpScreens(tester, FakeApi(), at: '/l1');
      for (final (title, body) in [
        ('messages (gửi vào model)', 'NOI-DUNG-MESSAGES'),
        ('tools (gửi kèm)', 'NOI-DUNG-TOOLS'),
        ('raw_output (output thô)', 'NOI-DUNG-RAW'),
      ]) {
        expect(find.textContaining(body), findsNothing, reason: '$title phải thu gọn');
        await tester.tap(find.text(title));
        await tester.pumpAndSettle();
        expect(find.textContaining(body), findsOneWidget, reason: '$title mở ra');
      }
    });

    testWidgets('Đúng/Sai gọi feedback và cập nhật nút', (tester) async {
      final api = FakeApi();
      await pumpScreens(tester, api, at: '/l1');
      await tester.tap(find.text('Đúng'));
      await tester.pumpAndSettle();
      expect(api.calls, ['feedback:l1:true']);
      expect(find.byIcon(Icons.thumb_up), findsOneWidget);   // outcome accepted -> icon đặc
      await tester.tap(find.text('Sai'));
      await tester.pumpAndSettle();
      expect(api.calls, ['feedback:l1:true', 'feedback:l1:false']);
      expect(find.byIcon(Icons.thumb_down), findsOneWidget);
    });

    testWidgets('đánh giá làm mới thống kê và danh sách ở màn bên dưới', (tester) async {
      final api = FakeApi();
      await pumpScreens(tester, api);
      await tester.tap(find.byKey(const ValueKey('log-l1')));
      await tester.pumpAndSettle();
      final (stats, lists) = (api.statsCalls, api.listCalls.length);
      await tester.tap(find.text('Đúng'));
      await tester.pumpAndSettle();
      await tester.pageBack();   // Riverpod tạm dừng provider của màn đang bị che: quay lại danh sách là nó tải lại
      await tester.pumpAndSettle();
      expect(find.text('Chi tiết nhật ký'), findsNothing);
      expect(api.statsCalls, greaterThan(stats));
      expect(api.listCalls.length, greaterThan(lists));
    });

    testWidgets('công tắc loại khỏi dataset gọi PATCH và phản ánh trạng thái mới', (tester) async {
      final api = FakeApi();
      await pumpScreens(tester, api, at: '/l1');
      expect(tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value, isFalse);
      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();
      expect(api.calls, ['exclude:l1:true']);
      expect(tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value, isTrue);
      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();
      expect(api.calls.last, 'exclude:l1:false');
    });

    testWidgets('lỗi khi gửi đánh giá → báo, trạng thái không đổi', (tester) async {
      final api = FakeApi()..failActions = true;
      await pumpScreens(tester, api, at: '/l1');
      await tester.tap(find.text('Đúng'));
      await tester.pumpAndSettle();
      expect(find.text('Không gửi được đánh giá.'), findsOneWidget);
      expect(find.byIcon(Icons.thumb_up), findsNothing);
    });

    testWidgets('lỗi khi đổi cờ loại → báo, công tắc không đổi', (tester) async {
      final api = FakeApi()..failActions = true;
      await pumpScreens(tester, api, at: '/l1');
      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();
      expect(find.text('Không đổi được cờ loại khỏi dataset.'), findsOneWidget);
      expect(tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value, isFalse);
    });

    testWidgets('không có ô nhập nào: nội dung log không sửa được từ app', (tester) async {
      await pumpScreens(tester, FakeApi(), at: '/l1');
      for (final t in ['messages (gửi vào model)', 'tools (gửi kèm)', 'raw_output (output thô)']) {
        await tester.tap(find.text(t));
        await tester.pumpAndSettle();
      }
      expect(find.byType(TextField), findsNothing);
      expect(find.byType(TextFormField), findsNothing);
      // SelectableText dựng EditableText chỉ-đọc để chọn/chép; không được có ô nhập nào ghi được.
      final editables = tester.widgetList<EditableText>(find.byType(EditableText));
      expect(editables, isNotEmpty);
      expect(editables.every((e) => e.readOnly), isTrue);
    });
  });
}
