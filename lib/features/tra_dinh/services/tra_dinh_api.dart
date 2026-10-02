import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/services/api_client.dart';
import '../models/practice_session.dart';
import '../models/skill_score.dart';

/// Trà Đình — luyện tiếng Anh với AI. Mọi route lọc theo user đăng nhập.
class TraDinhApi {
  const TraDinhApi(this._dio);

  final Dio _dio;

  /// Luôn đủ 6 kỹ năng theo thứ tự [Skill.values].
  Future<List<SkillScore>> getSkills() async {
    final res = await _dio.get<List<dynamic>>('/api/tra-dinh/skills');
    return res.data!.map((e) => SkillScore.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Mới tạo trước.
  Future<List<PracticeSession>> getSessions() async {
    final res = await _dio.get<List<dynamic>>('/api/tra-dinh/sessions');
    return res.data!.map((e) => PracticeSession.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Không có [name] thì server đặt `"<tên mode> — <ngày>"`.
  Future<PracticeSession> createSession({required PracticeMode mode, String? name}) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/tra-dinh/sessions',
      data: {'mode': mode.apiValue, 'name': ?name},
    );
    return PracticeSession.fromJson(res.data!);
  }
}

final traDinhApiProvider = Provider<TraDinhApi>((ref) => TraDinhApi(ref.watch(apiClientProvider)));
