import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../../shared/widgets/app_bar_back.dart';

const _demoMp3Url =
    'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';

/// Màn thử nghiệm tạm thời để kiểm tra phát MP3 trên web/iOS.
class MusicPlayerSpikeScreen extends StatefulWidget {
  const MusicPlayerSpikeScreen({super.key});

  @override
  State<MusicPlayerSpikeScreen> createState() => _MusicPlayerSpikeScreenState();
}

class _MusicPlayerSpikeScreenState extends State<MusicPlayerSpikeScreen> {
  final _player = AudioPlayer();
  bool _loading = true;
  String? _loadError;
  String? _playbackError;

  @override
  void initState() {
    super.initState();
    _loadTrack();
  }

  @override
  void dispose() {
    unawaited(_player.dispose());
    super.dispose();
  }

  Future<void> _loadTrack() async {
    setState(() {
      _loading = true;
      _loadError = null;
      _playbackError = null;
    });
    try {
      await _player.setUrl(_demoMp3Url);
    } catch (error) {
      if (mounted) {
        setState(() => _loadError = '$error');
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _togglePlayback() async {
    setState(() => _playbackError = null);
    try {
      if (_player.playing) {
        await _player.pause();
      } else {
        if (_player.processingState == ProcessingState.completed) {
          unawaited(_player.seek(Duration.zero));
        }
        // Gọi play ngay trong lượt xử lý thao tác chạm, không đợi tác vụ async nào khác.
        await _player.play();
      }
    } catch (error) {
      if (mounted) {
        setState(() => _playbackError = '$error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = !_loading && _loadError == null;

    return Scaffold(
      appBar: AppBar(
        leading: const AppBarBack(fallback: '/kieu-lau'),
        title: const Text('Trình phát MP3 (thử nghiệm)'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.library_music, size: 56),
                const SizedBox(height: 20),
                Text(
                  'SoundHelix Song 1',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  'MP3 mẫu công khai · phát chỉ bắt đầu sau khi chạm nút',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 28),
                StreamBuilder<Duration?>(
                  stream: _player.durationStream,
                  initialData: _player.duration,
                  builder: (context, durationSnapshot) {
                    final duration = durationSnapshot.data ?? Duration.zero;
                    final durationMs = duration.inMilliseconds;
                    return StreamBuilder<Duration>(
                      stream: _player.positionStream,
                      initialData: Duration.zero,
                      builder: (context, positionSnapshot) {
                        final position = positionSnapshot.data ?? Duration.zero;
                        final positionMs = position.inMilliseconds.clamp(
                          0,
                          durationMs,
                        );
                        return Column(
                          children: [
                            Slider(
                              min: 0,
                              max: durationMs > 0 ? durationMs.toDouble() : 1,
                              value: positionMs.toDouble(),
                              onChanged: enabled && durationMs > 0
                                  ? (value) => unawaited(
                                      _player.seek(
                                        Duration(milliseconds: value.round()),
                                      ),
                                    )
                                  : null,
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
                const SizedBox(height: 16),
                Center(
                  child: _loading
                      ? const CircularProgressIndicator()
                      : StreamBuilder<PlayerState>(
                          stream: _player.playerStateStream,
                          builder: (context, snapshot) {
                            final playing =
                                snapshot.data?.playing ?? _player.playing;
                            return IconButton.filled(
                              tooltip: playing ? 'Tạm dừng' : 'Phát',
                              iconSize: 36,
                              onPressed: enabled ? _togglePlayback : null,
                              icon: Icon(
                                playing ? Icons.pause : Icons.play_arrow,
                              ),
                            );
                          },
                        ),
                ),
                if (_loadError case final error?) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Không tải được MP3: $error',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  TextButton(
                    onPressed: _loadTrack,
                    child: const Text('Thử tải lại'),
                  ),
                ],
                if (_playbackError case final error?) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Không phát được MP3: $error',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);
  final mm = minutes.toString().padLeft(2, '0');
  final ss = seconds.toString().padLeft(2, '0');
  return hours > 0 ? '$hours:$mm:$ss' : '$mm:$ss';
}
