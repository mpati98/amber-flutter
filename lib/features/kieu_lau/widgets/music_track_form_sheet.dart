import 'package:material_ui/material_ui.dart';

import '../../../shared/widgets/form_bits.dart';
import '../models/music_track.dart';

Future<({String title, String? artist})?> showMusicTrackForm(
  BuildContext context,
  MusicTrack track,
) => showFinanceSheet<({String title, String? artist})>(
  context,
  MusicTrackFormSheet(track: track),
);

class MusicTrackFormSheet extends StatefulWidget {
  const MusicTrackFormSheet({super.key, required this.track});

  final MusicTrack track;

  @override
  State<MusicTrackFormSheet> createState() => _MusicTrackFormSheetState();
}

class _MusicTrackFormSheetState extends State<MusicTrackFormSheet> {
  late final TextEditingController _title;
  late final TextEditingController _artist;
  String? _error;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.track.title);
    _artist = TextEditingController(text: widget.track.artist ?? '');
  }

  @override
  void dispose() {
    _title.dispose();
    _artist.dispose();
    super.dispose();
  }

  void _save() {
    final title = _title.text.trim();
    if (title.isEmpty) {
      setState(() => _error = 'Nhập tên bài nhạc.');
      return;
    }
    Navigator.of(context).pop((
      title: title,
      artist: _artist.text.trim().isEmpty ? null : _artist.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) => FinanceSheetBody(
    title: 'Sửa thông tin bài nhạc',
    children: [
      TextField(
        controller: _title,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(labelText: 'Tên bài'),
      ),
      TextField(
        controller: _artist,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(
          labelText: 'Nghệ sĩ (không bắt buộc)',
        ),
      ),
      if (_error case final error?)
        Text(
          error,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      FilledButton(onPressed: _save, child: const Text('Lưu')),
    ],
  );
}
