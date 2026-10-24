import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';

import '../../../shared/theme/app_theme.dart';
import '../providers/music_player_provider.dart';

class MusicMiniPlayer extends StatelessWidget {
  const MusicMiniPlayer({super.key, required this.controller});

  final MusicPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final track = controller.currentTrack;
        if (track == null) return const SizedBox.shrink();
        final colors = Theme.of(context).colorScheme;
        return Material(
          color: colors.surface,
          child: InkWell(
            onTap: () => context.push('/kieu-lau/nhac'),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
                child: Row(
                  children: [
                    Icon(Icons.music_note, color: colors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            track.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            track.artist ?? 'Bộ sưu tập của bạn',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Theme.of(context).textMuted),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Bài trước',
                      onPressed: controller.tracks.length < 2
                          ? null
                          : () => unawaited(controller.previous()),
                      icon: const Icon(Icons.skip_previous),
                    ),
                    StreamBuilder<PlayerState>(
                      stream: controller.player.playerStateStream,
                      initialData: controller.player.playerState,
                      builder: (context, snapshot) {
                        final playing = snapshot.data?.playing ?? false;
                        return IconButton.filledTonal(
                          tooltip: playing ? 'Tạm dừng' : 'Phát',
                          onPressed: () => unawaited(
                            playing ? controller.pause() : controller.play(),
                          ),
                          icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                        );
                      },
                    ),
                    IconButton(
                      tooltip: 'Bài tiếp theo',
                      onPressed: controller.tracks.length < 2
                          ? null
                          : () => unawaited(controller.next()),
                      icon: const Icon(Icons.skip_next),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
