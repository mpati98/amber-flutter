import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/services/api_client.dart';
import '../models/finance_account.dart';
import '../models/finance_budget.dart';
import '../models/finance_category.dart';
import '../models/finance_summary.dart';
import '../models/finance_transaction.dart';
import '../models/project.dart';

/// Mảng Tài chính: mỗi tháng là 1 project FINANCE; ví và danh mục dùng chung
/// mọi tháng. Mọi route lọc theo user ở backend.
class FinanceApi {
  const FinanceApi(this._dio);

  final Dio _dio;

  /// Mọi tháng (kể cả đã kết thúc), mới nhất trước.
  Future<List<Project>> getFinanceProjects() async {
    final res = await _dio.get<List<dynamic>>('/api/finance/projects');
    return res.data!.map((e) => Project.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Bắt đầu tháng hiện tại (theo lịch VN ở backend). Gọi lại trong cùng tháng
  /// trả về đúng project đã có. Lần đầu dùng: backend tạo sẵn 7 danh mục.
  /// Đồng thời tự lưu trữ các tháng đã qua.
  Future<Project> startNewMonth() async {
    final res = await _dio.post<Map<String, dynamic>>('/api/finance/projects');
    return Project.fromJson(res.data!);
  }

  Future<FinanceSummary> getFinanceSummary(String projectId) async {
    final res = await _dio.get<Map<String, dynamic>>('/api/finance/summary', queryParameters: {'projectId': projectId});
    return FinanceSummary.fromJson(res.data!);
  }

  /// Chỉ ví chưa lưu trữ.
  Future<List<FinanceAccount>> getAccounts() async {
    final res = await _dio.get<List<dynamic>>('/api/finance/accounts');
    return res.data!.map((e) => FinanceAccount.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<FinanceAccount> createAccount({
    required String name,
    required AccountType type,
    double currentBalance = 0,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/finance/accounts',
      data: {'name': name, 'type': type.apiValue, 'currentBalance': currentBalance},
    );
    return FinanceAccount.fromJson(res.data!);
  }

  Future<List<FinanceCategory>> getCategories({MoneyKind? kind}) async {
    final res = await _dio.get<List<dynamic>>(
      '/api/finance/categories',
      queryParameters: {if (kind != null) 'kind': kind.apiValue},
    );
    return res.data!.map((e) => FinanceCategory.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<FinanceCategory> createCategory({required String name, String? icon, required MoneyKind kind}) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/finance/categories',
      data: {'name': name, 'icon': ?icon, 'kind': kind.apiValue},
    );
    return FinanceCategory.fromJson(res.data!);
  }

  Future<List<FinanceBudget>> getBudgets(String projectId) async {
    final res = await _dio.get<List<dynamic>>('/api/finance/budgets', queryParameters: {'projectId': projectId});
    return res.data!.map((e) => FinanceBudget.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Upsert theo (tháng, danh mục). 404 nếu tháng/danh mục không phải của
  /// user; 400 nếu tháng đã kết thúc.
  Future<FinanceBudget> setBudget({
    required String projectId,
    required String categoryId,
    required double limitAmount,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/finance/budgets',
      data: {'projectId': projectId, 'categoryId': categoryId, 'limitAmount': limitAmount},
    );
    return FinanceBudget.fromJson(res.data!);
  }

  /// Mới nhất trước, kèm tên danh mục/ví.
  Future<List<FinanceTransaction>> getTransactions(String projectId) async {
    final res = await _dio.get<List<dynamic>>('/api/finance/transactions', queryParameters: {'projectId': projectId});
    return res.data!.map((e) => FinanceTransaction.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Backend cộng/trừ số dư ví ngay trong cùng DB transaction. 404 nếu
  /// tháng/ví/danh mục không phải của user; 400 nếu tháng đã kết thúc.
  /// [occurredAt] null = lúc gọi (web chưa có ô chọn ngày).
  Future<FinanceTransaction> createTransaction({
    required String projectId,
    required String accountId,
    String? categoryId,
    required MoneyKind kind,
    required double amount,
    String? note,
    DateTime? occurredAt,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/finance/transactions',
      data: {
        'projectId': projectId,
        'accountId': accountId,
        'categoryId': ?categoryId,
        'kind': kind.apiValue,
        'amount': amount,
        'note': ?note,
        if (occurredAt != null) 'occurredAt': occurredAt.toUtc().toIso8601String(),
      },
    );
    return FinanceTransaction.fromJson(res.data!);
  }

  /// Hoàn lại số dư ví rồi xoá. 404 nếu không có/không phải của user.
  Future<void> deleteTransaction(String id) => _dio.delete<void>('/api/finance/transactions/$id');
}

final financeApiProvider = Provider<FinanceApi>((ref) => FinanceApi(ref.watch(apiClientProvider)));
