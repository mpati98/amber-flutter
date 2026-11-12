import 'package:material_ui/material_ui.dart';

import '../theme/design_tokens.dart';

/// Khối tổng quan của bố cục mới: nền panel, viền, bo 10; tiêu đề vàng in hoa + các dòng [OverviewRow] kẻ ngang giữa.
class OverviewBlock extends StatelessWidget {
  const OverviewBlock({super.key, required this.title, required this.rows, this.labelWidth = 70, this.footer});

  final String title;
  final List<Widget> rows;

  /// Bề rộng cột nhãn của mọi [OverviewRow] bên trong: Home 70, các tòa 90 (nhãn dài hơn: "Kế hoạch đọc").
  final double labelWidth;

  /// Phần dưới các dòng, không kẻ ngang (vd hộp cảnh báo "Thiếu N ngày" của Trà Đình).
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: DesignColors.panel,
        border: Border.all(color: DesignColors.panelBorder),
        borderRadius: BorderRadius.circular(10),
      ),
      child: _LabelWidth(
        width: labelWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                title.toUpperCase(),
                style: const TextStyle(fontSize: 13, letterSpacing: 1, color: DesignColors.gold),
              ),
            ),
            for (final (i, row) in rows.indexed)
              DecoratedBox(
                decoration: BoxDecoration(
                  border: i == 0 ? null : const Border(top: BorderSide(color: DesignColors.rowDivider)),
                ),
                child: row,
              ),
            if (footer != null) Padding(padding: const EdgeInsets.only(top: 8), child: footer),
          ],
        ),
      ),
    );
  }
}

class _LabelWidth extends InheritedWidget {
  const _LabelWidth({required this.width, required super.child});

  final double width;

  @override
  bool updateShouldNotify(_LabelWidth old) => old.width != width;
}

/// Một dòng: nhãn đậm rộng 70 + nội dung tự xuống dòng.
class OverviewRow extends StatelessWidget {
  const OverviewRow({super.key, required this.label, required this.child, this.onTap});

  /// Dòng chỉ có chữ phụ (vd "Đang tải…").
  OverviewRow.muted({super.key, required this.label, required String text, this.onTap})
    : child = Text(text, style: DesignText.muted);

  final String label;
  final Widget child;

  /// Bấm cả dòng (vd dòng Nhạc của Kiều Lâu mở thư viện nhạc).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          SizedBox(
            width: context.dependOnInheritedWidgetOfExactType<_LabelWidth>()?.width ?? 70,
            child: Text(label, style: DesignText.bold),
          ),
          Expanded(child: child),
        ],
      ),
    );
    final tap = onTap;
    if (tap == null) return row;
    return Semantics(
      button: true,
      child: InkWell(onTap: tap, child: row),
    );
  }
}
