import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/utils/duration_format.dart';
import '../../../../shared/utils/vn_time.dart';
import '../../../../shared/widgets/form_bits.dart';
import '../models/course.dart';
import '../models/study_enums.dart';
import '../models/study_log.dart';
import '../models/study_subject.dart';
import '../providers/hoc_tap_provider.dart';
import '../utils/hoc_tap_errors.dart';

/// Mở sheet ghi buổi học HÔM NAY ([editing] null) hoặc sửa / xoá một buổi của hôm nay. Xong thì hiện SnackBar
/// ở màn gọi (sheet trả về câu thông báo khi đóng).
Future<void> showLogSheet(BuildContext context, {String? subjectId, String? courseId, StudyLog? editing}) async {
  final message = await showFinanceSheet<String>(context, LogSheet(subjectId: subjectId, courseId: courseId, editing: editing));
  if (message != null && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

const _weekdayNames = ['Thứ Hai', 'Thứ Ba', 'Thứ Tư', 'Thứ Năm', 'Thứ Sáu', 'Thứ Bảy', 'Chủ nhật'];

/// "Thứ Tư, 14/10" theo lịch VN.
String viDayLabel([DateTime? at]) {
  final d = vnNow(at);
  return '${_weekdayNames[d.weekday - 1]}, ${d.day}/${d.month}';
}

/// Nhãn lý do trong sheet (dài hơn nhãn ngắn của [ReasonCode]).
const reasonChoices = <ReasonCode, String>{
  ReasonCode.busy: 'Bận việc',
  ReasonCode.tired: 'Mệt',
  ReasonCode.away: 'Đi xa',
  ReasonCode.other: 'Khác',
};

/// Chip chọn lý do (chọn được 0 hoặc 1) + ô văn bản. Dùng ở sheet ghi buổi và sheet lý do thiếu.
class ReasonPicker extends StatelessWidget {
  const ReasonPicker({super.key, required this.selected, required this.onSelected, required this.text});

  final ReasonCode? selected;
  final ValueChanged<ReasonCode> onSelected;
  final TextEditingController text;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final e in reasonChoices.entries)
              ChoiceChip(
                key: ValueKey('reason-${e.key.api}'),
                label: Text(e.value),
                selected: selected == e.key,
                showCheckmark: false,
                selectedColor: AppColors.kincha400,
                labelStyle: TextStyle(fontSize: 13, color: selected == e.key ? AppColors.ink950 : null),
                onSelected: (_) => onSelected(e.key),
              ),
          ],
        ),
        TextField(
          key: const ValueKey('reason-text'),
          controller: text,
          maxLength: 500,
          decoration: InputDecoration(labelText: selected == ReasonCode.other ? 'Lý do (bắt buộc)' : 'Ghi chú lý do (tuỳ chọn)', counterText: ''),
        ),
      ],
    );
  }
}

/// Hợp lệ khi đã chọn lý do và, nếu chọn Khác, có văn bản.
bool reasonValid(ReasonCode? code, String text) => code != null && (code != ReasonCode.other || text.trim().isNotEmpty);

class LogSheet extends ConsumerStatefulWidget {
  const LogSheet({super.key, this.subjectId, this.courseId, this.editing});

  final String? subjectId;
  final String? courseId;
  final StudyLog? editing;

  @override
  ConsumerState<LogSheet> createState() => _LogSheetState();
}

class _LogSheetState extends ConsumerState<LogSheet> {
  static const _sectionPage = 10;

  late final _minutes = TextEditingController(text: widget.editing?.minutes.toString() ?? '');
  late final _note = TextEditingController(text: widget.editing?.note ?? '');
  final _reasonText = TextEditingController();

  String? _subjectId;
  String? _courseId;
  bool _courseInit = false;
  String? _sectionsFor; // khóa mà _picked đã được khởi tạo
  final Map<String, bool> _picked = {}; // sectionId → xong phần
  bool _showAllSections = false;
  bool _stop = false;
  bool _stopInit = false;
  ReasonCode? _reason;
  bool _busy = false;
  String? _error;

  bool get _editing => widget.editing != null;

