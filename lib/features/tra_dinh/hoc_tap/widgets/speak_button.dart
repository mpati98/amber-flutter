import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/speech_service.dart';

/// Nút loa đọc [text] bằng tiếng Anh khi chạm. [small] = nút nhỏ hơn cho câu ví dụ. Rời màn hình thì dừng đọc.
class SpeakButton extends ConsumerStatefulWidget {
  const SpeakButton({super.key, required this.text, this.small = false});

  final String text;
  final bool small;

  @override
  ConsumerState<SpeakButton> createState() => _SpeakButtonState();
}

class _SpeakButtonState extends ConsumerState<SpeakButton> {
  late final SpeechService _speech = ref.read(speechServiceProvider);

  @override
  void initState() {
    super.initState();
    _speech.warmUp();
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IconButton(
    icon: Icon(Icons.volume_up_outlined, size: widget.small ? 18 : 24),
    tooltip: 'Đọc to',
    style: widget.small ? IconButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap) : null,
    constraints: BoxConstraints.tightFor(width: widget.small ? 40 : 48, height: widget.small ? 40 : 48),
    onPressed: () => _speech.speak(widget.text),
  );
}
