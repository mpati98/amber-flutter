typedef MediaSessionAction = Future<void> Function();
typedef MediaSessionSeekAction = Future<void> Function(Duration? value);

enum MusicMediaPlaybackState { none, paused, playing }

MusicMediaPlaybackState musicMediaPlaybackState({
  required bool hasTrack,
  required bool isPlaying,
}) {
  if (!hasTrack) return MusicMediaPlaybackState.none;
  return isPlaying
      ? MusicMediaPlaybackState.playing
      : MusicMediaPlaybackState.paused;
}

class MusicMediaPositionState {
  const MusicMediaPositionState({
    required this.duration,
    required this.position,
    required this.playbackRate,
  });

  final double duration;
  final double position;
  final double playbackRate;
}

MusicMediaPositionState? musicMediaPositionState({
  required Duration? duration,
  required Duration position,
  required double playbackRate,
}) {
  if (duration == null ||
      duration <= Duration.zero ||
      !playbackRate.isFinite ||
      playbackRate <= 0) {
    return null;
  }
  final durationSeconds =
      duration.inMicroseconds / Duration.microsecondsPerSecond;
  final positionSeconds =
      position.inMicroseconds.clamp(0, duration.inMicroseconds).toDouble() /
      Duration.microsecondsPerSecond;
  return MusicMediaPositionState(
    duration: durationSeconds,
    position: positionSeconds,
    playbackRate: playbackRate,
  );
}

abstract interface class MusicMediaSession {
  void setMetadata({required String? title, required String? artist});

  void setPlaybackState(MusicMediaPlaybackState state);

  void setPositionState(MusicMediaPositionState? state);

  void setActionHandlers({
    required MediaSessionAction onPlay,
    required MediaSessionAction onPause,
    required MediaSessionAction onPreviousTrack,
    required MediaSessionAction onNextTrack,
    required MediaSessionSeekAction onSeekTo,
    required MediaSessionSeekAction onSeekBackward,
    required MediaSessionSeekAction onSeekForward,
  });

  void clearActionHandlers();
}
