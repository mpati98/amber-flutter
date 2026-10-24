import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

import 'music_media_session_types.dart';

MusicMediaSession createMusicMediaSession() => _WebMusicMediaSession();

class _WebMusicMediaSession implements MusicMediaSession {
  web.MediaSession? get _session {
    try {
      final navigator = web.window.navigator;
      if (!navigator.has('mediaSession')) return null;
      final value = navigator['mediaSession'];
      return value == null ? null : value as web.MediaSession;
    } catch (error) {
      debugPrint('Media Session API is unavailable: $error');
      return null;
    }
  }

  @override
  void setMetadata({required String? title, required String? artist}) {
    _guard('metadata', () {
      final session = _session;
      if (session == null) return;
      if (title == null || title.isEmpty) {
        session.metadata = null;
        return;
      }
      if (!globalContext.has('MediaMetadata')) return;
      session.metadata = web.MediaMetadata(
        web.MediaMetadataInit(
          title: title,
          artist: artist ?? '',
          album: 'Amber',
        ),
      );
    });
  }

  @override
  void setPlaybackState(MusicMediaPlaybackState state) {
    _guard('playbackState', () {
      _session?.playbackState = switch (state) {
        MusicMediaPlaybackState.none => 'none',
        MusicMediaPlaybackState.paused => 'paused',
        MusicMediaPlaybackState.playing => 'playing',
      };
    });
  }

  @override
  void setPositionState(MusicMediaPositionState? state) {
    _guard('positionState', () {
      final session = _session;
      if (session == null || !session.has('setPositionState')) return;
      if (state == null) {
        session.setPositionState();
        return;
      }
      session.setPositionState(
        web.MediaPositionState(
          duration: state.duration,
          position: state.position,
          playbackRate: state.playbackRate,
        ),
      );
    });
  }

  @override
  void setActionHandlers({
    required MediaSessionAction onPlay,
    required MediaSessionAction onPause,
    required MediaSessionAction onPreviousTrack,
    required MediaSessionAction onNextTrack,
    required MediaSessionSeekAction onSeekTo,
    required MediaSessionSeekAction onSeekBackward,
    required MediaSessionSeekAction onSeekForward,
  }) {
    _setHandler('play', (_) => _run(onPlay));
    _setHandler('pause', (_) => _run(onPause));
    _setHandler('previoustrack', (_) => _run(onPreviousTrack));
    _setHandler('nexttrack', (_) => _run(onNextTrack));
    _setHandler('seekto', (details) => _runSeek(onSeekTo, details, 'seekTime'));
    _setHandler(
      'seekbackward',
      (details) => _runSeek(onSeekBackward, details, 'seekOffset'),
    );
    _setHandler(
      'seekforward',
      (details) => _runSeek(onSeekForward, details, 'seekOffset'),
    );
  }

  @override
  void clearActionHandlers() {
    for (final action in [
      'play',
      'pause',
      'previoustrack',
      'nexttrack',
      'seekto',
      'seekbackward',
      'seekforward',
    ]) {
      _setHandler(action, null);
    }
  }

  void _setHandler(String action, void Function(JSAny?)? callback) {
    _guard('action handler $action', () {
      final session = _session;
      if (session == null || !session.has('setActionHandler')) return;
      session.setActionHandler(action, callback?.toJS);
    });
  }

  void _runSeek(
    MediaSessionSeekAction action,
    JSAny? details,
    String property,
  ) {
    Duration? value;
    try {
      if (details != null) {
        final raw = (details as JSObject)[property]?.dartify();
        if (raw is num && raw.isFinite) {
          value = Duration(microseconds: (raw * 1000000).round());
        }
      }
    } catch (error) {
      debugPrint('Could not read Media Session $property: $error');
    }
    _run(() => action(value));
  }

  void _run(Future<void> Function() action) {
    unawaited(
      action().catchError((Object error, StackTrace stackTrace) {
        debugPrint('Media Session action failed: $error\n$stackTrace');
      }),
    );
  }

  void _guard(String operation, void Function() action) {
    try {
      action();
    } catch (error) {
      debugPrint('Media Session $operation unavailable: $error');
    }
  }
}
