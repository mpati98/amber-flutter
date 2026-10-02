import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/scroll_card.dart';
import '../models/placement_test.dart';
import '../models/skill_score.dart';
import '../providers/tra_dinh_provider.dart';
import '../services/tra_dinh_api.dart';

TextStyle _muted(double size) => TextStyle(fontSize: size, color: Colors.white.withValues(alpha: 0.4));

const _sectionStyle = TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.kincha400);

/// Đếm từ như web: tách theo khoảng trắng, bỏ phần rỗng.
int _wordCount(String text) => text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;

/// Port /tra-dinh/placement-test: intro → ngữ pháp/từ vựng → đọc hiểu → viết →
/// kết quả. Như web: phải trả lời hết mới qua bước tiếp, không quay lại bước
/// trước, không lưu nháp.
class PlacementTestScreen extends ConsumerStatefulWidget {
  const PlacementTestScreen({super.key});

  @override
  ConsumerState<PlacementTestScreen> createState() => _PlacementTestScreenState();
}

class _PlacementTestScreenState extends ConsumerState<PlacementTestScreen> {
  static const _intro = 0, _gv = 1, _reading = 2, _writing = 3, _results = 4;

  int _step = _intro;
  PlacementTest? _test;
  bool _loadingTest = false;
  String? _loadError;

  final _gvAnswers = <String, int>{};
  final _readingAnswers = <String, int>{};
  final _writingCtrl = TextEditingController();

  bool _submitting = false;
  String? _submitError;
  PlacementResult? _result;

  @override
  void initState() {
    super.initState();
    _writingCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _writingCtrl.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    setState(() {
      _loadingTest = true;
      _loadError = null;
    });
    try {
      final test = await ref.read(traDinhApiProvider).getPlacementTest();
      if (!mounted) return;
      setState(() {
        _test = test;
        _loadingTest = false;
        _step = _gv;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingTest = false;
        _loadError = 'Không tải được bài test (${e.response?.statusCode ?? e.type.name}), thử lại nhé.';
      });
    }
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _submitError = null;
      _step = _results;
    });
    try {
      final result = await ref
          .read(traDinhApiProvider)
          .submitPlacementTest(
            grammarVocabularyAnswers: Map.of(_gvAnswers),
            readingAnswers: Map.of(_readingAnswers),
            writingResponse: _writingCtrl.text,
          );
      // Điểm đã ghi ở server — làm mới lưới kỹ năng ngay, kể cả khi người dùng
      // thoát bằng nút back thay vì nút "Quay lại Trà Đình".
      ref.invalidate(skillScoresProvider);
      if (!mounted) return;
      setState(() {
        _result = result;
        _submitting = false;
      });
    } on DioException {
      if (!mounted) return;
      // Quay lại bước viết, giữ nguyên mọi câu trả lời để nộp lại.
      setState(() {
        _submitting = false;
        _step = _writing;
        _submitError = 'Không nộp được bài, thử lại nhé.';
      });
    }
  }

  void _backToHub() {
    ref.invalidate(skillScoresProvider);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final test = _test;
    return Scaffold(
      appBar: AppBar(title: const Text('Bài test đầu vào')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: IndexedStack(
            index: _step,
            sizing: StackFit.expand,
            children: [
              _IntroStep(loading: _loadingTest, error: _loadError, onStart: _start),
              if (test == null) ...[
                const SizedBox.shrink(),
                const SizedBox.shrink(),
                const SizedBox.shrink(),
              ] else ...[
                _QuestionsStep(
                  header: Text(
                    'Ngữ pháp & Từ vựng — ${test.grammarVocabularyQuestions.length} câu',
                    style: _sectionStyle,
                  ),
                  questions: test.grammarVocabularyQuestions,
                  answers: _gvAnswers,
                  onAnswer: (id, i) => setState(() => _gvAnswers[id] = i),
                  onNext: () => setState(() => _step = _reading),
                ),
                _QuestionsStep(
                  passage: test.readingPassage,
                  questions: test.readingQuestions,
                  answers: _readingAnswers,
                  onAnswer: (id, i) => setState(() => _readingAnswers[id] = i),
                  onNext: () => setState(() => _step = _writing),
                ),
                _WritingStep(
                  prompt: test.writingPrompt,
                  controller: _writingCtrl,
                  submitting: _submitting,
                  error: _submitError,
                  onSubmit: _submit,
                ),
              ],
              _result == null ? const _GradingIndicator() : _ResultsStep(result: _result!, onDone: _backToHub),
            ],
          ),
        ),
      ),
    );
  }
}

/// Thanh dưới cùng: chữ trạng thái bên trái, nút hành động bên phải.
class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.status, required this.button});

  final String status;
  final Widget button;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Expanded(child: Text(status, style: _muted(12))),
              button,
            ],
          ),
        ),
      ),
    );
  }
}

class _IntroStep extends StatelessWidget {
  const _IntroStep({required this.loading, required this.error, required this.onStart});

