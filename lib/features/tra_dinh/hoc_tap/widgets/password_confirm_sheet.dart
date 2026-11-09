import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';
import '../utils/hoc_tap_errors.dart';
import '../utils/password_error.dart';

/// Bottom sheet xác nhận bằng mật khẩu, dùng chung cho "Xoá khóa" và "Xoá hẳn". Trả true khi [onConfirm] thành công
/// (sheet tự đóng); false / null nếu huỷ. [onConfirm] ném lỗi (DioException) để sheet báo: 403 → lỗi dưới ô nhập + xoá ô;
/// 429 → thời gian chờ + vô hiệu nút; lỗi khác → thông báo chung, giữ sheet. Mật khẩu chỉ nằm trong ô nhập, không lưu, không ghi log.
Future<bool> showPasswordConfirmSheet(
  BuildContext context, {
  required String title,
  String? subtitle,
  List<String> bullets = const [],
  String? message,
  required String actionLabel,
  required Future<void> Function(String password) onConfirm,
}) async =>
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => PasswordConfirmSheet(
        title: title,
        subtitle: subtitle,
        bullets: bullets,
        message: message,
        actionLabel: actionLabel,
        onConfirm: onConfirm,
      ),
    ) ??
    false;

class PasswordConfirmSheet extends StatefulWidget {
  const PasswordConfirmSheet({
    super.key,
    required this.title,
    this.subtitle,
    this.bullets = const [],
    this.message,
    required this.actionLabel,
    required this.onConfirm,
  });

  final String title;
  final String? subtitle;
  final List<String> bullets;
  final String? message;
  final String actionLabel;
  final Future<void> Function(String password) onConfirm;

  @override
  State<PasswordConfirmSheet> createState() => _PasswordConfirmSheetState();
}

class _PasswordConfirmSheetState extends State<PasswordConfirmSheet> {
  final _password = TextEditingController();
  bool _busy = false;
  bool _locked = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _password.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  bool get _canSubmit => _password.text.isNotEmpty && !_busy && !_locked;

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.onConfirm(_password.text);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      final failure = classifyPasswordError(e);
      setState(() {
        _busy = false;
        switch (failure.kind) {
          case PasswordFailureKind.wrong:
            _error = 'Mật khẩu chưa đúng';
            _password.clear();
          case PasswordFailureKind.locked:
            _error = lockedMessage(failure.retryAfterSeconds ?? 0);
            _locked = true;
            _password.clear();
          case PasswordFailureKind.notFound:
          case PasswordFailureKind.other:
            _error = hocTapErrorMessage(e);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final buttonSize = const Size(0, 52);

    return PopScope(
      canPop: !_busy,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20,
            4,
            20,
            16 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.title,
                key: const ValueKey('pw-title'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (widget.subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  widget.subtitle!,
                  key: const ValueKey('pw-subtitle'),
                  style: TextStyle(fontSize: 14, color: theme.textMuted),
                ),
              ],
              if (widget.bullets.isNotEmpty) ...[
                const SizedBox(height: 12),
                for (final b in widget.bullets)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 7, right: 10),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: scheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const SizedBox(width: 6, height: 6),
                          ),
                        ),
                        Expanded(
                          child: Text(b, style: const TextStyle(fontSize: 14)),
                        ),
                      ],
                    ),
                  ),
              ],
              if (widget.message != null) ...[
                const SizedBox(height: 12),
                Text(
                  widget.message!,
                  key: const ValueKey('pw-message'),
                  style: const TextStyle(fontSize: 14),
                ),
              ],
              const SizedBox(height: 16),
              Text(
                'Nhập mật khẩu để xoá',
                style: TextStyle(fontSize: 13, color: theme.textMuted),
              ),
              const SizedBox(height: 6),
              TextField(
                key: const ValueKey('pw-field'),
                controller: _password,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                enabled: !_busy,
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  hintText: 'Mật khẩu',
                  constraints: const BoxConstraints(minHeight: 48),
                  errorText: _error,
                  errorMaxLines: 3,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                spacing: 12,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      key: const ValueKey('pw-cancel'),
                      style: OutlinedButton.styleFrom(minimumSize: buttonSize),
                      onPressed: _busy
                          ? null
                          : () => Navigator.of(context).pop(false),
                      child: const Text('Huỷ'),
                    ),
                  ),
                  Expanded(
                    child: FilledButton(
                      key: const ValueKey('pw-submit'),
                      style: FilledButton.styleFrom(
                        minimumSize: buttonSize,
                        backgroundColor: scheme.error,
                        foregroundColor: scheme.onError,
                        disabledBackgroundColor: scheme.error.withValues(
                          alpha: 0.35,
                        ),
                      ),
                      onPressed: _canSubmit ? _submit : null,
                      child: _busy
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(widget.actionLabel),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
