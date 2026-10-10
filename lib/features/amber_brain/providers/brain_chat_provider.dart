import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/utils/api_error.dart';
import '../../../shared/utils/currency.dart';
import '../models/brain_models.dart';
import '../services/brain_api.dart';

enum CardStatus { open, confirmed, cancelled, expired }

sealed class ChatEntry {
  const ChatEntry();
}

class TextEntry extends ChatEntry {
  const TextEntry(this.text, {required this.isUser, this.isError = false});
  final String text;
  final bool isUser;
  final bool isError;
}

class DraftEntry extends ChatEntry {
  const DraftEntry(this.draft, {this.status = CardStatus.open});
  final BrainDraft draft;
  final CardStatus status;
  DraftEntry withStatus(CardStatus s) => DraftEntry(draft, status: s);
}

class UndoEntry extends ChatEntry {
  const UndoEntry(this.target, {this.status = CardStatus.open});
  final UndoTarget target;
  final CardStatus status;
  UndoEntry withStatus(CardStatus s) => UndoEntry(target, status: s);
}

/// Kết quả sau khi brain ghi hoặc xóa — kèm số dư ví mới.
class ResultEntry extends ChatEntry {
  const ResultEntry({required this.text, required this.recorded});
  final String text;

  /// true = vừa ghi giao dịch (còn có thể hoàn tác); false = vừa xóa.
  final bool recorded;
}

class BrainChatState {
  const BrainChatState({this.entries = const [], this.conversationId, this.busy = false});

  final List<ChatEntry> entries;
  final String? conversationId;

  /// Đang chờ brain trả lời — khóa ô nhập, hiện bong bóng "đang gõ".
  final bool busy;

  bool get hasOpenCard => entries.any(
    (e) => (e is DraftEntry && e.status == CardStatus.open) || (e is UndoEntry && e.status == CardStatus.open),
  );

  /// Nút Hoàn tác chỉ hiện ở lần ghi gần nhất, khi chưa có lần xóa nào sau nó và không có thẻ đang mở.
  int? get undoableResultIndex {
    for (var i = entries.length - 1; i >= 0; i--) {
      final e = entries[i];
      if (e is ResultEntry) return e.recorded && !busy && !hasOpenCard ? i : null;
    }
    return null;
  }

  BrainChatState copyWith({List<ChatEntry>? entries, Object? conversationId = _keep, bool? busy}) => BrainChatState(
    entries: entries ?? this.entries,
    conversationId: identical(conversationId, _keep) ? this.conversationId : conversationId as String?,
    busy: busy ?? this.busy,
  );
}

const _keep = Object();

String kindLabel(bool income) => income ? 'thu nhập' : 'chi tiêu';

String dateLabelVi(String date, String? label) {
  final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(date);
  final d = m == null ? date : '${m.group(3)}/${m.group(2)}/${m.group(1)}';
  return switch (label) {
    'today' => '$d (hôm nay)',
    'yesterday' => '$d (hôm qua)',
    _ => d,
  };
}

/// Câu báo lỗi cho người dùng từ lỗi gọi brain.
String describeBrainError(Object e, {bool web = kIsWeb}) {
  if (e is DioException) {
    final status = e.response?.statusCode;
    final code = apiErrorCode(e);
    if (status == 404 && code == 'conversation_not_found') return 'Phiên đã hết, hãy gõ lại.';
    if (status == 409 && code == 'busy') return 'Amber đang xử lý tin nhắn trước, thử lại sau giây lát.';
    if (status == 409) return 'Không còn gì để xác nhận.';
    if (status == 401) return 'Phiên đăng nhập đã hết hạn, hãy đăng nhập lại.';
    if (status == 502) return 'Amber không nối được máy chủ dữ liệu.';
    if (status != null) return apiErrorMessage(e, 'Amber báo lỗi ($status).');
    if (e.type == DioExceptionType.receiveTimeout || e.type == DioExceptionType.connectionTimeout) {
      return 'Amber trả lời quá lâu (hơn 60 giây). Thử lại sau.';
    }
    return web
        ? 'Không nối được Amber. Nếu brain đang chạy, trình duyệt có thể đang chặn truy cập mạng nội bộ: '
              'hãy cho phép trang này truy cập thiết bị trong mạng nội bộ (biểu tượng ổ khóa cạnh địa chỉ → Cài đặt trang web).'
        : 'Không nối được Amber.';
  }
  return 'Có lỗi xảy ra: $e';
}

class BrainChatNotifier extends Notifier<BrainChatState> {
  @override
  BrainChatState build() => const BrainChatState();

  BrainApi get _api => ref.read(brainApiProvider);

  void _add(ChatEntry e) => state = state.copyWith(entries: [...state.entries, e]);

