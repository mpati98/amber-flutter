import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/theme/design_tokens.dart';
import '../../../shared/widgets/amber_logo.dart';
import '../providers/brain_chat_provider.dart';
import '../providers/brain_status_provider.dart';
import 'brain_cards.dart';
import 'log_push_banner.dart';

/// Bọc thân một màn: nút tròn góc phải dưới bật/tắt khung chat gọn với amber-brain.
///
/// Màn rộng (≥ 600): khung 360 × tối đa 520, nổi phía trên nút. Điện thoại: khung trải ngang (lề 8), cao tối đa 70% màn.
/// Dock luôn theo dõi [brainChatProvider] nên đóng/mở khung không mất lịch sử (lịch sử sống tới khi rời màn).
class AmberChatDock extends ConsumerStatefulWidget {
  const AmberChatDock({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AmberChatDock> createState() => _AmberChatDockState();
}

class _AmberChatDockState extends ConsumerState<AmberChatDock> {
  bool _open = false;

  void _toggle() => setState(() => _open = !_open);

  @override
  Widget build(BuildContext context) {
    final conn = ref.watch(brainStatusProvider);
    ref.watch(brainChatProvider.select((s) => s.busy)); // giữ lịch sử khi khung đóng

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= DesignLayout.medium;
        final edge = wide ? 20.0 : 12.0;
        const button = 52.0;
        final panelBottom = edge + button + 12;
        final maxHeight = (constraints.maxHeight - panelBottom - 12).clamp(0.0, double.infinity);
        final height = (wide ? 520.0 : MediaQuery.sizeOf(context).height * 0.7).clamp(0.0, maxHeight);

        return Stack(
          children: [
            Positioned.fill(child: widget.child),
            Positioned(
              right: wide ? edge : 8,
              left: wide ? null : 8,
              bottom: panelBottom,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 160),
                transitionBuilder: (child, a) => FadeTransition(
                  opacity: a,
                  child: ScaleTransition(scale: Tween(begin: 0.96, end: 1.0).animate(a), alignment: Alignment.bottomRight, child: child),
                ),
                child: _open
                    ? SizedBox(
                        key: const ValueKey('amber-chat-panel'),
                        width: wide ? 360 : null,
                        height: height,
                        child: AmberChatPanel(onClose: _toggle),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
            Positioned(
              right: edge,
              bottom: edge,
              child: _ToggleButton(open: _open, dot: _brainColor(conn), onTap: _toggle),
            ),
          ],
        );
      },
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({required this.open, required this.dot, required this.onTap});

  final bool open;
  final Color dot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: open ? 'Đóng chat Amber' : 'Trò chuyện với Amber',
      child: Material(
        color: DesignColors.panel,
        shape: const CircleBorder(side: BorderSide(color: DesignColors.gold)),
        elevation: 6,
        child: InkWell(
          key: const ValueKey('amber-chat-toggle'),
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox.square(
            dimension: 52,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(open ? Icons.close : Icons.chat_bubble_outline, color: DesignColors.gold, size: 22),
                if (!open)
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Container(
                      key: const Key('amber-status-dot'),
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: dot,
                        shape: BoxShape.circle,
                        border: Border.all(color: DesignColors.panel, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Khung chat gọn: đầu (logo, Amber, môi trường, trạng thái, đóng) · cảnh báo một dòng · tin nhắn · ô nhập.
class AmberChatPanel extends ConsumerStatefulWidget {
  const AmberChatPanel({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  ConsumerState<AmberChatPanel> createState() => _AmberChatPanelState();
}

class _AmberChatPanelState extends ConsumerState<AmberChatPanel> {
  final _input = TextEditingController();

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _send() {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    _input.clear();
    ref.read(brainChatProvider.notifier).send(text);
  }

  @override
  Widget build(BuildContext context) {
    final conn = ref.watch(brainStatusProvider);
    final chat = ref.watch(brainChatProvider);
    final notifier = ref.read(brainChatProvider.notifier);
    final canType = conn.canChat && !chat.busy;
    final undoIndex = chat.undoableResultIndex;

    final items = <Widget>[
      if (chat.busy) const _Typing(),
      for (var i = chat.entries.length - 1; i >= 0; i--)
        switch (chat.entries[i]) {
          TextEntry(:final text, :final isUser, :final isError) => _Bubble(text: text, isUser: isUser, isError: isError),
          final DraftEntry e => DraftCard(entry: e, enabled: canType, onConfirm: notifier.confirm, onCancel: notifier.cancel),
          final UndoEntry e => UndoCard(entry: e, enabled: canType, onConfirm: notifier.confirm, onCancel: notifier.cancel),
          final ResultEntry e => ResultCard(entry: e, onUndo: i == undoIndex && conn.canChat ? notifier.undo : null),
        },
    ];

    final logPush = conn.shouldWarnLogPush ? logPushMessage(conn.status?.logPush) : null;
    final warning = conn.offline
        ? ('Amber is offline', AppColors.shuiro500)
        : conn.mismatch
            ? (
                'Environment mismatch: Amber is on ${conn.status!.serverHost}, the app is on ${conn.apiHost}. Input is locked.',
                AppColors.kincha400,
              )
            : null;

    return CallbackShortcuts(
      bindings: {const SingleActivator(LogicalKeyboardKey.escape): widget.onClose},
      child: Material(
        color: DesignColors.panel,
        elevation: 12,
        shadowColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: DesignColors.frameBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: DefaultTextStyle.merge(
          style: DesignText.body,
          child: Column(
            children: [
              _Header(conn: conn, onClose: widget.onClose),
              if (warning != null)
                Container(
                  key: const ValueKey('amber-chat-warning'),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  color: warning.$2.withValues(alpha: 0.12),
                  child: Row(
                    spacing: 8,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(warning.$1, style: TextStyle(fontSize: 12, color: warning.$2)),
                            if (conn.offline && kIsWeb)
                              const Text(
                                'If the brain is running, allow this page to access devices on your local network.',
                                style: TextStyle(fontSize: 11, color: DesignColors.muted),
                              ),
                          ],
                        ),
                      ),
                      if (conn.offline)
                        InkWell(
                          onTap: () => ref.read(brainStatusProvider.notifier).refresh(),
                          child: const Text('Retry', style: TextStyle(fontSize: 12, color: DesignColors.gold)),
                        ),
                    ],
                  ),
                ),
              if (logPush != null)
                Container(
                  key: const Key('log-push-banner'),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  color: DesignColors.danger.withValues(alpha: 0.1),
                  child: Row(
                    spacing: 6,
                    children: [
                      const Icon(Icons.sync_problem_outlined, size: 14, color: DesignColors.danger),
                      Expanded(child: Text(logPush, style: const TextStyle(fontSize: 12, color: DesignColors.danger))),
                    ],
                  ),
                ),
              Expanded(
                child: ColoredBox(
                  color: DesignColors.frame,
                  child: items.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text(
                              'Ask for a balance, or record a transaction:\n"spent 45k on lunch with Momo"',
                              textAlign: TextAlign.center,
                              style: DesignText.muted,
                            ),
                          ),
                        )
                      : ListView.separated(
                          reverse: true,
                          padding: const EdgeInsets.all(12),
                          itemCount: items.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (_, i) => items[i],
                        ),
                ),
              ),
              _Input(controller: _input, enabled: canType, offline: !conn.canChat, onSend: _send),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.conn, required this.onClose});

  final BrainConnection conn;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final env = conn.status?.serverEnv;
    return Container(
      height: 48,
      padding: const EdgeInsets.only(left: 12, right: 4),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: DesignColors.topBarBorder))),
      child: Row(
        spacing: 8,
        children: [
          const AmberLogo(size: 26),
          Flexible(
            child: Text(
              'Amber',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: DesignText.serif(fontSize: 15, fontWeight: FontWeight.w700, color: DesignColors.text),
            ),
          ),
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: _brainColor(conn), shape: BoxShape.circle),
          ),
          if (env != null)
            Container(
              key: const ValueKey('amber-chat-env'),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                border: Border.all(color: (env == 'PROD' ? AppColors.shuiro500 : AppColors.kincha400).withValues(alpha: 0.6)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                env,
                style: TextStyle(fontSize: 10, letterSpacing: 0.5, color: env == 'PROD' ? AppColors.shuiro500 : AppColors.kincha400),
              ),
            ),
          const Spacer(),
          IconButton(
            key: const ValueKey('amber-chat-close'),
            tooltip: 'Đóng',
            onPressed: onClose,
            icon: const Icon(Icons.close, size: 18, color: DesignColors.muted),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.text, required this.isUser, this.isError = false});

  final String text;
  final bool isUser;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final (bg, border) = isError
        ? (DesignColors.danger.withValues(alpha: 0.1), DesignColors.danger.withValues(alpha: 0.4))
        : isUser
            ? (DesignColors.gold.withValues(alpha: 0.12), DesignColors.gold.withValues(alpha: 0.35))
            : (DesignColors.panel, DesignColors.panelBorder);
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: 0.85,
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: bg,
              border: Border.all(color: border),
              borderRadius: BorderRadius.circular(10),
            ),
            child: SelectableText(text, style: DesignText.body.copyWith(fontSize: 13.5)),
          ),
        ),
      ),
    );
  }
}

