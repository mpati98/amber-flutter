import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Toàn bộ hex lấy nguyên văn từ amber-v3/src/app/globals.css (không làm tròn).
abstract final class AppColors {
  // Theme tối "Âm Dương Giới"
  static const ink950 = Color(0xFF05070F);
  static const ink900 = Color(0xFF0C1128);
  static const ink800 = Color(0xFF18204A);
  static const yugen500 = Color(0xFF8B7FF0);
  static const yugen300 = Color(0xFFC9C3F5);
  static const shuiro500 = Color(0xFFE0616F);
  static const kincha400 = Color(0xFFECCB8A);
  static const kincha200 = Color(0xFFF3E2C0);

  // Theme sáng "đất nung"
  static const bgLight = Color(0xFFFAF3E7);
  static const primary50 = Color(0xFFFBF3E9);
  static const primary100 = Color(0xFFF2DFC2);
  static const primary300 = Color(0xFFD9A441);
  static const primary500 = Color(0xFFA9713C);
  static const primary700 = Color(0xFF6B4226);
  static const primary900 = Color(0xFF2B211A);
  static const accent400 = Color(0xFFE07A5F);
  static const accent500 = Color(0xFFC9622B);
  static const accent700 = Color(0xFF9C4A1F);
  static const secondary300 = Color(0xFFF2D399);
  static const secondary500 = Color(0xFFD9A441);
  static const textPrimary = Color(0xFF1F1712);
  static const textSecondary = Color(0xFF8A7B6C);
}

abstract final class AppTheme {
  /// --radius: 0.625rem ≈ 10px (globals.css).
  static const double radius = 10;
  static final _shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));

  /// Theme tối — trang chủ + 4 tòa. Inter cho nội dung, Noto Serif cho
  /// display/headline (tương đương font-sans / font-serif-display bên web).
  static ThemeData get darkTheme {
    final base = ThemeData(brightness: Brightness.dark);
    final inter = GoogleFonts.interTextTheme(base.textTheme);
    final textTheme = inter.copyWith(
      displayLarge: GoogleFonts.notoSerif(textStyle: inter.displayLarge),
      displayMedium: GoogleFonts.notoSerif(textStyle: inter.displayMedium),
      displaySmall: GoogleFonts.notoSerif(textStyle: inter.displaySmall),
      headlineLarge: GoogleFonts.notoSerif(textStyle: inter.headlineLarge),
      headlineMedium: GoogleFonts.notoSerif(textStyle: inter.headlineMedium),
      headlineSmall: GoogleFonts.notoSerif(textStyle: inter.headlineSmall),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.ink950,
      cardColor: AppColors.ink900,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.kincha400,
        onPrimary: AppColors.ink950,
        secondary: AppColors.yugen500,
        onSecondary: AppColors.ink950,
        tertiary: AppColors.yugen300,
        error: AppColors.shuiro500,
        onError: AppColors.ink950,
        surface: AppColors.ink900,
        onSurface: Colors.white,
        surfaceContainerHighest: AppColors.ink800,
      ),
      textTheme: textTheme,
    );
  }

  /// Theme sáng "đất nung" — chỉ login / register / settings.
  /// Mapping theo :root của globals.css: --primary = primary-700,
  /// --background = bg-light, --secondary = secondary-300, --border = primary-100.
  static ThemeData get lightTheme {
    final base = ThemeData(brightness: Brightness.light);
    final textTheme = GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.bgLight,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary700,
        onPrimary: Color(0xFFFAFAFA), // oklch(0.985 0 0)
        secondary: AppColors.secondary300,
        onSecondary: AppColors.primary700,
        tertiary: AppColors.accent500,
        // --destructive oklch(0.577 0.245 27.325) ≈ Tailwind red-600.
        error: Color(0xFFE7000B),
        surface: AppColors.bgLight,
        onSurface: AppColors.textPrimary,
        onSurfaceVariant: AppColors.textSecondary,
        outline: AppColors.primary100,
        surfaceContainerHighest: AppColors.primary50,
      ),
      textTheme: textTheme,
      cardTheme: CardThemeData(color: Colors.white, elevation: 0, shape: _shape),
      elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(shape: _shape)),
      filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(shape: _shape)),
      outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(shape: _shape)),
      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(shape: _shape)),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: AppColors.primary100),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: AppColors.primary100),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: AppColors.primary500, width: 1.5),
        ),
      ),
    );
  }
}
