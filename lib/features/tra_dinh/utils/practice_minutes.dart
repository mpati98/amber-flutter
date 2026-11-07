import '../models/practice_message.dart';

/// Khoảng cách tối đa giữa hai tin nhắn liên tiếp được tính vào thời gian luyện: mở app để đó không bị tính cả buổi.
const maxPracticeGap = Duration(minutes: 3);

/// Số phút điền sẵn cho sheet cuối phiên luyện AI. Hàm thuần.
///
/// Cộng khoảng cách giữa mọi tin nhắn liên tiếp (theo thời gian, từ tin đầu đến tin cuối), mỗi khoảng tối đa
/// [maxPracticeGap]. `createdAt` đã là mốc đúng của từng loại tin: tin người học = lúc gửi (`sentAt`), tin AI = lúc AI
/// trả lời (`repliedAt`) — server ghi tường minh hai mốc này. Làm tròn tới phút gần nhất, tối thiểu 1 phút khi có tin
/// nhắn (một tin nhắn cũng là một buổi luyện), tối đa 1440 như giới hạn của API; không có tin nào → 0 (không hiện sheet).
int estimatePracticeMinutes(List<PracticeMessage> messages) {
  if (messages.isEmpty) return 0;
  final times = [for (final m in messages) m.createdAt]..sort();
  var total = Duration.zero;
  for (var i = 1; i < times.length; i++) {
    final gap = times[i].difference(times[i - 1]);
    total += gap > maxPracticeGap ? maxPracticeGap : gap;
  }
  return (total.inSeconds / 60).round().clamp(1, 1440);
}
