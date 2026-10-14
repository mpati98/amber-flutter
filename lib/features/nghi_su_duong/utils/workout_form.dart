import 'package:dio/dio.dart';

import '../../../shared/utils/api_error.dart';
import '../models/routine.dart';

/// Giới hạn khớp backend (src/lib/workout-input.ts).
const maxWorkoutMinutes = 1440;
const maxExercises = 50;
const maxExerciseName = 100;
const _maxReps = 10000;
const _maxSets = 1000;
const _maxSeconds = 86400;

/// Một dòng bài tập đang nhập (chuỗi thô từ các ô).
class ExerciseDraft {
  const ExerciseDraft({
    this.name = '',
    this.measure = ExerciseMeasure.reps,
    this.sets = '',
    this.reps = '',
    this.seconds = '',
  });

  factory ExerciseDraft.fromExercise(Exercise e) => ExerciseDraft(
    name: e.name,
    measure: e.measure,
    sets: e.sets?.toString() ?? '',
    reps: e.reps?.toString() ?? '',
    seconds: e.durationSeconds?.toString() ?? '',
  );

  final String name;
  final ExerciseMeasure measure;
  final String sets;
  final String reps;
  final String seconds;

  /// Dòng hoàn toàn trống (không tên, không số) — bỏ qua khi lưu.
  bool get isBlank =>
      name.trim().isEmpty &&
      sets.trim().isEmpty &&
      reps.trim().isEmpty &&
      seconds.trim().isEmpty;
}

class WorkoutFormResult {
  const WorkoutFormResult({
    this.minutesError,
    this.rowErrors = const {},
    this.listError,
    this.minutes,
    this.exercises = const [],
  });

  final String? minutesError;

  /// Lỗi theo chỉ số dòng ĐANG HIỂN THỊ (kể cả dòng trống bị bỏ qua nên không bao giờ có lỗi).
  final Map<int, String> rowErrors;
  final String? listError;
  final int? minutes;
  final List<Exercise> exercises;

  bool get isValid =>
      minutesError == null && rowErrors.isEmpty && listError == null;
}

int? _positiveInt(String text, int max) {
  final n = int.tryParse(text.trim());
  return n != null && n >= 1 && n <= max ? n : null;
}

/// Kiểm tra form buổi tập. Số phút 1–1440 bắt buộc; mỗi bài cần tên và đúng các số của kiểu đo
/// (REPS: lần; SETS_REPS: hiệp + lần; DURATION: giây), số nguyên ≥ 1. Danh sách bài có thể rỗng.
WorkoutFormResult validateWorkoutForm({
  required String minutesText,
  required List<ExerciseDraft> rows,
}) {
  final minutes = _positiveInt(minutesText, maxWorkoutMinutes);
  final minutesError = minutes == null
      ? 'Nhập tổng số phút từ 1 đến $maxWorkoutMinutes.'
      : null;

  final errors = <int, String>{};
  final exercises = <Exercise>[];
  for (final (i, r) in rows.indexed) {
    if (r.isBlank) continue;
    final name = r.name.trim();
    if (name.isEmpty) {
      errors[i] = 'Nhập tên bài.';
      continue;
    }
    if (name.length > maxExerciseName) {
      errors[i] = 'Tên bài tối đa $maxExerciseName ký tự.';
      continue;
    }
    switch (r.measure) {
      case ExerciseMeasure.reps:
        final reps = _positiveInt(r.reps, _maxReps);
        if (reps == null) {
          errors[i] = 'Nhập số lần (số nguyên từ 1).';
        } else {
          exercises.add(Exercise(name: name, measure: r.measure, reps: reps));
        }
      case ExerciseMeasure.setsReps:
        final sets = _positiveInt(r.sets, _maxSets);
        final reps = _positiveInt(r.reps, _maxReps);
        if (sets == null || reps == null) {
          errors[i] = 'Nhập số hiệp và số lần (số nguyên từ 1).';
        } else {
          exercises.add(
            Exercise(name: name, measure: r.measure, sets: sets, reps: reps),
          );
        }
      case ExerciseMeasure.duration:
        final seconds = _positiveInt(r.seconds, _maxSeconds);
        if (seconds == null) {
          errors[i] = 'Nhập số giây (số nguyên từ 1).';
        } else {
          exercises.add(
            Exercise(name: name, measure: r.measure, durationSeconds: seconds),
          );
        }
    }
  }
  return WorkoutFormResult(
    minutesError: minutesError,
    rowErrors: errors,
    listError: exercises.length > maxExercises
        ? 'Tối đa $maxExercises bài một buổi.'
        : null,
    minutes: minutes,
    exercises: exercises,
  );
}

/// Câu báo lỗi tiếng Việt cho mã lỗi backend của việc hằng ngày; không rõ thì [fallback] (hoặc `message` của server).
String routineErrorMessage(Object error, String fallback) {
  switch (apiErrorCode(error)) {
    case 'not_today':
      return 'Chỉ ghi được buổi tập của hôm nay.';
    case 'not_scheduled':
      return 'Hôm nay không phải ngày của việc này.';
    case 'future_date':
      return 'Không ghi được cho ngày chưa tới.';
    case 'kind_locked':
      return 'Việc này đã có lịch sử nên không đổi loại được.';
    case 'routine_not_found':
      return 'Không tìm thấy việc này, có thể đã bị xoá.';
    case 'study_subject_required':
      return 'Chọn môn học cho việc này.';
    case 'study_subject_not_allowed':
      return 'Chỉ việc loại Học mới gắn với môn học.';
    case 'subject_not_found':
      return 'Không tìm thấy môn học này.';
    case 'goal_missing':
      return 'Môn này chưa đặt mục tiêu mỗi ngày, đặt trong Trà Đình trước.';
    case 'study_routine_exists':
      return 'Môn này đã có việc hằng ngày học tập.';
    case 'study_routine_auto':
      return 'Việc học tập tự tính từ buổi học ở Trà Đình, không tick tay.';
  }
  // Lỗi validate của zod: 400 với `error` là object (không phải câu cho người đọc).
  if (error is DioException &&
      error.response?.statusCode == 400 &&
      error.response?.data is Map &&
      (error.response!.data as Map)['error'] is Map) {
    return 'Dữ liệu buổi tập chưa hợp lệ, kiểm tra lại số phút và các bài.';
  }
  return apiErrorMessage(error, fallback);
}
