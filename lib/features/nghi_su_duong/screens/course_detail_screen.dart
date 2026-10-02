import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/duration_format.dart';
import '../../../shared/utils/vn_time.dart';
import '../../../shared/widgets/scroll_card.dart';
import '../models/course.dart';
import '../models/lesson.dart';
import '../providers/learn_provider.dart';
import '../providers/nghi_su_duong_provider.dart';
import '../services/learn_api.dart';
import '../widgets/add_lesson_modal.dart';
import '../widgets/finance_form_bits.dart';

TextStyle _muted(double size) => TextStyle(fontSize: size, color: Colors.white.withValues(alpha: 0.4));

/// "YYYY-MM-DD" → "d/M/yyyy".
String _viDate(String iso) {
  final p = iso.split('-');
  return '${int.parse(p[2])}/${int.parse(p[1])}/${p[0]}';
}

/// Port /hoc-tap/[id]. Backend không có GET 1 khóa học — lấy từ danh sách
/// (như web), bài học lấy riêng qua lessonsProvider.
class CourseDetailScreen extends ConsumerStatefulWidget {
  const CourseDetailScreen({super.key, required this.courseId});

  final String courseId;

  @override
  ConsumerState<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends ConsumerState<CourseDetailScreen> {
  final _outcome = TextEditingController();
  final _outcomeFocus = FocusNode();

  /// Giá trị outcome đã lưu gần nhất — chỉ PATCH khi thật sự đổi.
  String? _savedOutcome;
  bool _changingStatus = false;
  late final LearnApi _api = ref.read(learnApiProvider);

  @override
  void initState() {
    super.initState();
    // Tự lưu khi rời ô, như web (onBlur) — không có nút Lưu.
    _outcomeFocus.addListener(() {
      if (!_outcomeFocus.hasFocus) _saveOutcome();
    });
  }

  @override
  void dispose() {
    // Rời màn khi đang gõ dở (bấm back): vẫn lưu.
    if (_savedOutcome != null && _outcome.text != _savedOutcome) {
      _api.updateCourse(widget.courseId, outcome: _outcome.text);
    }
    _outcome.dispose();
    _outcomeFocus.dispose();
    super.dispose();
  }

  void _refresh() {
    ref.invalidate(coursesProvider);
    ref.invalidate(learnOverviewProvider); // card Học tập ở trang chính
  }

  Future<void> _saveOutcome() async {
    final text = _outcome.text;
    final previous = _savedOutcome;
    if (previous == null || text == previous) return;
    // Đánh dấu trước khi gửi: rời màn ngay sau khi rời ô thì dispose() thấy đã
    // lưu, không PATCH lần 2.
    _savedOutcome = text;
    try {
      await _api.updateCourse(widget.courseId, outcome: text);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Đã lưu kết quả đạt được.'), duration: Duration(seconds: 1)));
      }
    } on DioException {
      _savedOutcome = previous; // lần rời ô sau sẽ thử lưu lại
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Không lưu được kết quả, thử lại nhé.')));
      }
    }
  }

  /// Đổi trạng thái kèm tự điền ngày như web, theo lịch VN:
  /// - sang Đang học: startDate = hôm nay nếu chưa có;
  /// - sang Đã xong: endDate = hôm nay.
  /// archivedAt do backend tự đặt: Đã xong → now(), trạng thái khác → null.
  /// Khác web: bấm lại đúng trạng thái đang có thì bỏ qua — web vẫn gửi PATCH,
  /// với "Đã xong" sẽ ghi đè endDate và archivedAt bằng hôm nay.
  Future<void> _setStatus(Course course, CourseStatus status) async {
    if (status == course.status || _changingStatus) return;
    setState(() => _changingStatus = true);
    final today = vnToday();
    try {
      await _api.updateCourse(
        course.id,
        status: status,
        startDate: status == CourseStatus.inProgress && course.startDate == null ? today : null,
        endDate: status == CourseStatus.completed ? today : null,
      );
      _refresh();
    } on DioException {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Không đổi được trạng thái, thử lại nhé.')));
      }
    } finally {
      if (mounted) setState(() => _changingStatus = false);
    }
  }

  Future<void> _deleteLesson(Lesson lesson) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text('Xoá bài học "${lesson.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Huỷ')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.shuiro500),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _api.deleteLesson(lesson.id);
      ref.invalidate(lessonsProvider(widget.courseId));
      _refresh();
    } on DioException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không xoá được bài học.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final courses = ref.watch(coursesProvider);
    final lessons = ref.watch(lessonsProvider(widget.courseId));
    final course = courses.value?.where((c) => c.id == widget.courseId).firstOrNull;

    // Điền ô outcome 1 lần khi có dữ liệu (không ghi đè lúc đang gõ).
    if (course != null && _savedOutcome == null) {
      _savedOutcome = course.outcome ?? '';
      _outcome.text = _savedOutcome!;
    }

    return Scaffold(
      appBar: AppBar(title: Text(course?.name ?? 'Khóa học')),
      floatingActionButton: course == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => showAddLessonModal(context, courseId: course.id),
              icon: const Icon(Icons.add),
              label: const Text('Thêm bài học'),
            ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: courses.isLoading && course == null
              ? const Center(child: CircularProgressIndicator())
              : course == null
              ? Center(child: Text('Không tìm thấy khóa học này.', style: _muted(12)))
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  children: [
                    if (course.sourceAndField != null) ...[
                      Text(course.sourceAndField!, style: _muted(12)),
                      const SizedBox(height: 12),
                    ],
                    Row(
                      spacing: 12,
                      children: [
                        ChoiceRow<CourseStatus>(
                          options: {
                            for (final s in CourseStatus.values.where((s) => s != CourseStatus.unknown)) s: s.label,
                          },
                          selected: course.status,
                          onSelected: (s) => _setStatus(course, s),
                        ),
                        if (_changingStatus)
                          const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                      ],
                    ),
                    if (course.startDate != null || course.endDate != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        [
                          if (course.startDate != null) 'Bắt đầu ${_viDate(course.startDate!)}',
                          if (course.endDate != null) 'Kết thúc ${_viDate(course.endDate!)}',
                        ].join(' · '),
                        style: _muted(11),
                      ),
                    ],
                    const SizedBox(height: 16),
                    _Stats(lessons: lessons.value),
                    const SizedBox(height: 24),
                    ScrollCard(
                      glow: ScrollCardGlow.yugen,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: 8,
                        children: [
                          const _Title('Kết quả đạt được'),
                          TextField(
                            controller: _outcome,
                            focusNode: _outcomeFocus,
                            // Mặc định bấm ra ngoài KHÔNG bỏ focus (nhất là chuột trên web/desktop)
                            // → "rời ô" không xảy ra, không tự lưu.
                            onTapOutside: (_) => _outcomeFocus.unfocus(),
                            minLines: 2,
                            maxLines: 6,
                            decoration: const InputDecoration(hintText: 'Chứng chỉ, điểm số, tổng kết...'),
                          ),
                          Text('Tự lưu khi rời ô.', style: _muted(10)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ScrollCard(
                      glow: ScrollCardGlow.shuiro,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _Title('Bài học'),
                          const SizedBox(height: 8),
                          lessons.when(
                            loading: () => Text('Đang tải...', style: _muted(12)),
                            error: (_, _) => Text('Không tải được bài học.', style: _muted(12)),
                            data: (items) => items.isEmpty
                                ? Text('Chưa có bài học nào.', style: _muted(12))
                                : Column(
                                    children: [
                                      for (final l in items) _LessonRow(lesson: l, onDelete: () => _deleteLesson(l)),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.kincha400),
  );
}

class _Stats extends StatelessWidget {
  const _Stats({required this.lessons});

  final List<Lesson>? lessons;

  @override
  Widget build(BuildContext context) {
    final total = lessons?.fold<int>(0, (s, l) => s + (l.durationMinutes ?? 0));
    Widget box(String label, String value, ScrollCardGlow glow) => Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.ink900.withValues(alpha: 0.6),
          border: Border.all(color: glow.color),
          borderRadius: BorderRadius.circular(AppTheme.darkRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: _muted(11)),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
    return Row(
      spacing: 12,
      children: [
        box('Số bài đã học', lessons == null ? '–' : '${lessons!.length}', ScrollCardGlow.kincha),
        box('Tổng thời lượng', total == null ? '–' : formatDuration(total), ScrollCardGlow.yugen),
      ],
    );
  }
}

/// Xoá bằng nút thùng rác + xác nhận (không dùng vuốt như giao dịch: xoá bài
/// học không có tác dụng phụ như hoàn số dư ví, nút hiện rõ dễ tìm hơn).
class _LessonRow extends StatelessWidget {
  const _LessonRow({required this.lesson, required this.onDelete});

  final Lesson lesson;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final meta = [
      lesson.studiedAt == null ? 'Chưa ghi ngày' : _viDate(lesson.studiedAt!),
      if (lesson.durationMinutes != null) formatDuration(lesson.durationMinutes!),
      if (lesson.note != null && lesson.note!.isNotEmpty) lesson.note!,
    ].join(' · ');
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                  Text(meta, maxLines: 1, overflow: TextOverflow.ellipsis, style: _muted(11)),
                ],
              ),
            ),
          ),
          IconButton(
            tooltip: 'Xoá bài học',
            onPressed: onDelete,
            icon: Icon(Icons.delete_outline, size: 18, color: Colors.white.withValues(alpha: 0.4)),
          ),
        ],
      ),
    );
  }
}
