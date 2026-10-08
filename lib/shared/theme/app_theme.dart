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

  // Không phải token của globals.css: màu mặc định Tailwind, amber-v3 dùng
  // nhất quán cho trạng thái "xong" (StatusBadge READ, TaskStatusBadge DONE,
  // hoc-tap "Đã xong").
  // Giá trị đo pixel thật, không tra bảng màu: Tailwind v4.3.3 (bản amber-v3
  // cài), vẽ giá trị lab() của CSS đã build lên canvas sRGB trong Chromium.
  static const emerald300 = Color(0xFF5EE9B5);
  // Không dùng 0xFF00D294: đó là hex dự phòng cho trình duyệt không hỗ trợ
  // lab(), lệch màu thật 2 đơn vị ở kênh G và B.
  static const emerald400 = Color(0xFF00D492);

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

/// Màu ngữ nghĩa ngoài ColorScheme (ColorScheme của Material không có màu "thành công").
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({required this.success});

  /// Số tiền thu, trạng thái hoàn tất...
  final Color success;

  @override
  AppSemanticColors copyWith({Color? success}) => AppSemanticColors(success: success ?? this.success);

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) =>
      other is AppSemanticColors ? AppSemanticColors(success: Color.lerp(success, other.success, t)!) : this;
}

extension AppThemeColors on ThemeData {
  /// Màu thành công của theme; theme không khai báo (vd ThemeData.dark() trong test) thì dùng primary.
  Color get success => extension<AppSemanticColors>()?.success ?? colorScheme.primary;
}

abstract final class AppTheme {
  /// --radius: 0.625rem ≈ 10px (globals.css).
  static const double radius = 10;
  static final _shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));

  /// --radius-sm = 0.6 × --radius = 6px (globals.css) — bo góc của theme tối.
  static const double darkRadius = 6;
  static final _darkShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(darkRadius));

  /// Theme tối — trang chủ + 4 tòa. Inter cho nội dung, Noto Serif cho
  /// display/headline (tương đương font-sans / font-serif-display bên web).
  // Bo góc 6px lấy từ rounded-sm thật trong tang-kinh-cac/ui.tsx (ScrollCard) —
  // --radius-sm bị globals.css ghi đè còn 0.6× thay vì mặc định Tailwind, không phải 4px.
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
      extensions: const [AppSemanticColors(success: AppColors.emerald400)],
      cardTheme: CardThemeData(shape: _darkShape),
      elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(shape: _darkShape)),
      filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(shape: _darkShape)),
      outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(shape: _darkShape)),
      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(shape: _darkShape)),
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
      // emerald-700: đủ tương phản trên nền sáng.
      extensions: const [AppSemanticColors(success: Color(0xFF047857))],
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
