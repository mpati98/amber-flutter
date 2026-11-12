import 'package:amber_flutter/shared/theme/design_tokens.dart';
import 'package:amber_flutter/shared/widgets/app_toast.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

/// Màn có một nút gọi [onTap] với context nằm dưới Scaffold.
Future<void> _pump(WidgetTester tester, void Function(BuildContext) onTap) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        body: Builder(builder: (c) => Center(child: TextButton(onPressed: () => onTap(c), child: const Text('mở')))),
      ),
    ),
  );
}

/// Bề rộng thân toast (SnackBar ngoài cùng luôn rộng bằng màn, thân là Material bên trong).
double _bodyWidth(WidgetTester tester) =>
    tester.getSize(find.descendant(of: find.byType(SnackBar), matching: find.byType(Material)).first).width;

Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.text('mở'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 750)); // xong hiệu ứng hiện
}

void main() {
  for (final type in ToastType.values) {
    testWidgets('${type.name}: nội dung + icon + viền đúng màu, nền panel, nổi', (tester) async {
      await _pump(tester, (c) => showToast(c, 'Nội dung ${type.name}', type: type));
      await _open(tester);
      expect(find.text('Nội dung ${type.name}'), findsOneWidget);
      final icon = tester.widget<Icon>(find.byIcon(type.icon));
      expect(icon.color, type.color);
      final bar = tester.widget<SnackBar>(find.byKey(ValueKey('toast-${type.name}')));
      expect(bar.backgroundColor, DesignColors.panel);
      expect(bar.behavior, SnackBarBehavior.floating);
      expect((bar.shape! as RoundedRectangleBorder).side.color, type.color.withValues(alpha: 0.55));
      expect(bar.duration, type.duration);
    });
  }

  test('lỗi hiện lâu nhất, đỏ đúng DESIGN.md', () {
    expect(ToastType.error.color, const Color(0xFFFF7B7B));
    for (final t in ToastType.values) {
      expect(ToastType.error.duration >= t.duration, isTrue, reason: t.name);
    }
  });

  testWidgets('mặc định là info; toast mới thay toast cũ', (tester) async {
    var n = 0;
    await _pump(tester, (c) => showToast(c, 'Lần ${++n}'));
    await _open(tester);
    expect(find.byKey(const ValueKey('toast-info')), findsOneWidget);
    await _open(tester);
    await tester.pumpAndSettle();
    expect(find.text('Lần 1'), findsNothing);
    expect(find.text('Lần 2'), findsOneWidget);
  });

  testWidgets('nút hành động: chữ màu theo loại, bấm gọi onAction', (tester) async {
    var retried = 0;
    await _pump(tester, (c) => showToast(c, 'Lưu thất bại', type: ToastType.error, actionLabel: 'Thử lại', onAction: () => retried++));
    await _open(tester);
    expect(tester.widget<SnackBarAction>(find.byType(SnackBarAction)).textColor, ToastType.error.color);
    await tester.tap(find.text('Thử lại'));
    await tester.pumpAndSettle();
    expect(retried, 1);
  });

  testWidgets('tự ẩn sau thời gian của loại; duration truyền vào ghi đè', (tester) async {
    await _pump(tester, (c) => showToast(c, 'Đã lưu', type: ToastType.success, duration: const Duration(seconds: 1)));
    await _open(tester);
    expect(find.text('Đã lưu'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Đã lưu'), findsNothing);
  });

  testWidgets('rộng tối đa 420 trên màn lớn; 320 px chữ ×2,0 câu dài có nút: không tràn', (tester) async {
    await _pump(tester, (c) => showToast(c, 'Ngắn'));
    await _open(tester);
    expect(_bodyWidth(tester), 420);

    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _pump(
      tester,
      (c) => showToast(c, 'Không kết nối được máy chủ (http://localhost:3000). Kiểm tra mạng rồi thử lại.', type: ToastType.warning, actionLabel: 'Thử lại'),
    );
    await _open(tester);
    expect(tester.takeException(), isNull);
    expect(_bodyWidth(tester), 320 - 32);
  });
}
