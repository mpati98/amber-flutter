// Dữ liệu trao đổi với amber-brain (hợp đồng /v1/*, xem amber-brain/README.md).

// GET /v1/status.
class BrainStatus {
  const BrainStatus({required this.serverEnv, required this.serverHost, required this.ollama, required this.model});

  /// "DEV" hoặc "PROD" — môi trường của backend mà brain đang nối.
  final String serverEnv;

  /// host:port của backend mà brain đang nối (vd `localhost:3000`).
  final String serverHost;
  final String ollama;
  final String model;

  bool get isProd => serverEnv == 'PROD';

  factory BrainStatus.fromJson(Map<String, dynamic> json) => BrainStatus(
    serverEnv: json['serverEnv'] as String,
    serverHost: json['serverHost'] as String,
    ollama: json['ollama'] as String? ?? 'down',
    model: json['model'] as String? ?? '',
  );
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

  /// Câu trả lời tiếng Anh của brain — chỉ dùng cho tin nhắn thường; thẻ xác nhận
  /// và kết quả ghi/xóa được app tự viết bằng tiếng Việt từ dữ liệu có cấu trúc.
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
