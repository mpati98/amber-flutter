import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderOrFamily;

import '../../kieu_lau/providers/kieu_lau_provider.dart';

import '../models/finance_account.dart';
import '../models/finance_budget.dart';
import '../models/finance_category.dart';
import '../models/finance_summary.dart';
import '../models/finance_transaction.dart';
import '../models/project.dart';
import '../services/finance_api.dart';
import 'nghi_su_duong_provider.dart';

final financeProjectsProvider = FutureProvider.autoDispose<List<Project>>(
  (ref) => ref.watch(financeApiProvider).getFinanceProjects(),
);

final financeAccountsProvider = FutureProvider.autoDispose<List<FinanceAccount>>(
  (ref) => ref.watch(financeApiProvider).getAccounts(),
);

/// Mọi danh mục; lọc thu/chi ở nơi dùng (1 request cho cả 2 loại).
final financeCategoriesProvider = FutureProvider.autoDispose<List<FinanceCategory>>(
  (ref) => ref.watch(financeApiProvider).getCategories(),
);

// Tham số = projectId (1 tháng).

final financeSummaryProvider = FutureProvider.autoDispose.family<FinanceSummary, String>(
  (ref, projectId) => ref.watch(financeApiProvider).getFinanceSummary(projectId),
);

final financeBudgetsProvider = FutureProvider.autoDispose.family<List<FinanceBudget>, String>(
  (ref, projectId) => ref.watch(financeApiProvider).getBudgets(projectId),
);

final financeTransactionsProvider = FutureProvider.autoDispose.family<List<FinanceTransaction>, String>(
  (ref, projectId) => ref.watch(financeApiProvider).getTransactions(projectId),
);

/// Giao dịch gắn với một dự án STANDARD (tham số = id dự án), qua mọi tháng, mới nhất trước.
final projectTransactionsProvider = FutureProvider.autoDispose.family<List<FinanceTransaction>, String>(
  (ref, projectId) => ref.watch(financeApiProvider).getTransactionsByLinkedProject(projectId),
);

/// Làm mới sau mọi thay đổi giao dịch của một dự án: danh sách thu-chi của dự án, summary màn Dự án và
/// các provider tài chính đang dùng ở màn Tài chính (số dư ví, tháng hiện tại, giao dịch từng tháng).
/// [invalidate] = `ref.invalidate`.
void refreshProjectFinance(void Function(ProviderOrFamily) invalidate, String projectId) {
  invalidate(projectTransactionsProvider(projectId));
  invalidate(duAnSummaryProvider);
  invalidate(financeAccountsProvider); // số dư ví đổi
  invalidate(financeProjectsProvider); // có thể vừa mở tháng hiện tại
  invalidate(financeOverviewProvider); // card Tài chính ở trang chính
  invalidate(financeSummaryProvider); // thu/chi, ngân sách của từng tháng
  invalidate(financeTransactionsProvider);
  invalidate(notificationsProvider); // cảnh báo vượt ngân sách
}
