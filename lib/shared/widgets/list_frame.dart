import 'package:material_ui/material_ui.dart';

import '../theme/design_tokens.dart';

/// Khung nội dung của bố cục mới (thanh trên → tổng quan → một khung): viền, bo 12, nền tối hơn panel.
class ListFrame extends StatelessWidget {
  const ListFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Material (không phải Container tô nền): ListTile / InkWell bên trong vẽ hiệu ứng bấm lên Material gần nhất.
    return Material(
      color: DesignColors.frame,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: DesignColors.frameBorder),
      ),
      child: Padding(padding: const EdgeInsets.all(12), child: SizedBox(width: double.infinity, child: child)),
    );
  }
}

/// Ô bấm trong khung: nền panel, viền, bo 8; hover/nhấn đổi nền + viền vàng.
class FrameTile extends StatefulWidget {
  const FrameTile({
    super.key,
    required this.child,
    required this.onTap,
    this.semanticLabel,
    this.padding = const EdgeInsets.all(12),
    this.borderColor,
  });

  final Widget child;

  /// null = ô chỉ để xem (không hover, không phải nút).
  final VoidCallback? onTap;

  /// Viền khi không hover (vd đỏ sẫm cho tài chính âm); null = viền panel.
  final Color? borderColor;
  final String? semanticLabel;
  final EdgeInsetsGeometry padding;

  @override
  State<FrameTile> createState() => _FrameTileState();
}

class _FrameTileState extends State<FrameTile> {
  bool _hot = false;

  void _set(bool v) {
    if (_hot != v) setState(() => _hot = v);
  }

  @override
  Widget build(BuildContext context) {
    final box = Container(
      padding: widget.padding,
      decoration: BoxDecoration(
        color: _hot ? DesignColors.panelHover : DesignColors.panel,
        border: Border.all(color: _hot ? DesignColors.gold : (widget.borderColor ?? DesignColors.panelBorder)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: widget.child,
    );
    final onTap = widget.onTap;
    if (onTap == null) return box;
    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => _set(true),
        onExit: (_) => _set(false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          onTapDown: (_) => _set(true),
          onTapUp: (_) => _set(false),
          onTapCancel: () => _set(false),
          child: box,
        ),
      ),
    );
  }
}

/// Vòng tròn viền vàng chứa một chữ Hán (biểu tượng tòa / mục).
class GlyphCircle extends StatelessWidget {
  const GlyphCircle(this.glyph, {super.key, this.size = 34});

  final String glyph;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: DesignColors.gold)),
      child: Text(glyph, style: TextStyle(fontSize: size / 2, height: 1, color: DesignColors.gold)),
    );
  }
}

/// Một dòng trong khung danh sách: [leading] tuỳ chọn (vd "Tầng 1") · vòng chữ Hán · tên + [subtitle] (+ [below]) · [trailing].
/// Các dòng cách nhau 8 — đặt trong [FrameRows].
class FrameRow extends StatelessWidget {
  const FrameRow({
    super.key,
    required this.glyph,
    required this.title,
    this.subtitle,
    this.below,
    this.leading,
    this.trailing,
    this.onTap,
    this.borderColor,
    this.glyphSize = 34,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  });

  final String glyph;
  final String title;

  /// Chuỗi → chữ phụ; widget → dùng nguyên.
  final Object? subtitle;
  final Widget? below;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? borderColor;
  final double glyphSize;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final sub = subtitle;
    return FrameTile(
      onTap: onTap,
      semanticLabel: title,
      borderColor: borderColor,
      padding: padding,
      child: Row(
        spacing: 12,
        children: [
          ?leading,
          GlyphCircle(glyph, size: glyphSize),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: DesignText.bold),
                if (sub is String) Text(sub, style: DesignText.muted) else if (sub is Widget) sub,
                ?below,
              ],
            ),
          ),
          // Co được (chữ phóng to / màn hẹp) để không đẩy tràn hàng.
          if (trailing != null) Flexible(child: trailing!),
        ],
      ),
    );
  }
}

/// Cột các [FrameRow] cách nhau 8.
class FrameRows extends StatelessWidget {
  const FrameRows({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 8, children: children);
}

/// Nhãn nhỏ có viền bo tròn (vd "Âm quỹ", "Chờ", "×4").
class DesignPill extends StatelessWidget {
  const DesignPill(this.text, {super.key, this.color = DesignColors.gold});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(border: Border.all(color: color), borderRadius: BorderRadius.circular(10)),
      child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: color)),
    );
  }
}

/// Thanh tiến độ mảnh (cao 6, nền tối, phần đã xong xanh lam). [value] 0–100.
class DesignProgressBar extends StatelessWidget {
  const DesignProgressBar(this.value, {super.key});

  static const fill = Color(0xFF7AA2FF);

