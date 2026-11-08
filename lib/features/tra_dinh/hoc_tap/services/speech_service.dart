import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Đọc to tiếng Anh. Mọi lỗi (không có giọng, trình duyệt chặn, nền tảng không hỗ trợ) bị nuốt: không báo lỗi, không làm gì.
abstract class SpeechService {
  /// Chuẩn bị giọng đọc sớm (không phát âm) để lúc chạm chỉ còn gọi speak.
  void warmUp();

  /// Dừng câu đang đọc (nếu có) rồi đọc [text]. Chỉ được gọi từ một lần chạm của người dùng (iOS Safari).
  Future<void> speak(String text);

  Future<void> stop();
}

/// Cài đặt bằng flutter_tts (web dùng speechSynthesis của trình duyệt): en-US, tốc độ 0.45.
class FlutterTtsSpeech implements SpeechService {
  FlutterTts? _tts;
  Future<void>? _ready;

  Future<void> _init() async {
    try {
      final tts = _tts = FlutterTts();
      await tts.setLanguage('en-US');
      await tts.setSpeechRate(0.45);
    } catch (_) {
      // Nền tảng không có TTS: speak sẽ không làm gì.
    }
  }

  @override
  void warmUp() => _ready ??= _init();

  @override
  Future<void> speak(String text) async {
    final t = text.trim();
    if (t.isEmpty) return;
    try {
      await (_ready ??= _init());
      final tts = _tts;
      if (tts == null) return;
      await tts.stop();
      await tts.speak(t);
    } catch (_) {}
  }

  @override
  Future<void> stop() async {
    try {
      await _tts?.stop();
    } catch (_) {}
  }
}

final speechServiceProvider = Provider<SpeechService>((ref) {
  final s = FlutterTtsSpeech();
  ref.onDispose(() => unawaited(s.stop()));
  return s;
});
