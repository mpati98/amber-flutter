import 'package:flutter/material.dart';

import 'shared/theme/app_theme.dart';
import 'shared/widgets/scroll_card.dart';

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
      // TODO: ví dụ tạm để xem ScrollCard, xóa khi có màn hình thật.
      home: const Scaffold(
        body: Padding(
          padding: EdgeInsets.all(24),
          child: ScrollCard(glow: ScrollCardGlow.kincha, child: Text('Test')),
        ),
      ),
    );
  }
}
