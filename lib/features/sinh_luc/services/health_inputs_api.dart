import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/services/api_client.dart';
import '../models/health_inputs.dart';

/// Đầu vào Sức khoẻ của kinh tế (amber-v4): `/api/du-an/check-ins` (trưa / tối) và `/api/du-an/debuffs`.
/// Lưu xong backend tự dựng lại sổ cái; không có gì phải gọi thêm.
class HealthInputsApi {
  HealthInputsApi(this._dio);

  final Dio _dio;

  Future<CheckInHistory> checkIns({int days = 14}) async {
    final res = await _dio.get<Map<String, dynamic>>('/api/du-an/check-ins', queryParameters: {'days': days});
    return CheckInHistory.fromJson(res.data ?? const {});
  }

  Future<CheckIn> saveNoon({required String date, required int staminaSelf}) =>
      _put({'date': date, 'slot': 'noon', 'staminaSelf': staminaSelf});

  Future<CheckIn> saveEvening({required String date, int? exerciseMinutes, int? sportMinutes, required bool restDay}) =>
      _put({'date': date, 'slot': 'evening', 'exerciseMinutes': exerciseMinutes, 'sportMinutes': sportMinutes, 'restDay': restDay});

  Future<CheckIn> _put(Map<String, Object?> body) async {
    final res = await _dio.put<Map<String, dynamic>>('/api/du-an/check-ins', data: body);
    return CheckIn.fromJson(Map<String, dynamic>.from(res.data?['checkIn'] as Map? ?? const {}));
  }

  Future<void> deleteCheckIn(String date, String slot) => _dio.delete<void>('/api/du-an/check-ins/$date/$slot');

  Future<List<Debuff>> debuffs({int days = 30}) async {
    final res = await _dio.get<Map<String, dynamic>>('/api/du-an/debuffs', queryParameters: {'days': days});
    return [
      for (final e in (res.data?['debuffs'] as List?) ?? const [])
        if (e is Map) Debuff.fromJson(Map<String, dynamic>.from(e)),
    ];
  }

  /// `startedAt` null = bây giờ (server tự lấy giờ của nó).
  Future<Debuff> createDebuff({required String level, String? label, String? startedAt}) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/du-an/debuffs',
      data: {'level': level, 'label': _trimOrNull(label), 'startedAt': ?startedAt},
    );
    return Debuff.fromJson(Map<String, dynamic>.from(res.data?['debuff'] as Map? ?? const {}));
  }

  /// Chỉ gửi trường có giá trị; `ended` true = khỏi từ bây giờ, false = mở lại, null = không đổi.
  Future<Debuff> updateDebuff(String id, {String? level, String? label, bool? ended}) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      '/api/du-an/debuffs/$id',
      data: {
        'level': ?level,
        if (label != null) 'label': _trimOrNull(label),
        if (ended != null) 'endedAt': ended ? DateTime.now().toUtc().toIso8601String() : null,
      },
    );
    return Debuff.fromJson(Map<String, dynamic>.from(res.data?['debuff'] as Map? ?? const {}));
  }

  Future<void> deleteDebuff(String id) => _dio.delete<void>('/api/du-an/debuffs/$id');

  static String? _trimOrNull(String? s) => (s == null || s.trim().isEmpty) ? null : s.trim();
}

final healthInputsApiProvider = Provider<HealthInputsApi>((ref) => HealthInputsApi(ref.watch(apiClientProvider)));

final checkInHistoryProvider = FutureProvider.autoDispose<CheckInHistory>((ref) => ref.watch(healthInputsApiProvider).checkIns());

final debuffsProvider = FutureProvider.autoDispose<List<Debuff>>((ref) => ref.watch(healthInputsApiProvider).debuffs());
