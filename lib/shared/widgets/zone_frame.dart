import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:material_ui/material_ui.dart';

import '../theme/design_tokens.dart';

/// Khung nội dung của bố cục "vừa một màn" ([ZoneScaffold]): viền + nền như khối Tổng quan, tiêu đề cố định,
/// nội dung cuộn BÊN TRONG khung (có Scrollbar). Đặt được cả chỗ cao cố định (Expanded) lẫn chỗ "cao vừa nội dung"
/// có giới hạn trên — khung co theo nội dung, vượt giới hạn thì cuộn.
///
/// [expandable] = true: nút mở rộng ở góc phải tiêu đề → modal toàn màn hình dựng lại [childBuilder] với `expanded = true`
/// (nút đóng + phím Esc). Trạng thái dùng chung giữa khung và modal (vd chip lọc) phải nằm ngoài khung —
/// ValueNotifier / provider — vì modal là route riêng, setState của màn không dựng lại nó.
class ZoneFrame extends StatelessWidget {
  const ZoneFrame({
    super.key,
    required this.title,
    required this.childBuilder,
    this.actions = const [],
    this.header,
    this.scrollable = true,
    this.expandable = false,
    this.onRefresh,
  });

  final String title;
  final Widget Function(BuildContext context, bool expanded) childBuilder;

  /// Nút nhỏ bên phải tiêu đề (trước nút mở rộng).
  final List<Widget> actions;

  /// Phần cố định giữa tiêu đề và vùng cuộn (vd hàng chip lọc). Hiện cả trong modal mở rộng.
  final Widget? header;

  /// false = nội dung đặt thẳng, không cuộn (nội dung ngắn, biết chắc vừa khung).
  final bool scrollable;
  final bool expandable;

  /// Kéo xuống trong vùng cuộn để tải lại (thay cho kéo-làm-mới cả trang của DesignPage).
  final Future<void> Function()? onRefresh;

  /// Lề đáy vùng cuộn khi không mở rộng: dòng cuối cuộn được lên khỏi nút chat nổi (52 + lề 12–20) ở góc phải dưới.
  /// Chỉ thấy khi đã cuộn tới cuối, nội dung ngắn thì không tốn chỗ.
  static const chatClearance = 56.0;

  Future<void> _openExpanded(BuildContext context) {
    return showGeneralDialog<void>(
      context: context,
      barrierLabel: title,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (dialogContext, _, _) => _ExpandedFrame(frame: this),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _FrameShell(
      frame: this,
      expanded: false,
      button: expandable
          ? IconButton(
              key: ValueKey('zone-expand-$title'),
              tooltip: 'Mở rộng',
              onPressed: () => _openExpanded(context),
              icon: const Icon(Icons.open_in_full, size: 16, color: DesignColors.muted),
              visualDensity: VisualDensity.compact,
            )
          : null,
    );
  }
}

/// Modal toàn màn hình của [ZoneFrame]: cùng khung, nút đóng thay nút mở rộng, Esc để đóng.
class _ExpandedFrame extends StatelessWidget {
  const _ExpandedFrame({required this.frame});

  final ZoneFrame frame;

  @override
  Widget build(BuildContext context) {
    void close() => Navigator.of(context).pop();
    return CallbackShortcuts(
      bindings: {const SingleActivator(LogicalKeyboardKey.escape): close},
      child: Focus(
        autofocus: true,
        child: Material(
          key: ValueKey('zone-expanded-${frame.title}'),
          color: DesignColors.bgTop,
          child: DesignBackground(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _FrameShell(
                  frame: frame,
                  expanded: true,
                  button: IconButton(
                    key: const ValueKey('zone-expanded-close'),
                    tooltip: 'Đóng (Esc)',
                    onPressed: close,
                    icon: const Icon(Icons.close, size: 18, color: DesignColors.muted),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Phần khung dùng chung cho khung thường và modal: tiêu đề + [ZoneFrame.header] + vùng nội dung.
class _FrameShell extends StatefulWidget {
  const _FrameShell({required this.frame, required this.expanded, required this.button});

  final ZoneFrame frame;
  final bool expanded;
  final Widget? button;

  @override
  State<_FrameShell> createState() => _FrameShellState();
}

class _FrameShellState extends State<_FrameShell> {
  // Controller riêng: nhiều khung cùng màn không được dùng chung PrimaryScrollController.
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.frame;
    final content = f.childBuilder(context, widget.expanded);
    Widget body = content;
    if (f.scrollable) {
      body = SingleChildScrollView(
        controller: _scroll,
        physics: f.onRefresh == null ? null : const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(right: 8, bottom: widget.expanded ? 0 : ZoneFrame.chatClearance),
        child: content,
      );
      if (f.onRefresh != null) body = RefreshIndicator(onRefresh: f.onRefresh!, color: DesignColors.gold, child: body);
      body = Scrollbar(controller: _scroll, child: body);
    }

    return Material(
      key: ValueKey('zone-frame-${f.title}'),
      color: DesignColors.panel,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: DesignColors.panelBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 4, 10),
        // min + Flexible lỏng: chỗ cao cố định thì khung vẫn lấp đầy (Material nhận ràng buộc chặt),
        // chỗ "vừa nội dung" thì khung co theo nội dung tới giới hạn trên rồi mới cuộn.
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 36),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      f.title.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, letterSpacing: 1, color: DesignColors.gold),
                    ),
                  ),
                  // Khung hẹp / chữ phóng to: cụm nút co nhỏ lại thay vì đẩy tràn hàng tiêu đề.
                  if (f.actions.isNotEmpty)
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Row(mainAxisSize: MainAxisSize.min, spacing: 4, children: f.actions),
                      ),
                    ),
                  ?widget.button,
                ],
              ),
            ),
            if (f.header case final h?) Padding(padding: const EdgeInsets.only(right: 8, bottom: 8), child: h),
            Flexible(child: body),
          ],
        ),
      ),
    );
  }
}
