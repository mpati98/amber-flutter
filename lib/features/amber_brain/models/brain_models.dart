// Dữ liệu trao đổi với amber-brain (hợp đồng /v1/*, xem amber-brain/README.md).

// GET /v1/status.
class BrainStatus {
  const BrainStatus({required this.serverEnv, required this.serverHost, required this.ollama, required this.model, this.logPush});

  /// "DEV" hoặc "PROD" — môi trường của backend mà brain đang nối.
  final String serverEnv;

  /// host:port của backend mà brain đang nối (vd `localhost:3000`).
  final String serverHost;
  final String ollama;
  final String model;
  final LogPushStatus? logPush;

  bool get isProd => serverEnv == 'PROD';

  factory BrainStatus.fromJson(Map<String, dynamic> json) {
    final rawLogPush = json['logPush'];
    return BrainStatus(
      serverEnv: json['serverEnv'] as String,
      serverHost: json['serverHost'] as String,
      ollama: json['ollama'] as String? ?? 'down',
      model: json['model'] as String? ?? '',
      logPush: rawLogPush is Map<String, dynamic> ? LogPushStatus.fromJson(rawLogPush) : null,
    );
  }
}

/// Log delivery state reported by newer amber-brain versions.
class LogPushStatus {
  const LogPushStatus({this.pending = 0, this.lastSuccessAt, this.lastErrorAt, this.lastError});

  final int pending;
  final DateTime? lastSuccessAt;
  final DateTime? lastErrorAt;
  final String? lastError;

  bool get shouldWarn => lastError != null || pending >= 5;

  factory LogPushStatus.fromJson(Map<String, dynamic> json) {
    final rawPending = json['pending'];
    final rawError = json['lastError'];
    return LogPushStatus(
      pending: rawPending is int && rawPending >= 0 ? rawPending : 0,
      lastSuccessAt: _parseTimestamp(json['lastSuccessAt']),
      lastErrorAt: _parseTimestamp(json['lastErrorAt']),
      lastError: rawError is String && const {'network', 'auth', 'server', 'unknown'}.contains(rawError) ? rawError : null,
    );
  }

  static DateTime? _parseTimestamp(Object? raw) => raw is String ? DateTime.tryParse(raw) : null;
}

enum BrainState {
  idle,
  awaitingConfirm,
  awaitingUndo;

  static BrainState parse(Object? raw) => switch (raw) {
    'awaiting_confirm' => awaitingConfirm,
    'awaiting_undo' => awaitingUndo,
    _ => idle,
  };
}

/// Bản nháp giao dịch đã được brain kiểm tra, chờ người dùng xác nhận.
class BrainDraft {
  const BrainDraft({
    required this.kind,
    required this.amount,
    required this.accountName,
    required this.categoryName,
    required this.date,
    required this.dateLabel,
    required this.note,
  });

  /// `INCOME` hoặc `EXPENSE`.
  final String kind;
  final num amount;
  final String accountName;
  final String? categoryName;

  /// `YYYY-MM-DD`.
  final String date;

  /// `today` hoặc `yesterday`.
  final String? dateLabel;
  final String? note;

  bool get isIncome => kind == 'INCOME';

  factory BrainDraft.fromJson(Map<String, dynamic> json) => BrainDraft(
    kind: json['kind'] as String,
    amount: json['amount'] as num,
    accountName: (json['account'] as Map)['name'] as String,
    categoryName: (json['category'] as Map?)?['name'] as String?,
    date: json['date'] as String,
    dateLabel: json['dateLabel'] as String?,
    note: json['note'] as String?,
  );
}

/// Giao dịch brain đề nghị xóa (hoàn tác).
class UndoTarget {
  const UndoTarget({
    required this.id,
    required this.kind,
    required this.amount,
    required this.accountName,
    required this.date,
  });

  final String id;
  final String kind;
  final num amount;
  final String accountName;
  final String date;

  bool get isIncome => kind == 'INCOME';

  factory UndoTarget.fromJson(Map<String, dynamic> json) => UndoTarget(
    id: json['id'] as String,
    kind: json['kind'] as String,
    amount: json['amount'] as num,
    accountName: (json['account'] as Map)['name'] as String,
    date: json['date'] as String,
  );
}

/// Phản hồi của /v1/chat, /v1/confirm, /v1/cancel, /v1/undo.
class BrainReply {
  const BrainReply({
    required this.reply,
    required this.conversationId,
    required this.state,
    this.draft,
    this.undoTarget,
    this.action,
    this.transactionId,
    this.balance,
  });

  /// Câu trả lời tiếng Anh của brain — chỉ dùng cho tin nhắn thường; thẻ xác nhận (nhãn tiếng Việt)
  /// và dòng kết quả ghi/xóa (tiếng Anh) được app tự viết từ dữ liệu có cấu trúc.
  final String reply;
  final String conversationId;
  final BrainState state;
  final BrainDraft? draft;
  final UndoTarget? undoTarget;

  /// Chỉ có ở /v1/confirm: `recorded` hoặc `deleted`.
  final String? action;
  final String? transactionId;

  /// Số dư ví sau khi ghi/xóa (chỉ có ở /v1/confirm).
  final num? balance;

  factory BrainReply.fromJson(Map<String, dynamic> json) => BrainReply(
    reply: json['reply'] as String? ?? '',
    conversationId: json['conversationId'] as String,
    state: BrainState.parse(json['state']),
    draft: json['draft'] == null ? null : BrainDraft.fromJson(json['draft'] as Map<String, dynamic>),
    undoTarget: json['undoTarget'] == null ? null : UndoTarget.fromJson(json['undoTarget'] as Map<String, dynamic>),
    action: json['action'] as String?,
    transactionId: json['transactionId'] as String?,
    balance: json['balance'] as num?,
  );
}
