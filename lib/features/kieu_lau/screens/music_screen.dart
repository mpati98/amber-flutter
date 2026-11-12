import 'dart:async';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../../shared/theme/design_tokens.dart';
import '../../../shared/widgets/design_page.dart';
import '../../../shared/widgets/list_frame.dart';
import '../../../shared/widgets/overview_block.dart';
import '../../../shared/widgets/scroll_card.dart';
import '../models/music_track.dart';
import '../providers/music_player_provider.dart';
import '../widgets/music_track_form_sheet.dart';

class MusicScreen extends ConsumerStatefulWidget {
  const MusicScreen({super.key});

  @override
  ConsumerState<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends ConsumerState<MusicScreen> {
  bool _picking = false;
  String? _operationError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Lỗi tải đã được controller lưu (controller.error → dòng báo đỏ); nuốt ở đây để không thành lỗi không ai bắt.
      if (mounted) unawaited(ref.read(musicPlayerProvider).load().catchError((Object _) {}));
    });
  }

  Future<void> _pickAndUpload() async {
    if (_picking) return;
    setState(() {
      _picking = true;
      _operationError = null;
    });
    try {
      final selection = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: const ['mp3']);
      if (selection.isEmpty || !mounted) return;
      await ref.read(musicPlayerProvider).uploadFiles(selection);
    } on DioException catch (error) {
      if (mounted) {
        setState(() => _operationError = _errorMessage(error, 'Không tải được tệp lên.'));
      }
    } catch (error) {
      if (mounted) setState(() => _operationError = '$error');
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  Future<void> _editTrack(MusicTrack track) async {
    final result = await showMusicTrackForm(context, track);
    if (result == null || !mounted) return;
    try {
      await ref.read(musicPlayerProvider).renameTrack(track, title: result.title, artist: result.artist);
    } catch (error) {
      if (mounted) {
        setState(() => _operationError = _errorMessage(error, 'Không sửa được thông tin bài nhạc.'));
      }
    }
  }

  Future<void> _deleteTrack(MusicTrack track) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xoá bài nhạc?'),
        content: Text('Xoá "${track.title}" khỏi thư viện và xoá tệp đã tải lên?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Huỷ')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await ref.read(musicPlayerProvider).deleteTrack(track);
    } catch (error) {
      if (mounted) {
        setState(() => _operationError = _errorMessage(error, 'Không xoá được bài nhạc.'));
      }
    }
  }

  Future<void> _moveTrack(MusicTrack track, int offset) async {
    try {
      await ref.read(musicPlayerProvider).moveTrack(track, offset);
    } catch (error) {
      if (mounted) {
        setState(() => _operationError = _errorMessage(error, 'Không đổi được thứ tự bài nhạc.'));
      }
    }
  }

  String _errorMessage(Object error, String fallback) =>
      error is DioException ? '$fallback ${error.response?.statusCode ?? ''}'.trim() : '$fallback $error';

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(musicPlayerProvider);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final tracks = controller.tracks;
        final totalSeconds = tracks.fold<int>(0, (n, t) => n + (t.durationSeconds ?? 0));
        final current = controller.currentTrack;
        final error = _operationError ?? controller.playbackError ?? controller.error;
        final busy = _picking || controller.uploading;

        return DesignPage(
          title: 'Nhạc',
          backFallback: '/kieu-lau',
          onRefresh: controller.refreshTracks,
          overview: OverviewBlock(
            title: 'Thư viện nhạc',
            labelWidth: 90,
            rows: [
              OverviewRow.muted(
                label: 'Số bài',
                text: controller.loading && tracks.isEmpty
                    ? 'Đang tải…'
                    : '${tracks.length} bài · ${_formatDuration(Duration(seconds: totalSeconds))}',
              ),
              OverviewRow.muted(
                label: 'Đang phát',
                text: current == null
                    ? 'Chưa chọn bài'
                    : '${current.title}${current.artist == null ? '' : ' · ${current.artist}'}',
              ),
            ],
          ),
          content: (context, _) => ListFrame(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 10,
              children: [
                _NowPlayingCard(controller: controller),
                if (controller.uploading) ...[
                  Text('Đang tải ${controller.uploadingFile ?? ''}', style: DesignText.muted),
                  LinearProgressIndicator(
                    value: controller.uploadProgress,
                    color: DesignColors.gold,
                    backgroundColor: DesignColors.rowDivider,
                  ),
                ],
                if (error != null)
                  Text(
                    error,
                    key: const ValueKey('music-error'),
                    style: const TextStyle(color: DesignColors.danger),
                  ),
                const SizedBox(height: 4),
                Row(
                  spacing: 8,
                  children: [
                    Expanded(
                      child: Text(
                        'DANH SÁCH · ${tracks.length}',
                        style: const TextStyle(fontSize: 13, letterSpacing: 1, color: DesignColors.gold),
                      ),
                    ),
                    if (controller.loading)
                      const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: DesignColors.gold),
                      ),
                    Flexible(
                      child: DesignButton.outline(
                        key: const ValueKey('music-add'),
                        label: '+ Thêm MP3',
                        onPressed: busy ? null : _pickAndUpload,
                      ),
                    ),
                  ],
                ),
                if (controller.loading && tracks.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator(color: DesignColors.gold)),
                  )
                else if (tracks.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'Chưa có bài nhạc. Chọn một hoặc nhiều tệp MP3 để bắt đầu.',
                      textAlign: TextAlign.center,
                      style: DesignText.muted,
                    ),
                  )
                else
                  FrameRows(
                    children: [
                      for (var index = 0; index < tracks.length; index++)
                        _TrackTile(
                          key: ValueKey('track-${tracks[index].id}'),
                          track: tracks[index],
                          selected: current?.id == tracks[index].id,
                          canMoveUp: index > 0,
                          canMoveDown: index < tracks.length - 1,
                          onSelect: () => unawaited(controller.selectTrack(tracks[index])),
                          onEdit: () => _editTrack(tracks[index]),
                          onDelete: () => _deleteTrack(tracks[index]),
                          onMoveUp: () => _moveTrack(tracks[index], -1),
                          onMoveDown: () => _moveTrack(tracks[index], 1),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NowPlayingCard extends StatelessWidget {
  const _NowPlayingCard({required this.controller});

  final MusicPlayerController controller;

  @override
  Widget build(BuildContext context) {
    final track = controller.currentTrack;
    final player = controller.player;
    return ScrollCard(
      glow: ScrollCardGlow.kincha,
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          activeTrackColor: DesignColors.gold,
          inactiveTrackColor: DesignColors.rowDivider,
          thumbColor: DesignColors.gold,
          overlayColor: DesignColors.gold.withValues(alpha: 0.15),
        ),
        child: Column(
          children: [
            const GlyphCircle('樂', size: 64),
            const SizedBox(height: 8),
            Text(
              track?.title ?? 'Chưa chọn bài',
              key: const ValueKey('now-playing-title'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: DesignText.serif(fontSize: 18, fontWeight: FontWeight.w700, color: DesignColors.text),
            ),
            Text(track?.artist ?? ' ', maxLines: 1, overflow: TextOverflow.ellipsis, style: DesignText.muted),
            StreamBuilder<Duration?>(
              stream: player.durationStream,
              initialData: player.duration,
              builder: (context, durationSnapshot) {
                final duration = durationSnapshot.data ?? Duration.zero;
                return StreamBuilder<Duration>(
                  stream: player.positionStream,
                  initialData: Duration.zero,
                  builder: (context, positionSnapshot) {
                    final position = positionSnapshot.data ?? Duration.zero;
                    final max = duration.inMilliseconds;
                    final value = position.inMilliseconds.clamp(0, max);
                    return Column(
                      children: [
                        Slider(
                          min: 0,
                          max: max > 0 ? max.toDouble() : 1,
                          value: value.toDouble(),
                          onChanged: track == null || max == 0
                              ? null
                              : (milliseconds) =>
                                    unawaited(controller.seek(Duration(milliseconds: milliseconds.round()))),
                        ),
                        Row(
                          spacing: 8,
                          children: [
                            // Mỗi mốc chiếm tối đa nửa hàng, thu nhỏ khi chữ phóng to thay vì tràn.
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(_formatDuration(position), style: DesignText.muted),
                              ),
                            ),
                            const Spacer(),
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(_formatDuration(duration), style: DesignText.muted),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 4),
            // 5 nút điều khiển: khung hẹp / chữ phóng to thì thu nhỏ cả hàng thay vì tràn.
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: controller.shuffleEnabled ? 'Tắt phát ngẫu nhiên' : 'Bật phát ngẫu nhiên',
                    color: controller.shuffleEnabled ? DesignColors.gold : DesignColors.muted,
                    onPressed: track == null ? null : () => unawaited(controller.toggleShuffle()),
                    icon: const Icon(Icons.shuffle),
                  ),
                  IconButton(
                    tooltip: 'Bài trước',
                    onPressed: track == null ? null : () => unawaited(controller.previous()),
                    icon: const Icon(Icons.skip_previous),
                    color: DesignColors.text,
                    iconSize: 34,
                  ),
                  StreamBuilder<PlayerState>(
                    stream: player.playerStateStream,
                    initialData: player.playerState,
                    builder: (context, snapshot) {
                      final state = snapshot.data;
                      final playing = state?.playing ?? false;
                      final busy =
                          state?.processingState == ProcessingState.loading ||
                          state?.processingState == ProcessingState.buffering;
                      return IconButton.filled(
                        tooltip: playing ? 'Tạm dừng' : 'Phát',
                        iconSize: 36,
                        style: IconButton.styleFrom(
                          backgroundColor: DesignColors.gold,
                          foregroundColor: const Color(0xFF1A1A1A),
                          disabledBackgroundColor: DesignColors.gold.withValues(alpha: 0.35),
                        ),
                        onPressed: track == null || busy
                            ? null
                            : () => unawaited(playing ? controller.pause() : controller.play()),
                        icon: busy
                            ? const SizedBox.square(dimension: 28, child: CircularProgressIndicator(strokeWidth: 2))
                            : Icon(playing ? Icons.pause : Icons.play_arrow),
                      );
                    },
                  ),
                  IconButton(
                    tooltip: 'Bài tiếp theo',
                    onPressed: track == null ? null : () => unawaited(controller.next()),
                    icon: const Icon(Icons.skip_next),
                    color: DesignColors.text,
                    iconSize: 34,
                  ),
                  IconButton(
                    tooltip: 'Lặp ${_repeatLabel(controller.repeatMode)}',
                    color: controller.repeatMode == MusicRepeatMode.off ? DesignColors.muted : DesignColors.gold,
                    onPressed: track == null ? null : () => unawaited(controller.cycleRepeatMode()),
                    icon: Icon(controller.repeatMode == MusicRepeatMode.one ? Icons.repeat_one : Icons.repeat),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrackTile extends StatelessWidget {
  const _TrackTile({
    super.key,
    required this.track,
    required this.selected,
    required this.canMoveUp,
    required this.canMoveDown,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
    required this.onMoveUp,
    required this.onMoveDown,
  });

  final MusicTrack track;
  final bool selected;
  final bool canMoveUp;
  final bool canMoveDown;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;

  @override
  Widget build(BuildContext context) => FrameTile(
    onTap: onSelect,
    semanticLabel: track.title,
    borderColor: selected ? DesignColors.gold : null,
    padding: const EdgeInsets.fromLTRB(10, 6, 2, 6),
    child: Row(
      spacing: 10,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: selected ? DesignColors.gold : null,
            border: Border.all(color: DesignColors.gold),
          ),
          child: Icon(
            selected ? Icons.graphic_eq : Icons.music_note,
            size: 18,
            color: selected ? const Color(0xFF1A1A1A) : DesignColors.gold,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(track.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: DesignText.bold),
              Text(
                '${track.artist ?? 'Chưa rõ nghệ sĩ'} · ${track.durationSeconds == null ? '—:—' : _formatDuration(Duration(seconds: track.durationSeconds!))}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: DesignText.muted,
              ),
            ],
          ),
        ),
        PopupMenuButton<String>(
          tooltip: 'Thao tác bài nhạc',
          color: DesignColors.panel,
          icon: const Icon(Icons.more_vert, color: DesignColors.muted),
          onSelected: (value) {
            switch (value) {
              case 'up':
                onMoveUp();
              case 'down':
                onMoveDown();
              case 'edit':
                onEdit();
              case 'delete':
                onDelete();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(value: 'up', enabled: canMoveUp, child: const Text('Đưa lên')),
            PopupMenuItem(value: 'down', enabled: canMoveDown, child: const Text('Đưa xuống')),
            const PopupMenuItem(value: 'edit', child: Text('Sửa tên / nghệ sĩ')),
            const PopupMenuItem(value: 'delete', child: Text('Xoá')),
          ],
        ),
      ],
    ),
  );
}

String _repeatLabel(MusicRepeatMode mode) => switch (mode) {
  MusicRepeatMode.off => 'tắt',
  MusicRepeatMode.all => 'tất cả',
  MusicRepeatMode.one => 'một bài',
};

String _formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
}
