import 'package:material_ui/material_ui.dart';

import '../theme/design_tokens.dart';
import 'design_page.dart';
import 'list_frame.dart';

/// Một khung của màn [ZoneScaffold]: [id] để [ZoneScaffold.wide] tham chiếu, [label] là tên tab trên điện thoại.
class ZonePane {
  const ZonePane({required this.id, required this.label, required this.child});

  final String id;
  final String label;

  /// Thường là một ZoneFrame.
  final Widget child;
}

/// Bố cục lưới cho màn rộng (≥ 1024): cây hàng / cột chia theo flex, lá là một [ZoneCell].
sealed class ZoneLayout {
  const ZoneLayout(this.flex);

  final int flex;
}

final class ZoneRow extends ZoneLayout {
  const ZoneRow(this.children, {int flex = 1}) : super(flex);

  final List<ZoneLayout> children;
}

final class ZoneColumn extends ZoneLayout {
  const ZoneColumn(this.children, {int flex = 1}) : super(flex);

  final List<ZoneLayout> children;
}

final class ZoneCell extends ZoneLayout {
  /// Chiếm phần theo [flex].
  const ZoneCell(this.id, {int flex = 1}) : maxFraction = null, super(flex);

  /// Cao vừa nội dung (trong [ZoneColumn]), tối đa [maxFraction] chiều cao cột — vượt thì khung cuộn bên trong.
  /// Trong [ZoneRow] thì rộng đúng [maxFraction] bề ngang hàng.
  const ZoneCell.fit(this.id, {double this.maxFraction = 0.5}) : super(0);

  final String id;
  final double? maxFraction;
}

/// Khung màn "vừa một màn hình": thanh trên cố định (← + tiêu đề + [actions] + menu tài khoản), thân lấp phần còn lại,
/// KHÔNG cuộn cấp trang, không giới hạn bề ngang (lề ngoài [padding]). Nội dung dài cuộn trong từng khung.
///
/// Responsive theo bề ngang thân màn:
/// - ≥ 1024: lưới [wide] do màn tự khai báo.
/// - 600–1023: 2 cột, nửa đầu [panes] bên trái, phần còn lại bên phải; khung trong một cột chia đều chiều cao.
/// - < 600: mỗi khung một tab (hàng chip ở trên), tab đang chọn lấp hết chiều cao còn lại.
class ZoneScaffold extends StatefulWidget {
  const ZoneScaffold({
    super.key,
    required this.title,
    required this.panes,
    required this.wide,
    this.backFallback = '/',
    this.actions = const [],
    this.bottomBar,
    this.toolbar,
    this.compact,
    this.medium,
  });

  final String title;
  final String? backFallback;
  final List<Widget> actions;
  final List<ZonePane> panes;
  final ZoneLayout wide;

  /// Thanh cố định dưới đáy (vd trình phát nhạc mini).
  final Widget? bottomBar;

  /// Hàng cố định ngay trên lưới, mọi cỡ màn (vd chọn tầng của Tàng Kinh Các).
  final Widget? toolbar;

  /// 600–1023: lưới riêng thay cho 2 cột chia đều (vd giữ đúng tỉ lệ của [wide]).
  final ZoneLayout? medium;

  /// < 600: bố cục riêng thay cho tab (vd chỉ Danh sách; chạm một mục mới mở nội dung).
  final WidgetBuilder? compact;

  static const padding = 16.0;
  static const gap = 16.0;

  @override
  State<ZoneScaffold> createState() => _ZoneScaffoldState();
}

class _ZoneScaffoldState extends State<ZoneScaffold> {
  String? _tab;

  Widget _pane(String id) {
    final pane = widget.panes.where((p) => p.id == id).firstOrNull;
    assert(pane != null, 'ZoneScaffold.wide tham chiếu khung "$id" không có trong panes');
    return pane?.child ?? const SizedBox.shrink();
  }

  Widget _flex(Axis axis, List<ZoneLayout> children) {
    return LayoutBuilder(
      builder: (context, c) {
        final extent = axis == Axis.vertical ? c.maxHeight : c.maxWidth;
        final avail = extent - ZoneScaffold.gap * (children.length - 1);
        return Flex(
          direction: axis,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: ZoneScaffold.gap,
          children: [
            for (final node in children)
              if (node case ZoneCell(maxFraction: final f?))
                axis == Axis.vertical
                    ? ConstrainedBox(constraints: BoxConstraints(maxHeight: avail * f), child: _pane(node.id))
                    : SizedBox(width: avail * f, child: _pane(node.id))
              else
                Expanded(flex: node.flex, child: _node(node)),
          ],
        );
      },
    );
  }

  Widget _node(ZoneLayout node) => switch (node) {
    ZoneRow(:final children) => _flex(Axis.horizontal, children),
    ZoneColumn(:final children) => _flex(Axis.vertical, children),
    ZoneCell(:final id) => _pane(id),
  };

  Widget _medium() {
    final panes = widget.panes;
    final split = (panes.length / 2).ceil();
    Widget column(Iterable<ZonePane> ps) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: ZoneScaffold.gap,
      children: [for (final p in ps) Expanded(child: p.child)],
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: ZoneScaffold.gap,
      children: [
        Expanded(child: column(panes.take(split))),
        if (panes.length > split) Expanded(child: column(panes.skip(split))),
      ],
    );
  }

  Widget _compact() {
    final panes = widget.panes;
    final current = panes.where((p) => p.id == _tab).firstOrNull ?? panes.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        DesignChipRow<String>(
          items: [for (final p in panes) (p.id, p.label)],
          selected: current.id,
          onSelected: (id) => setState(() => _tab = id),
          keyOf: (id) => ValueKey('zone-tab-$id'),
        ),
        Expanded(child: KeyedSubtree(key: ValueKey('zone-pane-${current.id}'), child: current.child)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DesignScaffold(
      title: widget.title,
      backFallback: widget.backFallback,
      actions: widget.actions,
      fullWidth: true,
      bottomNavigationBar: widget.bottomBar,
      body: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;
          final compact = widget.compact;
          Widget body = w >= DesignLayout.wide
              ? _node(widget.wide)
              : (w >= DesignLayout.medium ? (widget.medium == null ? _medium() : _node(widget.medium!)) : (compact != null ? compact(context) : _compact()));
          if (widget.toolbar case final t?) {
            body = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [t, Expanded(child: body)],
            );
          }
          return Padding(padding: const EdgeInsets.all(ZoneScaffold.padding), child: body);
        },
      ),
    );
  }
}
