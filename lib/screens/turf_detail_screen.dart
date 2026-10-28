import 'package:flutter/material.dart';
import 'package:turfbuddie_mock/core/formatters.dart';
import 'package:turfbuddie_mock/core/theme.dart';
import 'package:turfbuddie_mock/models/models.dart';
import 'package:turfbuddie_mock/screens/checkout_screen.dart';
import 'package:turfbuddie_mock/state/app_state.dart';
import 'package:turfbuddie_mock/widgets/common.dart';

class TurfDetailScreen extends StatefulWidget {
  const TurfDetailScreen({super.key, required this.turf});
  final Turf turf;
  @override
  State<TurfDetailScreen> createState() => _TurfDetailScreenState();
}

class _TurfDetailScreenState extends State<TurfDetailScreen> {
  late DateTime date;
  final Set<int> selected = {};
  Set<int> booked = {};
  bool loadingSlots = true;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    final n = DateTime.now();
    date = DateTime(n.year, n.month, n.day);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      _load();
    }
  }

  Future<void> _load() async {
    setState(() {
      loadingSlots = true;
      selected.clear();
    });
    final b = await AppScope.of(context).bookedHours(widget.turf, date);
    if (!mounted) return;
    setState(() {
      booked = b;
      loadingSlots = false;
    });
  }

  bool _isPast(int h) {
    final n = DateTime.now();
    return sameDay(date, n) && h <= n.hour;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 90)),
    );
    if (d != null) {
      date = d;
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.turf;
    final cs = Theme.of(context).colorScheme;
    final total = t.pricePerHour * selected.length;
    final today = DateTime.now();
    final days = [for (var i = 0; i < 14; i++) DateTime(today.year, today.month, today.day + i)];
    final hours = selected.toList()..sort();

    return Scaffold(
      appBar: AppBar(title: Text(t.name, style: const TextStyle(fontWeight: FontWeight.w800))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          TurfThumb(t, height: 190),
          const SizedBox(height: 16),
          Text(t.name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.star, color: AppColors.amber, size: 20),
            Text(' ${t.rating} Rating',
                style: const TextStyle(color: AppColors.amber, fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(width: 14),
            const Icon(Icons.location_on_outlined, size: 18),
            Expanded(child: Text(' ${t.area}', overflow: TextOverflow.ellipsis)),
          ]),
          const SizedBox(height: 12),
          Align(alignment: Alignment.centerLeft, child: PriceChip(t.pricePerHour)),
          const SizedBox(height: 14),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final sp in t.sports) Chip(label: Text('${sportEmoji[sp]} $sp')),
            for (final f in t.formats) Chip(label: Text(f)),
            for (final a in t.amenities) Chip(label: Text('${amenityEmoji[a]} $a')),
          ]),
          const SizedBox(height: 22),
          Row(children: [
            const Icon(Icons.calendar_today_outlined, color: AppColors.green),
            const SizedBox(width: 10),
            const Text('Select Date', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const Spacer(),
            TextButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.edit_calendar, color: AppColors.green),
              label: const Text('Calendar', style: TextStyle(color: AppColors.green)),
            ),
          ]),
          const SizedBox(height: 8),
          SizedBox(
            height: 74,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: days.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final d = days[i];
                final sel = sameDay(d, date);
                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    date = d;
                    _load();
                  },
                  child: Container(
                    width: 60,
                    decoration: BoxDecoration(
                      color: sel ? AppColors.green : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: sel ? AppColors.green : cs.outlineVariant),
                    ),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(dayShort(d), style: TextStyle(fontSize: 12, color: sel ? Colors.white : Colors.grey)),
                      Text('${d.day}',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: sel ? Colors.white : null)),
                    ]),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 22),
          const Row(children: [
            Icon(Icons.schedule, color: AppColors.green),
            SizedBox(width: 10),
            Text('Select Time Slot(s)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          ]),
          const SizedBox(height: 6),
          Text(longDate(date), style: const TextStyle(fontSize: 15)),
          const SizedBox(height: 14),
          if (loadingSlots)
            const Padding(padding: EdgeInsets.all(30), child: Center(child: CircularProgressIndicator()))
          else
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.3,
              children: [
                for (final h in _orderedHours(t)) _slot(h, t, cs),
              ],
            ),
          const SizedBox(height: 10),
          const Row(children: [
            Icon(Icons.circle, size: 10, color: AppColors.green),
            Text('  Available     ', style: TextStyle(fontSize: 12)),
            Icon(Icons.circle, size: 10, color: Colors.grey),
            Text('  Booked / Past', style: TextStyle(fontSize: 12)),
          ]),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: GreenButton(
          label: selected.isEmpty ? 'Select a slot to continue' : 'Proceed to Checkout - ${rupee(total)}',
          onPressed: selected.isEmpty
              ? null
              : () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => CheckoutScreen(turf: t, date: date, hours: hours))),
        ),
      ),
    );
  }

  /// Available slots first (in time order), booked/past slots at the end.
  List<int> _orderedHours(Turf t) {
    bool unavailable(int h) => booked.contains(h) || _isPast(h);
    final l = [...t.slotHours];
    l.sort((a, b) {
      final ua = unavailable(a), ub = unavailable(b);
      if (ua == ub) return a.compareTo(b);
      return ua ? 1 : -1;
    });
    return l;
  }

  Widget _slot(int h, Turf t, ColorScheme cs) {
    final unavailable = booked.contains(h) || _isPast(h);
    final sel = selected.contains(h);
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: unavailable ? null : () => setState(() => sel ? selected.remove(h) : selected.add(h)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: sel ? AppColors.greenSoft : (unavailable ? cs.onSurface.withAlpha(12) : Colors.transparent),
          border: Border.all(
              color: sel ? AppColors.green : cs.outlineVariant, width: sel ? 2.5 : 1),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(slotLabel(h),
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: sel ? Colors.black : (unavailable ? Colors.grey : null),
                  decoration: unavailable ? TextDecoration.lineThrough : null)),
          Text(unavailable ? (booked.contains(h) ? 'Booked' : 'Past') : rupee(t.pricePerHour),
              style: TextStyle(color: unavailable ? Colors.grey : AppColors.greenDark)),
        ]),
      ),
    );
  }
}
