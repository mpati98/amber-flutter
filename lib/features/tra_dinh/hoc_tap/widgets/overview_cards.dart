import '../../../../shared/utils/duration_format.dart';
import '../../../../shared/utils/vn_time.dart';
import '../models/course.dart';

/// "09:41" theo giờ VN.
String vnClock(DateTime at) {
  final d = vnNow(at);
  return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

/// Mô tả ngắn thời lượng khóa: "5h 27p" hoặc "Chưa có phần".
String courseDurationLabel(CourseView c) => c.progress.totalMinutes == 0
    ? 'Chưa có phần'
    : formatDuration(c.progress.totalMinutes);
