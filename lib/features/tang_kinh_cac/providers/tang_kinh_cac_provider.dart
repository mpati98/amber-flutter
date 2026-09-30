import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/highlight.dart';
import '../models/reading_goal.dart';
import '../services/highlight_api.dart';
import '../services/reading_goal_api.dart';

// Số sách/tài liệu trên trang chính: dùng lại publicationsProvider(null) và
// documentsProvider(null), đếm ở client — giống web, quy mô cá nhân không đáng
// thêm endpoint riêng chỉ để đếm.

/// Mỗi lần vào trang chính rút 1 highlight mới (autoDispose).
final resurfacedHighlightProvider = FutureProvider.autoDispose<ResurfacedHighlight?>(
  (ref) => ref.watch(highlightApiProvider).getRandomHighlight(),
);

/// Tham số = năm (trang chính và Kế hoạch đọc dùng năm hiện tại).
final readingGoalProvider = FutureProvider.autoDispose.family<ReadingGoal, int>(
  (ref, year) => ref.watch(readingGoalApiProvider).getReadingGoal(year),
);
