import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/vn_time.dart';
import '../../../shared/widgets/progress_bar.dart';
import '../../../shared/widgets/scroll_card.dart';
import '../../../shared/widgets/tag.dart';
import '../models/practice_session.dart';
import '../models/skill_score.dart';
import '../providers/tra_dinh_provider.dart';
import '../widgets/new_practice_session_modal.dart';
import 'placement_test_screen.dart';

TextStyle _muted(double size) => TextStyle(fontSize: size, color: Colors.white.withValues(alpha: 0.4));

/// "d/M/yyyy" theo lịch VN, như toLocaleDateString("vi-VN").
String _viDate(DateTime at) {
  final d = vnNow(at);
  return '${d.day}/${d.month}/${d.year}';
}

String _errorText(Object e, String what) =>
    e is DioException ? 'Không tải được $what (${e.response?.statusCode ?? e.type.name}).' : 'Không tải được $what.';

/// Port /tra-dinh: trình độ theo kỹ năng + danh sách buổi luyện.
class TraDinhScreen extends ConsumerWidget {
  const TraDinhScreen({super.key});

  // TODO: bỏ khi có màn chat.
  static void _todo(BuildContext context, String message) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));

  Future<void> _newSession(BuildContext context) async {
    final created = await showNewPracticeSessionModal(context);
    if (created == null || !context.mounted) return;
    _todo(context, 'Đã tạo "${created.name}" — TODO: mở màn chat khi có.');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skills = ref.watch(skillScoresProvider);
    final sessions = ref.watch(practiceSessionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Trà Đình')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _newSession(context),
        icon: const Icon(Icons.add),
        label: const Text('Bắt đầu buổi luyện mới'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: RefreshIndicator(
            onRefresh: () =>
                Future.wait([ref.refresh(skillScoresProvider.future), ref.refresh(practiceSessionsProvider.future)]),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96), // chừa chỗ cho FAB
              children: [
                // Như web: chỉ hiện nút khi đã biết điểm, để chọn đúng nhãn.
                if (skills.value case final rows?)
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton(
                      onPressed: () =>
                          Navigator.of(context)
                              .push(MaterialPageRoute<void>(builder: (_) => const PlacementTestScreen())),
                      child: Text(rows.any((s) => s.hasResult) ? 'Làm lại bài test' : 'Làm bài test đầu vào'),
                    ),
                  ),
                const SizedBox(height: 16),
                ScrollCard(
                  glow: ScrollCardGlow.kincha,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _SectionTitle('Trình độ theo kỹ năng'),
                      const SizedBox(height: 12),
                      skills.when(
                        loading: () => Text('Đang tải...', style: _muted(12)),
                        error: (e, _) => Text(_errorText(e, 'trình độ'), style: _muted(12)),
                        data: (rows) => _SkillGrid(rows),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const _SectionTitle('Các buổi luyện'),
                const SizedBox(height: 12),
                ...sessions.when(
                  loading: () => [Text('Đang tải...', style: _muted(12))],
                  error: (e, _) => [Text(_errorText(e, 'buổi luyện'), style: _muted(12))],
                  data: (items) => items.isEmpty
                      ? [Text('Chưa có buổi luyện nào.', style: _muted(12))]
                      : [
                          for (final s in items) ...[
                            _SessionCard(
                              session: s,
                              onTap: () => _todo(context, 'TODO: mở "${s.name}" khi có màn chat.'),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.3, color: AppColors.kincha400),
  );
}

/// Lưới 2 cột, đủ 6 kỹ năng theo [Skill.values] kể cả khi server thiếu dòng.
class _SkillGrid extends StatelessWidget {
  const _SkillGrid(this.rows);

  final List<SkillScore> rows;

  @override
  Widget build(BuildContext context) {
    final bySkill = {for (final r in rows) r.skill: r};
    final cells = [for (final s in Skill.values) _SkillCell(skill: s, row: bySkill[s])];
    return Column(
      spacing: 12,
      children: [
        for (var i = 0; i < cells.length; i += 2)
          Row(
            spacing: 16,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: cells[i]),
              Expanded(child: i + 1 < cells.length ? cells[i + 1] : const SizedBox.shrink()),
            ],
          ),
      ],
    );
  }
}

class _SkillCell extends StatelessWidget {
  const _SkillCell({required this.skill, this.row});

  final Skill skill;
  final SkillScore? row;

  @override
  Widget build(BuildContext context) {
    // "B1 · 62"; thiếu 1 trong 2 thì chỉ hiện phần có.
    final parts = [?row?.cefrLevel, if (row?.score case final score?) '$score'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 4,
      children: [
        Text(skill.label, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.8))),
        Text(parts.isEmpty ? 'Chưa có điểm' : parts.join(' · '), style: _muted(11)),
        ProgressBar(value: (row?.score ?? 0).toDouble(), max: 100),
      ],
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session, required this.onTap});

  final PracticeSession session;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = session;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: ScrollCard(
        glow: s.isEnded ? ScrollCardGlow.yugen : ScrollCardGlow.kincha,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 4,
          children: [
            Row(
              spacing: 8,
              children: [
                Expanded(
                  child: Text(s.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                ),
                Tag(
                  label: s.mode.label,
                  color: Colors.white,
                  foregroundColor: Colors.white.withValues(alpha: 0.5),
                  variant: TagVariant.tonal,
                  backgroundAlpha: 0.08,
                  fontSize: 10,
                ),
              ],
            ),
            Text('${_viDate(s.createdAt)} · ${s.isEnded ? 'Đã kết thúc' : 'Đang diễn ra'}', style: _muted(11)),
            if (s.summary case final summary? when summary.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  summary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.6)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