  @override
  void initState() {
    super.initState();
    _subjectId = widget.editing?.subjectId ?? widget.subjectId;
    for (final c in [_minutes, _reasonText]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _minutes.dispose();
    _note.dispose();
    _reasonText.dispose();
    super.dispose();
  }

  int get _input => int.tryParse(_minutes.text.trim()) ?? 0;

  void _pickSubject(String id) => setState(() {
    _subjectId = id;
    _courseInit = false;
    _courseId = null;
    _sectionsFor = null;
    _picked.clear();
    _stopInit = false;
  });

  void _pickCourse(String? id) => setState(() {
    _courseId = id;
    _sectionsFor = null;
    _picked.clear();
    _showAllSections = false;
  });

  Future<void> _save({required StudySubject subject, required int logged, required Map<String, CourseStatus> statuses}) async {
    if (_busy) return;
    final goal = subject.dailyGoalMinutes;
    final stopActive = goal != null && logged + _input < goal && _stop;
    final sections = [for (final e in _picked.entries) {'sectionId': e.key, 'markDone': e.value}];
    final note = _note.text.trim();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final actions = ref.read(hocTapActionsProvider);
      final stop = stopActive ? {'code': _reason!.api, if (_reasonText.text.trim().isNotEmpty) 'text': _reasonText.text.trim()} : null;
      final StudyLogResult result;
      if (_editing) {
        result = await actions.patchLog(widget.editing!.id, {
          'minutes': _input,
          'note': note.isEmpty ? null : note,
          if (_courseId != null) 'sections': sections,
          'stopForToday': ?stop,
        });
      } else {
        result = await actions.createLog({
          'subjectId': subject.id,
          'courseId': ?_courseId,
          'minutes': _input,
          if (sections.isNotEmpty) 'sections': sections,
          if (note.isNotEmpty) 'note': note,
          'stopForToday': ?stop,
        });
      }
      final t = result.today;
      final todayText = t.goalMinutes == null ? '${t.minutes} phút' : '${t.minutes}/${t.goalMinutes}';
      final completed = result.course?.status == CourseStatus.done && statuses[result.course!.id] != CourseStatus.done;
      final message = [
        _editing ? 'Đã cập nhật buổi học · hôm nay $todayText' : 'Đã ghi $_input phút · hôm nay $todayText',
        if (completed) 'Xong khóa ${result.course!.title}',
      ].join('\n');
      if (mounted) Navigator.of(context).pop(message);
    } catch (e) {
      if (mounted) setState(() => (_busy = false, _error = hocTapErrorMessage(e)));
    }
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xoá buổi học?'),
        content: const Text('Xoá buổi học này khỏi hôm nay? Phần đã đánh dấu xong vẫn giữ nguyên.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Huỷ')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(hocTapActionsProvider).deleteLog(widget.editing!.id);
      if (mounted) Navigator.of(context).pop('Đã xoá buổi học');
    } catch (e) {
      if (mounted) setState(() => (_busy = false, _error = hocTapErrorMessage(e)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = _editing ? 'Sửa buổi học' : 'Ghi buổi học';
    final subjects = ref.watch(studySubjectsProvider).value;
    if (subjects == null || subjects.isEmpty) {
      return FinanceSheetBody(
        title: title,
        children: [Padding(padding: const EdgeInsets.all(24), child: Center(child: Text(subjects == null ? 'Đang tải...' : 'Tạo môn học trước khi ghi buổi học.')))],
      );
    }
    _subjectId = subjects.any((s) => s.id == _subjectId) ? _subjectId : (ref.watch(selectedSubjectIdProvider) ?? subjects.first.id);
    final subject = subjects.firstWhere((s) => s.id == _subjectId, orElse: () => subjects.first);

    final courses = ref.watch(studyCoursesProvider(CourseQuery(subjectId: subject.id, statuses: const [CourseStatus.active, CourseStatus.queued]))).value ?? const <CourseView>[];
    if (!_courseInit && ref.read(studyCoursesProvider(CourseQuery(subjectId: subject.id, statuses: const [CourseStatus.active, CourseStatus.queued]))).hasValue) {
      _courseInit = true;
      _courseId = _editing
          ? widget.editing!.courseId
          : (widget.courseId != null && widget.subjectId == subject.id ? widget.courseId : courses.where((c) => c.status == CourseStatus.active).firstOrNull?.id);
    }
    final detail = _courseId == null ? null : ref.watch(studyCourseDetailProvider(_courseId!)).value;
    final statuses = {for (final c in courses) c.id: c.status, if (detail != null) detail.course.id: detail.course.status};
    // Khóa đã chọn nhưng không còn ACTIVE / QUEUED (vd DONE) vẫn phải hiện trong danh sách.
    final options = <({String id, String title})>[
      for (final c in courses) (id: c.id, title: c.title),
      if (_courseId != null && !courses.any((c) => c.id == _courseId)) (id: _courseId!, title: detail?.course.title ?? widget.editing?.courseTitle ?? 'Khóa học'),
    ];

    // Khởi tạo các phần được chọn khi khóa tải xong.
    if (detail != null && _sectionsFor != _courseId) {
      _sectionsFor = _courseId;
      _picked.clear();
      if (_editing && widget.editing!.courseId == _courseId) {
        for (final s in widget.editing!.sections) {
          _picked[s.sectionId] = s.markedDone;
        }
      } else if (detail.course.nextSection != null) {
        _picked[detail.course.nextSection!.id] = false;
      }
    }

    final todayLogs = ref.watch(studyTodayLogsProvider(subject.id)).value ?? const <StudyLog>[];
    final logged = todayLogs.fold<int>(0, (n, l) => n + l.minutes) - (widget.editing?.minutes ?? 0);
    final goal = subject.dailyGoalMinutes;
    final planned = logged + _input;
    final reached = goal != null && planned >= goal;
    final canStop = goal != null && !reached;

    // Sửa buổi mà hôm nay đã có lý do dừng → bật sẵn.
    if (_editing && !_stopInit) {
      final overview = ref.watch(studyOverviewProvider).value;
      final existing = overview?.subjects.where((s) => s.subjectId == subject.id).firstOrNull?.today.reason;
      if (overview != null) {
        _stopInit = true;
        if (existing != null) {
          _stop = true;
          _reason = existing.code == ReasonCode.unknown ? null : existing.code;
          _reasonText.text = existing.text ?? '';
        }
      }
    }
    final stopActive = canStop && _stop;
    final canSave = !_busy && _input >= 1 && _input <= 1440 && (!stopActive || reasonValid(_reason, _reasonText.text));

    final visibleSections = detail == null ? const <CourseSection>[] : [for (final s in detail.sections) if (!s.done || _picked.containsKey(s.id)) s];
    final shownSections = _showAllSections ? visibleSections : visibleSections.take(_sectionPage).toList();

    return FinanceSheetBody(
      title: title,
      children: [
        Text('Hôm nay · ${viDayLabel()}. Chỉ ghi cho hôm nay.', key: const ValueKey('log-header'), style: TextStyle(fontSize: 13, color: theme.textMuted)),
        if (subjects.length > 1 && !_editing)
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final s in subjects)
                ChoiceChip(
                  key: ValueKey('log-subject-${s.id}'),
                  label: Text(s.name),
                  selected: s.id == subject.id,
                  showCheckmark: false,
                  selectedColor: AppColors.kincha400,
                  labelStyle: TextStyle(fontSize: 13, color: s.id == subject.id ? AppColors.ink950 : null),
                  onSelected: (_) => _pickSubject(s.id),
                ),
            ],
          ),
        if (_editing)
          Text('Môn: ${subject.name} · Khóa: ${widget.editing!.courseTitle ?? 'Ôn tập (không gắn khóa)'}', style: const TextStyle(fontSize: 13))
        else
          DropdownButtonFormField<String?>(
            key: ValueKey('log-course-${subject.id}-$_courseId'),
            initialValue: _courseId,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Khóa học'),
            items: [
              const DropdownMenuItem<String?>(value: null, child: Text('Không gắn khóa (ôn tập)')),
              for (final o in options) DropdownMenuItem<String?>(value: o.id, child: Text(o.title, overflow: TextOverflow.ellipsis)),
            ],
            onChanged: _pickCourse,
          ),
        TextField(
          key: const ValueKey('log-minutes'),
          controller: _minutes,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Số phút học', suffixText: 'phút'),
        ),
        Wrap(
          spacing: 6,
          children: [for (final m in const [30, 45, 60]) ActionChip(key: ValueKey('quick-$m'), label: Text('$m'), onPressed: () => _minutes.text = '$m')],
        ),
        if (_courseId != null && detail != null) ...[
          Text('Phần đã học', style: TextStyle(fontSize: 12, color: theme.textMuted)),
          if (visibleSections.isEmpty) Text('Khóa này không còn phần nào chưa xong.', style: TextStyle(fontSize: 13, color: theme.textMuted)),
          for (final s in shownSections) _SectionPick(
            section: s,
            picked: _picked.containsKey(s.id),
            markDone: _picked[s.id] ?? false,
            onPick: (on) => setState(() => on ? _picked[s.id] = false : _picked.remove(s.id)),
            onMarkDone: (v) => setState(() => _picked[s.id] = v),
          ),
          if (!_showAllSections && visibleSections.length > _sectionPage)
            TextButton(key: const ValueKey('more-sections'), onPressed: () => setState(() => _showAllSections = true), child: Text('Xem thêm (${visibleSections.length - _sectionPage})')),
          if (_editing)
            Text('Bỏ "Xong phần" ở đây không làm phần hết xong; muốn bỏ thì vào chi tiết khóa.', key: const ValueKey('edit-section-note'), style: TextStyle(fontSize: 12, color: theme.textFaint)),
        ],
        TextField(key: const ValueKey('log-note'), controller: _note, minLines: 1, maxLines: 3, maxLength: 2000, decoration: const InputDecoration(labelText: 'Ghi chú (tuỳ chọn)', counterText: '')),
        _TotalBlock(
          logged: logged,
          input: _input,
          goal: goal,
          reached: reached,
          stop: _stop,
          onStop: canStop ? (v) => setState(() => _stop = v) : null,
        ),
        if (stopActive) ReasonPicker(selected: _reason, onSelected: (r) => setState(() => _reason = r), text: _reasonText),
        if (canStop)
          Text('Không chọn dừng thì ngày vẫn mở; hết ngày mà chưa đủ, sáng mai app hỏi lý do.', key: const ValueKey('stop-hint'), style: TextStyle(fontSize: 12, color: theme.textFaint)),
        sheetError(context, _error),
        FilledButton(key: const ValueKey('log-save'), onPressed: canSave ? () => _save(subject: subject, logged: logged, statuses: statuses) : null, child: Text(_editing ? 'Lưu' : 'Ghi buổi học')),
        if (_editing)
          TextButton(
            key: const ValueKey('log-delete'),
            onPressed: _busy ? null : _delete,
            style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
            child: const Text('Xoá buổi học'),
          ),
      ],
    );
  }
}

