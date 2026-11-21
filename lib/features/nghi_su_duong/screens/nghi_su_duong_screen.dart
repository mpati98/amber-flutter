import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/theme/design_tokens.dart';
import '../../../shared/utils/currency.dart';
import '../../../shared/utils/date_format.dart';
import '../../../shared/utils/vn_time.dart';
import '../../../shared/widgets/list_frame.dart';
import '../../../shared/widgets/zone_frame.dart';
import '../../../shared/widgets/zone_scaffold.dart';
import '../../kieu_lau/providers/kieu_lau_provider.dart';
import '../../tra_dinh/hoc_tap/models/study_overview.dart';
import '../../tra_dinh/hoc_tap/providers/hoc_tap_provider.dart';
import '../models/finance_summary.dart';
import '../models/project.dart';
import '../models/project_summary.dart';
import '../providers/ats_tasks_provider.dart';
import '../providers/finance_provider.dart';
import '../providers/nghi_su_duong_provider.dart';
import '../utils/finance_month.dart';
import '../utils/nsd_notices.dart';
import '../widgets/add_account_modal.dart';
import '../widgets/add_transaction_modal.dart';
import '../widgets/ats_tasks_card.dart';
import '../widgets/finance_widgets.dart';
import '../widgets/new_project_modal.dart';
import '../widgets/project_card.dart';
import '../widgets/routines_card.dart';

/// /nghi-su-duong — MỘT màn cho cả tòa ([ZoneScaffold], không cuộn trang). Chỉ đi sâu khi mở chi tiết một dự án
/// (/du-an/:id) hay một tháng tài chính (/finance/:id), hoặc kế hoạch học (/hoc-tap). /du-an và /finance cũ redirect về đây.
///
/// Web rộng — 3 cột flex 2 / 3 / 2:
/// - Trái: Cần chú ý (vừa nội dung) · Hôm nay (việc hằng ngày + học tập) · Công việc ATS.
/// - Giữa: Dự án đang triển khai (mở rộng: thẻ đầy đủ, gồm cả tạm dừng / đã xong).
/// - Phải: Tài chính — đầu khung cố định số dư ví + tháng này; thân là giao dịch tháng (mở rộng: các tháng, chọn tháng xem giao dịch).
/// Điện thoại: tab Dự án / Tài chính / Hôm nay / Cần chú ý / ATS.
class NghiSuDuongScreen extends ConsumerWidget {
  const NghiSuDuongScreen({super.key});

  static const wide = ZoneRow([
    ZoneColumn([ZoneCell.fit('attention', maxFraction: 0.3), ZoneCell('today'), ZoneCell('ats')], flex: 2),
    ZoneCell('projects', flex: 3),
    ZoneCell('finance', flex: 2),
  ]);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lỗi của từng nguồn đã hiện trong khung của nó — không để một nguồn lỗi làm hỏng lần kéo làm mới.
    Future<void> settle(Future<Object?> f) => f.then<void>((_) {}, onError: (_) {});

