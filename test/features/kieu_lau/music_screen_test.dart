import 'package:amber_flutter/features/amber_brain/providers/brain_status_provider.dart';
import 'package:amber_flutter/features/kieu_lau/models/music_track.dart';
import 'package:amber_flutter/features/kieu_lau/screens/music_screen.dart';
import 'package:amber_flutter/features/kieu_lau/services/music_api.dart';
import 'package:amber_flutter/shared/theme/design_tokens.dart';
import 'package:amber_flutter/shared/widgets/list_frame.dart';
import 'package:amber_flutter/shared/widgets/overview_block.dart';
import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../amber_brain/fake_brain.dart';

MusicTrack _track(String id, String title, {String? artist, int? seconds}) => MusicTrack(
  id: id,
  title: title,
  artist: artist,
  blobUrl: 'https://blob/$id.mp3',
  blobPathname: '$id.mp3',
  durationSeconds: seconds,
  sizeBytes: 1000,
  position: 0,
  streamUrl: 'https://blob/$id.mp3?signed',
);

/// API nhạc giả: chỉ trả danh sách bài (không phát, không tải lên — trình phát thật cần plugin âm thanh).
class _FakeMusicApi extends MusicApi {
  _FakeMusicApi(this.tracks, {this.fail = false}) : super(Dio(), MemoryTokenStorage());

  final List<MusicTrack> tracks;
  final bool fail;

  @override
  Future<List<MusicTrack>> getTracks() async {
    if (fail) throw DioException(requestOptions: RequestOptions(path: '/api/music/tracks'));
    return tracks;
  }
}

Future<void> _pump(WidgetTester tester, MusicApi api, {Size size = const Size(390, 1600)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final router = GoRouter(
    initialLocation: '/kieu-lau/nhac',
    routes: [
      GoRoute(path: '/kieu-lau', builder: (_, _) => const Scaffold(body: Text('KIỀU LÂU'))),
      GoRoute(path: '/kieu-lau/nhac', builder: (_, _) => const MusicScreen()),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        brainStatusProvider.overrideWith(() => FixedBrainStatus()),
        musicApiProvider.overrideWithValue(api),
      ],
      child: MaterialApp.router(theme: ThemeData.dark(), routerConfig: router),
    ),
  );
  await _settle(tester);
}

/// Không dùng pumpAndSettle: sau khi tải danh sách, trình phát thật (không có plugin âm thanh trong test) ở trạng thái
/// "đang nạp" nên vòng xoay của nút Phát chạy mãi.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

final _tracks = [
  _track('a', 'Bài một', artist: 'Ca sĩ A', seconds: 200),
  _track('b', 'Bài hai', seconds: 100),
];

void main() {
  testWidgets('tổng quan: số bài + tổng thời lượng, chưa chọn bài; khung: trình phát, "+ Thêm MP3", mỗi bài một dòng', (tester) async {
    await _pump(tester, _FakeMusicApi(_tracks));
    expect(find.text('Nhạc'), findsOneWidget);
    expect(find.text('2 bài · 05:00'), findsOneWidget);
    // Dòng "Đang phát" của tổng quan khớp tên bài trên trình phát (controller có thể tự nạp bài đầu).
    final playing = tester.widget<Text>(find.byKey(const ValueKey('now-playing-title'))).data!;
    expect(find.textContaining(playing), findsWidgets);
    expect(find.text('DANH SÁCH · 2'), findsOneWidget);
    expect(find.byKey(const ValueKey('music-add')), findsOneWidget);
    expect(find.descendant(of: find.byType(ListFrame), matching: find.byKey(const ValueKey('track-a'))), findsOneWidget);
    expect(find.text('Ca sĩ A · 03:20'), findsOneWidget);
    expect(find.text('Chưa rõ nghệ sĩ · 01:40'), findsOneWidget);
    expect(find.byType(OverviewBlock), findsOneWidget);
  });

  testWidgets('menu một bài: Đưa lên khoá ở bài đầu, có Sửa và Xoá', (tester) async {
    await _pump(tester, _FakeMusicApi(_tracks));
    await tester.tap(find.descendant(of: find.byKey(const ValueKey('track-a')), matching: find.byTooltip('Thao tác bài nhạc')));
    await _settle(tester);
    expect(tester.widget<PopupMenuItem<String>>(find.widgetWithText(PopupMenuItem<String>, 'Đưa lên')).enabled, isFalse);
    expect(find.text('Đưa xuống'), findsOneWidget);
    expect(find.text('Sửa tên / nghệ sĩ'), findsOneWidget);
    expect(find.text('Xoá'), findsOneWidget);
  });

  testWidgets('thư viện trống → câu hướng dẫn', (tester) async {
    await _pump(tester, _FakeMusicApi(const []));
    expect(find.text('Chưa có bài nhạc. Chọn một hoặc nhiều tệp MP3 để bắt đầu.'), findsOneWidget);
    expect(find.text('0 bài · 00:00'), findsOneWidget);
  });

  testWidgets('lỗi tải danh sách → dòng lỗi đỏ', (tester) async {
    await _pump(tester, _FakeMusicApi(const [], fail: true));
    final error = tester.widget<Text>(find.byKey(const ValueKey('music-error')));
    expect(error.style?.color, DesignColors.danger);
  });

  testWidgets('← về Kiều Lâu', (tester) async {
    await _pump(tester, _FakeMusicApi(_tracks));
    await tester.tap(find.byKey(const ValueKey('design-top-bar-back')));
    await _settle(tester);
    expect(find.text('KIỀU LÂU'), findsOneWidget);
  });

  testWidgets('320 px, chữ ×2,0: không tràn', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _pump(tester, _FakeMusicApi(_tracks), size: const Size(320, 2400));
    expect(tester.takeException(), isNull);
  });
}
