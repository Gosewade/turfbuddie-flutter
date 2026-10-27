import 'package:flutter/material.dart';
import 'package:turfbuddie_mock/core/formatters.dart';
import 'package:turfbuddie_mock/core/theme.dart';
import 'package:turfbuddie_mock/models/models.dart';
import 'package:turfbuddie_mock/screens/auth_screen.dart';
import 'package:turfbuddie_mock/state/app_state.dart';
import 'package:turfbuddie_mock/widgets/common.dart';

class PlayersScreen extends StatefulWidget {
  const PlayersScreen({super.key});
  @override
  State<PlayersScreen> createState() => _PlayersScreenState();
}

class _PlayersScreenState extends State<PlayersScreen> {
  String? sport;

  Future<bool> _ensureTeam() async {
    final s = AppScope.of(context);
    if (s.myTeam != null) return true;
    if (!await requireLogin(context)) return false;
    if (!mounted) return false;
    final t = await showCreateTeamSheet(context);
    return t != null;
  }

  Future<void> _invite(Player p) async {
    final s = AppScope.of(context);
    final messenger = ScaffoldMessenger.of(context);
    // Gate: account -> team -> invite
    if (!await requireLogin(context)) return;
    if (!mounted || !await _ensureTeam()) return;
    s.update(() {
      p.invited = true;
      s.myTeam!.invited.add(p.name);
    });
    messenger.showSnackBar(SnackBar(content: Text('Invite sent to ${p.name} for ${s.myTeam!.name}')));
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final list = s.players.where((p) => sport == null || p.sport == sport).toList();
    final hasAccount = s.user != null;
    final team = s.myTeam;
    final ready = hasAccount && team != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Find Player', style: TextStyle(fontWeight: FontWeight.w800))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          const Text('Join or build squads. Filter by sport & skill.', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 16),
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Get started in 3 steps', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              _step(1, hasAccount, 'Create account / Login',
                  hasAccount ? 'Logged in as ${s.user!.name}' : 'Required to invite players',
                  hasAccount ? null : GreenButton(label: 'Login / Sign up', compact: true, onPressed: () => requireLogin(context))),
              _step(2, team != null, 'Create your team',
                  team != null
                      ? '${team.name} \u00B7 ${sportEmoji[team.sport]} ${team.sport} \u00B7 ${team.skill}'
                      : 'Name, sport & skill level',
                  team != null
                      ? null
                      : GreenButton(label: 'Create team', compact: true, onPressed: () => _ensureTeam())),
              _step(3, team != null && hasAccount && team.invited.isNotEmpty, 'Invite players',
                  (hasAccount && team != null) ? '${team.invited.length} invite(s) sent \u00B7 need ${team.playersNeeded} more' : 'Unlocks after steps 1 & 2', null,
                  last: true, locked: !ready),
            ]),
          ),
          const SizedBox(height: 18),
          Wrap(spacing: 8, runSpacing: 8, children: [
            Pill('All', selected: sport == null, onTap: () => setState(() => sport = null)),
            for (final sp in sportEmoji.keys)
              Pill('${sportEmoji[sp]} $sp', selected: sport == sp, onTap: () => setState(() => sport = sp)),
          ]),
          const SizedBox(height: 16),
          for (final p in list)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(children: [
                  CircleAvatar(
                    backgroundColor: AppColors.greenSoft,
                    child: Text(p.name[0], style: const TextStyle(color: AppColors.greenDark, fontWeight: FontWeight.w900)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(p.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                      Text('${sportEmoji[p.sport]} ${p.sport} \u00B7 ${p.skill} \u00B7 ${p.area}',
                          style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    ]),
                  ),
                  GreenButton(
                    compact: true,
                    outlined: p.invited,
                    label: p.invited ? 'Invited' : (ready ? 'Invite' : '\u{1F512} Invite'),
                    onPressed: p.invited ? null : () => _invite(p),
                  ),
                ]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _step(int n, bool done, String title, String sub, Widget? action, {bool last = false, bool locked = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 14),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CircleAvatar(
          radius: 15,
          backgroundColor: done ? AppColors.green : (locked ? Colors.grey.shade300 : AppColors.greenSoft),
          child: done
              ? const Icon(Icons.check, size: 18, color: Colors.white)
              : Text('$n', style: TextStyle(fontWeight: FontWeight.w900, color: locked ? Colors.grey : AppColors.greenDark)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: locked ? Colors.grey : null)),
            const SizedBox(height: 2),
            Text(sub, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            if (action != null) ...[const SizedBox(height: 8), action],
          ]),
        ),
      ]),
    );
  }
}

Future<Team?> showCreateTeamSheet(BuildContext context) => showModalBottomSheet<Team>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _TeamSheet(),
    );

class _TeamSheet extends StatefulWidget {
  const _TeamSheet();
  @override
  State<_TeamSheet> createState() => _TeamSheetState();
}

class _TeamSheetState extends State<_TeamSheet> {
  final name = TextEditingController();
  String sport = 'Football', skill = 'Intermediate';
  int need = 3;
  String? error;

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  void _create() {
    if (name.text.trim().length < 3) {
      setState(() => error = 'Team name must be at least 3 characters');
      return;
    }
    final s = AppScope.of(context);
    final t = Team(name: name.text.trim(), sport: sport, skill: skill, playersNeeded: need);
    s.update(() => s.myTeam = t);
    Navigator.pop(context, t);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Create your team', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 14),
          TextField(
            controller: name,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: 'Team name',
              errorText: error,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 14),
          const Text('Sport', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final sp in sportEmoji.keys)
              Pill('${sportEmoji[sp]} $sp', selected: sport == sp, onTap: () => setState(() => sport = sp)),
          ]),
          const SizedBox(height: 14),
          const Text('Skill level', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Wrap(spacing: 8, children: [
            for (final k in ['Beginner', 'Intermediate', 'Advanced'])
              Pill(k, selected: skill == k, onTap: () => setState(() => skill = k)),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            const Text('Players needed', style: TextStyle(fontWeight: FontWeight.w800)),
            const Spacer(),
            IconButton(onPressed: need > 1 ? () => setState(() => need--) : null, icon: const Icon(Icons.remove_circle_outline)),
            Text('$need', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            IconButton(onPressed: need < 15 ? () => setState(() => need++) : null, icon: const Icon(Icons.add_circle_outline)),
          ]),
          const SizedBox(height: 8),
          GreenButton(label: 'Create team', onPressed: _create),
        ]),
      ),
    );
  }
}
