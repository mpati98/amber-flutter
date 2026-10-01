import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/duration_format.dart';
import '../../../shared/widgets/scroll_card.dart';
import '../../../shared/widgets/tag.dart';
import '../models/course.dart';
import '../providers/learn_provider.dart';

TextStyle _muted(double size) => TextStyle(fontSize: size, color: Colors.white.withValues(alpha: 0.4));

/// Bên web chỉ đổi màu chữ (white/40, kincha-400, emerald-300); ở đây dùng Tag
/// nền mờ cùng bảng màu đó để nhãn tách khỏi tên khóa học trên màn nhỏ.
class CourseStatusTag extends StatelessWidget {
  const CourseStatusTag(this.status, {super.key});

  final CourseStatus status;

  @override
  Widget build(BuildContext context) {
    Tag tonal(Color bg, Color fg, {double alpha = 0.2}) => Tag(
      label: status.label,
      color: bg,
      foregroundColor: fg,
      variant: TagVariant.tonal,
      backgroundAlpha: alpha,
      fontSize: 11,
      fontWeight: FontWeight.w500,
    );
    return switch (status) {
      CourseStatus.planned ||
      CourseStatus.unknown => tonal(Colors.white, Colors.white.withValues(alpha: 0.6), alpha: 0.1),
      CourseStatus.inProgress => tonal(AppColors.kincha400, AppColors.kincha400),
      CourseStatus.completed => tonal(AppColors.emerald400, AppColors.emerald300),
    };
  }
}

/// Port /hoc-tap: danh sách khóa học, bấm vào để mở khung xem nhanh ngay tại
/// chỗ (như web), từ đó mới sang màn chi tiết.
class HocTapScreen extends ConsumerStatefulWidget {
  const HocTapScreen({super.key});

  @override
  ConsumerState<HocTapScreen> createState() => _HocTapScreenState();
}

class _HocTapScreenState extends ConsumerState<HocTapScreen> {
  String? _expandedId;

  void _todo(String what) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('TODO: $what')));

  @override
  Widget build(BuildContext context) {
    final courses = ref.watch(coursesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Học tập')),
      floatingActionButton: FloatingActionButton.extended(
        // TODO: mở AddCourseModal (bước 2).
        onPressed: () => _todo('AddCourseModal'),
        icon: const Icon(Icons.add),
        label: const Text('Thêm khóa học'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: RefreshIndicator(
            onRefresh: () => ref.refresh(coursesProvider.future),
            child: courses.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _Message(
                e is DioException
                    ? 'Không tải được khóa học (${e.response?.statusCode ?? e.type.name}).'
                    : 'Không tải được khóa học.',
              ),
              data: (items) => items.isEmpty
                  ? const _Message('Chưa có khóa học nào — bấm "Thêm khóa học" để bắt đầu theo dõi việc học.')
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96), // chừa chỗ cho FAB
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final c = items[i];
                        return _CourseCard(
                          course: c,
                          expanded: _expandedId == c.id,
                          onTap: () => setState(() => _expandedId = _expandedId == c.id ? null : c.id),
                          // TODO: điều hướng màn chi tiết khóa học (bước 2).
                          onOpenDetail: () => _todo('chi tiết ${c.name}'),
                        );
                      },
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.course, required this.expanded, required this.onTap, required this.onOpenDetail});

  final Course course;
  final bool expanded;
  final VoidCallback onTap;
  final VoidCallback onOpenDetail;

  @override
  Widget build(BuildContext context) {
    final c = course;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: ScrollCard(
        glow: expanded ? ScrollCardGlow.kincha : ScrollCardGlow.yugen,
        child: AnimatedSize(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.topCenter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                spacing: 8,
                children: [
                  Expanded(
                    child: Text(c.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  ),
                  CourseStatusTag(c.status),
                ],
              ),
              const SizedBox(height: 4),
              Text('${c.sourceAndField ?? '—'} · ${c.lessonCount} bài học', style: _muted(11)),
              if (expanded) ...[
                const SizedBox(height: 12),
                Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
                const SizedBox(height: 12),
                _QuickView(course: c),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(onPressed: onOpenDetail, child: const Text('Xem chi tiết →')),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Khung xem nhanh như web: tổng thời lượng, bài gần nhất, 3 bài gần nhất.
class _QuickView extends StatelessWidget {
  const _QuickView({required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    Widget stat(String label, String value) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: _muted(10)),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 4,
      children: [
        Row(
          spacing: 8,
          children: [
            stat('Tổng thời lượng', formatDuration(course.totalMinutes)),
            stat('Bài gần nhất', course.lastLessonTitle ?? '—'),
          ],
        ),
        if (course.lessons.isNotEmpty) ...[
          const SizedBox(height: 8),
          for (final l in course.lessons.take(3))
            Text('• ${l.title}', maxLines: 1, overflow: TextOverflow.ellipsis, style: _muted(11)),
        ] else
          Text('Chưa ghi bài học nào.', style: _muted(11)),
      ],
    );
  }
}

/// Trạng thái rỗng/lỗi — vẫn cuộn được để kéo xuống làm mới.
class _Message extends StatelessWidget {
  const _Message(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
          ),
        ),
      ],
    );
  }
}
