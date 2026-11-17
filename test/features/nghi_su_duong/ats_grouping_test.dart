import 'package:amber_flutter/features/nghi_su_duong/models/ats_task.dart';
import 'package:amber_flutter/features/nghi_su_duong/utils/ats_grouping.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ats_test_support.dart';

// Gom việc ATS theo dự án, gộp việc trùng, thứ tự nhóm, cắt 6 dòng.

const _pA = {'atsId': 'pA', 'name': 'Hội chợ A', 'type': 'FAIR', 'archived': false};
const _pB = {'atsId': 'pB', 'name': 'Chiến dịch B', 'type': 'CAMPAIGN', 'archived': false};
const _pC = {'atsId': 'pC', 'name': 'Khác C', 'type': 'OTHER', 'archived': true};

AtsTask _t(String id, Object? project, {String title = 'Việc', String? due, String? status = 'PREP', bool overdue = false}) =>
    AtsTask.fromJson(atsTaskJson(id, title: title, project: project, dueDate: due, status: status, attention: overdue ? 'OVERDUE' : null));

void main() {
  test('gộp việc trùng (tên + hạn + trạng thái) thành một dòng ×N, giữ bản xuất hiện đầu', () {
    final g = groupAtsTasks([
      _t('1', _pA, title: 'Report', due: '2026-11-17'),
      _t('2', _pA, title: 'Report', due: '2026-11-17'),
      _t('3', _pA, title: 'Report', due: '2026-11-17'),
      _t('4', _pA, title: 'Report', due: '2026-11-18'), // khác hạn → dòng riêng
      _t('5', _pA, title: 'Report', due: '2026-11-17', status: 'IN_PROGRESS'), // khác trạng thái → dòng riêng
    ]);
    expect(g, hasLength(1));
    expect(g.single.lines.map((l) => (l.task.id, l.count)), [('1', 3), ('4', 1), ('5', 1)]);
  });

  test('cùng tên nhưng khác dự án không gộp', () {
    final g = groupAtsTasks([_t('1', _pA, title: 'X', due: '2026-11-17'), _t('2', _pB, title: 'X', due: '2026-11-17')]);
    expect(g.map((x) => x.lines.single.count), [1, 1]);
  });

  test('thứ tự nhóm: có quá hạn trước, rồi hạn gần nhất (việc chưa xong), không hạn cuối; trong nhóm giữ thứ tự server', () {
    final g = groupAtsTasks([
      _t('b1', _pB, due: '2026-11-20'),
      _t('a1', _pA, due: '2026-11-25'),
      _t('a2', _pA, due: '2026-11-19'),
      _t('n1', null),
      _t('c1', _pC, due: '2026-11-01', overdue: true),
      _t('b2', _pB, due: '2026-11-10', status: 'DONE'), // việc xong không kéo nhóm B lên
    ]);
    expect(g.map((x) => x.project?.atsId), ['pC', 'pA', 'pB', null]);
    expect(g[1].lines.map((l) => l.task.id), ['a1', 'a2']);
    expect(g[1].nearestDue, '2026-11-19');
    expect(g[2].nearestDue, '2026-11-20');
  });

  test('nhãn nhóm', () {
    expect(atsGroupLabel(AtsProject.fromJson(_pA)), 'Hội chợ A · Hội chợ');
    expect(atsGroupLabel(AtsProject.fromJson(_pC)), 'Khác C · Khác · Lưu trữ');
    expect(atsGroupLabel(null), 'Không thuộc dự án');
    expect(atsGroupLabel(AtsProject.fromJson({'atsId': 'x', 'name': '', 'type': null, 'archived': false})), 'Không rõ dự án');
  });

  test('limitAtsLines: tối đa N dòng việc qua các nhóm, nhóm bị cắt hết thì bỏ, báo số dòng ẩn', () {
    final groups = groupAtsTasks([
      for (var i = 0; i < 4; i++) _t('a$i', _pA, title: 'A$i', due: '2026-11-1${i + 1}'),
      for (var i = 0; i < 4; i++) _t('b$i', _pB, title: 'B$i', due: '2026-11-2${i + 1}'),
      _t('c0', _pC, title: 'C0', due: '2026-11-29'),
    ]);
    final r = limitAtsLines(groups, 6);
    expect(r.groups.map((g) => g.lines.length), [4, 2]);
    expect(r.hidden, 3);
    final all = limitAtsLines(groups, 20);
    expect(all.hidden, 0);
    expect(all.groups, hasLength(3));
  });
}
