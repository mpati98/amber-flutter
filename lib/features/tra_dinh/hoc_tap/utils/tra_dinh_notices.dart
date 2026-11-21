import '../models/study_overview.dart';
import '../services/hoc_tap_api.dart';
import 'next_action.dart';

/// Dòng thông báo chung của popup Trà Đình trên cảnh 3D (`setTowerNotices('tradinh', …)`), chỉ từ Tổng quan học tập có sẵn:
/// 1. phút hôm nay / mục tiêu (cộng các môn; môn không mục tiêu chỉ cộng phút);
/// 2. chuỗi ngày dài nhất (bỏ nếu 0 / backend cũ không có);
/// 3. thẻ cần ôn hôm nay (còn N thẻ / chưa mở hàng ôn / đã ôn xong) — dùng đúng luật [cardsPending] của nút vàng.
/// Dạng `{text, lvl}` của cảnh.
List<Map<String, Object?>> buildTraDinhNotices(StudyOverview overview) {
  final subjects = overview.subjects;
  if (subjects.isEmpty) return [const {'text': 'Chưa có môn học nào', 'lvl': 'info'}];
  final out = <Map<String, Object?>>[];

  final minutes = subjects.fold<int>(0, (n, s) => n + s.today.minutes);
  final withGoal = subjects.where((s) => s.goalMinutes != null).toList();
  if (withGoal.isEmpty) {
    out.add({'text': 'Hôm nay $minutes phút', 'lvl': 'info'});
  } else {
    final goal = withGoal.fold<int>(0, (n, s) => n + s.goalMinutes!);
    out.add({'text': 'Hôm nay $minutes / $goal phút', 'lvl': withGoal.every((s) => s.today.done) ? 'ok' : 'warn'});
  }

  final streak = subjects.map((s) => s.streak ?? 0).fold<int>(0, (a, b) => a > b ? a : b);
  if (streak > 0) out.add({'text': 'Chuỗi $streak ngày', 'lvl': 'ok'});

  final withCards = [for (final s in subjects) if (s.cards case final c? when c.total != 0) c];
  if (withCards.isNotEmpty) {
    final pending = withCards.where(cardsPending).toList();
    final left = pending.where((c) => c.planned > 0).fold<int>(0, (n, c) => n + c.planned - c.finished);
    if (pending.isEmpty) {
      out.add({'text': 'Đã ôn xong thẻ hôm nay', 'lvl': 'ok'});
    } else if (left > 0) {
      out.add({'text': '$left thẻ cần ôn hôm nay', 'lvl': 'warn'});
    } else {
      out.add({'text': 'Chưa ôn thẻ hôm nay', 'lvl': 'warn'});
    }
  }
  return out;
}

/// Tải Tổng quan rồi [buildTraDinhNotices]. Lỗi thì ném — WorldFeeder bỏ phần Trà Đình của lần nạp đó.
Future<List<Map<String, Object?>>> fetchTraDinhNotices(HocTapApi api) async => buildTraDinhNotices(await api.getOverview());