    return ZoneScaffold(
      title: 'Nghị Sự Đường',
      wide: wide,
      panes: [
        ZonePane(
          id: 'projects',
          label: 'Dự án',
          child: ZoneFrame(
            title: 'Dự án',
            expandable: true,
            onRefresh: () => settle(ref.refresh(duAnSummaryProvider.future)),
            actions: [
              DesignButton.outline(
                key: const ValueKey('add-project'),
                label: '+ Dự án',
                onPressed: () => showNewProjectModal(context),
              ),
            ],
            childBuilder: (_, expanded) => _Projects(expanded: expanded),
          ),
        ),
        ZonePane(
          id: 'finance',
          label: 'Tài chính',
          child: ZoneFrame(
            title: 'Tài chính',
            expandable: true,
            onRefresh: () => Future.wait([
              settle(ref.refresh(financeOverviewProvider.future)),
              settle(ref.refresh(financeProjectsProvider.future)),
            ]).then((_) {
              ref.invalidate(financeSummaryProvider);
              ref.invalidate(financeTransactionsProvider);
            }),
            actions: const [_AddTransactionButton()],
            header: const _FinanceHeader(),
            childBuilder: (_, expanded) => expanded ? const _MonthsBrowser() : const _CurrentTransactions(),
          ),
        ),
        ZonePane(
          id: 'today',
          label: 'Hôm nay',
          child: ZoneFrame(
            title: 'Hôm nay',
            onRefresh: () => Future.wait([
              settle(ref.refresh(routinesProvider.future)),
              settle(ref.refresh(studyOverviewProvider.future)),
            ]),
            childBuilder: (_, _) => const Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [RoutinesCard(bare: true), _StudyRow()],
            ),
          ),
        ),
        ZonePane(
          id: 'attention',
          label: 'Cần chú ý',
          child: ZoneFrame(
            title: 'Cần chú ý',
            onRefresh: () => Future.wait([
              settle(ref.refresh(notificationsProvider.future)),
              settle(ref.refresh(financeOverviewProvider.future)),
              settle(ref.refresh(duAnSummaryProvider.future)),
              settle(ref.refresh(routinesProvider.future)),
            ]),
            childBuilder: (_, _) => const _Notices(),
          ),
        ),
        ZonePane(
          id: 'ats',
          label: 'ATS',
          child: ZoneFrame(
            title: 'Công việc ATS',
            onRefresh: () => settle(ref.refresh(atsTasksProvider.future)),
            childBuilder: (_, _) => const AtsTasksCard(bare: true),
          ),
        ),
      ],
    );
  }
}

String _loading(AsyncValue<Object?> a, String failed) => a.hasError ? failed : 'Đang tải…';

// ───────────────────────────── Cần chú ý ─────────────────────────────

/// Cảnh báo ngắn ([buildNsdNotices]); không có gì (và mọi nguồn đã tải xong) → "Mọi thứ ổn".
class _Notices extends ConsumerWidget {
  const _Notices();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final finance = ref.watch(financeOverviewProvider);
    final notifications = ref.watch(notificationsProvider);
    final summary = ref.watch(duAnSummaryProvider);
    final routines = ref.watch(routinesProvider);
    final notices = buildNsdNotices(
      finance: finance.value,
      alerts: notifications.value?.alerts,
      attention: summary.value?.attention,
      routines: routines.value,
    );
    final loading = [finance, notifications, summary, routines].any((a) => !a.hasValue && !a.hasError);
    if (notices.isEmpty) {
      return loading
          ? const Text('Đang tải…', style: DesignText.muted)
          : const Text('Mọi thứ ổn.', key: ValueKey('nsd-all-ok'), style: TextStyle(color: DesignColors.success));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 6,
      children: [for (final n in notices) _NoticeLine(n)],
    );
  }
}

class _NoticeLine extends StatelessWidget {
  const _NoticeLine(this.notice);

  final NsdNotice notice;

  @override
  Widget build(BuildContext context) {
    final n = notice;
    final text = Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: n.title,
            style: TextStyle(color: n.level == NsdNoticeLevel.bad ? DesignColors.danger : DesignColors.warning),
          ),
          if (n.detail case final d?) TextSpan(text: ' · $d', style: DesignText.muted),
        ],
      ),
    );
    final href = n.href;
    if (href == null) return KeyedSubtree(key: ValueKey('nsd-notice-${n.id}'), child: text);
    return Semantics(
      button: true,
      child: InkWell(key: ValueKey('nsd-notice-${n.id}'), onTap: () => context.push(href), child: text),
    );
  }
}

// ───────────────────────────── Hôm nay: học tập ─────────────────────────────

