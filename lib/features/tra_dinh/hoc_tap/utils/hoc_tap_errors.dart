import '../../../../shared/utils/api_error.dart';

const _messages = {
  'active_exists': 'Môn này đã có khóa đang học',
  'sections_unparsed': 'Còn dòng chưa đọc được thời lượng, kiểm tra lại các phần',
  'sections_conflict': 'Chỉ nhập các phần theo một cách',
  'subject_in_use': 'Môn đang gắn với việc hằng ngày, gỡ việc đó trước',
  'goal_missing': 'Môn chưa đặt mục tiêu phút mỗi ngày',
  'study_routine_exists': 'Môn này đã có việc hằng ngày học tập',
  'subject_not_found': 'Không tìm thấy môn học',
  'course_not_found': 'Không tìm thấy khóa học',
  'section_not_found': 'Không tìm thấy phần học',
  'unknown_section': 'Danh sách phần không khớp khóa học, tải lại rồi thử lại',
  'not_queued': 'Chỉ đổi thứ tự được với khóa đang chờ học',
  'too_many_sections': 'Khóa có quá nhiều phần',
  'invalid_json': 'Dữ liệu gửi lên không hợp lệ',
};

/// Mã lỗi backend → câu tiếng Việt cho người dùng; mã lạ / lỗi mạng → "Có lỗi, thử lại".
String hocTapErrorMessage(Object error, [String fallback = 'Có lỗi, thử lại']) {
  final code = apiErrorCode(error);
  if (code != null && _messages.containsKey(code)) return _messages[code]!;
  return fallback;
}
