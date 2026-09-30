import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/services/api_client.dart';
import '../models/reading_goal.dart';

class ReadingGoalApi {
  const ReadingGoalApi(this._dio);

  final Dio _dio;

  /// Luôn trả về, kể cả khi chưa đặt mục tiêu (target/note null, tiến độ vẫn tính).
  Future<ReadingGoal> getReadingGoal(int year) async {
    final res = await _dio.get<Map<String, dynamic>>('/api/tang-kinh-cac/reading-goals/$year');
    return ReadingGoal.fromJson(res.data!);
  }

  /// Upsert theo năm (POST /reading-goals). Theo backend: [targetBooks] và
  /// [note] luôn ghi đè (null = xoá, giống web gửi cả form); [targetPages] chỉ
  /// gửi khi khác null — không gửi thì backend giữ giá trị cũ.
  /// POST chỉ trả dòng mục tiêu (không có booksRead/pagesRead) nên đọc lại
  /// bằng GET để có ReadingGoal đầy đủ.
  Future<ReadingGoal> upsertReadingGoal(int year, {int? targetBooks, int? targetPages, String? note}) async {
    await _dio.post<void>(
      '/api/tang-kinh-cac/reading-goals',
      data: {'year': year, 'targetBooks': targetBooks, 'targetPages': ?targetPages, 'note': note},
    );
    return getReadingGoal(year);
  }
}

final readingGoalApiProvider = Provider<ReadingGoalApi>((ref) => ReadingGoalApi(ref.watch(apiClientProvider)));
