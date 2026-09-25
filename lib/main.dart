import 'package:flutter/material.dart';

import 'shared/theme/app_theme.dart';

void main() {
  runApp(const AmberApp());
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
      home: const Scaffold(),
    );
  }
}
