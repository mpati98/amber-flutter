import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/course.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_enums.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/utils/password_error.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _course({
  Object? deletedAt = '2026-11-09T03:00:00.000Z',
  Object? daysLeft = 29,
}) => {
  'id': 'c1',
  'subjectId': 's1',
  'title': 'Khóa A',
  'status': 'QUEUED',
  'queuePosition': null,
  'progress': {
    'doneSections': 0,
    'totalSections': 2,
    'doneMinutes': 0,
    'totalMinutes': 60,
  },
  'nextSection': null,
  'deletedAt': ?deletedAt,
  'daysLeft': ?daysLeft,
  'trườngLạ': {'x': 1},
};

DioException _err(
  int status,
  Object? data, {
  Map<String, List<String>> headers = const {},
}) {
  final req = RequestOptions(path: '/x');
  return DioException(
    requestOptions: req,
    type: DioExceptionType.badResponse,
    response: Response(
      requestOptions: req,
      statusCode: status,
      data: data,
      headers: Headers.fromMap(headers),
    ),
  );
}

void main() {
  group('CourseView (Thùng rác)', () {
    test('đọc deletedAt và daysLeft; bỏ qua trường lạ', () {
      final c = CourseView.fromJson(_course());
      expect(c.deletedAt, DateTime.utc(2026, 11, 9, 3));
      expect(c.daysLeft, 29);
      expect(c.status, CourseStatus.queued);
    });

    test('danh sách thường không có hai trường → null', () {
      final c = CourseView.fromJson(_course(deletedAt: null, daysLeft: null));
      expect((c.deletedAt, c.daysLeft), (null, null));
    });

    test('deletedAt hỏng không làm hỏng cả khóa', () {
      expect(
        CourseView.fromJson(_course(deletedAt: 'không phải ngày')).deletedAt,
        isNull,
      );
    });

    test('copyWith giữ deletedAt và daysLeft', () {
      final c = CourseView.fromJson(_course())
          .copyWith(progress: CourseProgress.empty);
      expect((c.daysLeft, c.deletedAt != null), (29, true));
    });
  });

  group('classifyPasswordError', () {
    test(
      '403 wrong_password',
      () => expect(
        classifyPasswordError(_err(403, {'error': 'wrong_password'})).kind,
        PasswordFailureKind.wrong,
      ),
    );

    test('429 lấy retryAfterSeconds trong body', () {
      final f = classifyPasswordError(
        _err(429, {'error': 'password_locked', 'retryAfterSeconds': 125}),
      );
      expect((f.kind, f.retryAfterSeconds), (PasswordFailureKind.locked, 125));
    });

    test('429 thiếu số giây trong body → lấy header Retry-After, rồi mới đến mặc định 15 phút', () {
      final h = classifyPasswordError(
        _err(
          429,
          {'error': 'password_locked'},
          headers: {
            'retry-after': ['90'],
          },
        ),
      );
      expect(h.retryAfterSeconds, 90);
      expect(
        classifyPasswordError(_err(429, {'error': 'password_locked'}))
            .retryAfterSeconds,
        900,
      );
    });

    test('404 → notFound; 500, lỗi mạng, body lạ → other', () {
      expect(
        classifyPasswordError(_err(404, {'error': 'course_not_found'})).kind,
        PasswordFailureKind.notFound,
      );
      expect(
        classifyPasswordError(_err(500, 'oops')).kind,
        PasswordFailureKind.other,
      );
      expect(
        classifyPasswordError(_err(403, 'html')).kind,
        PasswordFailureKind.other,
      );
      expect(
        classifyPasswordError(StateError('x')).kind,
        PasswordFailureKind.other,
      );
    });

    test('lockedMessage làm tròn lên theo phút, tối thiểu 1', () {
      expect(lockedMessage(900), 'Nhập sai nhiều lần. Thử lại sau 15 phút.');
      expect(lockedMessage(61), 'Nhập sai nhiều lần. Thử lại sau 2 phút.');
      expect(lockedMessage(125), 'Nhập sai nhiều lần. Thử lại sau 3 phút.');
      expect(lockedMessage(5), 'Nhập sai nhiều lần. Thử lại sau 1 phút.');
    });
  });
}
