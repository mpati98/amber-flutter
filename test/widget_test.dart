import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amber_flutter/main.dart';
import 'package:amber_flutter/shared/theme/design_tokens.dart';

void main() {
  testWidgets('app dùng theme tối của bộ thiết kế mới: nền #070b18, vàng #f0d68a, chữ Gelasio', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: AmberApp()));

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    final context = tester.element(find.byType(Scaffold));
    final theme = Theme.of(context);
    expect(theme.scaffoldBackgroundColor, DesignColors.bgTop);
    expect(theme.colorScheme.primary, DesignColors.gold);
    expect(theme.textTheme.bodyMedium?.fontFamily, contains('Gelasio'));
    expect(scaffold.backgroundColor, isNull); // lấy từ theme, không hardcode
  });
}
