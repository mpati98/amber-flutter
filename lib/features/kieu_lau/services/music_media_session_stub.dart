import 'music_media_session_types.dart';

MusicMediaSession createMusicMediaSession() => _NoopMusicMediaSession();

class _NoopMusicMediaSession implements MusicMediaSession {
  @override
  void clearActionHandlers() {}

  @override
  void setActionHandlers({
    required MediaSessionAction onPlay,
    required MediaSessionAction onPause,
    required MediaSessionAction onPreviousTrack,
    required MediaSessionAction onNextTrack,
    required MediaSessionSeekAction onSeekTo,
    required MediaSessionSeekAction onSeekBackward,
    required MediaSessionSeekAction onSeekForward,
  }) {}

  @override
  void setMetadata({required String? title, required String? artist}) {}

  @override
  void setPlaybackState(MusicMediaPlaybackState state) {}

  @override
  void setPositionState(MusicMediaPositionState? state) {}
}
