import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/reading_goal.dart';
import '../services/reading_goal_api.dart';

// Số sách / tài liệu (danh sách, popup cảnh 3D): dùng lại publicationsProvider(null) và
// documentsProvider(null), đếm ở client — giống web, quy mô cá nhân không đáng
// thêm endpoint riêng chỉ để đếm.

/// Tham số = năm (tầng 3 Kế hoạch đọc dùng năm hiện tại).
final readingGoalProvider = FutureProvider.autoDispose.family<ReadingGoal, int>(
  (ref, year) => ref.watch(readingGoalApiProvider).getReadingGoal(year),
);
