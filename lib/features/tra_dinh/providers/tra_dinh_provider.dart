import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/practice_session.dart';
import '../models/skill_score.dart';
import '../services/tra_dinh_api.dart';

final skillScoresProvider = FutureProvider.autoDispose<List<SkillScore>>(
  (ref) => ref.watch(traDinhApiProvider).getSkills(),
);

final practiceSessionsProvider = FutureProvider.autoDispose<List<PracticeSession>>(
  (ref) => ref.watch(traDinhApiProvider).getSessions(),
);

/// Chi tiết 1 buổi kèm tin nhắn. Notifier để chèn tin mới vào state ngay khi
/// gửi xong, không phải tải lại cả buổi.
class SessionDetailNotifier extends AsyncNotifier<PracticeSession> {
  SessionDetailNotifier(this.sessionId);

  final String sessionId;

  @override
  Future<PracticeSession> build() => ref.watch(traDinhApiProvider).getSessionDetail(sessionId);

  /// Ném lại DioException để màn hình tự xử lý từng mã lỗi; state chỉ đổi khi
  /// gửi thành công.
  Future<void> send(String content) async {
    final sent = await ref.read(traDinhApiProvider).sendMessage(sessionId, content: content);
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(messages: [...current.messages, sent.userMessage, sent.assistantMessage]));
  }

  /// Kết thúc buổi. Thành công → gộp archivedAt + tóm tắt vào state (giữ nguyên
  /// tin nhắn, vì response PATCH không kèm). Lỗi → state KHÔNG đổi (buổi vẫn mở,
  /// đúng với server) và ném lại để màn hình báo — không đặt AsyncError, vì
  /// như vậy cả màn chat sẽ bị thay bằng màn lỗi.
  Future<void> endSession() async {
    final ended = await ref.read(traDinhApiProvider).endSession(sessionId);
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(archivedAt: ended.archivedAt, summary: ended.summary));
  }

  /// Lấy lại từ server mà không về trạng thái loading (giữ màn hình đang hiện).
  Future<void> reload() async {
    state = AsyncData(await ref.read(traDinhApiProvider).getSessionDetail(sessionId));
  }
}

final sessionDetailProvider = AsyncNotifierProvider.autoDispose.family<SessionDetailNotifier, PracticeSession, String>(
  SessionDetailNotifier.new,
);