/// Học tập: việc tiếp theo · tuần X / Y phút · chuỗi N ngày (studyOverviewProvider của Trà Đình); bấm → /hoc-tap.
class _StudyRow extends ConsumerWidget {
  const _StudyRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final study = ref.watch(studyOverviewProvider);
    final o = study.value;
    return FrameRow(
      key: const ValueKey('nsd-hoc-tap'),
      glyph: '學',
      title: 'Học tập',
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      glyphSize: 30,
      subtitle: o == null ? _loading(study, 'Không tải được số liệu.') : _studyLines(o),
      onTap: () => context.push('/hoc-tap'),
    );
  }

  static Widget _studyLines(StudyOverview o) {
    final next = o.subjects.map((s) => s.next).nonNulls.firstOrNull;
    final active = o.subjects.map((s) => s.activeCourse).nonNulls.firstOrNull;
    final streak = o.subjects.map((s) => s.streak ?? 0).fold<int>(0, (a, b) => a > b ? a : b);
    final queued = o.subjects.fold<int>(0, (n, s) => n + s.counts.queued);
    final String first = next != null
        ? 'Tiếp: ${next.courseTitle} · ${next.sectionTitle}'
        : active != null
        ? 'Đang học: ${active.title}'
        : (queued > 0 ? '$queued khóa chờ' : 'Chưa có khóa nào');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(first, key: const ValueKey('nsd-study-next'), style: DesignText.muted),
        Text(
          'Tuần ${o.week.minutes} / ${o.week.goalMinutes} phút · chuỗi $streak ngày',
          key: const ValueKey('nsd-study-week'),
          style: DesignText.muted,
        ),
      ],
    );
  }
}

// ───────────────────────────── Dự án ─────────────────────────────

/// Khung: dự án đang triển khai, mỗi dự án một dòng. Mở rộng: thẻ đầy đủ theo 3 nhóm Đang triển khai / Tạm dừng / Đã xong.
class _Projects extends ConsumerWidget {
  const _Projects({required this.expanded});

  final bool expanded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(duAnSummaryProvider);
    final projects = summary.value?.projects;
    if (projects == null) return Text(_loading(summary, 'Không tải được dự án.'), style: DesignText.muted);
    List<ProjectSummary> by(ProjectStatus s) => projects.where((p) => p.status == s).toList();
    final active = by(ProjectStatus.active);

    if (!expanded) {
      if (active.isEmpty) return const Text('Chưa có dự án nào đang triển khai.', style: DesignText.muted);
      return FrameRows(children: [for (final p in active) _ProjectRow(p)]);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        for (final (status, label) in const [
          (ProjectStatus.active, 'Đang triển khai'),
          (ProjectStatus.paused, 'Tạm dừng'),
          (ProjectStatus.done, 'Đã xong'),
        ]) ...[
          Text(
            '$label · ${by(status).length}',
            key: ValueKey('nsd-projects-${status.apiValue}'),
            style: const TextStyle(fontSize: 13, letterSpacing: 1, color: DesignColors.gold),
          ),
          if (by(status).isEmpty)
            const Text('Không có dự án nào.', style: DesignText.muted)
          else
            ProjectGrid(projects: by(status)),
        ],
      ],
    );
  }
}

/// % việc đã xong (0 khi chưa có việc).
int projectTaskPct(ProjectSummary p) => p.taskTotal == 0 ? 0 : (p.taskDone * 100 / p.taskTotal).round();

/// Hạn gần nhất: mốc kế tiếp, không có thì ngày kết thúc dự án.
String projectDeadline(ProjectSummary p) {
  final m = p.nextMilestone;
  if (m != null) return '${m.title} · ${formatDayMonth(m.dueDate)}';
  final end = p.endDate;
  return end == null ? 'Chưa có hạn' : 'Hạn ${formatDayMonth(end)}';
}

/// Tên · nhãn trạng thái ([projectBadge]) · % việc xong · hạn gần nhất, thanh tiến độ; bấm → chi tiết dự án.
class _ProjectRow extends StatelessWidget {
  const _ProjectRow(this.project);

  final ProjectSummary project;

  @override
  Widget build(BuildContext context) {
    final p = project;
    final badge = projectBadge(p);
    final pct = projectTaskPct(p);
    return FrameRow(
      key: ValueKey('nsd-project-${p.id}'),
      glyph: '案',
      glyphSize: 30,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      title: p.name,
      borderColor: badge.tone == ProjectBadgeTone.warning ? DesignColors.danger.withValues(alpha: 0.5) : null,
      subtitle: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: badge.label,
              style: TextStyle(color: badge.tone == ProjectBadgeTone.warning ? DesignColors.danger : DesignColors.info),
            ),
            TextSpan(text: ' · $pct% · ${projectDeadline(p)}'),
          ],
        ),
        style: DesignText.muted,
      ),
      below: DesignProgressBar(pct),
      onTap: () => context.push('/du-an/${p.id}'),
    );
  }
}

