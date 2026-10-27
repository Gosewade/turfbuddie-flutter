import 'package:flutter/material.dart';
import 'package:turfbuddie_mock/core/formatters.dart';
import 'package:turfbuddie_mock/core/theme.dart';
import 'package:turfbuddie_mock/models/models.dart';
import 'package:turfbuddie_mock/screens/booking_detail_screen.dart';
import 'package:turfbuddie_mock/state/app_state.dart';
import 'package:turfbuddie_mock/widgets/common.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});
  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  String f = 'All';

  bool _past(Booking b) {
    final n = DateTime.now();
    return DateTime(b.date.year, b.date.month, b.date.day).isBefore(DateTime(n.year, n.month, n.day));
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final list = s.bookings.where((b) {
      switch (f) {
        case 'Confirmed':
          return b.status == BookingStatus.confirmed;
        case 'Cancelled':
          return b.status == BookingStatus.cancelled;
        case 'Previous':
          return _past(b) && b.status != BookingStatus.cancelled;
        default:
          return true;
      }
    }).toList();

    return Column(children: [
      const GreenHeader('My Bookings', dark: true, tall: true),
      Expanded(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final c in ['All', 'Confirmed', 'Cancelled', 'Previous'])
                Pill(f == c ? '\u2713 $c' : c, selected: f == c, onTap: () => setState(() => f = c)),
            ]),
            const SizedBox(height: 14),
            if (list.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(children: [
                  const Text('\u{1F3DF}\uFE0F', style: TextStyle(fontSize: 52)),
                  const SizedBox(height: 8),
                  const Text('No bookings here yet', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                  const SizedBox(height: 12),
                  GreenButton(label: 'Browse Turfs', compact: true, onPressed: () => s.update(() => s.tab = AppState.tabTurfs)),
                ]),
              ),
            for (final b in list)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppCard(
                  padding: const EdgeInsets.all(10),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => BookingDetailScreen(booking: b))),
                  child: Row(children: [
                    SizedBox(width: 92, height: 100, child: TurfThumb(b.turf, height: 100)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('${b.turf.area}, Nagpur', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
                        Text('${dayLong(b.date)}, ${hoursSummary(b.hours)} - ${shortDate(b.date)}',
                            style: const TextStyle(color: Colors.grey, fontSize: 11)),
                        const SizedBox(height: 4),
                        Row(children: [
                          const Icon(Icons.star, size: 14, color: AppColors.amber),
                          Text(' ${b.turf.rating}', style: const TextStyle(fontSize: 12)),
                        ]),
                        Text(rupee(b.price.total), style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 4),
                        Row(children: [
                          _status(b),
                          const SizedBox(width: 8),
                          Expanded(child: Text('Txn: ${b.txn}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey, fontSize: 10))),
                        ]),
                      ]),
                    ),
                  ]),
                ),
              ),
          ],
        ),
      ),
    ]);
  }

  Widget _status(Booking b) {
    late final String t;
    late final Color c;
    switch (b.status) {
      case BookingStatus.confirmed:
        t = 'Confirmed';
        c = AppColors.green;
      case BookingStatus.cancelled:
        t = 'Cancelled';
        c = AppColors.red;
      case BookingStatus.awaitingSplit:
        t = 'Split ${b.paidCount}/${b.squad.length}';
        c = AppColors.orange;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(12)),
      child: Text(t, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}
