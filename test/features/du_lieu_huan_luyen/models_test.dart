import 'package:amber_flutter/features/du_lieu_huan_luyen/models/training_log.dart';
import 'package:flutter_test/flutter_test.dart';

// Dạng response của amber-v4 /api/brain-logs (đã chạy thật trên nhánh dev, 2026-10).
Map<String, dynamic> summaryJson({String id = 'l1', String outcome = 'unknown', Object? toolOk = true}) => {
      'id': id,
      'createdAt': '2026-10-10T10:30:00.000Z',
      'agent': 'expense',
      'source': 'agent',
      'userInput': 'chi 45k ăn trưa Momo',
      'outcome': outcome,
      'toolName': 'them_giao_dich',
      'toolOk': toolOk,
      'parseOk': true,
      'hasCorrection': false,
      'excludeFromTraining': false,
    };

void main() {
  test('TrainingLogSummary từ response danh sách', () {
    final s = TrainingLogSummary.fromJson(summaryJson(outcome: 'corrected'));
    expect(s.createdAt, DateTime.utc(2026, 10, 10, 10, 30));
    expect((s.agent, s.userInput, s.outcome, s.toolOk), ('expense', 'chi 45k ăn trưa Momo', LogOutcome.corrected, true));
  });

  test('outcome lạ không làm vỡ; trường thiếu có mặc định', () {
    expect(LogOutcome.parse('gì-đó-mới'), LogOutcome.unknown);
    expect(LogOutcome.parse(null), LogOutcome.unknown);
    final s = TrainingLogSummary.fromJson({'id': 'x', 'createdAt': '2026-10-10T10:30:00Z'});
    expect((s.agent, s.userInput, s.toolOk, s.hasCorrection, s.excludeFromTraining), ('', '', null, false, false));
  });

  test('TrainingLogPage: items + con trỏ', () {
    final p = TrainingLogPage.fromJson({'items': [summaryJson(id: 'a'), summaryJson(id: 'b')], 'nextCursor': 'c1'});
    expect(p.items.map((i) => i.id).toList(), ['a', 'b']);
    expect(p.nextCursor, 'c1');
    expect(TrainingLogPage.fromJson({'items': <dynamic>[], 'nextCursor': null}).nextCursor, isNull);
  });

  test('TrainingLogDetail: hasCorrection suy từ correctedOutput, số liệu và khối JSON', () {
    final d = TrainingLogDetail.fromJson({
      ...summaryJson(outcome: 'corrected'),
      'hasCorrection': null,
      'parsedOutput': {'category': 'Ăn uống'},
      'correctedOutput': {'category': 'Xăng'},
      'correctedAt': '2026-10-11T01:00:00.000Z',
      'messages': [
        {'role': 'user', 'content': 'x'}
      ],
      'tools': [<String, dynamic>{}],
      'rawOutput': '{"a":1}',
      'error': null,
      'latencyMs': 1234,
      'promptTokens': 400,
      'completionTokens': 17,
      'modelName': 'qwen3:4b-instruct',
      'entityType': 'transaction',
      'entityId': 'tx-1',
    });
    expect(d.summary.hasCorrection, isTrue);
    expect((d.latencyMs, d.promptTokens, d.completionTokens, d.error), (1234, 400, 17, null));
    expect(d.correctedAt, DateTime.utc(2026, 10, 11, 1));
    expect((d.parsedOutput as Map)['category'], 'Ăn uống');
    expect((d.correctedOutput as Map)['category'], 'Xăng');
    expect((d.messages as List).length, 1);
    expect(d.rawOutput, '{"a":1}');
    expect(TrainingLogDetail.fromJson(summaryJson()).summary.hasCorrection, isFalse);
  });

  test('TrainingStats', () {
    final s = TrainingStats.fromJson({
      'total': 5,
      'eligible': 3,
      'byAgent': [
        {'agent': 'chat', 'total': 1, 'eligible': 1, 'outcomes': {'accepted': 1}},
        {'agent': 'expense', 'total': 4, 'eligible': 2, 'outcomes': {'unknown': 2, 'rejected': 2}},
      ],
    });
    expect((s.total, s.eligible), (5, 3));
    expect(s.byAgent.map((a) => a.agent).toList(), ['chat', 'expense']);
    expect(s.byAgent[1].outcomes['rejected'], 2);
  });

  test('agentLabel: tên đã biết dịch, lạ giữ nguyên', () {
    expect((agentLabel('expense'), agentLabel('web_search'), agentLabel('chat'), agentLabel('moi_la')), ('Thu chi', 'Tìm web', 'Trò chuyện', 'moi_la'));
  });
}
