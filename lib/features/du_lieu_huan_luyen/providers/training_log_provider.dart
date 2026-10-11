import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/training_log.dart';
import '../services/training_log_api.dart';

/// Số liệu đầu màn: số mẫu đủ điều kiện train theo agent. autoDispose: rời màn thì bỏ cache.
final trainingStatsProvider = FutureProvider.autoDispose<TrainingStats>(
  (ref) => ref.watch(trainingLogApiProvider).stats(),
);

final trainingLogDetailProvider = FutureProvider.autoDispose.family<TrainingLogDetail, String>(
  (ref, id) => ref.watch(trainingLogApiProvider).detail(id),
);

typedef LogFilter = ({String? agent, LogOutcome? outcome});

class LogFilterNotifier extends Notifier<LogFilter> {
  @override
  LogFilter build() => (agent: null, outcome: null);

  void setAgent(String? agent) => state = (agent: agent, outcome: state.outcome);
  void setOutcome(LogOutcome? outcome) => state = (agent: state.agent, outcome: outcome);
}

final logFilterProvider = NotifierProvider.autoDispose<LogFilterNotifier, LogFilter>(LogFilterNotifier.new);

/// Danh sách đã tải + con trỏ trang kế. `loadingMore`/`loadMoreError` tách riêng để lỗi "tải thêm" không xóa danh sách đang xem.
class LogListState {
  const LogListState({this.items = const [], this.nextCursor, this.loadingMore = false, this.loadMoreError = false});

  final List<TrainingLogSummary> items;
  final String? nextCursor;
  final bool loadingMore;
  final bool loadMoreError;

  bool get hasMore => nextCursor != null;
}

/// Trang đầu tải khi build (đổi bộ lọc = build lại); các trang sau qua [loadMore].
class LogListNotifier extends AsyncNotifier<LogListState> {
  @override
  Future<LogListState> build() async {
    final f = ref.watch(logFilterProvider);
    final page = await ref.watch(trainingLogApiProvider).list(agent: f.agent, outcome: f.outcome);
    return LogListState(items: page.items, nextCursor: page.nextCursor);
  }

  Future<void> loadMore() async {
    final cur = state.value;
    if (cur == null || !cur.hasMore || cur.loadingMore) return;
    state = AsyncData(LogListState(items: cur.items, nextCursor: cur.nextCursor, loadingMore: true));
    final f = ref.read(logFilterProvider);
    try {
      final page = await ref.read(trainingLogApiProvider).list(agent: f.agent, outcome: f.outcome, cursor: cur.nextCursor);
      final seen = {for (final i in cur.items) i.id};
      state = AsyncData(LogListState(
        items: [...cur.items, ...page.items.where((i) => !seen.contains(i.id))],
        nextCursor: page.nextCursor,
      ));
    } catch (_) {
      state = AsyncData(LogListState(items: cur.items, nextCursor: cur.nextCursor, loadMoreError: true));
    }
  }
}

final logListProvider = AsyncNotifierProvider.autoDispose<LogListNotifier, LogListState>(LogListNotifier.new);
