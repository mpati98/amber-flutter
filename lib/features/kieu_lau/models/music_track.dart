class MusicTrack {
  const MusicTrack({
    required this.id,
    required this.title,
    required this.artist,
    required this.blobUrl,
    required this.blobPathname,
    required this.durationSeconds,
    required this.sizeBytes,
    required this.position,
    this.streamUrl,
  });

  factory MusicTrack.fromJson(Map<String, dynamic> json) => MusicTrack(
    id: json['id'] as String,
    title: json['title'] as String,
    artist: json['artist'] as String?,
    blobUrl: json['blobUrl'] as String,
    blobPathname: json['blobPathname'] as String,
    durationSeconds: json['durationSeconds'] as int?,
    sizeBytes: json['sizeBytes'] as int,
    position: json['position'] as int,
    streamUrl: json['streamUrl'] as String?,
  );

  final String id;
  final String title;
  final String? artist;
  final String blobUrl;
  final String blobPathname;
  final int? durationSeconds;
  final int sizeBytes;
  final int position;
  final String? streamUrl;
}
