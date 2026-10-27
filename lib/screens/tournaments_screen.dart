import 'package:flutter/material.dart';
import 'package:turfbuddie_mock/core/formatters.dart';
import 'package:turfbuddie_mock/core/theme.dart';
import 'package:turfbuddie_mock/models/models.dart';
import 'package:turfbuddie_mock/screens/auth_screen.dart';
import 'package:turfbuddie_mock/state/app_state.dart';
import 'package:turfbuddie_mock/widgets/common.dart';

class TournamentsScreen extends StatelessWidget {
  const TournamentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return Column(children: [
      const GreenHeader('Tournaments', subtitle: 'Compete, win, repeat.', tall: true),
      Expanded(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            if (s.loading) const Center(child: CircularProgressIndicator()),
            for (final t in s.tournaments) _TournamentCard(t),
          ],
        ),
      ),
    ]);
  }
}

class _TournamentCard extends StatelessWidget {
  const _TournamentCard(this.t);
  final Tournament t;

  Future<void> _register(BuildContext context) async {
    if (!await requireLogin(context)) return;
    if (!context.mounted) return;
    final s = AppScope.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final ctrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Register for ${t.title}'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'Team name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.green),
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty || !context.mounted) return;
    final ok = await showPaymentSheet(context, amount: t.entryFee.toDouble(), title: 'Entry fee \u00B7 $name');
    if (ok != true) return;
    s.update(() {
      t.registered++;
      t.isRegistered = true;
    });
    messenger.showSnackBar(SnackBar(content: Text('$name registered for ${t.title} \u2705')));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final full = t.spotsLeft <= 0;
    final canRegister = !t.done && !full && !t.isRegistered;
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Column(children: [
            Container(
              height: 150,
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [Color(0xFF065F46), Color(0xFF10B981)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(999)),
                    child: Text('${sportEmoji[t.sport]} ${t.sport}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                        color: t.done ? Colors.grey.shade600 : Colors.white24,
                        borderRadius: BorderRadius.circular(999)),
                    child: Text(t.done ? 'Done' : 'Open',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                  ),
                ]),
                const Spacer(),
                Text(t.title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                Text('\u{1F525} ${t.tagline}', maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70)),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                Row(children: [
                  Expanded(child: _kv('PRIZE POOL', rupee(t.prize), green: true)),
                  Expanded(child: _kv('ENTRY FEE', rupee(t.entryFee))),
                ]),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(child: _kv('DATE', '\u{1F4C5} ${shortDate(t.date)}')),
                  Expanded(child: _kv('VENUE', '\u{1F4CD} ${t.venue}')),
                ]),
                const Divider(height: 28),
                Row(children: [
                  Expanded(
                    child: Text.rich(TextSpan(children: [
                      TextSpan(text: '${t.registered}', style: const TextStyle(fontWeight: FontWeight.w900)),
                      TextSpan(text: '/${t.capacity} teams \u00B7 '),
                      TextSpan(
                          text: full ? 'Full' : '${t.spotsLeft} left',
                          style: TextStyle(color: full ? AppColors.red : AppColors.greenDark, fontWeight: FontWeight.w700)),
                    ])),
                  ),
                  GreenButton(
                    compact: true,
                    label: t.isRegistered ? 'Registered \u2713' : (t.done ? 'Closed' : 'Register \u2192'),
                    onPressed: canRegister ? () => _register(context) : null,
                  ),
                ]),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _kv(String k, String v, {bool green = false}) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(k, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 0.5)),
        const SizedBox(height: 2),
        Text(v,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: green ? AppColors.greenDark : null)),
      ]);
}
