import 'package:flutter/material.dart';

class AppColors {
  static const green = Color(0xFF16A34A);
  static const greenDark = Color(0xFF0B5D1E);
  static const greenSoft = Color(0xFFE8F8EE);
  static const amber = Color(0xFFF59E0B);
  static const orange = Color(0xFFEA580C);
  static const red = Color(0xFFDC2626);
  static const whatsapp = Color(0xFF25D366);
  static const header = Color(0xFF0DA55B);
}

class AppTheme {
  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness b) {
    final isLight = b == Brightness.light;
    final scheme = ColorScheme.fromSeed(seedColor: AppColors.green, brightness: b)
        .copyWith(primary: AppColors.green, onPrimary: Colors.white);
    final bg = isLight ? const Color(0xFFF1F4F2) : const Color(0xFF0E1511);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme.copyWith(
        surface: isLight ? Colors.white : const Color(0xFF16201A),
        outlineVariant: isLight ? const Color(0xFFE5E7EB) : const Color(0xFF2A3A30),
      ),
      scaffoldBackgroundColor: bg,
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.green,
        thumbColor: AppColors.green,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: bg,
        indicatorColor: AppColors.greenSoft,
        labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
