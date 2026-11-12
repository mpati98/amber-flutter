import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../shared/theme/design_tokens.dart';
import '../../../shared/widgets/app_toast.dart';
import '../../../shared/widgets/design_page.dart';
import '../../../shared/widgets/list_frame.dart';
import '../../../shared/widgets/overview_block.dart';
import '../models/alert.dart';
import '../models/feed_article.dart';
import '../models/feed_source.dart';
import '../providers/kieu_lau_provider.dart';
import '../providers/music_player_provider.dart';
import '../services/kieu_lau_api.dart';
import '../utils/activity_groups.dart';
import '../widgets/add_feed_source_dialog.dart';
import '../widgets/music_mini_player.dart';

/// Bộ lọc của khung: nhật ký theo nguồn, hoặc Tin tức (RSS).
enum KieuLauFilter { all, finance, learn, news }

const _filters = [
  (KieuLauFilter.all, 'Tất cả'),
  (KieuLauFilter.finance, 'Tài chính'),
  (KieuLauFilter.learn, 'Học tập'),
  (KieuLauFilter.news, 'Tin tức'),
];

/// Giá trị `source` thật của activity_logs (xem logActivity bên amber-v4) → chữ Hán + màn mở khi bấm (null = không mở gì).
const _sources = <String, (String, String?)>{
  'FINANCE': ('財', '/finance'),
  'TRA_DINH': ('學', '/tra-dinh'),
  'LEARN': ('訓', '/tang-kinh-cac/du-lieu-huan-luyen'), // nhật ký sửa đáp án amber-brain
  'DU_AN': ('案', '/du-an'),
  'MUSIC': ('樂', '/kieu-lau/nhac'),
  'KIEU_LAU': ('樓', null),
};

bool _matches(KieuLauFilter f, String source) => switch (f) {
  KieuLauFilter.all => true,
  KieuLauFilter.finance => source == 'FINANCE',
  KieuLauFilter.learn => source == 'TRA_DINH' || source == 'LEARN',
  KieuLauFilter.news => false,
};

/// /kieu-lau theo design/ref/kieu-lau.html: Tổng quan (Nhạc · Cần chú ý) → khung có chip lọc:
/// nhật ký gần đây đã gộp ([groupActivity]) hoặc Tin tức (bài RSS + quản lý nguồn). Trình phát mini cố định dưới đáy.
class KieuLauScreen extends ConsumerStatefulWidget {
  const KieuLauScreen({super.key});

  @override
  ConsumerState<KieuLauScreen> createState() => _KieuLauScreenState();
}

class _KieuLauScreenState extends ConsumerState<KieuLauScreen> {
  KieuLauFilter _filter = KieuLauFilter.all;

  @override
  Widget build(BuildContext context) {
    return DesignPage(
      title: 'Kiều Lâu',
      onRefresh: () async {
        ref.invalidate(notificationsProvider);
        if (_filter == KieuLauFilter.news) {
          ref.invalidate(feedSourcesProvider);
          ref.invalidate(feedArticlesProvider);
        }
        await ref.read(notificationsProvider.future).then<void>((_) {}, onError: (_) {});
      },
      overview: OverviewBlock(
        title: 'Tổng quan',
        labelWidth: 90,
        rows: [
          OverviewRow(
            key: const ValueKey('kl-music'),
            label: 'Nhạc',
            onTap: () => context.push('/kieu-lau/nhac'),
            child: const Text('Tải lên và phát bộ sưu tập MP3 riêng ›', style: DesignText.muted),
          ),
          const OverviewRow(label: 'Cần chú ý', child: _Alerts()),
        ],
      ),
      content: (context, _) => ListFrame(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            DesignChipRow<KieuLauFilter>(
              items: _filters,
              selected: _filter,
              onSelected: (f) => setState(() => _filter = f),
            ),
            if (_filter == KieuLauFilter.news) const _News() else _Activity(filter: _filter),
          ],
        ),
      ),
      hint: 'Chạm vào một mục để xem chi tiết',
      bottomBar: MusicMiniPlayer(controller: ref.watch(musicPlayerProvider)),
    );
  }
}

