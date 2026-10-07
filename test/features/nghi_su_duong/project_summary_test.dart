import 'package:amber_flutter/features/nghi_su_duong/models/project_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('DuAnSummary.fromJson: mẫu đầy đủ, tiền parse từ chuỗi (âm có dấu), null cho KR và mốc', () {
    final s = DuAnSummary.fromJson({
      'projects': [
        {
          'id': 'p1',
          'name': 'PROJ A',
          'goal': 'Thử',
          'color': null,
          'status': 'ACTIVE',
          'startDate': '2026-10-06',
          'endDate': null,
          'closedAt': null,
          'krProgress': 0.5,
          'taskTotal': 4,
          'taskDone': 1,
          'taskDoing': 1,
          'attentionCount': 1,
          'nextMilestone': {'id': 'm1', 'title': 'moc', 'dueDate': '2026-10-14'},
          'finance': {'income': '0.00', 'expense': '100000.00', 'net': '-100000.00'},
        },
        {
          'id': 'p2',
          'name': 'Trống',
          'goal': null,
          'color': null,
          'status': 'DONE',
          'startDate': null,
          'endDate': null,
          'closedAt': '2026-10-07T13:27:08.025Z',
          'krProgress': null,
          'taskTotal': 0,
          'taskDone': 0,
          'taskDoing': 0,
          'attentionCount': 0,
          'nextMilestone': null,
          'finance': {'income': '0.00', 'expense': '0.00', 'net': '0.00'},
        },
      ],
      'attention': [
        {'taskId': 't1', 'title': 'ok', 'status': 'PREP', 'projectId': 'p1', 'projectName': 'PROJ A', 'kind': 'OVERDUE', 'days': 15},
      ],
    });
    final a = s.projects[0];
    expect(a.status, ProjectStatus.active);
    expect(a.krProgress, 0.5);
    expect(a.nextMilestone?.title, 'moc');
    expect(a.finance.expense, 100000);
    expect(a.finance.net, -100000);
    final b = s.projects[1];
    expect(b.status, ProjectStatus.done);
    expect(b.krProgress, isNull);
    expect(b.nextMilestone, isNull);
    expect(b.closedAt, DateTime.utc(2026, 10, 7, 13, 27, 8, 25));
    expect(s.attention.single.isOverdue, isTrue);
    expect(s.attention.single.days, 15);
  });

  test('trạng thái lạ → unknown', () {
    expect(ProjectStatus.fromApi('ARCHIVED'), ProjectStatus.unknown);
  });
}
