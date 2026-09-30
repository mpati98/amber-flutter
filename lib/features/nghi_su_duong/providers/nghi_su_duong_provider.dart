import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/overview.dart';
import '../models/task.dart';
import '../services/nghi_su_duong_api.dart';

// autoDispose như các tòa khác: rời màn là bỏ cache, quay lại tải mới.

final duAnOverviewProvider = FutureProvider.autoDispose<DuAnOverview>(
  (ref) => ref.watch(nghiSuDuongApiProvider).getDuAnOverview(),
);

final financeOverviewProvider = FutureProvider.autoDispose<FinanceOverview>(
  (ref) => ref.watch(nghiSuDuongApiProvider).getFinanceOverview(),
);

final learnOverviewProvider = FutureProvider.autoDispose<LearnOverview>(
  (ref) => ref.watch(nghiSuDuongApiProvider).getLearnOverview(),
);

/// Mọi task — màn Dự án tự lọc "hôm nay" / "đang làm".
final tasksProvider = FutureProvider.autoDispose<List<Task>>(
  (ref) => ref.watch(nghiSuDuongApiProvider).getTasks(),
);
