import 'package:flutter/material.dart';
import 'package:turfbuddie_mock/core/formatters.dart';
import 'package:turfbuddie_mock/core/theme.dart';
import 'package:turfbuddie_mock/state/app_state.dart';
import 'package:turfbuddie_mock/widgets/common.dart';

class TurfsScreen extends StatelessWidget {
  const TurfsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final list = s.filteredTurfs;
    return Column(children: [
      const GreenHeader('Find Turfs Near You', tall: true),
      Expanded(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            SearchBox(hint: 'Search turfs by name...', onChanged: (v) => s.update(() => s.query = v)),
            const SizedBox(height: 14),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              onTap: () => s.update(() => s.filtersOpen = !s.filtersOpen),
              child: Row(children: [
                const Icon(Icons.filter_alt, color: AppColors.green),
                const SizedBox(width: 14),
                const Expanded(child: Text('Filter Turfs', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16))),
                Icon(s.filtersOpen ? Icons.expand_less : Icons.expand_more),
              ]),
            ),
            if (s.filtersOpen) Padding(padding: const EdgeInsets.only(top: 10), child: _Filters(s)),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: Text('${list.length} turfs near ${s.city}', style: const TextStyle(fontWeight: FontWeight.w600))),
              DropdownButton<SortBy>(
                value: s.sort,
                underline: const SizedBox.shrink(),
                items: const [
                  DropdownMenuItem(value: SortBy.nearest, child: Text('Nearest First')),
                  DropdownMenuItem(value: SortBy.priceLow, child: Text('Price: Low to High')),
                  DropdownMenuItem(value: SortBy.rating, child: Text('Top Rated')),
                ],
                onChanged: (v) => s.update(() => s.sort = v ?? SortBy.nearest),
              ),
            ]),
            const SizedBox(height: 4),
            if (s.loading)
              const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator()))
            else if (list.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(children: [
                  const Text('\u{1F937}', style: TextStyle(fontSize: 48)),
                  const Text('No turfs match your search'),
                  TextButton(onPressed: s.resetFilters, child: const Text('Clear filters')),
                ]),
              )
            else
              for (final t in list) TurfRowCard(t),
          ],
        ),
      ),
    ]);
  }
}

class _Filters extends StatelessWidget {
  const _Filters(this.s);
  final AppState s;

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 10),
        child: Text(t, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1, color: Colors.grey)),
      );

  void _toggle(Set<String> set, String v) =>
      s.update(() => set.contains(v) ? set.remove(v) : set.add(v));

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('Filters', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const Spacer(),
          TextButton(onPressed: s.resetFilters, child: const Text('Clear all', style: TextStyle(color: AppColors.greenDark, fontWeight: FontWeight.w700))),
        ]),
        _label('SPORT'),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final sp in sportEmoji.keys)
            Pill('${sportEmoji[sp]} $sp', selected: s.fSports.contains(sp), onTap: () => _toggle(s.fSports, sp)),
        ]),
        _label('DISTANCE'),
        Row(children: [
          Expanded(child: Slider(value: s.fMaxKm, min: 1, max: 25, divisions: 24, onChanged: (v) => s.update(() => s.fMaxKm = v))),
          Text('Within ${s.fMaxKm.round()} km', style: const TextStyle(fontWeight: FontWeight.w600)),
        ]),
        const Text('\u{1F4CD} Location active \u2014 filtering by distance',
            style: TextStyle(color: AppColors.greenDark, fontSize: 13)),
        _label('PRICE / HR'),
        Row(children: [
          Expanded(child: Slider(value: s.fMaxPrice, min: 300, max: 2000, divisions: 17, onChanged: (v) => s.update(() => s.fMaxPrice = v))),
          Text('Up to ${rupee(s.fMaxPrice.round())}', style: const TextStyle(fontWeight: FontWeight.w600)),
        ]),
        _label('FORMAT'),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final f in ['5v5', '7v7', '11v11']) Pill(f, selected: s.fFormats.contains(f), onTap: () => _toggle(s.fFormats, f)),
        ]),
        _label('AMENITIES'),
        for (final a in amenityEmoji.keys)
          InkWell(
            onTap: () => _toggle(s.fAmenities, a),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(children: [
                Checkbox(
                  value: s.fAmenities.contains(a),
                  activeColor: AppColors.green,
                  onChanged: (_) => _toggle(s.fAmenities, a),
                ),
                Text('${amenityEmoji[a]}  $a', style: const TextStyle(fontSize: 16)),
              ]),
            ),
          ),
        _label('AVAILABILITY'),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final a in ['Open Now', 'Morning', 'Evening'])
            Pill(a, selected: s.fAvailability == a, onTap: () => s.update(() => s.fAvailability = s.fAvailability == a ? null : a)),
        ]),
      ]),
    );
  }
}
