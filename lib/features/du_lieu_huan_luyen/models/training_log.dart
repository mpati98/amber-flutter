// Nhật ký lượt gọi mô hình của amber-brain (bảng agent_logs ở amber-v4). TÁCH RIÊNG khỏi sách/tài liệu của Tàng Kinh Các:
// không dùng chung model, bảng hay API với chúng. App chỉ ĐỌC nội dung log; chỉ đặt được đánh giá và cờ loại khỏi dataset.

enum LogOutcome {
  unknown('Chưa rõ'),
  accepted('Đúng'),
  corrected('Đã sửa'),
  rejected('Sai / bị xóa'),
  retried('Làm lại');

  const LogOutcome(this.label);

  final String label;

  /// Giá trị lạ từ server (thêm outcome mới sau này) về [unknown] thay vì làm vỡ màn hình.
  static LogOutcome parse(Object? v) => LogOutcome.values.firstWhere((o) => o.name == v, orElse: () => LogOutcome.unknown);
}

/// Tên agent hiển thị; agent lạ giữ nguyên tên gốc.
String agentLabel(String agent) => switch (agent) {
      'expense' => 'Thu chi',
      'web_search' => 'Tìm web',
      'chat' => 'Trò chuyện',
      _ => agent,
    };

class TrainingLogSummary {
  const TrainingLogSummary({
    required this.id,
    required this.createdAt,
    required this.agent,
    required this.source,
    required this.userInput,
    required this.outcome,
    required this.toolName,
    required this.toolOk,
    required this.parseOk,
    required this.hasCorrection,
    required this.excludeFromTraining,
  });

  final String id;
  final DateTime createdAt;
  final String agent;
  final String source;
  final String userInput;
  final LogOutcome outcome;
  final String? toolName;

  /// null = lượt không chạy tool (hoặc chưa biết); true/false = tool thành công/lỗi.
  final bool? toolOk;
  final bool? parseOk;
  final bool hasCorrection;
  final bool excludeFromTraining;

  factory TrainingLogSummary.fromJson(Map<String, dynamic> j) => TrainingLogSummary(
        id: j['id'] as String,
        createdAt: DateTime.parse(j['createdAt'] as String),
        agent: j['agent'] as String? ?? '',
        source: j['source'] as String? ?? 'agent',
        userInput: j['userInput'] as String? ?? '',
        outcome: LogOutcome.parse(j['outcome']),
        toolName: j['toolName'] as String?,
        toolOk: j['toolOk'] as bool?,
        parseOk: j['parseOk'] as bool?,
        hasCorrection: j['hasCorrection'] as bool? ?? false,
        excludeFromTraining: j['excludeFromTraining'] as bool? ?? false,
      );
}

class TrainingLogPage {
  const TrainingLogPage({required this.items, required this.nextCursor});

  final List<TrainingLogSummary> items;
  final String? nextCursor;

  factory TrainingLogPage.fromJson(Map<String, dynamic> j) => TrainingLogPage(
        items: [for (final i in j['items'] as List<dynamic>) TrainingLogSummary.fromJson(i as Map<String, dynamic>)],
        nextCursor: j['nextCursor'] as String?,
      );
}

class TrainingLogDetail {
  const TrainingLogDetail({
    required this.summary,
    required this.json,
    required this.sessionId,
    required this.turnIndex,
    required this.lang,
    required this.modelName,
    required this.promptVersion,
    required this.adapterVersion,
    required this.error,
    required this.latencyMs,
    required this.promptTokens,
    required this.completionTokens,
    required this.entityType,
    required this.entityId,
    required this.correctedAt,
  });

  /// Các trường tóm tắt (câu gốc, outcome, tool, cờ loại) dùng chung với danh sách.
  final TrainingLogSummary summary;

  /// JSON gốc: nguồn của các khối lớn (messages, tools, rawOutput, parsedOutput, correctedOutput, toolArgs, toolResult,
  /// retrievedContext) — giữ nguyên dạng JSON để hiển thị, không ép sang model riêng.
  final Map<String, dynamic> json;
  final String? sessionId;
  final int? turnIndex;
  final String? lang;
  final String? modelName;
  final String? promptVersion;
  final String? adapterVersion;
  final String? error;
  final int? latencyMs;
  final int? promptTokens;
  final int? completionTokens;
  final String? entityType;
  final String? entityId;
  final DateTime? correctedAt;

  Object? get parsedOutput => json['parsedOutput'];
  Object? get correctedOutput => json['correctedOutput'];
  Object? get messages => json['messages'];
  Object? get tools => json['tools'];
  String? get rawOutput => json['rawOutput'] as String?;

  factory TrainingLogDetail.fromJson(Map<String, dynamic> j) {
    final c = j['correctedAt'] as String?;
    return TrainingLogDetail(
      // Dòng chi tiết không có hasCorrection: suy ra từ correctedOutput.
      summary: TrainingLogSummary.fromJson({...j, 'hasCorrection': j['correctedOutput'] != null}),
      json: j,
      sessionId: j['sessionId'] as String?,
      turnIndex: j['turnIndex'] as int?,
      lang: j['lang'] as String?,
      modelName: j['modelName'] as String?,
      promptVersion: j['promptVersion'] as String?,
      adapterVersion: j['adapterVersion'] as String?,
      error: j['error'] as String?,
      latencyMs: j['latencyMs'] as int?,
      promptTokens: j['promptTokens'] as int?,
      completionTokens: j['completionTokens'] as int?,
      entityType: j['entityType'] as String?,
      entityId: j['entityId'] as String?,
      correctedAt: c == null ? null : DateTime.parse(c),
    );
  }
}

class AgentStat {
  const AgentStat({required this.agent, required this.total, required this.eligible, required this.outcomes});

  final String agent;
  final int total;

  /// Số mẫu đủ điều kiện train (đã bỏ trùng, bỏ dòng bị loại).
  final int eligible;
  final Map<String, int> outcomes;

  factory AgentStat.fromJson(Map<String, dynamic> j) => AgentStat(
        agent: j['agent'] as String,
        total: (j['total'] as num).toInt(),
        eligible: (j['eligible'] as num).toInt(),
        outcomes: {for (final e in (j['outcomes'] as Map<String, dynamic>).entries) e.key: (e.value as num).toInt()},
      );
}

class TrainingStats {
  const TrainingStats({required this.total, required this.eligible, required this.byAgent});

  final int total;
  final int eligible;
  final List<AgentStat> byAgent;

  factory TrainingStats.fromJson(Map<String, dynamic> j) => TrainingStats(
        total: (j['total'] as num).toInt(),
        eligible: (j['eligible'] as num).toInt(),
        byAgent: [for (final a in j['byAgent'] as List<dynamic>) AgentStat.fromJson(a as Map<String, dynamic>)],
      );
}
