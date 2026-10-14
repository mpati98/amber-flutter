import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/form_bits.dart';
import '../models/course.dart';
import '../models/parsed_sections.dart';
import '../models/study_enums.dart';
import '../providers/hoc_tap_provider.dart';
import '../utils/hoc_tap_errors.dart';
import 'sections_paste_field.dart';

/// Form thêm khóa ([course] null) hoặc sửa thông tin [course]. Mở bằng showFinanceSheet; trả về id khóa vừa tạo.
Future<String?> showCourseFormSheet(BuildContext context, {CourseView? course, String? subjectId, CourseStatus initialStatus = CourseStatus.queued}) =>
    showFinanceSheet<String>(context, CourseFormSheet(course: course, subjectId: subjectId, initialStatus: initialStatus));

class CourseFormSheet extends ConsumerStatefulWidget {
  const CourseFormSheet({super.key, this.course, this.subjectId, this.initialStatus = CourseStatus.queued});

  final CourseView? course;
  final String? subjectId;
  final CourseStatus initialStatus;

  @override
  ConsumerState<CourseFormSheet> createState() => _CourseFormSheetState();
}

class _CourseFormSheetState extends ConsumerState<CourseFormSheet> {
  late final _title = TextEditingController(text: widget.course?.title ?? '');
  late final _instructor = TextEditingController(text: widget.course?.instructor ?? '');
  late final _platform = TextEditingController(text: widget.course?.platform ?? '');
  late final _url = TextEditingController(text: widget.course?.url ?? '');
  late final _price = TextEditingController(text: widget.course?.targetPrice ?? '');
  late final _note = TextEditingController(text: widget.course?.note ?? '');
  late String? _subjectId = widget.course?.subjectId ?? widget.subjectId;
  late CourseStatus _status = widget.initialStatus;
  ParsedSections _parsed = const ParsedSections();
  bool _pending = false;
  bool _parseFailed = false;
  bool _busy = false;
  String? _error;

  bool get _editing => widget.course != null;
  bool get _showMoney => _editing || _status == CourseStatus.wishlist;

  @override
  void initState() {
    super.initState();
    _title.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    for (final c in [_title, _instructor, _platform, _url, _price, _note]) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _canSave =>
      !_busy && _title.text.trim().isNotEmpty && _subjectId != null && _parsed.skipped.isEmpty && !_pending && !_parseFailed;

  String? _nullIfBlank(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();

  Future<void> _save() async {
    if (!_canSave) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final actions = ref.read(hocTapActionsProvider);
      if (_editing) {
        // Sửa: gửi mọi trường thông tin (rỗng → null để xoá).
        await actions.patchCourse(widget.course!.id, {
          'title': _title.text.trim(),
          'instructor': _nullIfBlank(_instructor),
          'platform': _nullIfBlank(_platform),
          'url': _nullIfBlank(_url),
          'targetPrice': _nullIfBlank(_price),
          'note': _nullIfBlank(_note),
        });
        if (mounted) Navigator.of(context).pop(widget.course!.id);
      } else {
        final created = await actions.createCourse({
          'subjectId': _subjectId,
          'title': _title.text.trim(),
          'instructor': ?_nullIfBlank(_instructor),
          'platform': ?_nullIfBlank(_platform),
          'url': ?_nullIfBlank(_url),
          'status': _status.api,
          if (_status == CourseStatus.wishlist) 'targetPrice': ?_nullIfBlank(_price),
          if (_status == CourseStatus.wishlist) 'note': ?_nullIfBlank(_note),
          if (_parsed.sections.isNotEmpty) 'sections': [for (final s in _parsed.sections) {'title': s.title, 'durationMinutes': s.durationMinutes}],
        });
        if (mounted) Navigator.of(context).pop(created.course.id);
      }
    } catch (e) {
      if (mounted) setState(() => (_busy = false, _error = hocTapErrorMessage(e)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final subjects = ref.watch(studySubjectsProvider).value ?? const [];
    return FinanceSheetBody(
      title: _editing ? 'Sửa khóa học' : 'Thêm khóa học',
      children: [
        TextField(key: const ValueKey('course-title'), controller: _title, maxLength: 255, decoration: const InputDecoration(labelText: 'Tên khóa', counterText: '')),
        TextField(key: const ValueKey('course-instructor'), controller: _instructor, maxLength: 255, decoration: const InputDecoration(labelText: 'Giảng viên', counterText: '')),
        TextField(key: const ValueKey('course-platform'), controller: _platform, maxLength: 255, decoration: const InputDecoration(labelText: 'Nền tảng (Udemy, Coursera...)', counterText: '')),
        TextField(key: const ValueKey('course-url'), controller: _url, keyboardType: TextInputType.url, decoration: const InputDecoration(labelText: 'Link khóa học')),
        if (!_editing) ...[
          DropdownButtonFormField<String>(
            key: const ValueKey('course-subject'),
            initialValue: subjects.any((s) => s.id == _subjectId) ? _subjectId : null,
            decoration: const InputDecoration(labelText: 'Môn'),
            items: [for (final s in subjects) DropdownMenuItem(value: s.id, child: Text(s.name))],
            onChanged: (v) => setState(() => _subjectId = v),
          ),
          ChoiceRow<CourseStatus>(
            options: const {CourseStatus.active: 'Đang học', CourseStatus.queued: 'Chờ học', CourseStatus.wishlist: 'Muốn mua'},
            selected: _status,
            onSelected: (s) => setState(() => _status = s),
          ),
        ],
        if (_showMoney) ...[
          TextField(key: const ValueKey('course-price'), controller: _price, maxLength: 200, decoration: const InputDecoration(labelText: 'Giá định mua', counterText: '')),
          TextField(key: const ValueKey('course-note'), controller: _note, minLines: 2, maxLines: 4, decoration: const InputDecoration(labelText: 'Ghi chú')),
        ],
        if (!_editing)
          SectionsPasteField(
            onChanged: (result, {required pending, required failed}) => setState(() {
              _parsed = result;
              _pending = pending;
              _parseFailed = failed;
            }),
          ),
        sheetError(context, _error),
        FilledButton(key: const ValueKey('course-save'), onPressed: _canSave ? _save : null, child: Text(_editing ? 'Lưu' : 'Thêm khóa')),
      ],
    );
  }
}
