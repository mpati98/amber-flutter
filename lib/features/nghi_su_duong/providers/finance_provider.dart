import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/finance_account.dart';
import '../models/finance_budget.dart';
import '../models/finance_category.dart';
import '../models/finance_summary.dart';
import '../models/finance_transaction.dart';
import '../models/project.dart';
import '../services/finance_api.dart';

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
