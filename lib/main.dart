import 'package:flutter/material.dart';

import 'shared/theme/app_theme.dart';
import 'shared/widgets/progress_bar.dart';
import 'shared/widgets/progress_ring.dart';
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
      // TODO: ví dụ tạm để xem ScrollCard/ProgressBar/ProgressRing, xóa khi có màn hình thật.
      home: const Scaffold(
        body: Padding(
          padding: EdgeInsets.all(24),
          child: ScrollCard(
            glow: ScrollCardGlow.kincha,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ProgressBar(value: 65, max: 100),
                SizedBox(height: 24),
                Center(child: ProgressRing(value: 3, max: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
