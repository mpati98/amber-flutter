/// 6 kỹ năng, đúng thứ tự `SKILLS` bên amber-v3/src/lib/skills.ts — GET
/// /tra-dinh/skills trả về theo thứ tự này và lưới kỹ năng giữ nguyên.
enum Skill {
  grammar('GRAMMAR', 'Ngữ pháp'),
  vocabulary('VOCABULARY', 'Từ vựng'),
  listening('LISTENING', 'Nghe'),
  speaking('SPEAKING', 'Nói'),
  reading('READING', 'Đọc'),
  writing('WRITING', 'Viết');

  const Skill(this.apiValue, this.label);

  final String apiValue;

  /// = SKILL_LABEL bên web.
  final String label;

  static Skill? fromApi(String? value) => values.where((s) => s.apiValue == value).firstOrNull;
}

/// 1 dòng của GET /tra-dinh/skills. Server luôn trả đủ 6 kỹ năng; kỹ năng chưa
/// từng được chấm có score/cefrLevel/updatedAt = null.
class SkillScore {
  const SkillScore({required this.skill, this.score, this.cefrLevel, this.updatedAt});

  factory SkillScore.fromJson(Map<String, dynamic> json) => SkillScore(
    skill: Skill.fromApi(json['skill'] as String?)!,
    score: json['score'] as int?,
    cefrLevel: json['cefrLevel'] as String?,
    updatedAt: json['updatedAt'] == null ? null : DateTime.parse(json['updatedAt'] as String),
  );

  final Skill skill;

  /// 0–100, thang nội bộ.
  final int? score;

  /// A1–C2.
  final String? cefrLevel;
  final DateTime? updatedAt;

  bool get hasResult => score != null || cefrLevel != null;
}
