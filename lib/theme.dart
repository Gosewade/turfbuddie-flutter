import 'package:flutter/material.dart';

/// ALL theme values live here. To match the APK exactly, change only this file.
class AppColors {
  static const green = Color(0xFF00B860); // logo green
  static const greenLight = Color(0xFF90D078); // logo light green
  static const ink = Color(0xFF181818); // logo black
  static const lightBg = Color(0xFFF5FAF6);
  static const darkBg = Color(0xFF101412);
}

final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.light);

class AppTheme {
  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness b) {
    final dark = b == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.green,
      brightness: b,
    ).copyWith(primary: AppColors.green, onPrimary: Colors.white);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: dark ? AppColors.darkBg : AppColors.lightBg,
      appBarTheme: AppBarTheme(
        backgroundColor: dark ? AppColors.darkBg : AppColors.lightBg,
        foregroundColor: dark ? Colors.white : AppColors.ink,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: dark ? Colors.white : AppColors.ink,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: dark ? const Color(0xFF1A201C) : Colors.white,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: dark ? const Color(0xFF2A322D) : const Color(0xFFE3EEE6),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: dark ? const Color(0xFF151B17) : Colors.white,
        indicatorColor: AppColors.green.withOpacity(0.18),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        selectedColor: AppColors.green,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
