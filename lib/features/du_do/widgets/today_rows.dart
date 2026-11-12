import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/design_tokens.dart';
import '../../../shared/utils/currency.dart';
import '../../../shared/widgets/overview_block.dart';
import '../../kieu_lau/providers/kieu_lau_provider.dart';
import '../../nghi_su_duong/models/overview.dart';
import '../../nghi_su_duong/providers/finance_provider.dart';
import '../../nghi_su_duong/providers/nghi_su_duong_provider.dart';
import '../../tra_dinh/hoc_tap/models/study_overview.dart';
import '../../tra_dinh/hoc_tap/providers/hoc_tap_provider.dart';

// Ba dòng "Cập nhật hôm nay" của trang chủ. Mỗi dòng tự tải; lỗi chỉ ảnh hưởng dòng đó.

const _loading = 'Đang tải…';

/// Tin tức = cảnh báo của Kiều Lâu (task trễ hạn, vượt ngân sách, thiếu tháng tài chính, lâu không học).
class NewsRow extends ConsumerWidget {
  const NewsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const label = 'Tin tức';
    final async = ref.watch(notificationsProvider);
    final alerts = async.value?.alerts;
    if (alerts == null) {
      return OverviewRow.muted(label: label, text: async.hasError ? 'Không tải được tin.' : _loading);
    }
    if (alerts.isEmpty) return OverviewRow.muted(label: label, text: 'Không có tin mới. Mọi thứ ổn.');
    final more = alerts.length > 1 ? ' và ${alerts.length - 1} tin khác' : '';
    return OverviewRow(
      label: label,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: '${alerts.length} cảnh báo', style: const TextStyle(color: DesignColors.danger)),
            TextSpan(text: ' · ${alerts.first.title}$more', style: DesignText.muted),
          ],
        ),
      ),
    );
  }
}

/// Chi tiêu = số dư hiện tại của mọi ví (đỏ khi âm, giống mục Tài chính ở Nghị Sự Đường) · tổng chi của tháng tài chính đang mở.
class SpendingRow extends ConsumerWidget {
  const SpendingRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const label = 'Chi tiêu';
    final overview = ref.watch(financeOverviewProvider);
    final o = overview.value;
    if (o == null) {
      return OverviewRow.muted(label: label, text: overview.hasError ? 'Không tải được tài chính.' : _loading);
    }
    final projectId = o.activeProjectId;
    final summary = projectId == null ? null : ref.watch(financeSummaryProvider(projectId));
    final String detail = switch (summary) {
      null => ' · chưa mở tháng tài chính này',
      AsyncValue(value: final s?) => ' · chi ${formatVnd(s.totalExpense)} tháng này',
      AsyncValue(hasError: true) => ' · không tải được tháng này',
      _ => '',
    };
    return OverviewRow(
      label: label,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: formatVnd(o.currentBalance),
              style: o.currentBalance < 0 ? const TextStyle(color: DesignColors.danger) : null,
            ),
            TextSpan(text: detail, style: DesignText.muted),
          ],
        ),
      ),
    );
  }
}

/// Task = thẻ còn phải ôn + phút học / mục tiêu (Trà Đình) + dự án đang chạy và % trung bình (Nghị Sự Đường).
class TaskRow extends ConsumerWidget {
  const TaskRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final study = ref.watch(studyOverviewProvider);
    final projects = ref.watch(duAnOverviewProvider);
    final String text;
    if (study.value == null && projects.value == null) {
      text = study.hasError && projects.hasError ? 'Không tải được việc hôm nay.' : _loading;
    } else {
      text = taskSummary(study.value, projects.value);
    }
    return OverviewRow.muted(label: 'Task', text: text);
  }
}

/// Ghép câu của dòng Task; phần nào chưa có dữ liệu (null) hoặc không áp dụng thì bỏ.
@visibleForTesting
String taskSummary(StudyOverview? study, DuAnOverview? projects) {
  final parts = <String>[];
  if (study != null) {
    final cards = [for (final s in study.subjects) ?s.cards];
    if (cards.isNotEmpty) {
      final planned = cards.fold(0, (n, c) => n + c.planned);
      final left = cards.fold(0, (n, c) => n + (c.planned - c.finished).clamp(0, c.planned));
      if (planned > 0) parts.add(left > 0 ? 'Ôn $left thẻ' : 'Đã ôn xong thẻ');
    }
    final withGoal = study.subjects.where((s) => (s.goalMinutes ?? 0) > 0);
    if (withGoal.isNotEmpty) {
      final done = withGoal.fold(0, (n, s) => n + s.today.minutes);
      final goal = withGoal.fold(0, (n, s) => n + s.goalMinutes!);
      parts.add('học $done/$goal phút');
    }
  }
  if (projects != null && projects.activeProjects.isNotEmpty) {
    parts.add('${projects.activeProjects.length} dự án ${projects.averageProgress}%');
  }
  if (parts.isEmpty) return 'Không có việc nào hôm nay.';
  final text = parts.join(' · ');
  return text[0].toUpperCase() + text.substring(1);
}
