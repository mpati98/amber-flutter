import 'package:amber_flutter/features/nghi_su_duong/models/course.dart';
import 'package:amber_flutter/shared/utils/duration_format.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _lesson(String id, String title, String? studiedAt, int? minutes) =>
    {'id': id, 'projectId': 'c1', 'title': title, 'studiedAt': studiedAt, 'durationMinutes': minutes, 'note': null};

void main() {
  // Shape theo GET /api/learn/courses: project + learnDetails + learnLessons.
  test('Course từ GET /learn/courses: details, bài học mới nhất trước, bài chưa có ngày xếp cuối', () {
    final c = Course.fromJson({
      'id': 'c1', 'userId': 'u', 'name': 'CS50', 'color': null, 'type': 'LEARN',
      'startDate': '2026-09-01', 'endDate': null, 'archivedAt': null, 'createdAt': '2026-09-01T00:00:00.000Z',
      'learnDetails': {'projectId': 'c1', 'source': 'edX', 'field': 'Lập trình', 'outcome': null, 'status': 'IN_PROGRESS'},
      'learnLessons': [
        _lesson('l1', 'Tuần 0', '2026-09-02', 45),
        _lesson('l2', 'Ghi chú lẻ', null, null),
        _lesson('l3', 'Tuần 1', '2026-09-09', 45),
      ],
    });
    expect(c.status, CourseStatus.inProgress);
    expect(c.sourceAndField, 'edX · Lập trình');
    expect(c.lessons.map((l) => l.title), ['Tuần 1', 'Tuần 0', 'Ghi chú lẻ']);
    expect(c.lastLessonTitle, 'Tuần 1');
    expect(c.lastLessonDate, '2026-09-09');
    expect(c.lessonCount, 3);
    expect(c.totalMinutes, 90);
    expect(formatDuration(c.totalMinutes), '1h 30p'); // web hiện "2h 30p"
  });

  test('POST/PATCH không kèm bài học; thiếu details → Dự định như web', () {
    final created = Course.fromJson({
      'id': 'c2', 'name': 'React', 'startDate': null, 'endDate': null, 'archivedAt': null,
      'learnDetails': {'projectId': 'c2', 'source': null, 'field': null, 'outcome': null, 'status': 'PLANNED'},
    });
    expect(created.lessons, isEmpty);
    expect(created.lastLessonTitle, isNull);
    expect(created.sourceAndField, isNull);
    final noDetails = Course.fromJson({'id': 'c3', 'name': 'X', 'learnDetails': null, 'learnLessons': []});
    expect(noDetails.status, CourseStatus.planned);
  });

  test('COMPLETED có archivedAt', () {
    final c = Course.fromJson({
      'id': 'c4', 'name': 'Done', 'archivedAt': '2026-09-20T10:00:00.000Z',
      'learnDetails': {'status': 'COMPLETED'}, 'learnLessons': [],
    });
    expect(c.status, CourseStatus.completed);
    expect(c.archivedAt, DateTime.utc(2026, 9, 20, 10));
  });
}
