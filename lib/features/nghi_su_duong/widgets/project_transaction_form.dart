import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/utils/api_error.dart';
import '../../../shared/utils/date_format.dart';
import '../../../shared/utils/vn_time.dart';
import '../../../shared/widgets/form_bits.dart';
import '../models/finance_account.dart';
import '../models/finance_category.dart';
import '../models/finance_transaction.dart';
import '../providers/finance_provider.dart';
import '../services/finance_api.dart';

/// Form giao dịch gắn với dự án [projectId]: thêm ([tx] null) hoặc sửa [tx]. Mở bằng showFinanceSheet.
Future<void> showProjectTransactionForm(BuildContext context, {required String projectId, FinanceTransaction? tx}) =>
    showFinanceSheet<void>(context, ProjectTransactionForm(projectId: projectId, tx: tx));

const _monthMissingMessage = 'Tháng này chưa mở sổ tài chính.';
const _monthLockedMessage = 'Tháng này đã khoá sổ.';

String _iso(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

String _full(String iso) => '${formatDayMonth(iso)}/${iso.substring(0, 4)}';

/// Thời điểm gửi lên server cho ngày [day] ("YYYY-MM-DD", lịch VN): hôm nay → lúc này; ngày khác →
/// 12:00 giờ VN của ngày đó (= 05:00 UTC).
DateTime occurredAtFor(String day, {DateTime? now}) {
  final at = now ?? DateTime.now();
  if (day == vnToday(at)) return at;
  final d = DateTime.parse('${day}T00:00:00Z');
  return DateTime.utc(d.year, d.month, d.day, 5);
}

class ProjectTransactionForm extends ConsumerStatefulWidget {
  const ProjectTransactionForm({super.key, required this.projectId, this.tx});

  final String projectId;
  final FinanceTransaction? tx;

  @override
  ConsumerState<ProjectTransactionForm> createState() => _ProjectTransactionFormState();
}

class _ProjectTransactionFormState extends ConsumerState<ProjectTransactionForm> {
  late final _amount = TextEditingController(text: widget.tx == null ? '' : widget.tx!.amount.round().toString());
  late final _note = TextEditingController(text: widget.tx?.note ?? '');
  late MoneyKind _kind = widget.tx?.kind ?? MoneyKind.expense;
  late String? _accountId = widget.tx?.accountId;
  late String? _categoryId = widget.tx?.categoryId;
  late String _day = widget.tx == null ? vnToday() : vnToday(widget.tx!.occurredAt);
  bool _defaultsApplied = false;
  bool _busy = false;
  String? _error;

  bool get _editing => widget.tx != null;

  @override
  void initState() {
    super.initState();
    _amount.addListener(() => setState(() {}));
    _note.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  List<FinanceCategory> _ofKind(List<FinanceCategory>? all, MoneyKind kind) => all?.where((c) => c.kind == kind).toList() ?? const [];

  int get _amountValue => int.tryParse(_amount.text) ?? 0;

  /// Đổi loại thì bỏ chọn danh mục nếu danh mục đang chọn khác loại.
  void _selectKind(MoneyKind kind, List<FinanceCategory>? all) {
    setState(() {
      _kind = kind;
      final current = all?.where((c) => c.id == _categoryId).firstOrNull;
      if (current != null && current.kind != kind) _categoryId = null;
    });
  }

  /// Khi sửa: chỉ các trường khác bản gốc.
  Map<String, Object?> get _patch {
    final t = widget.tx!;
    final note = _note.text.trim();
    return {
      if (_amountValue > 0 && _amountValue.toDouble() != t.amount) 'amount': _amountValue,
      if (_kind != t.kind) 'kind': _kind.apiValue,
      if (_accountId != t.accountId) 'accountId': _accountId,
      if (_categoryId != t.categoryId) 'categoryId': _categoryId,
      if (note != (t.note ?? '').trim()) 'note': note.isEmpty ? null : note,
    };
  }

  bool get _canSave => !_busy && _accountId != null && _amountValue > 0 && (!_editing || _patch.isNotEmpty);

  Future<void> _pickDate() async {
    final today = vnToday();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(_day),
      // Từ ngày 1 của tháng hiện tại tới hôm nay (giờ VN).
      firstDate: DateTime.parse('${today.substring(0, 8)}01'),
      lastDate: DateTime.parse(today),
      helpText: 'Ngày giao dịch',
    );
    if (picked != null) setState(() => _day = _iso(picked));
  }

  String _errorFor(Object e) {
    if (e is DioException) {
      switch (e.response?.data) {
        case {'error': 'finance_month_not_found'}:
          return _monthMissingMessage;
        case {'error': 'project_archived'}:
          return _monthLockedMessage;
      }
    }
    return apiErrorMessage(e, 'Không lưu được giao dịch, thử lại nhé.');
  }

  Future<void> _save() async {
    if (_busy) return;
    setState(() {
      _busy = true; // khoá ngay: bấm Lưu hai lần chỉ gửi một lần
      _error = null;
    });
    final api = ref.read(financeApiProvider);
    try {
      if (_editing) {
        await api.updateTransaction(widget.tx!.id, _patch);
      } else {
        final note = _note.text.trim();
        await api.createTransaction(
          // Không gửi projectId (tháng): server tự chọn theo occurredAt.
          linkedProjectId: widget.projectId,
          accountId: _accountId!,
          categoryId: _categoryId,
          kind: _kind,
          amount: _amountValue.toDouble(),
          note: note.isEmpty ? null : note,
          occurredAt: occurredAtFor(_day),
        );
      }
      refreshProjectFinance(ref.invalidate, widget.projectId);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = _errorFor(e);
        });
      }
    }
  }

  Future<void> _unlink() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bỏ gắn khỏi dự án?'),
        content: const Text('Giao dịch vẫn nằm trong sổ thu-chi của tháng, chỉ không còn tính vào dự án này.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Huỷ')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Bỏ gắn')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(financeApiProvider).updateTransaction(widget.tx!.id, {'linkedProjectId': null});
      refreshProjectFinance(ref.invalidate, widget.projectId);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = _errorFor(e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final muted = TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.6));
    final accountsAsync = ref.watch(financeAccountsProvider);
    final categoriesAsync = ref.watch(financeCategoriesProvider);
    final accounts = accountsAsync.value?.where((a) => a.archivedAt == null).toList();
    final allCategories = categoriesAsync.value;

    // Thêm mới: mặc định ví đầu tiên khi dữ liệu vừa có.
    if (!_defaultsApplied && accounts != null) {
      _defaultsApplied = true;
      _accountId ??= accounts.firstOrNull?.id;
    }
    final categories = _ofKind(allCategories, _kind);
    // Ví của giao dịch đang sửa có thể đã lưu trữ → vẫn cho hiện để dropdown hợp lệ.
    final accountItems = <FinanceAccount>[
      ...?accounts,
      if (_editing && accounts != null && !accounts.any((a) => a.id == widget.tx!.accountId))
        FinanceAccount(id: widget.tx!.accountId, name: widget.tx!.accountName ?? 'Ví đã lưu trữ', type: AccountType.unknown, currentBalance: 0),
    ];

    return FinanceSheetBody(
      title: _editing ? 'Sửa giao dịch' : 'Thêm giao dịch',
      children: [
        ChoiceRow<MoneyKind>(
          options: const {MoneyKind.expense: 'Chi', MoneyKind.income: 'Thu'},
          selected: _kind == MoneyKind.unknown ? MoneyKind.expense : _kind,
          onSelected: (k) => _selectKind(k, allCategories),
        ),
        MoneyField(controller: _amount, hint: 'Số tiền (VND)'),
        if (accounts == null || allCategories == null)
          Text(accountsAsync.hasError || categoriesAsync.hasError ? 'Không tải được ví và danh mục.' : 'Đang tải ví và danh mục...', style: muted)
        else ...[
          DropdownButtonFormField<String>(
            initialValue: accountItems.any((a) => a.id == _accountId) ? _accountId : null,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Ví'),
            items: [for (final a in accountItems) DropdownMenuItem(value: a.id, child: Text(a.name, overflow: TextOverflow.ellipsis))],
            onChanged: (v) => setState(() => _accountId = v),
          ),
          // key theo loại: đổi Thu/Chi thì dựng lại dropdown với danh sách và giá trị mới.
          DropdownButtonFormField<String?>(
            key: ValueKey(_kind),
            initialValue: categories.any((c) => c.id == _categoryId) ? _categoryId : null,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Danh mục'),
            items: [
              const DropdownMenuItem<String?>(value: null, child: Text('Chưa phân loại')),
              for (final c in categories)
                DropdownMenuItem<String?>(
                  value: c.id,
                  child: Text('${c.icon != null ? '${c.icon} ' : ''}${c.name}', overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: (v) => setState(() => _categoryId = v),
          ),
        ],
        if (_editing) ...[
          Text('Ngày: ${_full(_day)}', style: TextStyle(fontSize: 14, color: cs.onSurface)),
          Text('Muốn đổi ngày thì xoá giao dịch rồi thêm lại.', style: muted),
        ] else
          OutlinedButton(
            onPressed: _pickDate,
            child: Align(alignment: Alignment.centerLeft, child: Text('Ngày: ${_full(_day)}')),
          ),
        TextField(
          controller: _note,
          decoration: const InputDecoration(labelText: 'Ghi chú (tuỳ chọn)'),
        ),
        if (accounts != null && accounts.isEmpty) Text('Chưa có ví nào — tạo ví trước đã.', style: muted),
        sheetError(context, _error),
        FilledButton(
          onPressed: _canSave ? _save : null,
          child: Text(_busy ? 'Đang lưu...' : 'Lưu'),
        ),
        if (_editing)
          OutlinedButton(
            onPressed: _busy ? null : _unlink,
            child: const Text('Bỏ gắn khỏi dự án'),
          ),
      ],
    );
  }
}
