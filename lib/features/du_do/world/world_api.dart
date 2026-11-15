import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/services/api_client.dart';

/// Một sự kiện từ nhật ký hoạt động, đã gán công trình (backend: lib/world-stats.ts `activityEvent`).
class WorldActivity {
  const WorldActivity({required this.from, required this.lvl, required this.text});

  factory WorldActivity.fromJson(Map<String, dynamic> j) => WorldActivity(
    from: j['from'] as String? ?? 'center',
    lvl: j['lvl'] as String? ?? 'info',
    text: j['text'] as String? ?? '',
  );

  final String from;
  final String lvl;
  final String text;

  Map<String, Object?> toPush() => {'from': from, 'lvl': lvl, 'text': text};
}

/// GET /api/kieu-lau/world: 5 chỉ số (`{v: số | null, src}`) + sự kiện sau `since` + con trỏ mới.
/// `economy` (thêm 15/11/2026): Thể lực, Nguyên Tệ, nhật ký luật — chuyển nguyên khối cho `AmberWorld.setEconomy` (cảnh tự kiểm hình dạng).
/// null khi backend chưa có / không tính được. Ô `sinhLuc` giờ là Sức khoẻ của kinh tế.
class WorldSummary {
  const WorldSummary({required this.stats, required this.events, required this.cursor, this.economy});

  factory WorldSummary.fromJson(Map<String, dynamic> j) => WorldSummary(
    stats: {
      for (final e in ((j['stats'] as Map?) ?? const {}).entries)
        if (e.value is Map) e.key as String: Map<String, Object?>.from(e.value as Map),
    },
    events: [
      for (final e in (j['events'] as List?) ?? const [])
        if (e is Map) WorldActivity.fromJson(Map<String, dynamic>.from(e)),
    ],
    cursor: j['cursor'] as String?,
    economy: j['economy'] is Map ? Map<String, Object?>.from(j['economy'] as Map) : null,
  );

  final Map<String, Map<String, Object?>> stats;
  final Map<String, Object?>? economy;
  final List<WorldActivity> events;
  final String? cursor;
}

class WorldApi {
  WorldApi(this._dio);

  final Dio _dio;

  Future<WorldSummary> getSummary({String? since}) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/api/kieu-lau/world',
      queryParameters: {'since': ?since},
    );
    return WorldSummary.fromJson(res.data ?? const {});
  }

  /// Đúng dạng `AmberWorld.setWeather()`: code, temp, wind, sunrise, sunset (giờ thập phân), source.
  Future<Map<String, dynamic>> getWeather() async {
    final res = await _dio.get<Map<String, dynamic>>('/api/kieu-lau/weather');
    return res.data ?? const {};
  }
}

final worldApiProvider = Provider<WorldApi>((ref) => WorldApi(ref.watch(apiClientProvider)));
