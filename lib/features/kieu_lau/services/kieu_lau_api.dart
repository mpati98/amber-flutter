import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/services/api_client.dart';
import '../models/activity_log_entry.dart';
import '../models/alert.dart';
import '../models/feed_article.dart';
import '../models/feed_source.dart';

typedef KieuLauNotifications = ({List<Alert> alerts, List<ActivityLogEntry> recentActivity});

/// `failed` là tên các nguồn không parse được RSS.
typedef FeedRefreshResult = ({int refreshed, List<String> failed});

class KieuLauApi {
  const KieuLauApi(this._dio);

  final Dio _dio;

  Future<KieuLauNotifications> getNotifications() async {
    final res = await _dio.get<Map<String, dynamic>>('/api/kieu-lau/notifications');
    final data = res.data!;
    return (
      alerts: _parseList(data['alerts'], Alert.fromJson),
      recentActivity: _parseList(data['recentActivity'], ActivityLogEntry.fromJson),
    );
  }

  Future<List<FeedArticle>> getFeedArticles() async {
    final res = await _dio.get<List<dynamic>>('/api/kieu-lau/feed-articles');
    return _parseList(res.data, FeedArticle.fromJson);
  }

  Future<List<FeedSource>> getFeedSources() async {
    final res = await _dio.get<List<dynamic>>('/api/kieu-lau/feed-sources');
    return _parseList(res.data, FeedSource.fromJson);
  }

  /// 400 nếu tên rỗng hoặc URL không hợp lệ.
  Future<FeedSource> addFeedSource(String name, String url) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/kieu-lau/feed-sources',
      data: {'name': name, 'url': url},
    );
    return FeedSource.fromJson(res.data!);
  }

  /// Xoá nguồn kéo theo xoá cache bài viết của nguồn đó (cascade ở DB).
  Future<void> deleteFeedSource(String id) => _dio.delete<void>('/api/kieu-lau/feed-sources/$id');

  Future<FeedRefreshResult> refreshFeeds() async {
    final res = await _dio.post<Map<String, dynamic>>('/api/kieu-lau/feeds/refresh');
    final data = res.data!;
    return (refreshed: data['refreshed'] as int, failed: (data['failed'] as List<dynamic>).cast<String>());
  }

  static List<T> _parseList<T>(Object? json, T Function(Map<String, dynamic>) fromJson) =>
      (json as List<dynamic>).map((e) => fromJson(e as Map<String, dynamic>)).toList();
}

final kieuLauApiProvider = Provider<KieuLauApi>((ref) => KieuLauApi(ref.watch(apiClientProvider)));
