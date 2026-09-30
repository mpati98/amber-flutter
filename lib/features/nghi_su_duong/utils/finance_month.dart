import '../../../shared/utils/vn_time.dart';
import '../models/project.dart';

/// "YYYY-MM" của tháng hiện tại theo lịch VN.
String vnMonthKey([DateTime? at]) => vnToday(at).substring(0, 7);

/// Tháng hiện tại (lịch VN) đã có project FINANCE chưa — backend tạo tháng với
/// startDate = ngày 1 theo lịch VN, nên so "YYYY-MM" của startDate là đủ.
/// Web so theo UTC (`toISOString().slice(0, 7)`) nên 0h–7h sáng ngày 1 vẫn
/// thấy tháng cũ và giấu nút "Bắt đầu tháng mới".
bool hasCurrentFinanceMonth(List<Project> financeProjects, [DateTime? at]) {
  final key = vnMonthKey(at);
  return financeProjects.any((p) => p.startDate?.startsWith(key) ?? false);
}
