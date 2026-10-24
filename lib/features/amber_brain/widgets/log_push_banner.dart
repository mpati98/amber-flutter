import 'package:flutter/material.dart';

import '../models/brain_models.dart';

/// Shared warning for log delivery problems on screens that expose brain status.
class LogPushBanner extends StatelessWidget {
  const LogPushBanner({
    super.key,
    required this.status,
    this.vietnamese = false,
  });

  final LogPushStatus? status;
  final bool vietnamese;

  @override
  Widget build(BuildContext context) {
    if (status == null || !status!.shouldWarn) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final message = switch (status!.lastError) {
      'auth' =>
        vietnamese
            ? 'Vui lòng đăng nhập lại để đồng bộ nhật ký.'
            : 'Please sign in again to sync logs.',
      'network' || 'server' || 'unknown' =>
        vietnamese
            ? 'Chưa gửi được nhật ký, hệ thống sẽ thử lại.'
            : 'Log sync failed. It will be retried.',
      _ =>
        vietnamese
            ? 'Còn ${status!.pending} dòng nhật ký đang chờ gửi.'
            : '${status!.pending} log entries are waiting to sync.',
    };

    return Container(
      key: const Key('log-push-banner'),
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.45),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.sync_problem_outlined, color: colorScheme.error, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: colorScheme.error,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
