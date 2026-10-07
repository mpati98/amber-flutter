import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/utils/api_error.dart';
import '../../../shared/widgets/progress_bar.dart';
import '../../../shared/widgets/scroll_card.dart';
import '../models/key_result.dart';
import '../providers/nghi_su_duong_provider.dart';
import '../services/nghi_su_duong_api.dart';
import 'key_result_form.dart';

/// Khối "Kết quả then chốt": mỗi KR một dòng, nút Thêm KR.
class KeyResultsBlock extends StatelessWidget {
  const KeyResultsBlock({super.key, required this.projectId, required this.keyResults});

  final String projectId;
  final List<KeyResult> keyResults;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ScrollCard(
      glow: ScrollCardGlow.kincha,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Kết quả then chốt',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: cs.primary),
                ),
              ),
              TextButton.icon(
                onPressed: () => showKeyResultForm(context, projectId: projectId),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Thêm KR'),
              ),
            ],
          ),
          if (keyResults.isEmpty)
            Text(
              'Dự án chưa có kết quả then chốt nào.',
              style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.6)),
            )
          else
            for (final (i, kr) in keyResults.indexed)
              _KeyResultRow(key: ValueKey('kr-${kr.id}'), projectId: projectId, index: i + 1, kr: kr),
        ],
      ),
    );
  }
}

/// Giá trị hiển thị bên phải thanh tiến độ.
String keyResultValueLabel(KeyResult kr) {
  final unit = kr.unit == null || kr.unit!.isEmpty ? '' : ' ${kr.unit}';
  if (kr.mode == KrMode.manual) return '${kr.current} / ${kr.target}$unit';
  return kr.linkedTotal == 0 ? 'Chưa gắn việc' : '${kr.linkedDone} / ${kr.linkedTotal}$unit';
}

class _KeyResultRow extends ConsumerStatefulWidget {
  const _KeyResultRow({super.key, required this.projectId, required this.index, required this.kr});

  final String projectId;
  final int index;
  final KeyResult kr;

  @override
  ConsumerState<_KeyResultRow> createState() => _KeyResultRowState();
}

class _KeyResultRowState extends ConsumerState<_KeyResultRow> {
  bool _sending = false;

  Future<void> _step(int delta) async {
    if (_sending) return;
    setState(() => _sending = true);
    try {
      await ref.read(nghiSuDuongApiProvider).updateKeyResult(widget.projectId, widget.kr.id, {
        'current': widget.kr.current + delta,
      });
      refreshProjectData(ref.invalidate, widget.projectId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(apiErrorMessage(e, 'Không cập nhật được KR, thử lại nhé.'))),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final kr = widget.kr;
    final muted = TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.6));
    final manual = kr.mode == KrMode.manual;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 4,
      children: [
        Row(
          spacing: 8,
          children: [
            Text('KR ${widget.index}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: cs.primary)),
            Expanded(
              child: Text(
                kr.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, color: cs.onSurface),
              ),
            ),
            if (manual) ...[
              IconButton(
                tooltip: 'Giảm 1',
                visualDensity: VisualDensity.compact,
                onPressed: _sending || kr.current <= 0 ? null : () => _step(-1),
                icon: const Icon(Icons.remove_circle_outline),
              ),
              IconButton(
                tooltip: 'Tăng 1',
                visualDensity: VisualDensity.compact,
                onPressed: _sending || kr.current >= kr.target ? null : () => _step(1),
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
            IconButton(
              tooltip: 'Sửa KR',
              visualDensity: VisualDensity.compact,
              onPressed: () => showKeyResultForm(context, projectId: widget.projectId, kr: kr),
              icon: const Icon(Icons.edit_outlined),
            ),
          ],
        ),
        ProgressBar(value: kr.progress, max: 1),
        Row(
          children: [
            Expanded(child: Text(manual ? 'nhập tay' : 'tự đếm từ việc', style: muted)),
            Text(keyResultValueLabel(kr), style: muted.copyWith(color: cs.onSurface.withValues(alpha: 0.85))),
          ],
        ),
      ],
    );
  }
}
