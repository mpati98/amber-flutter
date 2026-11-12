import 'package:amber_flutter/features/amber_brain/models/brain_models.dart';
import 'package:amber_flutter/features/amber_brain/providers/brain_chat_provider.dart';
import 'package:amber_flutter/features/amber_brain/providers/brain_status_provider.dart';
import 'package:amber_flutter/features/amber_brain/widgets/amber_chat_dock.dart';
import 'package:amber_flutter/shared/theme/app_theme.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_brain.dart';

const _online = BrainConnection(
  link: BrainLink.online,
  apiHost: 'localhost:3000',
  status: BrainStatus(serverEnv: 'DEV', serverHost: 'localhost:3000', ollama: 'up', model: 'm'),
);

/// Chat giả: trạng thái ban đầu cho trước, send() chỉ ghi lại câu và thêm vào danh sách.
class _FakeChat extends BrainChatNotifier {
  _FakeChat([this.initial = const BrainChatState()]);

  final BrainChatState initial;
  final sent = <String>[];

  @override
  BrainChatState build() => initial;

  @override
  Future<void> send(String text) async {
    sent.add(text);
    state = state.copyWith(entries: [...state.entries, TextEntry(text, isUser: true)]);
  }
}

Future<_FakeChat> _pump(
  WidgetTester tester, {
  BrainConnection brain = _online,
  BrainChatState chat = const BrainChatState(),
  Size size = const Size(1280, 800),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final fake = _FakeChat(chat);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        brainStatusProvider.overrideWith(() => FixedBrainStatus(brain)),
        brainChatProvider.overrideWith(() => fake),
      ],
      child: MaterialApp(
        theme: ThemeData.dark(),
        home: const Scaffold(body: AmberChatDock(child: Center(child: Text('NỘI DUNG')))),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return fake;
}

final _toggle = find.byKey(const ValueKey('amber-chat-toggle'));
final _panel = find.byKey(const ValueKey('amber-chat-panel'));

Future<void> _tap(WidgetTester tester, Finder f) async {
  await tester.tap(f);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('nút tròn góc phải dưới; khung đóng sẵn, bấm mở / bấm lại đóng, nội dung màn vẫn còn', (tester) async {
    await _pump(tester);
    final r = tester.getRect(_toggle);
    expect(r.size, const Size(52, 52));
    expect(r.right, 1280 - 20);
    expect(r.bottom, 800 - 20);
    expect(_panel, findsNothing);

    await _tap(tester, _toggle);
    expect(_panel, findsOneWidget);
    expect(find.text('NỘI DUNG'), findsOneWidget);
    await _tap(tester, _toggle);
    expect(_panel, findsNothing);
  });

  testWidgets('web rộng: khung 360 × 520, nằm trên nút, mép phải thẳng nút', (tester) async {
    await _pump(tester);
    await _tap(tester, _toggle);
    final panel = tester.getRect(_panel);
    expect(panel.size, const Size(360, 520));
    expect(panel.right, tester.getRect(_toggle).right);
    expect(panel.bottom, lessThan(tester.getRect(_toggle).top));
  });

  testWidgets('điện thoại: khung trải ngang lề 8, cao ≤ 70% màn; 320 px chữ ×2,0 không tràn', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _pump(tester, size: const Size(320, 640), chat: const BrainChatState(entries: [TextEntry('xin chào Amber, số dư Momo bao nhiêu?', isUser: true)]));
    await _tap(tester, _toggle);
    final panel = tester.getRect(_panel);
    expect(panel.left, 8);
    expect(panel.right, 320 - 8);
    expect(panel.height, lessThanOrEqualTo(640 * 0.7));
    expect(tester.takeException(), isNull);
  });

  testWidgets('nút X ở đầu khung và phím Esc đều đóng', (tester) async {
    await _pump(tester);
    await _tap(tester, _toggle);
    await _tap(tester, find.byKey(const ValueKey('amber-chat-close')));
    expect(_panel, findsNothing);

    await _tap(tester, _toggle);
    await tester.tap(find.byKey(const Key('brain-input'))); // focus vào trong khung
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(_panel, findsNothing);
  });

  testWidgets('gõ + Enter hoặc nút gửi → send; nút gửi tắt khi ô trống', (tester) async {
    final fake = await _pump(tester);
    await _tap(tester, _toggle);
    IconButton send() => tester.widget<IconButton>(find.byKey(const ValueKey('amber-chat-send')));
    expect(send().onPressed, isNull);

    await tester.enterText(find.byKey(const Key('brain-input')), '  số dư Momo ');
    await tester.pump();
    expect(send().onPressed, isNotNull);
    await _tap(tester, find.byKey(const ValueKey('amber-chat-send')));
    await tester.enterText(find.byKey(const Key('brain-input')), 'chi 45k ăn trưa');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pumpAndSettle();
    expect(fake.sent, ['số dư Momo', 'chi 45k ăn trưa']);
    expect(find.text('số dư Momo'), findsOneWidget);
  });

  testWidgets('đóng rồi mở lại vẫn giữ lịch sử', (tester) async {
    await _pump(tester);
    await _tap(tester, _toggle);
    await tester.enterText(find.byKey(const Key('brain-input')), 'hello');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pumpAndSettle();
    await _tap(tester, _toggle);
    await _tap(tester, _toggle);
    expect(find.text('hello'), findsOneWidget);
  });

  testWidgets('lịch sử trống → gợi ý; đang chờ → "Amber is replying...", ô nhập khoá', (tester) async {
    await _pump(tester);
    await _tap(tester, _toggle);
    expect(find.textContaining('Ask for a balance'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await _pump(tester, chat: const BrainChatState(entries: [TextEntry('hi', isUser: true)], busy: true));
    await tester.tap(_toggle);
    await tester.pump(const Duration(milliseconds: 300)); // spinner quay mãi, không pumpAndSettle
    expect(find.text('Amber is replying...'), findsOneWidget);
    expect(tester.widget<TextField>(find.byKey(const Key('brain-input'))).enabled, isFalse);
  });

  testWidgets('chấm trạng thái trên nút theo amber-brain; ngoại tuyến → cảnh báo + Retry, ô nhập khoá', (tester) async {
    Color dot() => ((tester.widget<Container>(find.byKey(const Key('amber-status-dot'))).decoration! as BoxDecoration).color)!;
    await _pump(tester);
    expect(dot(), AppColors.emerald400);
    await _tap(tester, _toggle);
    expect(find.byKey(const ValueKey('amber-chat-warning')), findsNothing);
    expect(find.text('DEV'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await _pump(tester, brain: const BrainConnection(link: BrainLink.offline, apiHost: 'localhost:3000'));
    expect(dot(), AppColors.shuiro500);
    await _tap(tester, _toggle);
    expect(find.text('Amber is offline'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    expect(tester.widget<TextField>(find.byKey(const Key('brain-input'))).enabled, isFalse);
  });

  testWidgets('lệch môi trường → cảnh báo khoá nhập, không có Retry', (tester) async {
    await _pump(
      tester,
      brain: const BrainConnection(
        link: BrainLink.online,
        apiHost: 'localhost:3000',
        status: BrainStatus(serverEnv: 'PROD', serverHost: 'amber.duangmai.io.vn', ollama: 'up', model: 'm'),
      ),
    );
    await _tap(tester, _toggle);
    expect(find.textContaining('Input is locked'), findsOneWidget);
    expect(find.text('Retry'), findsNothing);
  });
}