  /// Đổi trạng thái mọi thẻ đang mở.
  void _closeCards(CardStatus to) {
    state = state.copyWith(
      entries: [
        for (final e in state.entries)
          if (e is DraftEntry && e.status == CardStatus.open)
            e.withStatus(to)
          else if (e is UndoEntry && e.status == CardStatus.open)
            e.withStatus(to)
          else
            e,
      ],
    );
  }

  /// Chạy một lời gọi brain, khóa ô nhập trong lúc chờ. Trả null nếu lỗi (đã ghi vào danh sách).
  Future<BrainReply?> _call(Future<BrainReply> Function() fn, {bool resetOnMissing = true}) async {
    if (state.busy) return null;
    state = state.copyWith(busy: true);
    try {
      final r = await fn();
      state = state.copyWith(conversationId: r.conversationId);
      return r;
    } on Object catch (e) {
      if (e is DioException && e.response?.statusCode == 404 && resetOnMissing) {
        _closeCards(CardStatus.expired);
        state = state.copyWith(conversationId: null);
      } else if (e is DioException && e.response?.statusCode == 409 && apiErrorCode(e) != 'busy') {
        _closeCards(CardStatus.expired);
      }
      _add(TextEntry(describeBrainError(e), isUser: false, isError: true));
      return null;
    } finally {
      state = state.copyWith(busy: false);
    }
  }

  Future<void> send(String text) async {
    final t = text.trim();
    if (t.isEmpty || state.busy) return;
    // Gõ câu mới khi còn thẻ mở thì brain bỏ bản nháp đó.
    _closeCards(CardStatus.expired);
    _add(TextEntry(t, isUser: true));
    final r = await _call(() => _api.chat(t, conversationId: state.conversationId));
    if (r == null) return;
    _show(r);
  }

  void _show(BrainReply r) {
    if (r.state == BrainState.awaitingConfirm && r.draft != null) {
      _add(DraftEntry(r.draft!));
    } else if (r.state == BrainState.awaitingUndo && r.undoTarget != null) {
      _add(UndoEntry(r.undoTarget!));
    } else if (r.reply.isNotEmpty) {
      _add(TextEntry(r.reply, isUser: false));
    }
  }

  Future<void> confirm() async {
    final cardIndex = state.entries.lastIndexWhere(
      (e) => (e is DraftEntry && e.status == CardStatus.open) || (e is UndoEntry && e.status == CardStatus.open),
    );
    final id = state.conversationId;
    if (cardIndex < 0 || id == null || state.busy) return;
    final card = state.entries[cardIndex];
    final r = await _call(() => _api.confirm(id));
    if (r == null) return;
    _setCard(cardIndex, CardStatus.confirmed);
    final balance = r.balance == null ? '' : ' Số dư mới: ${formatVnd(r.balance!)}.';
    if (card is DraftEntry) {
      final d = card.draft;
      _add(
        ResultEntry(
          text: 'Đã ghi ${kindLabel(d.isIncome)} ${formatVnd(d.amount)} vào ví ${d.accountName}.$balance',
          recorded: true,
        ),
      );
    } else if (card is UndoEntry) {
      final t = card.target;
      _add(
        ResultEntry(
          text: 'Đã xóa giao dịch ${kindLabel(t.isIncome)} ${formatVnd(t.amount)} (ví ${t.accountName}).$balance',
          recorded: false,
        ),
      );
    }
  }

  Future<void> cancel() async {
    final cardIndex = state.entries.lastIndexWhere(
      (e) => (e is DraftEntry && e.status == CardStatus.open) || (e is UndoEntry && e.status == CardStatus.open),
    );
    final id = state.conversationId;
    if (cardIndex < 0 || id == null || state.busy) return;
    final r = await _call(() => _api.cancel(id));
    if (r == null) return;
    _setCard(cardIndex, CardStatus.cancelled);
    _add(const TextEntry('Đã hủy, chưa có gì bị thay đổi.', isUser: false));
  }

  /// Hoàn tác giao dịch gần nhất do Amber ghi: brain đề nghị, người dùng xác nhận rồi mới xóa.
  Future<void> undo() async {
    if (state.busy) return;
    _closeCards(CardStatus.expired);
    final r = await _call(() => _api.undo(conversationId: state.conversationId), resetOnMissing: false);
    if (r == null) return;
    if (r.state == BrainState.awaitingUndo && r.undoTarget != null) {
      _add(UndoEntry(r.undoTarget!));
    } else {
      _add(const TextEntry('Không có giao dịch nào do Amber ghi để hoàn tác.', isUser: false));
    }
  }

  void _setCard(int i, CardStatus s) {
    final e = state.entries[i];
    final next = switch (e) {
      DraftEntry() => e.withStatus(s),
      UndoEntry() => e.withStatus(s),
      _ => e,
    };
    state = state.copyWith(entries: [...state.entries]..[i] = next);
  }
}

/// autoDispose: lịch sử chỉ sống trong phiên màn hình, không lưu.
final brainChatProvider = NotifierProvider.autoDispose<BrainChatNotifier, BrainChatState>(BrainChatNotifier.new);
