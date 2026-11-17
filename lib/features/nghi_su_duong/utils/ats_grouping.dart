// Gom việc ATS theo dự án cho khối "Công việc ATS" (hàm thuần — test ở ats_grouping_test.dart).
//
// - Gộp việc trùng (cùng dự án + tên + hạn + trạng thái + quá hạn) thành MỘT dòng kèm số lượng (×N).
// - Thứ tự nhóm: nhóm có việc quá hạn trước, rồi theo hạn gần nhất của các việc CHƯA XONG trong nhóm (không hạn / chỉ có việc xong → cuối);
//   hoà thì theo vị trí xuất hiện đầu tiên trong danh sách server. Trong nhóm giữ nguyên thứ tự server.

import '../models/ats_task.dart';

/// Một dòng hiển thị: việc đại diện (bản xuất hiện đầu tiên) + số việc giống hệt nó.
class AtsTaskLine {
  const AtsTaskLine({required this.task, required this.count});

  final AtsTask task;
  final int count;
}

class AtsTaskGroup {
  const AtsTaskGroup({required this.project, required this.lines});

  final AtsProject? project;
  final List<AtsTaskLine> lines;

  bool get hasOverdue => lines.any((l) => l.task.overdue);

  /// Hạn sớm nhất của các việc chưa xong ("YYYY-MM-DD"), null nếu không có.
  String? get nearestDue {
    String? best;
    for (final l in lines) {
      final d = l.task.dueDate;
      if (l.task.isDone || d == null) continue;
      if (best == null || d.compareTo(best) < 0) best = d;
    }
    return best;
  }
}

/// Nhãn tiêu đề nhóm: "Tên dự án · Loại" (+ " · Lưu trữ"); không có dự án → "Không thuộc dự án".
String atsGroupLabel(AtsProject? p) {
  if (p == null) return 'Không thuộc dự án';
  final parts = [
    p.name.isEmpty ? 'Không rõ dự án' : p.name,
    if (p.typeLabel.isNotEmpty) p.typeLabel,
    if (p.archived) 'Lưu trữ',
  ];
  return parts.join(' · ');
}

String _projectKey(AtsProject? p) => p == null ? '\u0000none' : (p.atsId ?? 'name:${p.name}');

String _dupKey(AtsTask t) => [t.title, t.dueDate ?? '', t.status.apiValue, t.overdue].join('\u0001');

List<AtsTaskGroup> groupAtsTasks(List<AtsTask> tasks) {
  final order = <String, int>{};
  final projects = <String, AtsProject?>{};
  final lines = <String, List<AtsTask>>{};
  final counts = <String, Map<String, int>>{};

  for (final t in tasks) {
    final pk = _projectKey(t.project);
    order.putIfAbsent(pk, () => order.length);
    projects.putIfAbsent(pk, () => t.project);
    final groupLines = lines.putIfAbsent(pk, () => []);
    final groupCounts = counts.putIfAbsent(pk, () => {});
    final dk = _dupKey(t);
    if (groupCounts.containsKey(dk)) {
      groupCounts[dk] = groupCounts[dk]! + 1;
    } else {
      groupCounts[dk] = 1;
      groupLines.add(t);
    }
  }

  final groups = [
    for (final pk in order.keys)
      AtsTaskGroup(
        project: projects[pk],
        lines: [for (final t in lines[pk]!) AtsTaskLine(task: t, count: counts[pk]![_dupKey(t)]!)],
      ),
  ];
  final firstSeen = {for (final g in groups) g: order[_projectKey(g.project)]!};
  groups.sort((a, b) {
    if (a.hasOverdue != b.hasOverdue) return a.hasOverdue ? -1 : 1;
    final da = a.nearestDue, db = b.nearestDue;
    if (da != db) {
      if (da == null) return 1;
      if (db == null) return -1;
      return da.compareTo(db);
    }
    return firstSeen[a]!.compareTo(firstSeen[b]!);
  });
  return groups;
}

/// Cắt còn tối đa [maxLines] dòng việc (không tính tiêu đề nhóm), giữ thứ tự nhóm; nhóm bị cắt hết thì bỏ.
/// Trả về các nhóm đã cắt và số dòng bị ẩn.
({List<AtsTaskGroup> groups, int hidden}) limitAtsLines(List<AtsTaskGroup> groups, int maxLines) {
  final out = <AtsTaskGroup>[];
  var left = maxLines;
  var hidden = 0;
  for (final g in groups) {
    if (left <= 0) {
      hidden += g.lines.length;
      continue;
    }
    final take = g.lines.length <= left ? g.lines.length : left;
    out.add(AtsTaskGroup(project: g.project, lines: g.lines.sublist(0, take)));
    hidden += g.lines.length - take;
    left -= take;
  }
  return (groups: out, hidden: hidden);
}
