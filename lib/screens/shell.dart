import 'package:flutter/material.dart';
import 'package:turfbuddie_mock/screens/bookings_screen.dart';
import 'package:turfbuddie_mock/screens/home_screen.dart';
import 'package:turfbuddie_mock/screens/profile_screen.dart';
import 'package:turfbuddie_mock/screens/tournaments_screen.dart';
import 'package:turfbuddie_mock/screens/turfs_screen.dart';
import 'package:turfbuddie_mock/state/app_state.dart';

/// Same 5-tab layout as the live app: Turfs, Booking, Home, Tournaments, Profile
class Shell extends StatelessWidget {
  const Shell({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return Scaffold(
      body: IndexedStack(
        index: s.tab,
        children: const [TurfsScreen(), BookingsScreen(), HomeScreen(), TournamentsScreen(), ProfileScreen()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: s.tab,
        onDestinationSelected: (i) => s.update(() => s.tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.sports_soccer_outlined), selectedIcon: Icon(Icons.sports_soccer), label: 'Turfs'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'Booking'),
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.emoji_events_outlined), selectedIcon: Icon(Icons.emoji_events), label: 'Tournaments'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
