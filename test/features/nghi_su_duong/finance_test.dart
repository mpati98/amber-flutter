import 'package:amber_flutter/features/nghi_su_duong/models/finance_account.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/finance_budget.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/finance_category.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/finance_summary.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/finance_transaction.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/project.dart';
import 'package:amber_flutter/features/nghi_su_duong/utils/finance_month.dart';
import 'package:flutter_test/flutter_test.dart';

Project _month(String start) => Project(id: start, name: start, type: ProjectType.finance, startDate: start);

void main() {
  group('Nút "Bắt đầu tháng mới" — tháng hiện tại theo lịch VN', () {
    final sep = [_month('2026-09-01')];

    test('21:14 VN 30/9: đã có tháng 9 → ẩn nút', () {
      expect(hasCurrentFinanceMonth(sep, DateTime.utc(2026, 9, 30, 14, 14)), isTrue);
    });

    test('00:30 VN 1/10 (UTC vẫn 30/9): chưa có tháng 10 → hiện nút', () {
      expect(hasCurrentFinanceMonth(sep, DateTime.utc(2026, 9, 30, 17, 30)), isFalse);
    });

    test('đã có tháng 10 → ẩn, dù còn tháng cũ trong danh sách', () {
      expect(hasCurrentFinanceMonth([_month('2026-10-01'), ...sep], DateTime.utc(2026, 10, 5)), isTrue);
    });

    test('chưa có tháng nào → hiện nút', () {
      expect(hasCurrentFinanceMonth(const [], DateTime.utc(2026, 9, 30)), isFalse);
    });

    test('không nhầm cùng tháng khác năm', () {
      expect(hasCurrentFinanceMonth([_month('2025-09-01')], DateTime.utc(2026, 9, 10)), isFalse);
    });
  });

  // JSON thật từ API (curl 2026-09-30).
  group('parse response thật', () {
    test('ví: currentBalance là chuỗi "118792.00"', () {
      final a = FinanceAccount.fromJson({
        'id': '034d', 'userId': 'u', 'name': 'Momo', 'type': 'E_WALLET',
        'currentBalance': '118792.00', 'archivedAt': null, 'createdAt': '2026-09-12T02:27:01.049Z',
      });
      expect(a.type, AccountType.eWallet);
      expect(a.currentBalance, 118792);
    });

    test('giao dịch kèm category/account (số dư lồng dạng "2940000", không có .00)', () {
      final t = FinanceTransaction.fromJson({
        'id': '604e', 'userId': 'u', 'projectId': '3103', 'accountId': 'de4f', 'categoryId': 'cfba',
        'kind': 'EXPENSE', 'amount': '40000.00', 'note': 'Coffee',
        'occurredAt': '2026-09-12T02:29:15.176Z', 'createdAt': '2026-09-12T02:29:15.042Z',
        'category': {'id': 'cfba', 'userId': 'u', 'name': 'Ăn uống', 'icon': '🍜', 'kind': 'EXPENSE'},
        'account': {'id': 'de4f', 'userId': 'u', 'name': 'Cash', 'type': 'CASH', 'currentBalance': '2940000'},
      });
      expect(t.kind, MoneyKind.expense);
      expect(t.amount, 40000);
      expect(t.categoryName, 'Ăn uống');
      expect(t.accountName, 'Cash');
      expect(t.occurredAt.isUtc, isTrue);
    });

    test('summary: số do server tính là number', () {
      final s = FinanceSummary.fromJson({
        'project': {
          'id': '3103', 'name': 'Tài chính — Tháng 9/2026',
          'startDate': '2026-09-01', 'endDate': '2026-09-30', 'archivedAt': null,
        },
        'totalBalance': 3058792, 'totalIncome': 0, 'totalExpense': 60000, 'netThisMonth': -60000,
        'budgetProgress': [
          {'categoryId': 'c', 'categoryName': 'Ăn uống', 'icon': '🍜', 'limitAmount': 50000, 'spent': 60000},
        ],
      });
      expect(s.netThisMonth, -60000);
      expect(s.budgetProgress.single.isOver, isTrue);
      expect(s.budgetProgress.single.percent, 100);
    });

    test('budget GET kèm category; POST không có category → tên null', () {
      final withCat = FinanceBudget.fromJson({
        'id': 'b', 'userId': 'u', 'projectId': 'p', 'categoryId': 'c', 'limitAmount': '500000.00',
        'category': {'id': 'c', 'name': 'Ăn uống', 'icon': '🍜', 'kind': 'EXPENSE'},
      });
      expect(withCat.limitAmount, 500000);
      expect(withCat.categoryName, 'Ăn uống');
      final posted = FinanceBudget.fromJson(
          {'id': 'b', 'userId': 'u', 'projectId': 'p', 'categoryId': 'c', 'limitAmount': '500000'});
      expect(posted.categoryName, isNull);
    });

    test('danh mục', () {
      final c = FinanceCategory.fromJson({'id': 'x', 'userId': 'u', 'name': 'Lương', 'icon': '💰', 'kind': 'INCOME'});
      expect(c.kind, MoneyKind.income);
    });
  });
}
