import 'package:flutter/material.dart';
import 'package:turfbuddie_mock/core/formatters.dart';
import 'package:turfbuddie_mock/core/theme.dart';
import 'package:turfbuddie_mock/models/models.dart';
import 'package:turfbuddie_mock/screens/match_calc_screen.dart';
import 'package:turfbuddie_mock/screens/players_screen.dart';
import 'package:turfbuddie_mock/screens/turf_detail_screen.dart';
import 'package:turfbuddie_mock/state/app_state.dart';
import 'package:turfbuddie_mock/widgets/common.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int page = 0;
  final _pc = PageController(viewportFraction: 0.92);

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final top = [...s.turfs]..sort((a, b) => b.rating.compareTo(a.rating));
    final near = [...s.turfs]..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    final topList = top.take(4).toList();

    return Column(children: [
      GreenHeader(s.city, subtitle: 'Your Location', icon: Icons.location_on, onTap: () => pickCity(context), tall: true),
      Expanded(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            SearchBox(hint: 'Search for turfs, locations...', readOnly: true, onTap: () => s.update(() => s.tab = AppState.tabTurfs)),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: _Quick('\u{1F50D}', 'Find Players', 'Build team & invite', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PlayersScreen())))),
              const SizedBox(width: 12),
              Expanded(child: _Quick('\u{1F3C6}', 'Tournaments', 'Compete & win', () => s.update(() => s.tab = AppState.tabTournaments))),
            ]),
            const SizedBox(height: 22),
            _title('Top Rated Turfs', () => s.update(() {
                  s.sort = SortBy.rating;
                  s.tab = AppState.tabTurfs;
                })),
            const SizedBox(height: 12),
            if (s.loading)
              const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator()))
            else ...[
              SizedBox(
                height: 230,
                child: PageView.builder(
                  controller: _pc,
                  itemCount: topList.length,
                  onPageChanged: (i) => setState(() => page = i),
                  itemBuilder: (_, i) => _Featured(topList[i]),
                ),
              ),
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                for (var i = 0; i < topList.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == page ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(color: i == page ? AppColors.green : Colors.grey.shade400, borderRadius: BorderRadius.circular(8)),
                  ),
              ]),
            ],
            const SizedBox(height: 22),
            _title('Turfs Near You', () => s.update(() {
                  s.sort = SortBy.nearest;
                  s.tab = AppState.tabTurfs;
                })),
            const SizedBox(height: 12),
            for (final t in near.take(4)) TurfRowCard(t),
            const SizedBox(height: 10),
            _Quick('\u{1F9EE}', 'Match Calculator', 'Cost per player & cricket run rate',
                () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MatchCalcScreen()))),
          ],
        ),
      ),
    ]);
  }

  Widget _title(String t, VoidCallback onAll) => Row(children: [
        Expanded(child: Text(t, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900))),
        GestureDetector(onTap: onAll, child: const Text('View all', style: TextStyle(color: AppColors.green, fontWeight: FontWeight.w700))),
      ]);
}

class _Quick extends StatelessWidget {
  const _Quick(this.emoji, this.title, this.sub, this.onTap);
  final String emoji, title, sub;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => SizedBox(
        height: 78, // fixed so every quick card has the same size
        child: AppCard(
          onTap: onTap,
          child: Center(
            child: Row(children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
                  Text(sub, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                ]),
              ),
            ]),
          ),
        ),
      );
}

class _Featured extends StatelessWidget {
  const _Featured(this.t);
  final Turf t;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => TurfDetailScreen(turf: t))),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(children: [
            Positioned.fill(child: Image.asset(turfPhoto(t), fit: BoxFit.cover)),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.transparent, Colors.black.withAlpha(170)], begin: Alignment.center, end: Alignment.bottomCenter),
                ),
              ),
            ),
            Positioned(
              top: 14,
              right: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: Text(rupee(t.pricePerHour), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),
              ),
            ),
            Positioned(
              left: 14,
              bottom: 14,
              right: 90,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Text(t.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                Text('\u{1F4CD} ${t.area}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ]),
            ),
            Positioned(
              right: 14,
              bottom: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: AppColors.amber, borderRadius: BorderRadius.circular(14)),
                child: Text('\u2606 ${t.rating}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
