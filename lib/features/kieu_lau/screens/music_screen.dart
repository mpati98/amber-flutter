import 'dart:async';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/app_bar_back.dart';
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
      if (mounted) unawaited(ref.read(musicPlayerProvider).load());
    });
  }

  Future<void> _pickAndUpload() async {
    if (_picking) return;
    setState(() {
      _picking = true;
      _operationError = null;
    });
    try {
      final selection = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['mp3'],
      );
      if (selection.isEmpty || !mounted) return;
      await ref.read(musicPlayerProvider).uploadFiles(selection);
    } on DioException catch (error) {
      if (mounted) {
        setState(
          () =>
              _operationError = _errorMessage(error, 'Không tải được tệp lên.'),
        );
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
      await ref
          .read(musicPlayerProvider)
          .renameTrack(track, title: result.title, artist: result.artist);
    } catch (error) {
      if (mounted) {
        setState(
          () => _operationError = _errorMessage(
            error,
            'Không sửa được thông tin bài nhạc.',
          ),
        );
      }
    }
  }

  Future<void> _deleteTrack(MusicTrack track) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xoá bài nhạc?'),
        content: Text(
          'Xoá "${track.title}" khỏi thư viện và xoá tệp đã tải lên?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Huỷ'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
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
        setState(
          () => _operationError = _errorMessage(
            error,
            'Không xoá được bài nhạc.',
          ),
        );
      }
    }
  }

  Future<void> _moveTrack(MusicTrack track, int offset) async {
    try {
      await ref.read(musicPlayerProvider).moveTrack(track, offset);
    } catch (error) {
      if (mounted) {
        setState(
          () => _operationError = _errorMessage(
            error,
            'Không đổi được thứ tự bài nhạc.',
          ),
        );
      }
    }
  }

  String _errorMessage(Object error, String fallback) => error is DioException
      ? '$fallback ${error.response?.statusCode ?? ''}'.trim()
      : '$fallback $error';

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(musicPlayerProvider);
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        leading: const AppBarBack(fallback: '/kieu-lau'),
        title: const Text('Nhạc của tôi'),
        actions: [
          IconButton(
            tooltip: 'Thêm MP3',
            onPressed: _picking || controller.uploading ? null : _pickAndUpload,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) => RefreshIndicator(
          onRefresh: controller.refreshTracks,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _NowPlayingCard(controller: controller),
              if (controller.uploading) ...[
                const SizedBox(height: 12),
                Text('Đang tải ${controller.uploadingFile ?? ''}'),
                const SizedBox(height: 6),
                LinearProgressIndicator(value: controller.uploadProgress),
              ],
              if (_operationError != null ||
                  controller.error != null ||
                  controller.playbackError != null) ...[
                const SizedBox(height: 12),
                Text(
                  _operationError ??
                      controller.playbackError ??
                      controller.error!,
                  style: TextStyle(color: colors.error),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Danh sách · ${controller.tracks.length}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  if (controller.loading)
                    const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  TextButton.icon(
                    onPressed: _picking || controller.uploading
                        ? null
                        : _pickAndUpload,
                    icon: const Icon(Icons.library_add),
                    label: const Text('Thêm MP3'),
                  ),
                ],
              ),
              if (controller.loading && controller.tracks.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (controller.tracks.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Text(
                    'Chưa có bài nhạc. Chọn một hoặc nhiều tệp MP3 để bắt đầu.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Theme.of(context).textMuted),
                  ),
                )
              else
                for (var index = 0; index < controller.tracks.length; index++)
                  _TrackTile(
                    track: controller.tracks[index],
                    selected:
                        controller.currentTrack?.id ==
                        controller.tracks[index].id,
                    canMoveUp: index > 0,
                    canMoveDown: index < controller.tracks.length - 1,
                    onSelect: () => unawaited(
                      controller.selectTrack(controller.tracks[index]),
                    ),
                    onEdit: () => _editTrack(controller.tracks[index]),
                    onDelete: () => _deleteTrack(controller.tracks[index]),
                    onMoveUp: () => _moveTrack(controller.tracks[index], -1),
                    onMoveDown: () => _moveTrack(controller.tracks[index], 1),
                  ),
            ],
          ),
        ),
      ),
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
    final colors = Theme.of(context).colorScheme;
    return Card(
      color: colors.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
        child: Column(
          children: [
            Icon(Icons.album, size: 76, color: colors.primary),
            const SizedBox(height: 8),
            Text(
              track?.title ?? 'Chưa chọn bài',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              track?.artist ?? ' ',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Theme.of(context).textMuted),
            ),
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
                              : (milliseconds) => unawaited(
                                  controller.seek(
                                    Duration(
                                      milliseconds: milliseconds.round(),
                                    ),
                                  ),
                                ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_formatDuration(position)),
                            Text(_formatDuration(duration)),
                          ],
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  tooltip: controller.shuffleEnabled
                      ? 'Tắt phát ngẫu nhiên'
                      : 'Bật phát ngẫu nhiên',
                  color: controller.shuffleEnabled ? colors.primary : null,
                  onPressed: track == null
                      ? null
                      : () => unawaited(controller.toggleShuffle()),
                  icon: const Icon(Icons.shuffle),
                ),
                IconButton(
                  tooltip: 'Bài trước',
                  onPressed: track == null
                      ? null
                      : () => unawaited(controller.previous()),
                  icon: const Icon(Icons.skip_previous),
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
                      onPressed: track == null || busy
                          ? null
                          : () => unawaited(
                              playing ? controller.pause() : controller.play(),
                            ),
                      icon: busy
                          ? const SizedBox.square(
                              dimension: 28,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(playing ? Icons.pause : Icons.play_arrow),
                    );
                  },
                ),
                IconButton(
                  tooltip: 'Bài tiếp theo',
                  onPressed: track == null
                      ? null
                      : () => unawaited(controller.next()),
                  icon: const Icon(Icons.skip_next),
                  iconSize: 34,
                ),
                IconButton(
                  tooltip: 'Lặp ${_repeatLabel(controller.repeatMode)}',
                  color: controller.repeatMode == MusicRepeatMode.off
                      ? null
                      : colors.primary,
                  onPressed: track == null
                      ? null
                      : () => unawaited(controller.cycleRepeatMode()),
                  icon: Icon(
                    controller.repeatMode == MusicRepeatMode.one
                        ? Icons.repeat_one
                        : Icons.repeat,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TrackTile extends StatelessWidget {
  const _TrackTile({
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
  Widget build(BuildContext context) => Card(
    color: selected ? AppColors.ink800 : null,
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: selected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Icon(
          selected ? Icons.graphic_eq : Icons.music_note,
          color: selected ? Theme.of(context).colorScheme.onPrimary : null,
        ),
      ),
      title: Text(track.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '${track.artist ?? 'Chưa rõ nghệ sĩ'} · ${track.durationSeconds == null ? '—:—' : _formatDuration(Duration(seconds: track.durationSeconds!))}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: onSelect,
      trailing: PopupMenuButton<String>(
        tooltip: 'Thao tác bài nhạc',
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
          PopupMenuItem(
            value: 'up',
            enabled: canMoveUp,
            child: const Text('Đưa lên'),
          ),
          PopupMenuItem(
            value: 'down',
            enabled: canMoveDown,
            child: const Text('Đưa xuống'),
          ),
          const PopupMenuItem(value: 'edit', child: Text('Sửa tên / nghệ sĩ')),
          const PopupMenuItem(value: 'delete', child: Text('Xoá')),
        ],
      ),
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