String _loadError(Object error) =>
    error is DioException ? 'Không tải được (${error.response?.statusCode ?? error.type.name}).' : 'Không tải được.';

/// Cảnh báo (task trễ hạn, vượt ngân sách, thiếu tháng tài chính…); bấm mở đúng màn qua `href`.
class _Alerts extends ConsumerWidget {
  const _Alerts();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(notificationsProvider).when(
      loading: () => const Text('Đang tải…', style: DesignText.muted),
      error: (e, _) => Text(_loadError(e), style: DesignText.muted),
      data: (n) => n.alerts.isEmpty
          ? const Text('Không có gì cần chú ý. Mọi thứ ổn.', style: TextStyle(color: DesignColors.success))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [for (final a in n.alerts) _AlertLine(a)],
            ),
    );
  }
}

class _AlertLine extends StatelessWidget {
  const _AlertLine(this.alert);

  final Alert alert;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: InkWell(
        key: ValueKey('kl-alert-${alert.id}'),
        // Route table khớp đường dẫn web nên dùng thẳng href; push để back về Kiều Lâu.
        onTap: () => context.push(alert.href),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(text: alert.title, style: const TextStyle(color: DesignColors.danger)),
              if (alert.detail case final d?) TextSpan(text: ' · $d', style: DesignText.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _Activity extends ConsumerWidget {
  const _Activity({required this.filter});

  final KieuLauFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(notificationsProvider).when(
      loading: () => const Text('Đang tải…', style: DesignText.muted),
      error: (e, _) => Text(_loadError(e), style: DesignText.muted),
      data: (n) {
        if (n.recentActivity.isEmpty) return const Text('Chưa có hoạt động nào.', style: DesignText.muted);
        final groups = groupActivity(n.recentActivity).where((g) => _matches(filter, g.source)).toList();
        if (groups.isEmpty) return const Text('Không có mục nào.', style: DesignText.muted);
        return FrameRows(
          children: [
            for (final (i, g) in groups.indexed)
              FrameRow(
                key: ValueKey('kl-activity-$i'),
                glyph: _sources[g.source]?.$1 ?? '•',
                glyphSize: 30,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                title: g.title,
                subtitle: g.repeat == null
                    ? g.subtitle
                    : Wrap(
                        spacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          DesignPill('×${g.repeat}', color: DesignColors.info),
                          Text(g.shortDate, style: DesignText.muted),
                        ],
                      ),
                onTap: switch (_sources[g.source]?.$2) {
                  final path? => () => context.push(path),
                  null => null,
                },
              ),
          ],
        );
      },
    );
  }
}

/// Tin tức: nguồn (xoá được) + "+ Nguồn" + Làm mới, rồi danh sách bài (bấm mở trình duyệt).
class _News extends ConsumerStatefulWidget {
  const _News();

  @override
  ConsumerState<_News> createState() => _NewsState();
}

class _NewsState extends ConsumerState<_News> {
  bool _refreshing = false;

