import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ats_task.dart';
import '../services/ats_tasks_api.dart';

/// Bật "Xem tất cả (gồm lưu trữ)" ⇒ tải `?all=1`. Mặc định tắt; rời màn là về mặc định (autoDispose).
class AtsIncludeAllNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool value) => state = value;
}

final atsIncludeAllProvider = NotifierProvider.autoDispose<AtsIncludeAllNotifier, bool>(AtsIncludeAllNotifier.new);

/// Danh sách task ats-app cho khối "Công việc ATS" của màn Dự án. Lỗi chỉ làm hỏng khối này, không làm hỏng cả màn.
/// TẮT tự thử lại của Riverpod: khi đang thử lại, `.future` chưa kết thúc nên kéo làm mới cả màn (chờ cả khối này)
/// sẽ quay mãi khi ats lỗi. Lỗi hiện ngay, khối có nút "Thử lại".
final atsTasksProvider = FutureProvider.autoDispose<AtsTasksData>(
  (ref) => ref.watch(atsTasksApiProvider).getTasks(all: ref.watch(atsIncludeAllProvider)),
  retry: (_, _) => null,
);
