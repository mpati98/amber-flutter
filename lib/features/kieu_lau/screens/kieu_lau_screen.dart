import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../shared/providers/auth_provider.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/scroll_card.dart';
import '../models/activity_log_entry.dart';
import '../models/alert.dart';
import '../models/feed_article.dart';
import '../models/feed_source.dart';
import '../providers/kieu_lau_provider.dart';
import '../services/kieu_lau_api.dart';
import '../widgets/add_feed_source_dialog.dart';

// Giá trị `source` thật của activity_logs (xem logActivity bên amber-v3).
const _sourceIcon = {
  'DU_AN': '📋',
  'FINANCE': '💰',
  'LEARN': '🎓',
  'TRA_DINH': '💬',
  'KIEU_LAU': '📰',
};

/// Giống `toLocaleDateString("vi-VN")` bên web: d/M/yyyy, giờ địa phương.
String _formatDate(DateTime d) {
  final local = d.toLocal();
  return '${local.day}/${local.month}/${local.year}';
}

/// Trung tâm thông báo & tin tức — port từ amber-v3/src/app/kieu-lau/page.tsx,
/// xếp dọc 3 khối thay cho lưới 3 cột bên web.
class KieuLauScreen extends ConsumerWidget {
  const KieuLauScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kiều Lâu'),
        actions: [
          // TODO: tạm để test luồng auth — chuyển sang màn Cài đặt khi có router.
          IconButton(
            tooltip: 'Đăng xuất',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).logout();
              if (!context.mounted) return;
              // Redirect cũng tự đưa về /login, nhưng kèm ?from=/kieu-lau — đăng
              // xuất chủ động thì không cần quay lại đây sau khi đăng nhập lại.
              context.go('/login');
            },
          ),
        ],
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 20,
          children: [_AlertsCard(), _ActivityCard(), _NewsCard()],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.kincha400),
    );
  }
}

class _Muted extends StatelessWidget {
  const _Muted(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.4)));
  }
}

Widget _loadError(Object error) => _Muted(
      error is DioException ? 'Không tải được (${error.response?.statusCode ?? error.type.name}).' : 'Không tải được.',
    );

class _AlertsCard extends ConsumerWidget {
  const _AlertsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScrollCard(
      glow: ScrollCardGlow.shuiro,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          const _SectionTitle('Cần chú ý'),
          ref.watch(notificationsProvider).when(
                loading: () => const _Muted('Đang tải...'),
                error: (e, _) => _loadError(e),
                data: (n) => n.alerts.isEmpty
                    ? const _Muted('Không có gì cần chú ý — mọi thứ ổn.')
                    : Column(children: [for (final a in n.alerts) _AlertTile(a)]),
              ),
        ],
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile(this.alert);

  final Alert alert;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(alert.title),
      subtitle: alert.detail == null ? null : Text(alert.detail!),
      // Route table khớp đường dẫn web nên dùng thẳng href (/du-an, /finance/<id>...).
      // push (không go) để back được về Kiều Lâu.
      onTap: () => context.push(alert.href),
    );
  }
}

class _ActivityCard extends ConsumerWidget {
  const _ActivityCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScrollCard(
      glow: ScrollCardGlow.yugen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          const _SectionTitle('Nhật ký gần đây'),
          ref.watch(notificationsProvider).when(
                loading: () => const _Muted('Đang tải...'),
                error: (e, _) => _loadError(e),
                data: (n) => n.recentActivity.isEmpty
                    ? const _Muted('Chưa có hoạt động nào.')
                    : Column(spacing: 8, children: [for (final r in n.recentActivity) _ActivityRow(r)]),
              ),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow(this.entry);

  final ActivityLogEntry entry;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text(_sourceIcon[entry.source] ?? '•'),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.8)),
              ),
              Text(
                _formatDate(entry.createdAt),
                style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.3)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NewsCard extends ConsumerStatefulWidget {
  const _NewsCard();

  @override
  ConsumerState<_NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends ConsumerState<_NewsCard> {
  bool _refreshing = false;

  void _showSnack(String message) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  Future<void> _refresh() async {
    setState(() => _refreshing = true);
    try {
      final result = await ref.read(kieuLauApiProvider).refreshFeeds();
      if (result.failed.isNotEmpty) _showSnack('Không làm mới được: ${result.failed.join(', ')}');
      ref.invalidate(feedArticlesProvider);
      ref.invalidate(notificationsProvider); // backend vừa ghi activity log
    } on DioException {
      _showSnack('Không làm mới được tin tức, thử lại nhé.');
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  Future<void> _addSource() async {
    final created = await showDialog<FeedSource>(context: context, builder: (_) => const AddFeedSourceDialog());
    if (created == null) return;
    ref.invalidate(feedSourcesProvider);
    ref.invalidate(notificationsProvider);
  }

  Future<void> _deleteSource(FeedSource source) async {
    try {
      await ref.read(kieuLauApiProvider).deleteFeedSource(source.id);
    } on DioException {
      _showSnack('Không xoá được nguồn "${source.name}".');
    }
    ref.invalidate(feedSourcesProvider);
    // Bài của nguồn bị xoá cũng mất theo (cascade).
    ref.invalidate(feedArticlesProvider);
    ref.invalidate(notificationsProvider);
  }

  Future<void> _openArticle(FeedArticle article) async {
    final ok = await launchUrl(Uri.parse(article.url), mode: LaunchMode.externalApplication);
    if (!ok) _showSnack('Không mở được liên kết.');
  }

  @override
  Widget build(BuildContext context) {
    final sources = ref.watch(feedSourcesProvider);
    final hasSources = sources.value?.isNotEmpty ?? false;

    return ScrollCard(
      glow: ScrollCardGlow.kincha,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Row(
            children: [
              const Expanded(child: _SectionTitle('Tin tức')),
              TextButton(
                onPressed: _refreshing || !hasSources ? null : _refresh,
                child: Text(_refreshing ? 'Đang làm mới...' : 'Làm mới'),
              ),
            ],
          ),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final s in sources.value ?? const <FeedSource>[])
                Chip(label: Text(s.name), onDeleted: () => _deleteSource(s)),
              ActionChip(label: const Text('+ Nguồn'), onPressed: _addSource),
            ],
          ),
          if (sources.hasError) _loadError(sources.error!),
          ref.watch(feedArticlesProvider).when(
                loading: () => const _Muted('Đang tải...'),
                error: (e, _) => _loadError(e),
                data: (articles) => articles.isEmpty
                    ? const _Muted('Chưa có tin nào — thêm nguồn rồi bấm "Làm mới".')
                    : ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 320),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: articles.length,
                          itemBuilder: (_, i) => _ArticleTile(articles[i], onTap: () => _openArticle(articles[i])),
                        ),
                      ),
              ),
        ],
      ),
    );
  }
}

class _ArticleTile extends StatelessWidget {
  const _ArticleTile(this.article, {required this.onTap});

  final FeedArticle article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final date = article.publishedAt == null ? '' : ' · ${_formatDate(article.publishedAt!)}';
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(article.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text('${article.sourceName}$date'),
      onTap: onTap,
    );
  }
}