  final num value;

  @override
  Widget build(BuildContext context) {
    final f = (value / 100).clamp(0, 1).toDouble();
    return Container(
      height: 6,
      margin: const EdgeInsets.only(top: 6),
      decoration: BoxDecoration(color: DesignColors.rowDivider, borderRadius: BorderRadius.circular(3)),
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: f,
        child: Container(decoration: BoxDecoration(color: fill, borderRadius: BorderRadius.circular(3))),
      ),
    );
  }
}

/// Hàng chip lọc trong khung: cuộn NGANG, không xuống dòng (quy ước của app — Wrap vỡ bố cục trên iPhone cũ).
/// Chip đang chọn nền vàng chữ tối; còn lại nền panel viền mảnh.
class DesignChipRow<T> extends StatelessWidget {
  const DesignChipRow({super.key, required this.items, required this.selected, required this.onSelected, this.keyOf});

  final List<(T, String)> items;
  final T selected;
  final ValueChanged<T> onSelected;

  /// Key riêng cho từng chip (mặc định `chip-<nhãn>`).
  final Key Function(T value)? keyOf;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: 6,
        children: [
          for (final (value, label) in items)
            _Chip(
              chipKey: keyOf?.call(value) ?? ValueKey('chip-$label'),
              label: label,
              on: value == selected,
              onTap: () => onSelected(value),
            ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.chipKey, required this.label, required this.on, required this.onTap});

  final Key chipKey;
  final String label;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: on,
      child: Material(
        key: chipKey,
        color: on ? DesignColors.gold : DesignColors.panel,
        shape: StadiumBorder(side: BorderSide(color: on ? DesignColors.gold : DesignColors.panelBorder)),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: on ? const Color(0xFF1A1A1A) : const Color(0xFFCFD3EA)),
            ),
          ),
        ),
      ),
    );
  }
}

/// Nút theo bản mẫu: [DesignButton.primary] = `.btn` (vàng, chữ tối), [DesignButton.outline] = `.btn.o` (viền vàng).
/// Cao tối thiểu 32 (đặt [minHeight] 44 cho nút đứng riêng cần vùng chạm lớn).
class DesignButton extends StatelessWidget {
  const DesignButton.primary({super.key, required this.label, required this.onPressed, this.minHeight = 32}) : primary = true;
  const DesignButton.outline({super.key, required this.label, required this.onPressed, this.minHeight = 32}) : primary = false;

  final String label;
  final VoidCallback? onPressed;
  final bool primary;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(6));
    const pad = EdgeInsets.symmetric(horizontal: 12, vertical: 6);
    final text = DesignText.serif(fontSize: 13);
    final child = Text(label, textAlign: TextAlign.center);
    if (primary) {
      return FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: DesignColors.gold,
          foregroundColor: const Color(0xFF1A1A1A),
          disabledBackgroundColor: DesignColors.gold.withValues(alpha: 0.4),
          padding: pad,
          minimumSize: Size(0, minHeight),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: shape,
          textStyle: text,
        ),
        child: child,
      );
    }
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: DesignColors.gold,
        disabledForegroundColor: DesignColors.muted,
        side: BorderSide(color: onPressed == null ? DesignColors.panelBorder : DesignColors.gold),
        padding: pad,
        minimumSize: Size(0, minHeight),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: shape,
        textStyle: text,
      ),
      child: child,
    );
  }
}

/// Đầu khung: hàng chip lọc (co giãn, cuộn ngang) + nút hành động bên phải (vd "+ Thêm sách").
class FrameToolbar extends StatelessWidget {
  const FrameToolbar({super.key, required this.chips, this.action});

  final Widget chips;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final a = action;
    if (a == null) return chips;
    // Khung hẹp (điện thoại nhỏ, chữ phóng to): nút xuống dòng dưới chip, căn phải — không chèn ép hàng chip.
    return LayoutBuilder(
      builder: (context, c) => c.maxWidth < 420
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 8,
              children: [chips, Align(alignment: Alignment.centerRight, child: a)],
            )
          : Row(spacing: 8, children: [Expanded(child: chips), a]),
    );
  }
}

/// Ô nhập trong khung theo bộ thiết kế mới: nền tối, viền panel, viền vàng khi đang gõ, chữ gợi ý màu phụ.
InputDecoration designInput(String hint) {
  OutlineInputBorder border(Color c) =>
      OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: c));
  return InputDecoration(
    hintText: hint,
    hintStyle: DesignText.serif(fontSize: 14, color: DesignColors.muted),
    isDense: true,
    filled: true,
    fillColor: DesignColors.panel,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    border: border(DesignColors.panelBorder),
    enabledBorder: border(DesignColors.panelBorder),
    focusedBorder: border(DesignColors.gold),
  );
}
