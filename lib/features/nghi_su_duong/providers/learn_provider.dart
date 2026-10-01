import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/course.dart';
import '../models/lesson.dart';
import '../services/learn_api.dart';

/// Mọi khóa học, kèm bài học của từng khóa.
final coursesProvider = FutureProvider.autoDispose<List<Course>>(
  (ref) => ref.watch(learnApiProvider).getCourses(),
);

/// Tham số = courseId. Màn chi tiết dùng; danh sách đã có bài học sẵn trong Course.
final lessonsProvider = FutureProvider.autoDispose.family<List<Lesson>, String>(
  (ref, courseId) async => sortLessonsRecentFirst(await ref.watch(learnApiProvider).getLessons(courseId)),
);
