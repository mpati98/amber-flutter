import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amber_flutter/main.dart';
import 'package:amber_flutter/shared/theme/app_theme.dart';

void main() {
  testWidgets('app dùng theme tối với nền ink-950', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: AmberApp()));

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    final context = tester.element(find.byType(Scaffold));
    expect(Theme.of(context).scaffoldBackgroundColor, AppColors.ink950);
    expect(scaffold.backgroundColor, isNull); // lấy từ theme, không hardcode
  });
}
