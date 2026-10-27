import 'package:flutter/material.dart';
import 'package:turfbuddie_mock/core/theme.dart';
import 'package:turfbuddie_mock/screens/shell.dart';
import 'package:turfbuddie_mock/services/auth_service.dart';
import 'package:turfbuddie_mock/services/booking_service.dart';
import 'package:turfbuddie_mock/state/app_state.dart';

void main() => runApp(const TurfBuddieApp());

class TurfBuddieApp extends StatefulWidget {
  const TurfBuddieApp({super.key});
  @override
  State<TurfBuddieApp> createState() => _TurfBuddieAppState();
}

class _TurfBuddieAppState extends State<TurfBuddieApp> {
  // SWAP HERE: MockBookingService()/MockAuthService() -> your real implementations
  late final AppState state = AppState(MockBookingService(), MockAuthService())..init();

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: ListenableBuilder(
        listenable: state,
        builder: (context, _) => MaterialApp(
          title: 'TurfBuddie',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: state.themeMode,
          home: const Shell(),
        ),
      ),
    );
  }
}
