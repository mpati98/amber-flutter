import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/app_theme.dart';
import '../providers/brain_chat_provider.dart';
import '../providers/brain_status_provider.dart';
import '../widgets/brain_cards.dart';
import '../../../shared/widgets/app_bar_back.dart';

/// Màn chat với amber-brain (trợ lý tài chính): hỏi số dư, ghi giao dịch có
/// xác nhận, hoàn tác. Lịch sử chỉ giữ trong state, không lưu.
class AmberBrainScreen extends ConsumerStatefulWidget {
  const AmberBrainScreen({super.key});

  @override
  ConsumerState<AmberBrainScreen> createState() => _AmberBrainScreenState();
}

class _AmberBrainScreenState extends ConsumerState<AmberBrainScreen> {
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
      if (chat.busy) const _TypingBubble(),
      for (var i = chat.entries.length - 1; i >= 0; i--)
        switch (chat.entries[i]) {
          TextEntry(:final text, :final isUser, :final isError) => _Bubble(
            text: text,
            isUser: isUser,
            isError: isError,
          ),
          final DraftEntry e => DraftCard(
            entry: e,
            enabled: canType,
            onConfirm: notifier.confirm,
            onCancel: notifier.cancel,
          ),
          final UndoEntry e => UndoCard(
            entry: e,
            enabled: canType,
            onConfirm: notifier.confirm,
            onCancel: notifier.cancel,
          ),
          final ResultEntry e => ResultCard(entry: e, onUndo: i == undoIndex && conn.canChat ? notifier.undo : null),
        },
    ];

    return Scaffold(
      appBar: AppBar(
        leading: const AppBarBack(),
        title: Row(
          spacing: 8,
          children: [
            const Text('Amber'),
            if (conn.status case final s?) _EnvChip(env: s.serverEnv),
          ],
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            children: [
              if (conn.offline)
                _Banner(
                  text: 'Amber is offline',
                  detail: kIsWeb
                      ? 'If the brain is running, the browser may be blocking local-network access — allow this page to access devices on your local network.'
                      : null,
                  color: AppColors.shuiro500,
                  onRetry: () => ref.read(brainStatusProvider.notifier).refresh(),
                ),
              if (conn.mismatch)
                _Banner(
                  text: 'Environment mismatch: Amber is connected to ${conn.status!.serverHost}, but the app is connected to ${conn.apiHost}.',
                  detail: 'Input is locked so nothing is written to the wrong data.',
                  color: AppColors.kincha400,
                ),
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Text('Ask for a balance, or record a transaction: "spent 45k on lunch with Momo"', style: muted(12)),
                      )
                    : ListView.separated(
                        reverse: true,
                        padding: const EdgeInsets.all(16),
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (_, i) => items[i],
                      ),
              ),
              _InputBar(controller: _input, enabled: canType, busy: chat.busy, offline: !conn.canChat, onSend: _send),
            ],
          ),
        ),
      ),
    );
  }
}

class _EnvChip extends StatelessWidget {
  const _EnvChip({required this.env});

  final String env;

  @override
  Widget build(BuildContext context) {
    final color = env == 'PROD' ? AppColors.shuiro500 : AppColors.kincha400;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.6)),
        borderRadius: BorderRadius.circular(AppTheme.darkRadius),
      ),
      child: Text(
        env,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.5),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.text, required this.color, this.detail, this.onRetry});

  final String text;
  final String? detail;
  final Color color;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(AppTheme.darkRadius),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  text,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color),
                ),
                if (detail != null) Text(detail!, style: muted(12)),
              ],
            ),
          ),
          if (onRetry != null) TextButton(onPressed: onRetry, child: const Text('Retry')),
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
    final tint = isError ? AppColors.shuiro500 : (isUser ? AppColors.kincha400 : Colors.white);
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: tint.withValues(alpha: isUser || isError ? 0.1 : 0.05),
          border: Border.all(color: tint.withValues(alpha: isUser || isError ? 0.3 : 0.1)),
          borderRadius: BorderRadius.circular(AppTheme.darkRadius),
        ),
        child: SelectableText(text, style: const TextStyle(fontSize: 13, height: 1.45)),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(AppTheme.darkRadius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2)),
            Text('Amber is replying...', style: muted(12)),
          ],
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.enabled,
    required this.busy,
    required this.offline,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool enabled;
  final bool busy;
  final bool offline;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            spacing: 8,
            children: [
              Expanded(
                child: ListenableBuilder(
                  listenable: controller,
                  builder: (_, _) => TextField(
                    key: const Key('brain-input'),
                    controller: controller,
                    enabled: enabled,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => onSend(),
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: offline ? "Amber isn't ready" : 'Type a message...',
                      isDense: true,
                    ),
                  ),
                ),
              ),
              ListenableBuilder(
                listenable: controller,
                builder: (_, _) => FilledButton(
                  onPressed: enabled && controller.text.trim().isNotEmpty ? onSend : null,
                  child: Text(busy ? '...' : 'Send'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
