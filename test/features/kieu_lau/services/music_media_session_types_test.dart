import 'package:amber_flutter/features/kieu_lau/services/music_media_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('musicMediaPlaybackState', () {
    test('returns none when there is no current track', () {
      expect(
        musicMediaPlaybackState(hasTrack: false, isPlaying: true),
        MusicMediaPlaybackState.none,
      );
      expect(
        musicMediaPlaybackState(hasTrack: false, isPlaying: false),
        MusicMediaPlaybackState.none,
      );
    });

    test('maps the current track and player state', () {
      expect(
        musicMediaPlaybackState(hasTrack: true, isPlaying: true),
        MusicMediaPlaybackState.playing,
      );
      expect(
        musicMediaPlaybackState(hasTrack: true, isPlaying: false),
        MusicMediaPlaybackState.paused,
      );
    });
  });

  group('musicMediaPositionState', () {
    test('returns null until duration is known', () {
      expect(
        musicMediaPositionState(
          duration: null,
          position: const Duration(seconds: 2),
          playbackRate: 1,
        ),
        isNull,
      );
    });

    test('uses seconds and clamps position within duration', () {
      final state = musicMediaPositionState(
        duration: const Duration(minutes: 2),
        position: const Duration(minutes: 3),
        playbackRate: 1.25,
      );
      expect(state, isNotNull);
      expect(
        (state!.duration, state.position, state.playbackRate),
        (120, 120, 1.25),
      );
    });

    test('rejects a playback rate unsupported by setPositionState', () {
      expect(
        musicMediaPositionState(
          duration: const Duration(seconds: 10),
          position: Duration.zero,
          playbackRate: 0,
        ),
        isNull,
      );
    });
  });

  test('the platform wrapper can be called without a browser', () {
    final bridge = createMusicMediaSession();
    bridge
      ..setMetadata(title: 'Song', artist: 'Artist')
      ..setPlaybackState(MusicMediaPlaybackState.playing)
      ..setPositionState(
        const MusicMediaPositionState(
          duration: 60,
          position: 10,
          playbackRate: 1,
        ),
      )
      ..setActionHandlers(
        onPlay: () async {},
        onPause: () async {},
        onPreviousTrack: () async {},
        onNextTrack: () async {},
        onSeekTo: (_) async {},
        onSeekBackward: (_) async {},
        onSeekForward: (_) async {},
      )
      ..clearActionHandlers();
  });
}