  final bool loading;
  final String? error;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ScrollCard(
          glow: ScrollCardGlow.kincha,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              Text(
                'Bài kiểm tra tiếng Anh đầu vào',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 20, color: Colors.white),
              ),
              Text(
                'Ước lượng trình độ CEFR cho Ngữ pháp, Từ vựng, Đọc và Viết. Gồm 3 phần: '
                '25 câu ngữ pháp & từ vựng, 1 đoạn đọc hiểu với 5 câu hỏi, và 1 đoạn viết ngắn.',
                style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.6)),
              ),
              Text(
                'Chọn đáp án đúng nhất cho mỗi câu. Không cần vội — câu khó dần về cuối là bình thường. '
                'Phải trả lời hết mới sang được phần tiếp theo, và không quay lại phần trước được.',
                style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.7)),
              ),
              if (error != null) Text(error!, style: const TextStyle(fontSize: 12, color: AppColors.shuiro500)),
              // Spinner + chữ như nút "Bắt đầu tháng mới" — spinner trơn trong nút
              // bị khoá gần như không thấy.
              FilledButton.icon(
                onPressed: loading ? null : onStart,
                icon: loading
                    ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : null,
                label: Text(loading ? 'Đang tải đề...' : 'Bắt đầu'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Bước trắc nghiệm. Có [passage] (đọc hiểu) thì đoạn văn nằm cố định phía
/// trên, tự cuộn bên trong, để vừa đọc vừa trả lời — như khung sticky bên web.
class _QuestionsStep extends StatelessWidget {
  const _QuestionsStep({
    this.header,
    this.passage,
    required this.questions,
    required this.answers,
    required this.onAnswer,
    required this.onNext,
  });

  final Widget? header;
  final String? passage;
  final List<PlacementQuestion> questions;
  final Map<String, int> answers;
  final void Function(String id, int index) onAnswer;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final answered = questions.where((q) => answers.containsKey(q.id)).length;
    final allAnswered = answered == questions.length;

    return Column(
      children: [
        if (passage != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: ScrollCard(
              glow: ScrollCardGlow.kincha,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.35),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [
                      const Text('Đọc hiểu', style: _sectionStyle),
                      Text(
                        passage!,
                        style: TextStyle(fontSize: 13, height: 1.6, color: Colors.white.withValues(alpha: 0.8)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: questions.length + (header == null ? 0 : 1),
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              if (header != null && i == 0) return header!;
              final index = header == null ? i : i - 1;
              final q = questions[index];
              return _QuestionCard(
                number: index + 1,
                question: q,
                selected: answers[q.id],
                onSelect: (choice) => onAnswer(q.id, choice),
              );
            },
          ),
        ),
        _BottomBar(
          status: 'Đã trả lời $answered/${questions.length} câu',
          button: FilledButton(onPressed: allAnswered ? onNext : null, child: const Text('Tiếp')),
        ),
      ],
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({required this.number, required this.question, required this.selected, required this.onSelect});

  final int number;
  final PlacementQuestion question;
  final int? selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return ScrollCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('$number. ${question.question}', style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 4),
          RadioGroup<int>(
            groupValue: selected,
            onChanged: (v) {
              if (v != null) onSelect(v);
            },
            child: Column(
              children: [
                for (var i = 0; i < question.options.length; i++)
                  RadioListTile<int>(
                    value: i,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.kincha400,
                    title: Text(
                      question.options[i],
                      style: TextStyle(
                        fontSize: 13,
                        color: selected == i ? AppColors.kincha200 : Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WritingStep extends StatelessWidget {
  const _WritingStep({
    required this.prompt,
    required this.controller,
    required this.submitting,
    required this.error,
    required this.onSubmit,
  });

  final String prompt;
  final TextEditingController controller;
  final bool submitting;
  final String? error;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final words = _wordCount(controller.text);
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ScrollCard(
                glow: ScrollCardGlow.shuiro,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 12,
                  children: [
                    const Text('Viết', style: _sectionStyle),
                    Text(prompt, style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.8))),
                    TextField(
                      controller: controller,
                      minLines: 10,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      style: const TextStyle(fontSize: 13),
                      decoration: const InputDecoration(hintText: 'Viết câu trả lời của bạn ở đây...'),
                    ),
                    Text('$words từ', style: _muted(11)),
                  ],
                ),
              ),
              if (error != null) ...[
                const SizedBox(height: 12),
                Text(error!, style: const TextStyle(fontSize: 12, color: AppColors.shuiro500)),
              ],
            ],
          ),
        ),
        _BottomBar(
          // Như web: chỉ chặn khi chưa viết gì, không ép đúng 100–150 từ.
          status: 'Yêu cầu 100–150 từ',
          button: FilledButton(
            onPressed: !submitting && words > 0 ? onSubmit : null,
            child: Text(submitting ? 'Đang chấm...' : 'Nộp bài'),
          ),
        ),
      ],
    );
  }
}

class _GradingIndicator extends StatelessWidget {
  const _GradingIndicator();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: [
          const CircularProgressIndicator(),
          Text('Đang chấm bài...', style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.8))),
          Text('Phần viết do AI chấm, có thể mất vài giây.', style: _muted(12)),
        ],
      ),
    );
  }
}

class _ResultsStep extends StatelessWidget {
  const _ResultsStep({required this.result, required this.onDone});

  final PlacementResult result;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Kết quả', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 20, color: Colors.white)),
        const SizedBox(height: 16),
        for (final skill in PlacementResult.skills) ...[
          ScrollCard(
            glow: ScrollCardGlow.kincha,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 8,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(skill.label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.kincha400.withValues(alpha: 0.4)),
                        borderRadius: BorderRadius.circular(AppTheme.darkRadius),
                      ),
                      child: Text(
                        result.results[skill]?.cefrLevel ?? '—',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.kincha400),
                      ),
                    ),
                  ],
                ),
                Text('${result.results[skill]?.score ?? '—'}/100', style: _muted(12)),
                if (skill == Skill.writing && result.writingFeedback != null) ...[
                  Divider(color: Colors.white.withValues(alpha: 0.1), height: 8),
                  Text(
                    result.writingFeedback!,
                    style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.7)),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 4),
        FilledButton(onPressed: onDone, child: const Text('Quay lại Trà Đình')),
      ],
    );
  }
}
