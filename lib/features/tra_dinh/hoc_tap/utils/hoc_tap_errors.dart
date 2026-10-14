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
  'not_today': 'Chỉ sửa hoặc xoá được buổi học của hôm nay',
  'log_not_found': 'Không tìm thấy buổi học, có thể đã bị xoá',
  'reason_required': 'Chọn lý do dừng',
  'reason_text_required': 'Nhập lý do khi chọn "Khác"',
  'course_not_in_subject': 'Khóa học này không thuộc môn đã chọn',
  'sections_without_course': 'Chọn khóa học trước khi chọn các phần đã học',
  'section_not_in_course': 'Có phần không thuộc khóa học đã chọn',
  'duplicate_section': 'Một phần bị chọn hai lần',
  'future_date': 'Không ghi được cho ngày chưa tới',
  'goal_met': 'Ngày đó đã đủ mục tiêu, không cần lý do',
  'study_routine_auto': 'Việc học tập tự tính từ buổi học, không tick tay',
  'invalid_date': 'Ngày không hợp lệ',
};

/// Mã lỗi backend → câu tiếng Việt cho người dùng; mã lạ / lỗi mạng → "Có lỗi, thử lại".
String hocTapErrorMessage(Object error, [String fallback = 'Có lỗi, thử lại']) {
  final code = apiErrorCode(error);
  if (code != null && _messages.containsKey(code)) return _messages[code]!;
  return fallback;
}
