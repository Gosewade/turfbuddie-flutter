import 'package:flutter/material.dart';
import 'package:turfbuddie_mock/core/theme.dart';
import 'package:turfbuddie_mock/screens/auth_screen.dart';
import 'package:turfbuddie_mock/screens/match_calc_screen.dart';
import 'package:turfbuddie_mock/screens/players_screen.dart';
import 'package:turfbuddie_mock/state/app_state.dart';
import 'package:turfbuddie_mock/widgets/common.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final u = s.user;
    void soon(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$m (coming soon)')));

    return Column(children: [
      const GreenHeader('My Profile', tall: true),
      Expanded(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                const CircleAvatar(radius: 28, backgroundColor: AppColors.greenSoft, child: Icon(Icons.person, size: 30, color: AppColors.greenDark)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(u?.name ?? 'Guest', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                    Text(u == null ? 'Login to book turfs & join tournaments' : (u.email.isEmpty ? '+91 ${u.phone}' : u.email),
                        style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    if (u != null) Text('${u.city} \u00B7 ${u.role} \u00B7 \u2B50 ${s.loyaltyPoints} pts', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ]),
                ),
              ]),
            ),
            if (u == null) ...[
              const SizedBox(height: 12),
              GreenButton(label: 'Login / Sign up', onPressed: () => requireLogin(context)),
            ],
            const SizedBox(height: 12),
            _item(Icons.manage_accounts, AppColors.green, 'Account Settings', 'Manage your personal information', () => soon('Account settings')),
            _item(Icons.menu_book, Colors.blue, 'Your Bookings', 'View all your bookings', () => s.update(() => s.tab = AppState.tabBooking)),
            _item(Icons.groups, AppColors.orange, 'Find Players', s.myTeam == null ? 'Create a team & invite players' : 'Team: ${s.myTeam!.name}',
                () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PlayersScreen()))),
            _item(Icons.calculate, Colors.lightBlue, 'Match Calculator', 'Split cost & cricket run rate',
                () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MatchCalcScreen()))),
            _item(Icons.support_agent, Colors.deepOrange, 'Help & Support', 'Get help with your bookings', () => soon('Help & support')),
            _item(Icons.privacy_tip, Colors.purple, 'Privacy Policy', 'Read our privacy policy', () => soon('Privacy policy')),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(children: [
                const Icon(Icons.dark_mode_outlined),
                const SizedBox(width: 14),
                const Expanded(child: Text('Dark mode', style: TextStyle(fontWeight: FontWeight.w700))),
                Switch(value: s.themeMode == ThemeMode.dark, activeColor: AppColors.green, onChanged: (_) => s.toggleTheme()),
              ]),
            ),
            if (u != null) ...[
              const SizedBox(height: 16),
              GreenButton(label: 'Logout', outlined: true, color: AppColors.red, onPressed: s.logout),
            ],
          ],
        ),
      ),
    ]);
  }

  Widget _item(IconData icon, Color c, String title, String sub, VoidCallback onTap) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: AppCard(
          onTap: onTap,
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(color: c.withAlpha(30), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: c),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                Text(sub, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ]),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ]),
        ),
      );
}
