import 'key_result.dart';
import 'project_summary.dart';

/// GET /api/projects/[id]: dự án STANDARD kèm keyResults (cũ → mới).
class ProjectDetail {
  const ProjectDetail({
    required this.id,
    required this.name,
    this.goal,
    this.color,
    required this.status,
    this.startDate,
    this.endDate,
    this.closedAt,
    this.keyResults = const [],
  });

  factory ProjectDetail.fromJson(Map<String, dynamic> json) => ProjectDetail(
        id: json['id'] as String,
        name: json['name'] as String,
        goal: json['goal'] as String?,
        color: json['color'] as String?,
        status: ProjectStatus.fromApi(json['status'] as String),
        startDate: json['startDate'] as String?,
        endDate: json['endDate'] as String?,
        closedAt: json['closedAt'] == null ? null : DateTime.parse(json['closedAt'] as String),
        keyResults: [
          for (final e in (json['keyResults'] as List? ?? const [])) KeyResult.fromJson(e as Map<String, dynamic>),
        ],
      );

  final String id;
  final String name;
  final String? goal;
  final String? color;
  final ProjectStatus status;

  /// "YYYY-MM-DD".
  final String? startDate;
  final String? endDate;
  final DateTime? closedAt;
  final List<KeyResult> keyResults;
}