class _Typing extends StatelessWidget {
  const _Typing();

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          SizedBox.square(dimension: 12, child: CircularProgressIndicator(strokeWidth: 2, color: DesignColors.gold)),
          Text('Amber is replying...', style: DesignText.muted),
        ],
      ),
    );
  }
}

class _Input extends StatelessWidget {
  const _Input({required this.controller, required this.enabled, required this.offline, required this.onSend});

  final TextEditingController controller;
  final bool enabled;
  final bool offline;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: DesignColors.panelBorder),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 6, 8),
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) => Row(
          spacing: 4,
          children: [
            Expanded(
              child: TextField(
                key: const Key('brain-input'),
                controller: controller,
                enabled: enabled,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                cursorColor: DesignColors.gold,
                style: DesignText.body.copyWith(fontSize: 13.5),
                decoration: InputDecoration(
                  hintText: offline ? "Amber isn't ready" : 'Type a message...',
                  hintStyle: DesignText.body.copyWith(fontSize: 13.5, color: DesignColors.muted),
                  isDense: true,
                  filled: true,
                  fillColor: DesignColors.frame,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                  border: border,
                  enabledBorder: border,
                  disabledBorder: border,
                  focusedBorder: border.copyWith(borderSide: const BorderSide(color: DesignColors.gold)),
                ),
              ),
            ),
            IconButton(
              key: const ValueKey('amber-chat-send'),
              tooltip: 'Send',
              onPressed: enabled && controller.text.trim().isNotEmpty ? onSend : null,
              icon: const Icon(Icons.arrow_upward, size: 20),
              color: DesignColors.gold,
              disabledColor: DesignColors.muted.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }
}

Color _brainColor(BrainConnection c) => switch (c) {
  BrainConnection(offline: true) => AppColors.shuiro500,
  BrainConnection(mismatch: true) => AppColors.kincha400,
  BrainConnection(online: true) => AppColors.emerald400,
  _ => Colors.grey,
};
