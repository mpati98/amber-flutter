import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/theme/design_tokens.dart';
import '../../../shared/utils/currency.dart';
import '../../../shared/widgets/design_page.dart';
import '../../../shared/widgets/list_frame.dart';
import '../../../shared/widgets/overview_block.dart';
import '../../tra_dinh/hoc_tap/models/study_overview.dart';
import '../../tra_dinh/hoc_tap/providers/hoc_tap_provider.dart';
import '../models/finance_summary.dart';
import '../models/overview.dart';
import '../providers/finance_provider.dart';
import '../providers/nghi_su_duong_provider.dart';

/// /nghi-su-duong theo design/ref/nghi-su-duong.html: Tổng quan (Dự án · Tài chính · Học tập) → 3 mục Dự án / Tài chính / Học tập.
/// 3 mảng mở ở cấp gốc (/du-an, /finance, /hoc-tap) như web.
class NghiSuDuongScreen extends ConsumerWidget {
  const NghiSuDuongScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(duAnOverviewProvider);
    final finance = ref.watch(financeOverviewProvider);
    final activeMonth = finance.value?.activeProjectId;
    final month = activeMonth == null ? null : ref.watch(financeSummaryProvider(activeMonth));
    final study = ref.watch(studyOverviewProvider);
    final learn = _LearnInfo.from(study.value);

    return DesignPage(
      title: 'Nghị Sự Đường',
      onRefresh: () => Future.wait([
        ref.refresh(duAnOverviewProvider.future),
        ref.refresh(financeOverviewProvider.future),
        // Học tập: lỗi tải không được làm hỏng việc làm mới hai mảng kia.
        ref.refresh(studyOverviewProvider.future).then<void>((_) {}, onError: (_) {}),
      ]),
      overview: OverviewBlock(
        title: 'Tổng quan',
        labelWidth: 90,
        rows: [
          OverviewRow.muted(label: 'Dự án', text: _projectsLine(projects)),
          OverviewRow(label: 'Tài chính', child: _FinanceLine(finance: finance)),
          OverviewRow.muted(
            label: 'Học tập',
            text: study.hasError && study.value == null ? 'Không tải được số liệu.' : (learn?.line ?? 'Đang tải…'),
          ),
        ],
      ),
      content: (context, _) => ListFrame(
        child: FrameRows(
          children: [
            _ProjectsRow(projects: projects, onTap: () => context.push('/du-an')),
            _FinanceRow(finance: finance, month: month, onTap: () => context.push('/finance')),
            FrameRow(
              key: const ValueKey('nsd-hoc-tap'),
              glyph: '學',
              title: 'Học tập',
              subtitle: learn?.line,
              trailing: learn?.pill,
              onTap: () => context.push('/hoc-tap'),
            ),
          ],
        ),
      ),
      hint: 'Chạm vào một mục để vào',
    );
  }
}

String _projectsLine(AsyncValue<DuAnOverview> projects) {
  final d = projects.value;
  if (d == null) return projects.hasError ? 'Không tải được số liệu.' : 'Đang tải…';
  return '${d.activeProjects.length} đang chạy · ${d.completedThisYear} xong năm nay';
}

/// Số dư hiện tại của mọi ví (đỏ khi âm) · tên tháng tài chính đang mở.
class _FinanceLine extends StatelessWidget {
  const _FinanceLine({required this.finance});

  final AsyncValue<FinanceOverview> finance;

  @override
  Widget build(BuildContext context) {
    final d = finance.value;
    if (d == null) return Text(finance.hasError ? 'Không tải được số liệu.' : 'Đang tải…', style: DesignText.muted);
    final month = d.activeProjectName;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: formatVnd(d.currentBalance), style: d.currentBalance < 0 ? const TextStyle(color: DesignColors.danger) : null),
          if (month != null) TextSpan(text: ' · $month', style: DesignText.muted),
        ],
      ),
    );
  }
}

class _ProjectsRow extends StatelessWidget {
  const _ProjectsRow({required this.projects, required this.onTap});

  final AsyncValue<DuAnOverview> projects;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final d = projects.value;
    final String sub;
    num? progress;
    if (d == null) {
      sub = projects.hasError ? 'Không tải được số liệu.' : 'Đang tải…';
    } else if (d.activeProjects.isEmpty) {
      sub = 'Chưa có dự án nào đang triển khai.';
    } else if (d.activeProjects.length == 1) {
      final p = d.activeProjects.single;
      sub = '${p.name} · ${p.progressPct}%';
      progress = p.progressPct;
    } else {
      sub = '${d.activeProjects.length} dự án · trung bình ${d.averageProgress}%';
      progress = d.averageProgress;
    }
    return FrameRow(
      key: const ValueKey('nsd-du-an'),
      glyph: '案',
      title: 'Dự án thông thường',
      subtitle: sub,
      below: progress == null ? null : DesignProgressBar(progress),
      onTap: onTap,
    );
  }
}

/// Số dư lớn (đỏ + "Âm quỹ" + viền đỏ sẫm khi âm) · Thu / Chi của tháng tài chính đang mở.
class _FinanceRow extends StatelessWidget {
  const _FinanceRow({required this.finance, required this.month, required this.onTap});

  final AsyncValue<FinanceOverview> finance;
  final AsyncValue<FinanceSummary>? month;
  final VoidCallback onTap;

  static const _negativeBorder = Color(0xFF7A2F2F);

  @override
  Widget build(BuildContext context) {
    final d = finance.value;
    if (d == null) {
      return FrameRow(
        key: const ValueKey('nsd-finance'),
        glyph: '財',
        title: 'Tài chính',
        subtitle: finance.hasError ? 'Không tải được số liệu.' : 'Đang tải…',
        onTap: onTap,
      );
    }
    final negative = d.currentBalance < 0;
    final m = month?.value;
    final String detail = month == null
        ? 'Chưa mở tháng tài chính này.'
        : m == null
            ? (month!.hasError ? 'Không tải được tháng này.' : 'Đang tải…')
            : 'Thu ${formatVnd(m.totalIncome)} · Chi ${formatVnd(m.totalExpense)}';
    return FrameRow(
      key: const ValueKey('nsd-finance'),
      glyph: '財',
      title: 'Tài chính',
      borderColor: negative ? _negativeBorder : null,
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            formatVnd(d.currentBalance),
            key: const ValueKey('nsd-balance'),
            style: TextStyle(fontSize: 20, color: negative ? DesignColors.danger : DesignColors.text),
          ),
          Wrap(
            spacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (negative) const DesignPill('Âm quỹ', color: DesignColors.danger),
              Text(detail, style: DesignText.muted),
            ],
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}

/// Dòng phụ + nhãn của mục Học tập (kế hoạch): đang học → "Đang học: …"; không thì "N khóa chờ".
class _LearnInfo {
  const _LearnInfo(this.line, this.pill);

  final String? line;
  final Widget? pill;

  static _LearnInfo? from(StudyOverview? o) {
    if (o == null) return null;
    final active = o.subjects.map((s) => s.activeCourse).nonNulls.firstOrNull;
    final queued = o.subjects.fold<int>(0, (n, s) => n + s.counts.queued);
    if (active != null) return _LearnInfo('Đang học: ${active.title}', const DesignPill('Đang học', color: DesignColors.info));
    if (queued > 0) return _LearnInfo('$queued khóa chờ', const DesignPill('Chờ'));
    return const _LearnInfo('Chưa có khóa nào', null);
  }
}
