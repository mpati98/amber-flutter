import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/services/api_client.dart';
import '../models/placement_test.dart';
import '../models/practice_message.dart';
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

  /// Kèm toàn bộ tin nhắn (cũ trước). 404 nếu không có hoặc không thuộc user.
  Future<PracticeSession> getSessionDetail(String id) async {
    final res = await _dio.get<Map<String, dynamic>>('/api/tra-dinh/sessions/$id');
    return PracticeSession.fromJson(res.data!);
  }

  /// Server gọi AI (không stream, vài giây), thành công mới ghi cả 2 tin.
  /// Lỗi: 400 `session_ended` (buổi đã kết thúc), 502 `ai_unavailable` (không
  /// ghi gì — gửi lại an toàn).
  Future<({PracticeMessage userMessage, PracticeMessage assistantMessage})> sendMessage(
    String sessionId, {
    required String content,
    String? audioUrl,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/tra-dinh/sessions/$sessionId/messages',
      data: {'content': content, 'audioUrl': ?audioUrl},
    );
    final data = res.data!;
    return (
      userMessage: PracticeMessage.fromJson(data['userMessage'] as Map<String, dynamic>),
      assistantMessage: PracticeMessage.fromJson(data['assistantMessage'] as Map<String, dynamic>),
    );
  }

  /// Đề không kèm đáp án.
  Future<PlacementTest> getPlacementTest() async {
    final res = await _dio.get<Map<String, dynamic>>('/api/tra-dinh/placement-test');
    return PlacementTest.fromJson(res.data!);
  }

  /// Đáp án = chỉ số lựa chọn theo id câu. Server chấm trắc nghiệm theo đáp án
  /// gốc, gọi AI chấm bài viết (chậm vài giây), rồi ghi đè điểm GRAMMAR,
  /// VOCABULARY, READING, WRITING của user.
  Future<PlacementResult> submitPlacementTest({
    required Map<String, int> grammarVocabularyAnswers,
    required Map<String, int> readingAnswers,
    required String writingResponse,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/tra-dinh/placement-test/submit',
      data: {
        'grammarVocabularyAnswers': grammarVocabularyAnswers,
        'readingAnswers': readingAnswers,
        'writingResponse': writingResponse,
      },
    );
    return PlacementResult.fromJson(res.data!);
  }
}

final traDinhApiProvider = Provider<TraDinhApi>((ref) => TraDinhApi(ref.watch(apiClientProvider)));
