import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderOrFamily;

import '../../../shared/utils/vn_time.dart';
import '../../kieu_lau/providers/kieu_lau_provider.dart';

import '../models/overview.dart';
import '../models/project_detail.dart';
import '../models/project_summary.dart';
import '../models/routine.dart';
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

/// Việc hằng ngày (hôm nay). Notifier để tick ngay (lạc quan) rồi mới gọi API.
class RoutinesNotifier extends AsyncNotifier<List<Routine>> {
  @override
  Future<List<Routine>> build() => ref.watch(nghiSuDuongApiProvider).getRoutines();

  void _replace(Routine r) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData([for (final x in current) x.id == r.id ? r : x]);
  }

  /// Tick (`done` true → PUT log hôm nay) hoặc bỏ tick (DELETE). Đổi state NGAY; thành công thì thay bằng
  /// routine server trả về; lỗi thì trả lại bản cũ và ném lại để nơi gọi báo lỗi.
  Future<void> setDoneToday(Routine routine, bool done) async {
    _replace(routine.withDoneToday(done));
    try {
      final api = ref.read(nghiSuDuongApiProvider);
      final today = vnToday();
      _replace(done ? await api.markRoutineDone(routine.id, today) : await api.unmarkRoutineDone(routine.id, today));
    } catch (_) {
      _replace(routine);
      rethrow;
    }
  }
}

final routinesProvider = AsyncNotifierProvider.autoDispose<RoutinesNotifier, List<Routine>>(RoutinesNotifier.new);

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

/// Dự án STANDARD [id] kèm keyResults — màn Chi tiết dự án.
final projectDetailProvider = FutureProvider.autoDispose.family<ProjectDetail, String>(
  (ref, id) => ref.watch(nghiSuDuongApiProvider).getProject(id),
);

/// Việc của một dự án. Notifier để chuyển cột ngay (optimistic) rồi mới PATCH.
class ProjectTasksNotifier extends AsyncNotifier<List<Task>> {
  ProjectTasksNotifier(this.projectId);

  final String projectId;

  @override
  Future<List<Task>> build() => ref.watch(nghiSuDuongApiProvider).getProjectTasks(projectId);

  void _setStatus(String id, TaskStatus status) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData([for (final t in current) t.id == id ? t.copyWith(status: status) : t]);
  }

  /// Tick một mục checklist ngay (lạc quan) — chỉ đổi state, việc gọi API do nơi gọi làm.
  void setChecklistDone(String taskId, String itemId, bool done) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData([
      for (final t in current)
        t.id == taskId
            ? t.copyWith(
                checklistItems: [
                  for (final i in t.checklistItems)
                    i.id == itemId ? ChecklistItem(id: i.id, text: i.text, done: done, position: i.position) : i,
                ],
              )
            : t,
    ]);
  }

  /// Chuyển việc sang [next]: đổi state NGAY rồi PATCH; lỗi thì hoàn lại và ném lại để màn hình báo.
  /// Khoá theo id ([movingTasksProvider]) nên bấm liên tiếp chỉ gửi 1 PATCH — kể cả khi thẻ đã
  /// sang cột khác. Trả false nếu việc đang được gửi.
  Future<bool> move(Task task, TaskStatus next) async {
    final moving = ref.read(movingTasksProvider.notifier);
    if (!moving.start(task.id)) return false;
    _setStatus(task.id, next);
    try {
      await ref.read(nghiSuDuongApiProvider).updateTask(task.id, {'status': next.apiValue});
    } catch (_) {
      _setStatus(task.id, task.status);
      moving.finish(task.id);
      rethrow;
    }
    moving.finish(task.id);
    refreshProjectData(ref.invalidate, projectId);
    return true;
  }
}

final projectTasksProvider = AsyncNotifierProvider.autoDispose.family<ProjectTasksNotifier, List<Task>, String>(
  ProjectTasksNotifier.new,
);

/// Id các việc đang gửi PATCH chuyển cột — thẻ khoá nút theo đây.
class MovingTasksNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};

  /// false nếu [id] đang được gửi (đồng bộ, nên chống bấm đúp).
  bool start(String id) {
    if (state.contains(id)) return false;
    state = {...state, id};
    return true;
  }

  void finish(String id) => state = {...state}..remove(id);
}

final movingTasksProvider = NotifierProvider<MovingTasksNotifier, Set<String>>(MovingTasksNotifier.new);

/// Làm mới dữ liệu sau mọi thay đổi ở màn Chi tiết dự án (KR, việc, thông tin dự án): chính màn đó,
/// summary + overview của màn Dự án, cảnh báo hạn việc (Kiều Lâu). [invalidate] = `ref.invalidate`.
void refreshProjectData(void Function(ProviderOrFamily) invalidate, String? projectId) {
  if (projectId != null) {
    invalidate(projectDetailProvider(projectId));
    invalidate(projectTasksProvider(projectId));
  }
  invalidate(duAnSummaryProvider);
  invalidate(duAnOverviewProvider);
  invalidate(notificationsProvider);
}
