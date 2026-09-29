import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/auth/screens/login_screen.dart';
import 'shared/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: AmberApp()));
}

class AmberApp extends StatelessWidget {
  const AmberApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Amber',
      debugShowCheckedModeBanner: false,
      // Theme tối là mặc định; AppTheme.lightTheme để sẵn cho login/register/settings.
      theme: AppTheme.darkTheme,
      // TODO: tạm vào thẳng LoginScreen, thay bằng router thật khi có nhiều màn hình.
      home: const LoginScreen(),
    );
  }
}
