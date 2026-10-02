import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'shared/router/app_router.dart';
import 'shared/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: AmberApp()));
}

class AmberApp extends ConsumerWidget {
  const AmberApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Amber',
      debugShowCheckedModeBanner: false,
      // Theme tối là mặc định; AppTheme.lightTheme để sẵn cho login/register/settings.
      theme: AppTheme.darkTheme,
      // Màn đầu tiên do redirect quyết định theo token đã lưu (xem app_router.dart).
      routerConfig: ref.watch(routerProvider),
    );
  }
}
