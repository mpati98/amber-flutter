import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../kieu_lau/providers/kieu_lau_provider.dart';

import '../models/overview.dart';
import '../models/project_summary.dart';
import '../models/task.dart';
import '../services/nghi_su_duong_api.dart';

// autoDispose như các tòa khác: rời màn là bỏ cache, quay lại tải mới.

final duAnOverviewProvider = FutureProvider.autoDispose<DuAnOverview>(
  (ref) => ref.watch(nghiSuDuongApiProvider).getDuAnOverview(),
);

/// Dữ liệu màn Dự án (danh sách dự án + việc cần chú ý). Làm mới: ref.invalidate / refresh.
final duAnSummaryProvider = FutureProvider.autoDispose<DuAnSummary>(
  (ref) => ref.watch(nghiSuDuongApiProvider).getDuAnSummary(),
);

/// Bộ lọc trạng thái ở khu "Dự án" của màn Dự án (mặc định Đang triển khai).
class DuAnFilterNotifier extends Notifier<ProjectStatus> {
  @override
  ProjectStatus build() => ProjectStatus.active;

  void select(ProjectStatus status) => state = status;
}

final duAnFilterProvider = NotifierProvider.autoDispose<DuAnFilterNotifier, ProjectStatus>(DuAnFilterNotifier.new);

final financeOverviewProvider = FutureProvider.autoDispose<FinanceOverview>(
  (ref) => ref.watch(nghiSuDuongApiProvider).getFinanceOverview(),
);

final learnOverviewProvider = FutureProvider.autoDispose<LearnOverview>(
  (ref) => ref.watch(nghiSuDuongApiProvider).getLearnOverview(),
);

/// Mọi task của user (cả việc đã xong, mọi ngày) — màn Dự án lọc "hôm nay" /
/// "đang làm", màn chi tiết dự án lọc theo projectId ở client.
/// Notifier để sửa state ngay (tick hoàn thành optimistic, ẩn việc vừa xoá).
class TasksNotifier extends AsyncNotifier<List<Task>> {
  @override
  Future<List<Task>> build() => ref.watch(nghiSuDuongApiProvider).getTasks();

  void _update(String id, Task Function(Task) change) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData([for (final t in current) t.id == id ? change(t) : t]);
  }

  /// Tick: chưa xong → DONE, đã xong → IN_PROGRESS. Đổi state NGAY rồi mới
  /// PATCH; lỗi thì hoàn lại trạng thái cũ và ném lại để màn hình báo.
  /// Chống bấm đúp nằm ở [TaskTile] (khoá ô tick trong lúc gửi).
  Future<void> toggleDone(Task task) async {
    final next = task.status == TaskStatus.done ? TaskStatus.inProgress : TaskStatus.done;
    _update(task.id, (t) => t.copyWith(status: next));
    try {
      await ref.read(nghiSuDuongApiProvider).updateTask(task.id, status: next);
    } catch (_) {
      _update(task.id, (t) => t.copyWith(status: task.status));
      rethrow;
    }
    refreshAfterWrite();
  }

  /// Bỏ việc vừa xoá khỏi state ngay (Dismissible đã dismiss mà còn trong cây
  /// widget sẽ báo lỗi) — server đã xoá, lần tải lại sau cũng không còn.
  void removeLocal(String id) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData([for (final t in current) if (t.id != id) t]);
  }

  /// Sau mọi thao tác ghi lên việc: danh sách việc, tiến độ dự án / "TB hoàn
  /// thành" và cảnh báo hạn việc + badge ở Dư Đồ (Kiều Lâu) đều phụ thuộc.
  /// Trong lúc tải lại vẫn giữ state hiện tại (đã cập nhật optimistic).
  void refreshAfterWrite() {
    ref.invalidateSelf();
    ref.invalidate(duAnOverviewProvider);
    ref.invalidate(duAnSummaryProvider);
    ref.invalidate(notificationsProvider);
  }
}

final tasksProvider = AsyncNotifierProvider.autoDispose<TasksNotifier, List<Task>>(TasksNotifier.new);