  Future<void> _refresh() async {
    setState(() => _refreshing = true);
    try {
      final result = await ref.read(kieuLauApiProvider).refreshFeeds();
      if (!mounted) return;
      if (result.failed.isNotEmpty) {
        showToast(context, 'Không làm mới được: ${result.failed.join(', ')}', type: ToastType.warning);
      } else {
        showToast(context, 'Đã cập nhật ${result.refreshed} nguồn', type: ToastType.success);
      }
      ref.invalidate(feedArticlesProvider);
      ref.invalidate(notificationsProvider); // backend vừa ghi activity log
    } on DioException {
      if (mounted) showToast(context, 'Không làm mới được tin tức, thử lại nhé.', type: ToastType.error);
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  Future<void> _addSource() async {
    final created = await showAddFeedSourceDialog(context);
    if (created == null) return;
    ref.invalidate(feedSourcesProvider);
    ref.invalidate(notificationsProvider);
  }

  Future<void> _deleteSource(FeedSource source) async {
    try {
      await ref.read(kieuLauApiProvider).deleteFeedSource(source.id);
    } on DioException {
      if (mounted) showToast(context, 'Không xoá được nguồn "${source.name}".', type: ToastType.error);
    }
    ref.invalidate(feedSourcesProvider);
    ref.invalidate(feedArticlesProvider); // bài của nguồn bị xoá mất theo (cascade)
    ref.invalidate(notificationsProvider);
  }

  Future<void> _open(FeedArticle article) async {
    final ok = await launchUrl(Uri.parse(article.url), mode: LaunchMode.externalApplication);
    if (!ok && mounted) showToast(context, 'Không mở được liên kết.', type: ToastType.error);
  }

  @override
  Widget build(BuildContext context) {
    final sources = ref.watch(feedSourcesProvider);
    final hasSources = sources.value?.isNotEmpty ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        Row(
          spacing: 8,
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  spacing: 6,
                  children: [
                    for (final s in sources.value ?? const <FeedSource>[])
                      _SourceChip(source: s, onDelete: () => _deleteSource(s)),
                    _SmallButton(key: const ValueKey('kl-add-source'), label: '+ Nguồn', onTap: _addSource),
                  ],
                ),
              ),
            ),
            _SmallButton(
              key: const ValueKey('kl-refresh'),
              label: _refreshing ? 'Đang làm mới...' : 'Làm mới',
              onTap: _refreshing || !hasSources ? null : _refresh,
            ),
          ],
        ),
        if (sources.hasError) Text(_loadError(sources.error!), style: DesignText.muted),
        ref.watch(feedArticlesProvider).when(
          loading: () => const Text('Đang tải…', style: DesignText.muted),
          error: (e, _) => Text(_loadError(e), style: DesignText.muted),
          data: (articles) => articles.isEmpty
              ? const Text('Chưa có tin nào — thêm nguồn rồi bấm "Làm mới".', style: DesignText.muted)
              : FrameRows(
                  children: [
                    for (final a in articles)
                      FrameRow(
                        key: ValueKey('kl-article-${a.id}'),
                        glyph: '聞',
                        glyphSize: 30,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        title: a.title,
                        subtitle: [a.sourceName, if (a.publishedAt case final d?) _date(d)].join(' · '),
                        onTap: () => _open(a),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

/// d/M/yyyy theo giờ máy, như `toLocaleDateString("vi-VN")` bên web.
String _date(DateTime d) {
  final l = d.toLocal();
  return '${l.day}/${l.month}/${l.year}';
}

class _SourceChip extends StatelessWidget {
  const _SourceChip({required this.source, required this.onDelete});

  final FeedSource source;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey('kl-source-${source.id}'),
      padding: const EdgeInsets.only(left: 10, right: 2),
      decoration: const ShapeDecoration(
        color: DesignColors.panel,
        shape: StadiumBorder(side: BorderSide(color: DesignColors.panelBorder)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(source.name, style: const TextStyle(fontSize: 13, color: Color(0xFFCFD3EA))),
          IconButton(
            tooltip: 'Xoá nguồn ${source.name}',
            onPressed: onDelete,
            icon: const Icon(Icons.close, size: 14, color: DesignColors.muted),
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}

/// Nút chữ viền vàng nhỏ (như `.btn.o` của bản mẫu).
class _SmallButton extends StatelessWidget {
  const _SmallButton({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: DesignColors.gold,
        disabledForegroundColor: DesignColors.muted,
        side: BorderSide(color: onTap == null ? DesignColors.panelBorder : DesignColors.gold),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        minimumSize: const Size(0, 30),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        textStyle: DesignText.serif(fontSize: 13),
      ),
      child: Text(label),
    );
  }
}
