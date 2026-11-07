import '../../../../shared/utils/date_format.dart';
import '../models/study_enums.dart';
import '../models/study_log.dart';

/// Tiêu đề một buổi học trong danh sách: buổi ôn thẻ → "Ôn thẻ"; buổi luyện AI → "Luyện AI"; buổi gắn khóa → tên khóa; còn lại → "Ôn tập".
String logTitle({required LogActivity activity, String? courseTitle}) => switch (activity) {
  LogActivity.cardReview => 'Ôn thẻ',
  LogActivity.practice => 'Luyện AI',
  _ => courseTitle ?? 'Ôn tập',
};

/// Dòng trong ô chọn buổi học: "dd/MM · tên khóa (hoặc Ôn tập) · N phút".
String lessonPickLabel(StudyLog log) => '${formatDayMonth(log.logDate)} · ${logTitle(activity: log.activity, courseTitle: log.courseTitle)} · ${log.minutes} phút';
