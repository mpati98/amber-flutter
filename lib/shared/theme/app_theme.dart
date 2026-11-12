import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';

import 'design_tokens.dart';

/// Bảng màu của các màn cũ. Từ 12/11/2026 các token tối được ánh xạ sang bộ thiết kế mới ([DesignColors], design/DESIGN.md)
/// để mọi màn chưa làm lại cũng cùng tông; tên giữ nguyên (gốc từ amber-v3 globals.css) để không phải sửa từng chỗ dùng.
/// Màn mới dùng thẳng [DesignColors].
abstract final class AppColors {
  // Theme tối "Âm Dương Giới" → bộ thiết kế mới.
  static const ink950 = DesignColors.bgTop; // nền sâu nhất; chữ tối trên nền vàng
  static const ink900 = DesignColors.panel; // nền thẻ / panel
  static const ink800 = DesignColors.frame; // ô chưa có dữ liệu, nền lõm
  static const yugen500 = DesignColors.info; // nhấn phụ (xanh lam)
  static const yugen300 = DesignColors.muted; // chữ phụ có màu
  static const shuiro500 = DesignColors.danger; // âm, cảnh báo
  static const kincha400 = DesignColors.gold; // vàng: tiêu đề, nút chính, điểm nhấn
  static const kincha200 = Color(0xFFF7E7B0); // vàng nhạt (đỉnh gradient logo trong bản mẫu)

  // Trạng thái "xong" / thu nhập.
  static const emerald300 = DesignColors.success;
  static const emerald400 = DesignColors.success;

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

  /// Chữ phụ vẫn đọc được trên nền tối (62%). Chỉ dùng ở màn mới, màn cũ tự đặt độ mờ riêng.
  Color get textMuted => colorScheme.onSurface.withValues(alpha: 0.62);

  /// Chi tiết trang trí, không mang thông tin chính (40%).
  Color get textFaint => colorScheme.onSurface.withValues(alpha: 0.4);
}

abstract final class AppTheme {
  /// Thay cho `GoogleFonts.interTextTheme`: hàm đó nhận/trả `TextTheme` của `flutter/material`, còn app đã chuyển sang
  /// `material_ui` (TextTheme khác kiểu). Áp Inter cho từng style giống hệt cách google_fonts làm bên trong.
  static TextTheme _interTextTheme(TextTheme t) => _fontTextTheme(t, (s) => GoogleFonts.inter(textStyle: s));

  /// Áp một font Google cho từng style của [t] (google_fonts không trả TextTheme của material_ui — xem [_interTextTheme]).
  static TextTheme _fontTextTheme(TextTheme t, TextStyle Function(TextStyle?) font) {
    TextStyle? inter(TextStyle? s) => font(s);
    return TextTheme(
      displayLarge: inter(t.displayLarge),
      displayMedium: inter(t.displayMedium),
      displaySmall: inter(t.displaySmall),
      headlineLarge: inter(t.headlineLarge),
      headlineMedium: inter(t.headlineMedium),
      headlineSmall: inter(t.headlineSmall),
      titleLarge: inter(t.titleLarge),
      titleMedium: inter(t.titleMedium),
      titleSmall: inter(t.titleSmall),
      bodyLarge: inter(t.bodyLarge),
      bodyMedium: inter(t.bodyMedium),
      bodySmall: inter(t.bodySmall),
      labelLarge: inter(t.labelLarge),
      labelMedium: inter(t.labelMedium),
      labelSmall: inter(t.labelSmall),
    );
  }

  /// --radius: 0.625rem ≈ 10px (globals.css).
  static const double radius = 10;
  static final _shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));

  /// --radius-sm = 0.6 × --radius = 6px (globals.css) — bo góc của theme tối.
  static const double darkRadius = 6;

  /// Theme tối của cả app theo bộ thiết kế mới (design/DESIGN.md): chữ Gelasio (thay Georgia), vàng `#f0d68a` cho nút chính /
  /// điểm nhấn, nền panel `#0e1430`, viền `#2c3766`, chữ phụ `#a9b0d0`, đỏ `#ff7b7b`. Màn đã làm lại dùng thẳng [DesignColors];
  /// theme này để các màn / form / hộp thoại cũ (dùng colorScheme) cũng cùng tông.
  static ThemeData get darkTheme {
    final base = ThemeData(brightness: Brightness.dark);
    final textTheme = _fontTextTheme(base.textTheme, (s) => GoogleFonts.gelasio(textStyle: s))
        .apply(bodyColor: DesignColors.text, displayColor: DesignColors.text);
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(6));
    OutlineInputBorder border(Color c) =>
        OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: c));

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: DesignColors.bgTop,
      cardColor: DesignColors.panel,
      canvasColor: DesignColors.panel,
      dividerColor: DesignColors.rowDivider,
      colorScheme: const ColorScheme.dark(
        primary: DesignColors.gold,
        onPrimary: Color(0xFF1A1A1A),
        secondary: DesignColors.info,
        onSecondary: Color(0xFF1A1A1A),
        tertiary: DesignColors.muted,
        error: DesignColors.danger,
        onError: Color(0xFF1A1A1A),
        surface: DesignColors.panel,
        onSurface: DesignColors.text,
        onSurfaceVariant: DesignColors.muted,
        outline: DesignColors.panelBorder,
        outlineVariant: DesignColors.rowDivider,
        surfaceContainerHighest: DesignColors.frame,
      ),
      textTheme: textTheme,
      extensions: const [AppSemanticColors(success: DesignColors.success)],
      appBarTheme: AppBarTheme(
        backgroundColor: DesignColors.panel,
        foregroundColor: DesignColors.text,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.gelasio(fontSize: 16, fontWeight: FontWeight.w700, color: DesignColors.text),
        shape: const Border(bottom: BorderSide(color: DesignColors.topBarBorder)),
      ),
      cardTheme: CardThemeData(
        color: DesignColors.panel,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: DesignColors.panelBorder),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: DesignColors.panel,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: DesignColors.frameBorder),
        ),
      ),
      popupMenuTheme: const PopupMenuThemeData(color: DesignColors.panel, surfaceTintColor: Colors.transparent),
      bottomSheetTheme: const BottomSheetThemeData(backgroundColor: DesignColors.panel, surfaceTintColor: Colors.transparent),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DesignColors.frame,
        hintStyle: GoogleFonts.gelasio(color: DesignColors.muted),
        border: border(DesignColors.panelBorder),
        enabledBorder: border(DesignColors.panelBorder),
        focusedBorder: border(DesignColors.gold),
        errorBorder: border(DesignColors.danger),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: DesignColors.gold),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? DesignColors.gold : DesignColors.muted),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? DesignColors.gold.withValues(alpha: 0.35) : DesignColors.frame,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(shape: shape)),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: shape,
          backgroundColor: DesignColors.gold,
          foregroundColor: const Color(0xFF1A1A1A),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: shape,
          foregroundColor: DesignColors.gold,
          side: const BorderSide(color: DesignColors.gold),
        ),
      ),
      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(shape: shape, foregroundColor: DesignColors.gold)),
    );
  }

  /// Theme sáng "đất nung" — chỉ login / register / settings.
  /// Mapping theo :root của globals.css: --primary = primary-700,
  /// --background = bg-light, --secondary = secondary-300, --border = primary-100.
  static ThemeData get lightTheme {
    final base = ThemeData(brightness: Brightness.light);
    final textTheme = _interTextTheme(base.textTheme).apply(
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
