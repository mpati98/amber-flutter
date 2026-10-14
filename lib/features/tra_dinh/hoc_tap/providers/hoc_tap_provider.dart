import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../nghi_su_duong/providers/nghi_su_duong_provider.dart';
import '../models/course.dart';
import '../models/study_enums.dart';
import '../models/study_overview.dart';
import '../models/study_subject.dart';
import '../services/hoc_tap_api.dart';

// autoDispose như các tòa khác: rời màn là bỏ cache, quay lại tải mới.

final studySubjectsProvider = FutureProvider.autoDispose<List<StudySubject>>((ref) => ref.watch(hocTapApiProvider).getSubjects());

final studyOverviewProvider = FutureProvider.autoDispose<StudyOverview>((ref) => ref.watch(hocTapApiProvider).getOverview());

/// Môn đang chọn ở chip tổng quan; null = chưa chọn (dùng môn đầu tiên).
class SelectedSubjectNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? id) => state = id;
}

final selectedSubjectIdProvider = NotifierProvider<SelectedSubjectNotifier, String?>(SelectedSubjectNotifier.new);

/// Khóa của danh sách khóa học: môn + các trạng thái (so sánh theo giá trị để family cache đúng).
class CourseQuery {
  CourseQuery({this.subjectId, Iterable<CourseStatus> statuses = const []}) : statuses = (statuses.toList()..sort((a, b) => a.api.compareTo(b.api)));

  final String? subjectId;
  final List<CourseStatus> statuses;

  @override
  bool operator ==(Object other) => other is CourseQuery && other.subjectId == subjectId && _same(other.statuses, statuses);

  @override
  int get hashCode => Object.hash(subjectId, Object.hashAll(statuses));

  static bool _same(List<CourseStatus> a, List<CourseStatus> b) => a.length == b.length && [for (var i = 0; i < a.length; i++) a[i] == b[i]].every((x) => x);
}

final studyCoursesProvider = FutureProvider.autoDispose.family<List<CourseView>, CourseQuery>(
  (ref, q) => ref.watch(hocTapApiProvider).getCourses(subjectId: q.subjectId, statuses: q.statuses),
);

/// Chi tiết 1 khóa. Notifier để tick phần ngay (lạc quan) rồi mới gọi API.
class StudyCourseDetailNotifier extends AsyncNotifier<CourseDetail> {
  StudyCourseDetailNotifier(this.courseId);

  final String courseId;

  @override
  Future<CourseDetail> build() => ref.watch(hocTapApiProvider).getCourseDetail(courseId);

  /// Tick / bỏ tick một phần. Đổi state NGAY; thành công thì thay bằng dữ liệu server (giữ recentLogs);
  /// lỗi thì hoàn tác và ném lại để màn hình báo.
  Future<void> setSectionDone(String sectionId, bool done) async {
    final before = state.value;
    if (before == null) return;
    state = AsyncData(before.withSectionDone(sectionId, done));
    try {
      final fresh = await ref.read(hocTapApiProvider).setSectionDone(courseId, sectionId, done);
      state = AsyncData(fresh.copyWith(recentLogs: before.recentLogs));
      _invalidateAround(ref, courseId: courseId, keepDetail: true);
    } catch (_) {
      state = AsyncData(before);
      rethrow;
    }
  }
}

final studyCourseDetailProvider = AsyncNotifierProvider.autoDispose.family<StudyCourseDetailNotifier, CourseDetail, String>(StudyCourseDetailNotifier.new);

/// Mọi thứ phụ thuộc khóa / môn học cần tải lại sau một thay đổi: tổng quan, danh sách khóa, chi tiết,
/// và việc hằng ngày của Nghị Sự Đường (routine STUDY tính từ nhật ký học).
void _invalidateAround(Ref ref, {String? courseId, bool keepDetail = false, bool subjects = false}) {
  ref.invalidate(studyOverviewProvider);
  ref.invalidate(studyCoursesProvider);
  if (!keepDetail) ref.invalidate(studyCourseDetailProvider);
  if (subjects) ref.invalidate(studySubjectsProvider);
  ref.invalidate(routinesProvider);
}

/// Các thao tác ghi: gọi API rồi invalidate các provider liên quan. Lỗi ném lại cho nơi gọi báo.
class HocTapActions {
  const HocTapActions(this._ref);

  final Ref _ref;

  HocTapApi get _api => _ref.read(hocTapApiProvider);

  Future<StudySubject> createSubject(Map<String, Object?> body) async {
    final s = await _api.createSubject(body);
    _invalidateAround(_ref, subjects: true);
    return s;
  }

  Future<void> updateSubject(String id, Map<String, Object?> patch) async {
    await _api.updateSubject(id, patch);
    _invalidateAround(_ref, subjects: true);
  }

  Future<void> deleteSubject(String id) async {
    await _api.deleteSubject(id);
    if (_ref.read(selectedSubjectIdProvider) == id) _ref.read(selectedSubjectIdProvider.notifier).select(null);
    _invalidateAround(_ref, subjects: true);
  }

  Future<void> rebaseline(String subjectId) async {
    await _api.rebaseline(subjectId);
    _invalidateAround(_ref);
  }

  Future<CourseDetail> createCourse(Map<String, Object?> body) async {
    final d = await _api.createCourse(body);
    _invalidateAround(_ref);
    return d;
  }

  Future<void> patchCourse(String id, Map<String, Object?> patch) async {
    await _api.patchCourse(id, patch);
    _invalidateAround(_ref, courseId: id);
  }

  Future<void> deleteCourse(String id) async {
    await _api.deleteCourse(id);
    _invalidateAround(_ref, courseId: id);
  }

  Future<void> putSections(String courseId, List<SectionInput> sections) async {
    await _api.putSections(courseId, sections);
    _invalidateAround(_ref, courseId: courseId);
  }

  Future<void> moveCourse(String id, {required bool up}) async {
    await _api.moveCourse(id, up: up);
    _invalidateAround(_ref, courseId: id);
  }
}

final hocTapActionsProvider = Provider<HocTapActions>(HocTapActions.new);
