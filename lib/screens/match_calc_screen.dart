import 'package:flutter/material.dart';
import 'package:turfbuddie_mock/core/formatters.dart';
import 'package:turfbuddie_mock/core/theme.dart';
import 'package:turfbuddie_mock/models/models.dart';
import 'package:turfbuddie_mock/screens/turf_detail_screen.dart';
import 'package:turfbuddie_mock/state/app_state.dart';
import 'package:turfbuddie_mock/widgets/common.dart';

/// Match Calculator: (1) cost per player for a turf match, (2) cricket run rate.
class MatchCalcScreen extends StatefulWidget {
  const MatchCalcScreen({super.key});
  @override
  State<MatchCalcScreen> createState() => _MatchCalcScreenState();
}

class _MatchCalcScreenState extends State<MatchCalcScreen> {
  int mode = 0; // 0 = cost split, 1 = cricket
  String? turfId;
  int hours = 1, players = 10, totalOvers = 20;
  final extras = TextEditingController(text: '0');
  final runs = TextEditingController();
  final overs = TextEditingController();
  final target = TextEditingController();

  @override
  void dispose() {
    for (final c in [extras, runs, overs, target]) {
      c.dispose();
    }
    super.dispose();
  }

  int _balls(String o) {
    final p = o.trim().split('.');
    final ov = int.tryParse(p[0]) ?? 0;
    final b = p.length > 1 ? (int.tryParse(p[1]) ?? 0).clamp(0, 5) : 0;
    return ov * 6 + b;
  }

  Widget _stepper(String label, int v, int min, int max, ValueChanged<int> on) => Row(children: [
        Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800))),
        IconButton(onPressed: v > min ? () => on(v - 1) : null, icon: const Icon(Icons.remove_circle_outline)),
        Text('$v', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
        IconButton(onPressed: v < max ? () => on(v + 1) : null, icon: const Icon(Icons.add_circle_outline)),
      ]);

  Widget _num(TextEditingController c, String label, {bool decimal = false}) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextField(
          controller: c,
          keyboardType: TextInputType.numberWithOptions(decimal: decimal),
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(labelText: label, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
        ),
      );

  Widget _row(String l, String v, {bool big = false, Color? color}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(children: [
          Expanded(child: Text(l, style: TextStyle(fontSize: big ? 18 : 15, fontWeight: big ? FontWeight.w900 : FontWeight.w500))),
          Text(v, style: TextStyle(fontSize: big ? 22 : 15, fontWeight: FontWeight.w900, color: color)),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Match Calculator', style: TextStyle(fontWeight: FontWeight.w800))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Wrap(spacing: 8, children: [
            Pill('\u{1F4B0} Cost Split', selected: mode == 0, onTap: () => setState(() => mode = 0)),
            Pill('\u{1F3CF} Cricket Run Rate', selected: mode == 1, onTap: () => setState(() => mode = 1)),
          ]),
          const SizedBox(height: 14),
          if (mode == 0) ..._cost(s) else ..._cricket(),
        ],
      ),
    );
  }

  List<Widget> _cost(AppState s) {
    if (s.turfs.isEmpty) return [const Center(child: CircularProgressIndicator())];
    final Turf t = s.turfs.firstWhere((x) => x.id == turfId, orElse: () => s.turfs.first);
    final pb = PriceBreakdown.calc(base: (t.pricePerHour * hours).toDouble());
    final ex = double.tryParse(extras.text) ?? 0;
    final total = pb.total + ex;
    final per = (total / players).ceilToDouble();
    return [
      AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Turf', style: TextStyle(fontWeight: FontWeight.w800)),
          DropdownButton<String>(
            isExpanded: true,
            value: t.id,
            items: [for (final x in s.turfs) DropdownMenuItem(value: x.id, child: Text('${x.name} \u00B7 ${rupee(x.pricePerHour)}/hr'))],
            onChanged: (v) => setState(() => turfId = v),
          ),
          _stepper('Hours', hours, 1, 6, (v) => setState(() => hours = v)),
          _stepper('Players (total)', players, 2, 22, (v) => setState(() => players = v)),
          const SizedBox(height: 6),
          _num(extras, 'Extras: ball / umpire / equipment (\u20B9)'),
        ]),
      ),
      const SizedBox(height: 12),
      AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          _row('Turf (${hours}h \u00D7 ${rupee(t.pricePerHour)})', rupee(pb.base)),
          _row('Platform fee', rupee(pb.platformFee)),
          if (ex > 0) _row('Extras', rupee(ex)),
          const Divider(),
          _row('Total', rupee(total), big: true),
          _row('Per player ($players)', rupee(per), big: true, color: AppColors.green),
          _row('Per team (2 teams)', rupee((total / 2).ceilToDouble())),
        ]),
      ),
      const SizedBox(height: 12),
      GreenButton(
        label: 'Book this turf',
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => TurfDetailScreen(turf: t))),
      ),
    ];
  }

  List<Widget> _cricket() {
    final r = int.tryParse(runs.text) ?? 0;
    final balls = _balls(overs.text);
    final tg = int.tryParse(target.text) ?? 0;
    final crr = balls == 0 ? 0.0 : r / (balls / 6);
    final left = totalOvers * 6 - balls;
    final projected = (crr * totalOvers).round();
    final need = tg - r;
    final rrr = (need > 0 && left > 0) ? need / (left / 6) : 0.0;
    return [
      AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Match overs', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: [
            for (final o in [5, 6, 10, 20]) Pill('$o', selected: totalOvers == o, onTap: () => setState(() => totalOvers = o)),
          ]),
          const SizedBox(height: 14),
          _num(runs, 'Runs scored'),
          _num(overs, 'Overs bowled (e.g. 7.3)', decimal: true),
          _num(target, 'Target to chase (optional)'),
        ]),
      ),
      const SizedBox(height: 12),
      AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          _row('Current run rate', crr.toStringAsFixed(2), big: true, color: AppColors.green),
          _row('Balls bowled / left', '$balls / ${left < 0 ? 0 : left}'),
          _row('Projected score ($totalOvers ov)', '$projected'),
          if (tg > 0) ...[
            const Divider(),
            if (need <= 0)
              const Text('\u{1F3C6} Target achieved!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.green))
            else if (left <= 0)
              Text('\u274C Innings over \u2014 ${need - 1 <= 0 ? 'scores level' : 'lost by ${need - 1} runs'}', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.red))
            else ...[
              _row('Runs needed', '$need'),
              _row('Required run rate', rrr.toStringAsFixed(2), big: true, color: rrr > crr ? AppColors.red : AppColors.green),
            ],
          ],
        ]),
      ),
    ];
  }
}
