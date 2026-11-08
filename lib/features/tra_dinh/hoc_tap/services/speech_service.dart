import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Tốc độ đọc gốc theo nền tảng (1.0 = bình thường trên web, 0.5 = bình thường trên iOS/Android). Sửa ở đây.
const webSpeechRate = 1.0;
const nativeSpeechRate = 0.5;

/// Chế độ "Slow" = 0.75 lần tốc độ gốc.
const slowSpeechFactor = 0.75;
const speechPitch = 1.0;
const speechVolume = 1.0;

/// Khoá lưu lựa chọn Normal / Slow (localStorage trên web).
const speechSlowPrefKey = 'tra_dinh.card_speech_slow';

double baseSpeechRate() => kIsWeb ? webSpeechRate : nativeSpeechRate;

/// Một giọng đọc: tên và locale như hệ thống báo (en-US hoặc en_US).
typedef SpeechVoice = ({String name, String locale});

String _loc(String l) => l.toLowerCase().replaceAll('_', '-');

/// Chọn giọng tiếng Anh theo thứ tự ưu tiên: en-US có "Premium"/"Enhanced" trong tên; rồi tên Ava, Evan, Samantha, Nathan
/// (theo thứ tự đó, chỉ en-US); rồi bất kỳ en-US; rồi bất kỳ en-*. Không có giọng Anh → null. Hàm thuần để test.
SpeechVoice? pickEnglishVoice(Iterable<SpeechVoice> voices) {
  final all = voices.toList();
  final us = all.where((v) => _loc(v.locale) == 'en-us').toList();
  for (final v in us) {
    final n = v.name.toLowerCase();
    if (n.contains('premium') || n.contains('enhanced')) return v;
  }
  for (final want in const ['ava', 'evan', 'samantha', 'nathan']) {
    for (final v in us) {
      if (v.name.toLowerCase().contains(want)) return v;
    }
  }
  if (us.isNotEmpty) return us.first;
  for (final v in all) {
    if (_loc(v.locale).startsWith('en-') || _loc(v.locale) == 'en') return v;
  }
  return null;
}

/// Đọc danh sách giọng thô của flutter_tts thành [SpeechVoice]; phần tử lạ bị bỏ.
List<SpeechVoice> parseVoices(Object? raw) => [
  for (final v in (raw as List? ?? const []))
    if (v is Map && v['name'] is String) (name: v['name'] as String, locale: '${v['locale'] ?? ''}'),
];

/// Một dòng "tên (locale)" cho mọi giọng, sắp xếp, để xem trình duyệt có những giọng nào.
String describeVoices(Iterable<SpeechVoice> voices) => (voices.map((v) => '${v.name} (${v.locale})').toList()..sort()).join(', ');

/// Dòng hiển thị giọng đang dùng ở form thẻ; chưa có giọng Anh → "mặc định".
String voiceLabel(SpeechVoice? v) => 'Giọng: ${v == null ? 'mặc định' : '${v.name} (${v.locale})'}';

/// Đọc to tiếng Anh. Mọi lỗi (không có giọng, trình duyệt chặn, nền tảng không hỗ trợ) bị nuốt: không báo lỗi, không làm gì.
abstract class SpeechService {
  /// Giọng đã chọn; null khi chưa có giọng tiếng Anh (dùng giọng mặc định).
  ValueListenable<SpeechVoice?> get voice;

  /// Chuẩn bị giọng đọc sớm (không phát âm) để lúc chạm chỉ còn gọi speak.
  void warmUp();

  /// Dừng câu đang đọc (nếu có) rồi đọc [text]. Chỉ được gọi từ một lần chạm của người dùng (iOS Safari).
  Future<void> speak(String text);

  Future<void> stop();
}

/// Cài đặt bằng flutter_tts (web dùng speechSynthesis của trình duyệt). [slow] cho biết đang ở chế độ Slow.
class FlutterTtsSpeech implements SpeechService {
  FlutterTtsSpeech({bool Function()? slow}) : _slow = slow ?? (() => false);

  final bool Function() _slow;
  FlutterTts? _tts;
  Future<void>? _ready;
  final _voiceNotifier = ValueNotifier<SpeechVoice?>(null);
  SpeechVoice? get _voice => _voiceNotifier.value; // giọng đã chọn, nhớ lại
  var _listed = false;

  @override
  ValueListenable<SpeechVoice?> get voice => _voiceNotifier;
  double? _appliedRate;

  Future<void> _init() async {
    try {
      final tts = _tts = FlutterTts();
      await tts.setLanguage('en-US');
      await tts.setPitch(speechPitch);
      await tts.setVolume(speechVolume);
      await _chooseVoice();
    } catch (_) {
      // Nền tảng không có TTS: speak sẽ không làm gì.
    }
  }

  /// Trình duyệt thường nạp danh sách giọng muộn: chưa có thì thử lại lần sau, có rồi mới nhớ.
  Future<void> _chooseVoice() async {
    final tts = _tts;
    if (tts == null || _voice != null) return;
    try {
      final raw = await tts.getVoices;
      final list = parseVoices(raw);
      if (list.isNotEmpty && !_listed) {
        _listed = true;
        debugPrint('TTS các giọng có sẵn (${list.length}): ${describeVoices(list)}');
      }
      final picked = pickEnglishVoice(list);
      if (picked == null) return;
      _voiceNotifier.value = picked;
      await tts.setVoice({'name': picked.name, 'locale': picked.locale});
      debugPrint('TTS giọng đã chọn: ${picked.name} (${picked.locale})');
    } catch (_) {}
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
      if (_voice == null) await _chooseVoice();
      final rate = baseSpeechRate() * (_slow() ? slowSpeechFactor : 1.0);
      if (rate != _appliedRate) {
        await tts.setSpeechRate(rate);
        _appliedRate = rate;
      }
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

/// Lựa chọn tốc độ Normal (false) / Slow (true), nhớ qua lần mở sau. Lỗi đọc/ghi bộ nhớ → giữ Normal.
class SpeechSlowNotifier extends Notifier<bool> {
  @override
  bool build() {
    unawaited(_load());
    return false;
  }

  Future<void> _load() async {
    try {
      final v = (await SharedPreferences.getInstance()).getBool(speechSlowPrefKey);
      if (v != null && ref.mounted) state = v;
    } catch (_) {}
  }

  Future<void> set(bool slow) async {
    state = slow;
    try {
      await (await SharedPreferences.getInstance()).setBool(speechSlowPrefKey, slow);
    } catch (_) {}
  }
}

final speechSlowProvider = NotifierProvider<SpeechSlowNotifier, bool>(SpeechSlowNotifier.new);

final speechServiceProvider = Provider<SpeechService>((ref) {
  final s = FlutterTtsSpeech(slow: () => ref.read(speechSlowProvider));
  ref.onDispose(() => unawaited(s.stop()));
  return s;
});
