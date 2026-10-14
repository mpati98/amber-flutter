import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/date_format.dart';
import '../../../shared/widgets/progress_ring.dart';
import '../../tra_dinh/hoc_tap/widgets/missing_reason_sheet.dart';
import '../models/routine.dart';
import 'routine_form.dart';

/// Dòng routine STUDY trong "Việc hằng ngày": vòng tiến độ phút học hôm nay / mục tiêu, tên môn, chuỗi.
/// Không tick tay — tự tính từ buổi học ở Trà Đình. Bấm → mở sheet ghi buổi học; có ngày thiếu lý do → hàng cảnh báo.
class StudyRoutineRow extends StatelessWidget {
  const StudyRoutineRow({super.key, required this.routine});

  final Routine routine;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = routine;
    final minutes = r.todayMinutes ?? 0;
    final goal = r.goalMinutes ?? 0;
    final dim = r.dueToday ? 1.0 : 0.5;
    // Ngày thiếu lý do hiển thị mới nhất trước.
    final pending = [...r.pendingReasonDates]..sort((a, b) => b.compareTo(a));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: InkWell(
                key: ValueKey('study-open-${r.id}'),
                onTap: () => context.push('/tra-dinh?openLog=1&subjectId=${r.studySubjectId ?? ''}'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    spacing: 12,
                    children: [
                      // Vượt mục tiêu thì ProgressRing tự kẹp ở đầy vòng; chữ số phút đầy đủ nằm ở dòng bên cạnh.
                      KeyedSubtree(
                        key: ValueKey('study-ring-${r.id}'),
                        child: ProgressRing(
                          value: minutes.toDouble(),
                          max: goal.toDouble(),
                          size: 64,
                          label: '${goal > 0 ? (minutes * 100 / goal).clamp(0, 100).round() : 0}%',
                          labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 2,
                          children: [
                            Text(r.name, style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withValues(alpha: dim))),
                            if (r.studySubjectName != null) Text(r.studySubjectName!, style: TextStyle(fontSize: 12, color: theme.textMuted)),
                            Text(
                              '$minutes / $goal phút · chuỗi ${r.streak} ngày',
                              key: ValueKey('study-progress-${r.id}'),
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: r.doneToday ? theme.success : theme.colorScheme.primary),
                            ),
                            Text('Tự tính từ buổi học ở Trà Đình', style: TextStyle(fontSize: 11, color: theme.textFaint)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            IconButton(tooltip: 'Sửa việc hằng ngày', visualDensity: VisualDensity.compact, onPressed: () => showRoutineForm(context, routine: r), icon: const Icon(Icons.edit_outlined)),
          ],
        ),
        if (pending.isNotEmpty && r.studySubjectId != null)
          InkWell(
            key: ValueKey('study-pending-${r.id}'),
            onTap: () => showMissingReasonSheet(
              context,
              subjectId: r.studySubjectId!,
              subjectName: r.studySubjectName ?? 'Môn học',
              goalMinutes: goal,
              dates: r.pendingReasonDates,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.shuiro500.withValues(alpha: 0.12),
                border: Border.all(color: AppColors.shuiro500.withValues(alpha: 0.5)),
                borderRadius: BorderRadius.circular(AppTheme.darkRadius),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, size: 18, color: AppColors.shuiro500),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Thiếu lý do: ${pending.map(formatDayMonth).join(', ')}', style: const TextStyle(fontSize: 13))),
                  Icon(Icons.chevron_right, color: theme.textFaint),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
