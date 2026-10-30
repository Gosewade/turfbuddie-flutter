import 'package:flutter/material.dart';
import 'screens.dart';
import 'theme.dart';

void main() => runApp(const TurfBuddieApp());

class TurfBuddieApp extends StatelessWidget {
  const TurfBuddieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeMode,
      builder: (_, mode, __) => MaterialApp(
        title: 'TurfBuddie',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: mode,
        home: const Shell(),
      ),
    );
  }
}
