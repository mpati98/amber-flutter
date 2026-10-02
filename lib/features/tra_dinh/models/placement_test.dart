import 'skill_score.dart';

/// 1 câu trắc nghiệm 4 lựa chọn. Server đã bỏ field `answer` — chấm điểm chỉ
/// diễn ra ở server, client gửi chỉ số lựa chọn (0–3) theo [id].
class PlacementQuestion {
  const PlacementQuestion({required this.id, required this.question, required this.options, this.level});

  factory PlacementQuestion.fromJson(Map<String, dynamic> json) => PlacementQuestion(
    id: json['id'] as String,
    question: json['question'] as String,
    options: [for (final o in json['options'] as List<dynamic>) o as String],
    level: json['level'] as String?,
  );

  final String id;
  final String question;
  final List<String> options;

  /// A1–C1, chỉ câu ngữ pháp/từ vựng có; câu đọc hiểu không có.
  final String? level;
}

/// GET /tra-dinh/placement-test: 25 câu ngữ pháp/từ vựng, 1 đoạn đọc + 5 câu,
/// 1 đề viết. Bỏ qua title/description/instructions (màn intro viết sẵn) và
/// `writing.note` (ghi chú cho người chấm, web cũng không hiện).
class PlacementTest {
  const PlacementTest({
    required this.grammarVocabularyQuestions,
    required this.readingPassage,
    required this.readingQuestions,
    required this.writingPrompt,
  });

  factory PlacementTest.fromJson(Map<String, dynamic> json) {
    List<PlacementQuestion> questions(List<dynamic> list) => [
      for (final q in list) PlacementQuestion.fromJson(q as Map<String, dynamic>),
    ];
    final reading = json['reading'] as Map<String, dynamic>;
    return PlacementTest(
      grammarVocabularyQuestions: questions(json['grammarVocabulary'] as List<dynamic>),
      readingPassage: reading['passage'] as String,
      readingQuestions: questions(reading['questions'] as List<dynamic>),
      writingPrompt: (json['writing'] as Map<String, dynamic>)['prompt'] as String,
    );
  }

  final List<PlacementQuestion> grammarVocabularyQuestions;
  final String readingPassage;
  final List<PlacementQuestion> readingQuestions;
  final String writingPrompt;
}

class SkillResult {
  const SkillResult({this.score, this.cefrLevel});

  factory SkillResult.fromJson(Map<String, dynamic> json) => SkillResult(
    // Điểm viết do LLM trả — phòng trường hợp ra số lẻ.
    score: (json['score'] as num?)?.round(),
    cefrLevel: json['cefrLevel'] as String?,
  );

  /// 0–100. WRITING null khi AI chấm lỗi — không phải lỗi request.
  final int? score;
  final String? cefrLevel;
}

/// POST /tra-dinh/placement-test/submit: kết quả 4 kỹ năng GRAMMAR,
/// VOCABULARY (cùng điểm — chung 1 phần thi), READING, WRITING.
class PlacementResult {
  const PlacementResult({required this.results, this.writingFeedback});

  factory PlacementResult.fromJson(Map<String, dynamic> json) {
    final feedback = json['writingFeedback'] as String?;
    return PlacementResult(
      results: {
        for (final e in (json['results'] as Map<String, dynamic>).entries)
          // Bỏ qua khoá lạ (không phải 1 trong 6 kỹ năng).
          ?Skill.fromApi(e.key): SkillResult.fromJson(e.value as Map<String, dynamic>),
      },
      // Server trả "" khi AI không kèm nhận xét — coi như không có.
      writingFeedback: feedback == null || feedback.trim().isEmpty ? null : feedback,
    );
  }

  /// Thứ tự hiển thị kết quả, như RESULT_SKILLS bên web.
  static const skills = [Skill.grammar, Skill.vocabulary, Skill.reading, Skill.writing];

  final Map<Skill, SkillResult> results;
  final String? writingFeedback;
}
