import 'music_media_session_types.dart';
import 'music_media_session_stub.dart'
    if (dart.library.js_interop) 'music_media_session_web.dart'
    as platform;

export 'music_media_session_types.dart';

MusicMediaSession createMusicMediaSession() =>
    platform.createMusicMediaSession();
