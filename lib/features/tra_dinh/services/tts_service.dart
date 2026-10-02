// StreamAudioSource/StreamAudioResponse là API "experimental" của just_audio
// nhưng là cách chính thức duy nhất để phát từ bộ nhớ (không ghi file tạm).
// ignore_for_file: experimental_member_use

import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../../shared/services/api_client.dart';
import '../utils/wav_header.dart';

/// Đọc tin nhắn thành tiếng: POST /tra-dinh/speak → WAV (Groq TTS) → phát từ
/// bộ nhớ. Chỉ 1 AudioPlayer → phát tin mới tự thay tin cũ. Không cache —
/// mỗi lần phát gọi lại /speak, như web.
class TtsService {
  TtsService(this._dio, [AudioPlayer? player]) : _player = player ?? AudioPlayer();

  final Dio _dio;
  final AudioPlayer _player;

  /// Bytes WAV thô. 400 nếu text rỗng/quá 2000 ký tự, 502 nếu Groq lỗi.
  Future<Uint8List> fetchSpeech(String text) async {
    final res = await _dio.post<List<int>>(
      '/api/tra-dinh/speak',
      data: {'text': text},
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(res.data!);
  }

  /// Phát [wav] tới khi hết, bị [stop], hoặc lỗi (ném ra). Không bao giờ treo:
  /// lỗi giữa chừng từ stream sự kiện cũng làm Future kết thúc.
  Future<void> play(Uint8List wav) async {
    await _player.stop();
    await _player.setAudioSource(_BytesAudioSource(fixWavSizes(wav), 'audio/wav'));

    final done = Completer<void>();
    final sub = _player.playerStateStream.listen(
      (s) {
        // completed = phát hết; idle = đã stop (từ nút, tin khác, rời màn).
        if (s.processingState == ProcessingState.completed || s.processingState == ProcessingState.idle) {
          if (!done.isCompleted) done.complete();
        }
      },
      onError: (Object e, StackTrace st) {
        if (!done.isCompleted) done.completeError(e, st);
      },
    );
    try {
      unawaited(
        _player.play().catchError((Object e, StackTrace st) {
          if (!done.isCompleted) done.completeError(e, st);
        }),
      );
      await done.future;
    } finally {
      await sub.cancel();
      // Hết bài thì `playing` vẫn true (just_audio) — stop để về trạng thái sạch.
      if (_player.processingState == ProcessingState.completed) await _player.stop();
    }
  }

  Future<void> stop() => _player.stop();

  Future<void> dispose() => _player.dispose();
}

/// Phát thẳng từ bộ nhớ, không ghi file tạm. just_audio: web → data URL;
/// Android/iOS/macOS → proxy HTTP localhost của chính just_audio (cần cho phép
/// cleartext tới 127.0.0.1 — xem AndroidManifest/Info.plist).
class _BytesAudioSource extends StreamAudioSource {
  _BytesAudioSource(this._bytes, this._contentType);

  final Uint8List _bytes;
  final String _contentType;

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= _bytes.length;
    return StreamAudioResponse(
      sourceLength: _bytes.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(_bytes.sublist(start, end)),
      contentType: _contentType,
    );
  }
}

final ttsServiceProvider = Provider.autoDispose<TtsService>((ref) {
  final service = TtsService(ref.watch(apiClientProvider));
  ref.onDispose(service.dispose);
  return service;
});