// ───────────────────────────── Tài chính ─────────────────────────────

/// Đầu khung Tài chính (cố định, cả trong modal): số dư mọi ví · tháng đang mở (bấm → chi tiết tháng) với thu / chi /
/// chênh lệch · thanh ngân sách gộp (khi tháng có đặt). Chưa mở tháng hiện tại → nút "Bắt đầu tháng mới".
class _FinanceHeader extends ConsumerWidget {
  const _FinanceHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(financeOverviewProvider);
    final months = ref.watch(financeProjectsProvider);
    final o = overview.value;
    final monthId = o?.activeProjectId;
    final summary = monthId == null ? null : ref.watch(financeSummaryProvider(monthId));
    final s = summary?.value;
    final showStart = months.hasValue && !hasCurrentFinanceMonth(months.value!);

    final balance = o == null
        ? Text(_loading(overview, 'Không tải được số dư.'), style: DesignText.muted)
        : Wrap(
            spacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                formatVnd(o.currentBalance),
                key: const ValueKey('nsd-balance'),
                style: TextStyle(fontSize: 20, color: o.currentBalance < 0 ? DesignColors.danger : DesignColors.text),
              ),
              if (o.currentBalance < 0) const DesignPill('Âm quỹ', color: DesignColors.danger),
            ],
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 4,
      children: [
        const Text('Số dư ví', style: DesignText.muted),
        balance,
        if (o != null && monthId == null) const Text('Chưa mở tháng tài chính nào.', style: DesignText.muted),
        if (monthId != null)
          InkWell(
            key: const ValueKey('nsd-month-open'),
            onTap: () => context.push('/finance/$monthId'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${o?.activeProjectName ?? s?.projectName ?? 'Tháng này'} ›', style: DesignText.bold),
                if (s != null)
                  MonthTotals(s)
                else
                  Text(_loading(summary!, 'Không tải được tháng này.'), style: DesignText.muted),
              ],
            ),
          ),
        if (s != null && s.budgetProgress.isNotEmpty) _BudgetTotal(s.budgetProgress),
        if (showStart) const Align(alignment: Alignment.centerLeft, child: StartMonthButton()),
      ],
    );
  }
}

/// Ngân sách gộp của tháng: tổng đã chi / tổng hạn mức; đỏ khi có danh mục vượt.
class _BudgetTotal extends StatelessWidget {
  const _BudgetTotal(this.budgets);

  final List<BudgetProgress> budgets;

  @override
  Widget build(BuildContext context) {
    final spent = budgets.fold<double>(0, (n, b) => n + b.spent);
    final limit = budgets.fold<double>(0, (n, b) => n + b.limitAmount);
    final over = budgets.where((b) => b.isOver).length;
    final color = over > 0 ? DesignColors.danger : DesignColors.gold;
    return Column(
      key: const ValueKey('nsd-budget'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: 'Ngân sách ${formatVnd(spent)} / ${formatVnd(limit)}'),
              if (over > 0) TextSpan(text: ' · vượt $over mục', style: const TextStyle(color: DesignColors.danger)),
            ],
          ),
          style: DesignText.muted,
        ),
        DesignProgressBar(limit == 0 ? 0 : spent * 100 / limit, color: color),
      ],
    );
  }
}

/// "+ Giao dịch" (form có sẵn) vào tháng đang mở; chưa có ví → mở form thêm ví trước (như màn chi tiết tháng).
/// Tắt khi chưa có tháng đang mở hoặc tháng đó đã qua.
class _AddTransactionButton extends ConsumerWidget {
  const _AddTransactionButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthId = ref.watch(financeOverviewProvider).value?.activeProjectId;
    final s = monthId == null ? null : ref.watch(financeSummaryProvider(monthId)).value;
    final accounts = ref.watch(financeAccountsProvider);
    final ended = s != null && (s.archivedAt != null || s.endDate.compareTo(vnToday()) < 0);
    final enabled = monthId != null && s != null && !ended && accounts.hasValue;
    return DesignButton.outline(
      key: const ValueKey('add-transaction'),
      label: '+ Giao dịch',
      onPressed: !enabled
          ? null
          : () => (accounts.value?.isNotEmpty ?? false)
                ? showAddTransactionModal(context, projectId: monthId)
                : showAddAccountModal(context, projectId: monthId),
    );
  }
}