class _SectionPick extends StatelessWidget {
  const _SectionPick({required this.section, required this.picked, required this.markDone, required this.onPick, required this.onMarkDone});

  final CourseSection section;
  final bool picked;
  final bool markDone;
  final ValueChanged<bool> onPick;
  final ValueChanged<bool> onMarkDone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      key: ValueKey('pick-row-${section.id}'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () => onPick(!picked),
          child: Row(
            children: [
              Checkbox(key: ValueKey('pick-${section.id}'), value: picked, onChanged: (v) => onPick(v ?? false)),
              Expanded(child: Text(section.title, style: const TextStyle(fontSize: 14))),
              Text(formatDuration(section.durationMinutes), style: TextStyle(fontSize: 12, color: theme.textMuted)),
            ],
          ),
        ),
        if (picked)
          Padding(
            padding: const EdgeInsets.only(left: 48),
            child: Row(
              children: [
                Text('Xong phần', style: TextStyle(fontSize: 13, color: theme.textMuted)),
                const SizedBox(width: 8),
                Switch(key: ValueKey('done-${section.id}'), value: markDone, onChanged: onMarkDone),
              ],
            ),
          ),
      ],
    );
  }
}

/// Khối "Hôm nay": (đã ghi + đang nhập) / mục tiêu. Đủ mục tiêu → màu đạt, ẩn công tắc dừng.
class _TotalBlock extends StatelessWidget {
  const _TotalBlock({required this.logged, required this.input, required this.goal, required this.reached, required this.stop, required this.onStop});

  final int logged;
  final int input;
  final int? goal;
  final bool reached;
  final bool stop;
  final ValueChanged<bool>? onStop;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = reached ? theme.success : AppColors.kincha400;
    return Container(
      key: const ValueKey('total-block'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(AppTheme.darkRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            goal == null ? 'Hôm nay: ${logged + input} phút' : 'Hôm nay: ${logged + input} / $goal phút${reached ? ' · đủ mục tiêu' : ''}',
            key: const ValueKey('total-text'),
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: color),
          ),
          Text('Đã ghi $logged + đang nhập $input', style: TextStyle(fontSize: 12, color: theme.textMuted)),
          if (goal == null) Text('Môn chưa đặt mục tiêu mỗi ngày.', style: TextStyle(fontSize: 12, color: theme.textFaint)),
          if (onStop != null)
            Row(
              children: [
                const Expanded(child: Text('Hôm nay dừng ở đây', style: TextStyle(fontSize: 14))),
                Switch(key: const ValueKey('stop-switch'), value: stop, onChanged: onStop),
              ],
            ),
        ],
      ),
    );
  }
}
