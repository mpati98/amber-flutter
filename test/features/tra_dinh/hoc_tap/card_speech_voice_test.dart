import 'package:amber_flutter/features/tra_dinh/hoc_tap/services/speech_service.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/widgets/card_sheet.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'hoc_tap_test_support.dart';
import 'hoc_tap_widget_support.dart';

// Dòng "Giọng: ..." ở form thẻ, với danh sách giọng giả.

/// Giống FlutterTtsSpeech: đọc danh sách giọng thô → chọn giọng Anh → báo qua [voice].
class _FakeSpeech implements SpeechService {
  _FakeSpeech(this.rawVoices);

  final List<Object?> rawVoices;

  final _voice = ValueNotifier<SpeechVoice?>(null);

  @override
  ValueListenable<SpeechVoice?> get voice => _voice;

  @override
  void warmUp() => _voice.value = pickEnglishVoice(parseVoices(rawVoices));

  @override
  Future<void> speak(String text) async {}

  @override
  Future<void> stop() async {}
}

Finder _k(String key) => find.byKey(ValueKey(key));

Future<void> _openSheet(WidgetTester tester, List<Object?> voices) async {
  await pumpHocTap(
    tester,
    const Scaffold(body: CardSheet(subjectId: 's1')),
    api: FakeHocTapApi(),
    overrides: [speechServiceProvider.overrideWithValue(_FakeSpeech(voices))],
  );
}

void main() {
  testWidgets('có giọng Anh: "Giọng: <tên> (<locale>)" cạnh công tắc Normal / Slow', (tester) async {
    await _openSheet(tester, [
      {'name': 'Thomas', 'locale': 'fr-FR'},
      {'name': 'Samantha', 'locale': 'en-US'},
      {'name': 'Daniel', 'locale': 'en-GB'},
    ]);
    expect(tester.widget<Text>(_k('speech-voice')).data, 'Giọng: Samantha (en-US)');
    expect(_k('speech-speed'), findsOneWidget);
    expect(tester.getCenter(_k('speech-voice')).dy, closeTo(tester.getCenter(_k('speech-speed')).dy, 30), reason: 'cùng một hàng');
  });

  testWidgets('chưa có giọng Anh: "Giọng: mặc định"', (tester) async {
    await _openSheet(tester, [
      {'name': 'Linh', 'locale': 'vi-VN'},
    ]);
    expect(tester.widget<Text>(_k('speech-voice')).data, 'Giọng: mặc định');
  });

  test('describeVoices: sắp xếp, đủ tên và locale', () {
    expect(describeVoices(const [(name: 'b', locale: 'en-US'), (name: 'a', locale: 'vi-VN')]), 'a (vi-VN), b (en-US)');
  });
}
