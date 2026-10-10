import 'package:flutter/material.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/currency.dart';
import '../providers/brain_chat_provider.dart';

TextStyle muted(double size) => TextStyle(fontSize: size, color: Colors.white.withValues(alpha: 0.4));

class _CardShell extends StatelessWidget {
  const _CardShell({required this.title, required this.rows, required this.status, this.actions});

  final String title;
  final List<(String, String)> rows;
  final CardStatus status;
  final Widget? actions;

  @override
  Widget build(BuildContext context) {
    final done = status != CardStatus.open;
    final statusText = switch (status) {
      CardStatus.open => null,
      CardStatus.confirmed => 'Đã xác nhận',
      CardStatus.cancelled => 'Đã hủy',
      CardStatus.expired => 'Đã bỏ qua',
    };
    return Align(
      alignment: Alignment.centerLeft,
      child: Opacity(
        opacity: done ? 0.55 : 1,
        child: Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.9),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.kincha400.withValues(alpha: 0.06),
            border: Border.all(color: AppColors.kincha400.withValues(alpha: 0.35)),
            borderRadius: BorderRadius.circular(AppTheme.darkRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            spacing: 6,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.kincha400),
              ),
              for (final (k, v) in rows)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 84, child: Text(k, style: muted(12))),
                    Expanded(child: Text(v, style: const TextStyle(fontSize: 13))),
                  ],
                ),
              if (statusText != null) Text(statusText, style: muted(12)),
              if (!done && actions != null) actions!,
            ],
          ),
        ),
      ),
    );
  }
}

class _Buttons extends StatelessWidget {
  const _Buttons({required this.confirmLabel, required this.onConfirm, required this.onCancel, required this.enabled});

  final String confirmLabel;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final bool enabled;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 4),
    child: Row(
      spacing: 8,
      children: [
        FilledButton(onPressed: enabled ? onConfirm : null, child: Text(confirmLabel)),
        OutlinedButton(onPressed: enabled ? onCancel : null, child: const Text('Hủy')),
      ],
    ),
  );
}

/// Thẻ xác nhận ghi giao dịch, vẽ từ `draft` của brain.
class DraftCard extends StatelessWidget {
  const DraftCard({
    super.key,
    required this.entry,
    required this.enabled,
    required this.onConfirm,
    required this.onCancel,
  });

  final DraftEntry entry;
  final bool enabled;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final d = entry.draft;
    return _CardShell(
      title: 'Xác nhận ghi giao dịch',
      status: entry.status,
      rows: [
        ('Loại', d.isIncome ? 'Thu nhập' : 'Chi tiêu'),
        ('Số tiền', formatVnd(d.amount)),
        ('Ví', d.accountName),
        ('Danh mục', d.categoryName ?? '—'),
        ('Ngày', dateLabelVi(d.date, d.dateLabel)),
        ('Ghi chú', (d.note == null || d.note!.isEmpty) ? '—' : d.note!),
      ],
      actions: _Buttons(confirmLabel: 'Xác nhận', onConfirm: onConfirm, onCancel: onCancel, enabled: enabled),
    );
  }
}

/// Thẻ xác nhận xóa (hoàn tác), vẽ từ `undoTarget`.
class UndoCard extends StatelessWidget {
  const UndoCard({
    super.key,
    required this.entry,
    required this.enabled,
    required this.onConfirm,
    required this.onCancel,
  });

  final UndoEntry entry;
  final bool enabled;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final t = entry.target;
    return _CardShell(
      title: 'Hoàn tác giao dịch này?',
      status: entry.status,
      rows: [
        ('Loại', t.isIncome ? 'Thu nhập' : 'Chi tiêu'),
        ('Số tiền', formatVnd(t.amount)),
        ('Ví', t.accountName),
        ('Ngày', dateLabelVi(t.date, null)),
      ],
      actions: _Buttons(confirmLabel: 'Xóa giao dịch', onConfirm: onConfirm, onCancel: onCancel, enabled: enabled),
    );
  }
}

/// Kết quả ghi/xóa kèm số dư mới; nút Hoàn tác khi [onUndo] khác null.
class ResultCard extends StatelessWidget {
  const ResultCard({super.key, required this.entry, this.onUndo});

  final ResultEntry entry;
  final VoidCallback? onUndo;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.9),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).success.withValues(alpha: 0.08),
          border: Border.all(color: Theme.of(context).success.withValues(alpha: 0.35)),
          borderRadius: BorderRadius.circular(AppTheme.darkRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: [
            Text(entry.text, style: const TextStyle(fontSize: 13, height: 1.45)),
            if (onUndo != null) OutlinedButton(onPressed: onUndo, child: const Text('Hoàn tác')),
          ],
        ),
      ),
    );
  }
}