/// Thân khung: giao dịch của tháng đang mở.
class _CurrentTransactions extends ConsumerWidget {
  const _CurrentTransactions();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(financeOverviewProvider);
    final o = overview.value;
    if (o == null) return Text(_loading(overview, 'Không tải được.'), style: DesignText.muted);
    final id = o.activeProjectId;
    if (id == null) return const Text('Chưa mở tháng tài chính này.', style: DesignText.muted);
    return _TransactionList(monthId: id);
  }
}

class _TransactionList extends ConsumerWidget {
  const _TransactionList({required this.monthId});

  final String monthId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(financeTransactionsProvider(monthId)).when(
      loading: () => const Text('Đang tải…', style: DesignText.muted),
      error: (_, _) => const Text('Không tải được giao dịch.', style: DesignText.muted),
      data: (items) => items.isEmpty
          ? const Text('Chưa có giao dịch nào.', style: DesignText.muted)
          : Column(
              key: ValueKey('nsd-transactions-$monthId'),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [for (final t in items) TransactionRow(t, key: ValueKey('tx-${t.id}'))],
            ),
    );
  }
}

/// Modal mở rộng của Tài chính (thay màn "Tài chính cá nhân" cũ): các tháng, chọn tháng → giao dịch tháng đó ngay trong modal,
/// kèm lối vào màn chi tiết tháng. Rộng: danh sách tháng bên trái; hẹp: hàng chip tháng ở trên.
class _MonthsBrowser extends ConsumerStatefulWidget {
  const _MonthsBrowser();

  @override
  ConsumerState<_MonthsBrowser> createState() => _MonthsBrowserState();
}

class _MonthsBrowserState extends ConsumerState<_MonthsBrowser> {
  String? _selected;

  @override
  Widget build(BuildContext context) {
    final months = ref.watch(financeProjectsProvider);
    final items = months.value;
    if (items == null) return Text(_loading(months, 'Không tải được danh sách tháng.'), style: DesignText.muted);
    if (items.isEmpty) {
      return const Text(
        'Chưa có dự án tài chính nào — bấm "Bắt đầu tháng mới" để tạo dự án cho tháng hiện tại.',
        style: DesignText.muted,
      );
    }
    final active = ref.watch(financeOverviewProvider).value?.activeProjectId;
    final selected = items.where((m) => m.id == _selected).firstOrNull ??
        items.where((m) => m.id == active).firstOrNull ??
        items.first;
    void select(Project m) => setState(() => _selected = m.id);
    final view = _MonthView(month: selected);

    return LayoutBuilder(
      builder: (context, c) {
        if (c.maxWidth >= 720) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              SizedBox(
                width: 320,
                child: FrameRows(
                  children: [for (final m in items) FinanceMonthRow(month: m, selected: m.id == selected.id, onTap: () => select(m))],
                ),
              ),
              Expanded(child: view),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            DesignChipRow<String>(
              items: [for (final m in items) (m.id, m.name)],
              selected: selected.id,
              onSelected: (id) => setState(() => _selected = id),
              keyOf: (id) => ValueKey('month-chip-$id'),
            ),
            view,
          ],
        );
      },
    );
  }
}

/// Một tháng trong modal: tên + thu / chi / chênh lệch + "Chi tiết tháng ›" (màn /finance/:id), rồi giao dịch.
class _MonthView extends ConsumerWidget {
  const _MonthView({required this.month});

  final Project month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(financeSummaryProvider(month.id)).value;
    return Column(
      key: ValueKey('nsd-month-view-${month.id}'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        Row(
          spacing: 8,
          children: [
            Expanded(child: Text(month.name, style: DesignText.bold)),
            DesignButton.outline(
              key: ValueKey('month-detail-${month.id}'),
              label: 'Chi tiết tháng ›',
              onPressed: () => context.push('/finance/${month.id}'),
            ),
          ],
        ),
        if (s != null) MonthTotals(s),
        _TransactionList(monthId: month.id),
      ],
    );
  }
}
