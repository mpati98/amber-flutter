// ignore_for_file: experimental_member_use

import 'dart:async';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../models/music_track.dart';
import '../services/music_api.dart';
import '../services/music_media_session.dart';
import '../utils/mp3_metadata.dart';

enum MusicRepeatMode { off, all, one }

class MusicPlayerController extends ChangeNotifier {
  MusicPlayerController(this._api) {
    _subscriptions.add(
      _player.playerStateStream.listen((_) {
        if (!_disposed) {
          _syncMediaSession();
          notifyListeners();
        }
      }),
    );
    _subscriptions.add(
      _player.currentIndexStream.listen((_) {
        if (!_disposed) {
          _syncMediaSession();
          notifyListeners();
        }
      }),
    );
    _subscriptions.add(
      _player.errorStream.listen((error) {
        if (_disposed) return;
        _playbackError = error.message ?? 'Không phát được tệp MP3.';
        notifyListeners();
        unawaited(_recoverStream());
      }),
    );
    _mediaSession.setActionHandlers(
      onPlay: _handleMediaPlay,
      onPause: pause,
      onPreviousTrack: previous,
      onNextTrack: next,
      onSeekTo: _handleMediaSeekTo,
      onSeekBackward: _handleMediaSeekBackward,
      onSeekForward: _handleMediaSeekForward,
    );
    _syncMediaSession();
    _positionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (currentTrack != null) _syncMediaSession();
    });
    _renewalTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (_urlsFetchedAt != null &&
          DateTime.now().difference(_urlsFetchedAt!) >=
              const Duration(minutes: 50)) {
        unawaited(
          refreshTracks(preservePlayback: true).catchError((Object _) {}),
        );
      }
    });
  }

  final MusicApi _api;
  final AudioPlayer _player = AudioPlayer();
  final MusicMediaSession _mediaSession = createMusicMediaSession();
  final Random _random = Random();
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  Timer? _positionTimer;
  Timer? _renewalTimer;
  Future<void>? _refreshing;
  DateTime? _urlsFetchedAt;
  DateTime? _lastRecoveryAt;
  bool _disposed = false;
  bool _loaded = false;
  bool _loading = false;
  bool _uploading = false;
  bool _shuffleEnabled = false;
  bool _recovering = false;
  bool _mediaMetadataInitialized = false;
  String? _mediaTitle;
  String? _mediaArtist;
  MusicMediaPlaybackState? _mediaPlaybackState;
  double _uploadProgress = 0;
  String? _uploadingFile;
  String? _error;
  String? _playbackError;
  List<MusicTrack> _tracks = [];
  List<MusicTrack> _queue = [];
  MusicRepeatMode _repeatMode = MusicRepeatMode.off;

  AudioPlayer get player => _player;
  List<MusicTrack> get tracks => List.unmodifiable(_tracks);
  bool get loading => _loading;
  bool get uploading => _uploading;
  double get uploadProgress => _uploadProgress;
  String? get uploadingFile => _uploadingFile;
  String? get error => _error;
  String? get playbackError => _playbackError;
  bool get shuffleEnabled => _shuffleEnabled;
  MusicRepeatMode get repeatMode => _repeatMode;
  int? get currentIndex => _player.currentIndex;
  MusicTrack? get currentTrack {
    final index = currentIndex;
    return index == null || index < 0 || index >= _queue.length
        ? null
        : _queue[index];
  }

  Future<void> load() async {
    if (_loaded || _loading) return;
    await refreshTracks();
  }

  Future<void> refreshTracks({bool preservePlayback = true}) {
    if (_refreshing != null) return _refreshing!;
    final future = _fetchAndSetTracks(preservePlayback: preservePlayback);
    _refreshing = future.whenComplete(() => _refreshing = null);
    return _refreshing!;
  }

  Future<void> _fetchAndSetTracks({required bool preservePlayback}) async {
    final wasPlaying = preservePlayback && _player.playing;
    final oldTrackId = preservePlayback ? currentTrack?.id : null;
    final oldPosition = preservePlayback ? _player.position : Duration.zero;
    _loading = !_loaded;
    _error = null;
    notifyListeners();
    try {
      _tracks = await _api.getTracks();
      _urlsFetchedAt = DateTime.now();
      _loaded = true;
      final oldIndex = oldTrackId == null
          ? -1
          : _tracks.indexWhere((track) => track.id == oldTrackId);
      final initialIndex = oldIndex >= 0
          ? oldIndex
          : (_tracks.isEmpty ? null : 0);
      _queue = _orderedQueue(
        initialIndex == null ? null : _tracks[initialIndex],
      );
      await _installPlaylist(
        selectedTrackId: initialIndex == null ? null : _tracks[initialIndex].id,
        initialPosition: oldIndex >= 0 ? oldPosition : Duration.zero,
        resumePlayback: wasPlaying && oldIndex >= 0,
      );
    } catch (error) {
      _error = 'Không tải được danh sách nhạc: $error';
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  List<MusicTrack> _orderedQueue(MusicTrack? selected) {
    if (!_shuffleEnabled || _tracks.length < 2) return List.of(_tracks);
    final remaining =
        _tracks.where((track) => track.id != selected?.id).toList()
          ..shuffle(_random);
    return [?selected, ...remaining];
  }

  Future<void> _installPlaylist({
    required String? selectedTrackId,
    required Duration initialPosition,
    required bool resumePlayback,
  }) async {
    if (_queue.isEmpty) {
      await _player.stop();
      return;
    }
    final selectedIndex = _queue.indexWhere(
      (track) => track.id == selectedTrackId,
    );
    await _player.setAudioSources(
      [for (final track in _queue) _audioSource(track)],
      initialIndex: selectedIndex < 0 ? 0 : selectedIndex,
      initialPosition: initialPosition,
    );
    await _player.setLoopMode(switch (_repeatMode) {
      MusicRepeatMode.off => LoopMode.off,
      MusicRepeatMode.all => LoopMode.all,
      MusicRepeatMode.one => LoopMode.one,
    });
    await _player.setShuffleModeEnabled(false);
    if (resumePlayback) unawaited(_player.play());
  }

  AudioSource _audioSource(MusicTrack track) {
    final streamUrl = track.streamUrl;
    if (streamUrl == null) {
      throw StateError('Track ${track.id} không có streamUrl từ GET /tracks.');
    }
    return AudioSource.uri(Uri.parse(streamUrl));
  }

  Future<void> selectTrack(MusicTrack track) async {
    final index = _queue.indexWhere((item) => item.id == track.id);
    if (index < 0) return;
    _playbackError = null;
    await _player.seek(Duration.zero, index: index);
    _syncMediaSession();
    notifyListeners();
  }

  /// Khi URL còn mới, player.play() được gọi ngay trong lượt xử lý thao tác chạm
  /// để trình duyệt iOS nhận đúng user activation.
  Future<void> play() {
    if (_urlsAreStale) return _refreshAndPlay();
    _playbackError = null;
    notifyListeners();
    return _player.play();
  }

  Future<void> pause() => _player.pause();

  Future<void> _handleMediaPlay() async {
    if (currentTrack != null) await play();
  }

  Future<void> _handleMediaSeekTo(Duration? position) async {
    if (currentTrack == null) return;
    final target = position ?? _player.position;
    await seek(_clampMediaPosition(target));
  }

  Future<void> _handleMediaSeekBackward(Duration? offset) async {
    if (currentTrack == null) return;
    final skip = offset == null || offset <= Duration.zero
        ? const Duration(seconds: 10)
        : offset;
    await seek(_clampMediaPosition(_player.position - skip));
  }

  Future<void> _handleMediaSeekForward(Duration? offset) async {
    if (currentTrack == null) return;
    final skip = offset == null || offset <= Duration.zero
        ? const Duration(seconds: 10)
        : offset;
    final duration = _player.duration;
    final target = _player.position + skip;
    await seek(duration == null ? target : _clampMediaPosition(target));
  }

  Duration _clampMediaPosition(Duration position) {
    if (position < Duration.zero) return Duration.zero;
    final duration = _player.duration;
    return duration != null && position > duration ? duration : position;
  }

  void _syncMediaSession() {
    if (_disposed) return;
    final track = currentTrack;
    final title = track?.title;
    final artist = track?.artist;
    if (!_mediaMetadataInitialized ||
        title != _mediaTitle ||
        artist != _mediaArtist) {
      _mediaMetadataInitialized = true;
      _mediaTitle = title;
      _mediaArtist = artist;
      _mediaSession.setMetadata(title: title, artist: artist);
    }
    final playbackState = musicMediaPlaybackState(
      hasTrack: track != null,
      isPlaying: _player.playing,
    );
    if (playbackState != _mediaPlaybackState) {
      _mediaPlaybackState = playbackState;
      _mediaSession.setPlaybackState(playbackState);
    }
    _mediaSession.setPositionState(
      musicMediaPositionState(
        duration: _player.duration,
        position: _player.position,
        playbackRate: _player.speed,
      ),
    );
  }

  bool get _urlsAreStale =>
      _urlsFetchedAt == null ||
      DateTime.now().difference(_urlsFetchedAt!) >= const Duration(minutes: 50);

  Future<void> _refreshAndPlay() async {
    final selectedId = currentTrack?.id;
    final position = _player.position;
    try {
      await refreshTracks(preservePlayback: false);
      if (selectedId != null) {
        final index = _tracks.indexWhere((track) => track.id == selectedId);
        if (index < 0) return;
        await selectTrack(_tracks[index]);
        await _player.seek(position);
      }
      await _player.play();
    } catch (error) {
      _playbackError = 'Không làm mới được đường dẫn phát nhạc: $error';
      notifyListeners();
    }
  }

  Future<void> next() async {
    if (_player.hasNext) {
      await _player.seekToNext();
    } else if (_repeatMode == MusicRepeatMode.all && _queue.isNotEmpty) {
      await _player.seek(Duration.zero, index: 0);
    }
    if (_queue.isNotEmpty) await _player.play();
  }

  Future<void> previous() async {
    if (_player.position > const Duration(seconds: 3)) {
      await _player.seek(Duration.zero);
      return;
    }
    if (_player.hasPrevious) {
      await _player.seekToPrevious();
    } else if (_repeatMode == MusicRepeatMode.all && _queue.isNotEmpty) {
      await _player.seek(Duration.zero, index: _queue.length - 1);
    }
  }

  Future<void> cycleRepeatMode() async {
    _repeatMode = MusicRepeatMode
        .values[(_repeatMode.index + 1) % MusicRepeatMode.values.length];
    await _player.setLoopMode(switch (_repeatMode) {
      MusicRepeatMode.off => LoopMode.off,
      MusicRepeatMode.all => LoopMode.all,
      MusicRepeatMode.one => LoopMode.one,
    });
    notifyListeners();
  }

  Future<void> toggleShuffle() async {
    final selected = currentTrack;
    final position = _player.position;
    final wasPlaying = _player.playing;
    _shuffleEnabled = !_shuffleEnabled;
    _queue = _orderedQueue(selected);
    await _installPlaylist(
      selectedTrackId: selected?.id,
      initialPosition: position,
      resumePlayback: wasPlaying,
    );
    notifyListeners();
  }

  Future<void> seek(Duration position) => _player.seek(position);

  Future<void> uploadFiles(List<PlatformFile> files) async {
    if (_uploading) return;
    final userId = await _api.currentUserId();
    _uploading = true;
    _error = null;
    notifyListeners();
    final failures = <String>[];
    try {
      for (final file in files) {
        _uploadingFile = file.name;
        _uploadProgress = 0;
        notifyListeners();
        try {
          if (file.extension?.toLowerCase() != 'mp3') {
            throw ArgumentError('Chỉ nhận tệp MP3.');
          }
          final size = await file.length();
          if (size == null || size == 0 || size > musicMaxFileBytes) {
            throw ArgumentError('Dung lượng phải nhỏ hơn hoặc bằng 50 MiB.');
          }
          final bytes = await file.readAsBytes();
          final duration = await _readDuration(bytes);
          final blob = await _api.uploadMp3(
            bytes: bytes,
            fileName: file.name,
            userId: userId,
            onProgress: (sent, total) {
              if (total > 0) {
                _uploadProgress = (sent / total).clamp(0, 1).toDouble();
                notifyListeners();
              }
            },
          );
          await _api.createTrack(
            title: mp3Title(bytes, file.name),
            artist: null,
            upload: blob,
            durationSeconds: duration?.inSeconds,
            sizeBytes: bytes.length,
          );
        } catch (error) {
          failures.add('${file.name}: $error');
        }
      }
      await refreshTracks(preservePlayback: true);
      if (failures.isNotEmpty) {
        _error = 'Một số tệp chưa thêm được:\n${failures.join('\n')}';
      }
    } finally {
      _uploading = false;
      _uploadingFile = null;
      _uploadProgress = 0;
      notifyListeners();
    }
  }

  Future<Duration?> _readDuration(Uint8List bytes) async {
    final temporaryPlayer = AudioPlayer();
    try {
      return await temporaryPlayer.setAudioSource(_MemoryMp3Source(bytes));
    } finally {
      await temporaryPlayer.dispose();
    }
  }

  Future<void> renameTrack(
    MusicTrack track, {
    required String title,
    required String? artist,
  }) async {
    await _api.updateTrack(track.id, title: title, artist: artist);
    await refreshTracks(preservePlayback: true);
  }

  Future<void> deleteTrack(MusicTrack track) async {
    await _api.deleteTrack(track.id);
    await refreshTracks(preservePlayback: true);
  }

  Future<void> moveTrack(MusicTrack track, int offset) async {
    final index = _tracks.indexWhere((item) => item.id == track.id);
    final target = index + offset;
    if (index < 0 || target < 0 || target >= _tracks.length) return;
    await _api.updateTrack(track.id, artist: track.artist, position: target);
    await refreshTracks(preservePlayback: true);
  }

  Future<void> _recoverStream() async {
    if (_recovering || _disposed) return;
    final now = DateTime.now();
    if (_lastRecoveryAt != null &&
        now.difference(_lastRecoveryAt!) < const Duration(seconds: 30)) {
      return;
    }
    _recovering = true;
    _lastRecoveryAt = now;
    final selectedId = currentTrack?.id;
    final position = _player.position;
    final wasPlaying = _player.playing;
    try {
      await refreshTracks(preservePlayback: false);
      if (selectedId != null &&
          _tracks.any((track) => track.id == selectedId)) {
        _queue = _orderedQueue(
          _tracks.firstWhere((track) => track.id == selectedId),
        );
        await _installPlaylist(
          selectedTrackId: selectedId,
          initialPosition: position,
          resumePlayback: wasPlaying,
        );
        _playbackError = null;
      }
    } catch (error) {
      _playbackError = 'Không làm mới được đường dẫn phát nhạc: $error';
    } finally {
      _recovering = false;
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _positionTimer?.cancel();
    _renewalTimer?.cancel();
    _mediaSession.clearActionHandlers();
    _mediaSession.setMetadata(title: null, artist: null);
    _mediaSession.setPlaybackState(MusicMediaPlaybackState.none);
    _mediaSession.setPositionState(null);
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    unawaited(_player.dispose());
    super.dispose();
  }
}

class _MemoryMp3Source extends StreamAudioSource {
  _MemoryMp3Source(this._bytes);

  final Uint8List _bytes;

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    final from = start ?? 0;
    final to = (end ?? _bytes.length).clamp(from, _bytes.length);
    return StreamAudioResponse(
      sourceLength: _bytes.length,
      contentLength: to - from,
      offset: from,
      stream: Stream.value(_bytes.sublist(from, to)),
      contentType: 'audio/mpeg',
    );
  }
}

final musicPlayerProvider = Provider<MusicPlayerController>((ref) {
  final controller = MusicPlayerController(ref.watch(musicApiProvider));
  ref.onDispose(controller.dispose);
  return controller;
});
