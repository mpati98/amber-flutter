import 'package:material_ui/material_ui.dart';

import '../../../shared/theme/design_tokens.dart';
import '../../../shared/utils/currency.dart';
import '../providers/brain_chat_provider.dart';

// Thẻ giao dịch trong khung chat Amber, theo bộ thiết kế mới (Gelasio, màu DesignColors).
// Nhãn trên thẻ giữ tiếng Việt; câu chat của Amber là tiếng Anh.

const _gold = Color(0xFFE8C987); // nền nút chính, cùng nút Đăng nhập

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
    return Opacity(
      opacity: done ? 0.55 : 1,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        decoration: BoxDecoration(
          color: DesignColors.panel,
          border: Border.all(color: DesignColors.gold.withValues(alpha: 0.45)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(title, style: DesignText.serif(fontSize: 13.5, fontWeight: FontWeight.w700, color: DesignColors.gold)),
            ),
            for (final (i, (k, v)) in rows.indexed)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  border: i == 0 ? null : const Border(top: BorderSide(color: DesignColors.rowDivider)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    SizedBox(width: 72, child: Text(k, style: DesignText.serif(fontSize: 12.5, color: DesignColors.muted))),
                    Expanded(child: Text(v, style: DesignText.serif(fontSize: 13.5, color: DesignColors.text))),
                  ],
                ),
              ),
            if (statusText != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(statusText, style: DesignText.serif(fontSize: 12.5, color: DesignColors.muted)),
              ),
            if (!done && actions != null) actions!,
          ],
        ),
      ),
    );
  }
}

/// Nút chính (vàng) + nút Hủy (viền); xuống dòng khi khung hẹp / chữ phóng to.
class _Buttons extends StatelessWidget {
  const _Buttons({required this.confirmLabel, required this.onConfirm, required this.onCancel, required this.enabled});

  final String confirmLabel;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final bool enabled;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 10),
    child: Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilledButton(onPressed: enabled ? onConfirm : null, style: _primary, child: Text(confirmLabel)),
        OutlinedButton(onPressed: enabled ? onCancel : null, style: _secondary, child: const Text('Hủy')),
      ],
    ),
  );
}

final _shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(6));
const _pad = EdgeInsets.symmetric(horizontal: 14, vertical: 8);

final _primary = FilledButton.styleFrom(
  backgroundColor: _gold,
  foregroundColor: const Color(0xFF1A1A1A),
  disabledBackgroundColor: _gold.withValues(alpha: 0.4),
  disabledForegroundColor: const Color(0xFF1A1A1A),
  padding: _pad,
  minimumSize: Size.zero,
  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  shape: _shape,
  textStyle: DesignText.serif(fontSize: 13.5),
);

final _secondary = OutlinedButton.styleFrom(
  foregroundColor: DesignColors.text,
  disabledForegroundColor: DesignColors.muted,
  side: const BorderSide(color: DesignColors.panelBorder),
  padding: _pad,
  minimumSize: Size.zero,
  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  shape: _shape,
  textStyle: DesignText.serif(fontSize: 13.5),
);

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

/// Kết quả ghi/xóa kèm số dư mới (tông xanh thành công); nút Hoàn tác khi [onUndo] khác null.
class ResultCard extends StatelessWidget {
  const ResultCard({super.key, required this.entry, this.onUndo});

  final ResultEntry entry;
  final VoidCallback? onUndo;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DesignColors.success.withValues(alpha: 0.08),
        border: Border.all(color: DesignColors.success.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Icon(entry.recorded ? Icons.check_circle_outline : Icons.delete_outline, size: 18, color: DesignColors.success),
              Expanded(child: Text(entry.text, style: DesignText.serif(fontSize: 13.5, height: 1.45, color: DesignColors.text))),
            ],
          ),
          if (onUndo != null) OutlinedButton(onPressed: onUndo, style: _secondary, child: const Text('Hoàn tác')),
        ],
      ),
    );
  }
}
