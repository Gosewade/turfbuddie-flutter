import 'package:flutter/material.dart';
import 'package:turfbuddie_mock/core/formatters.dart';
import 'package:turfbuddie_mock/core/theme.dart';
import 'package:turfbuddie_mock/models/models.dart';
import 'package:turfbuddie_mock/state/app_state.dart';
import 'package:turfbuddie_mock/widgets/common.dart';

class BookingDetailScreen extends StatelessWidget {
  const BookingDetailScreen({super.key, required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context); // rebuilds on state change
    final b = booking;
    final confirmed = b.status == BookingStatus.confirmed;
    return Scaffold(
      appBar: AppBar(title: Text('Booking ${b.id}', style: const TextStyle(fontWeight: FontWeight.w800))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: b.status == BookingStatus.cancelled ? AppColors.red : (confirmed ? AppColors.green : AppColors.orange),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(b.status == BookingStatus.cancelled ? '\u274C Booking cancelled' : (confirmed ? '\u2705 Booking confirmed' : '\u23F3 Waiting for squad payments'),
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text(b.turf.name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
              Text('${longDate(b.date)}\n${hoursSummary(b.hours)}', style: const TextStyle(color: Colors.white70)),
            ]),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(children: [
              _r('Base price (${b.hours.length} slots)', rupee(b.price.base)),
              if (b.price.couponDiscount > 0) _r('Coupon', '-${rupee(b.price.couponDiscount)}'),
              _r('Platform fee', rupee(b.price.platformFee)),
              _r('GST', rupee(b.price.gst)),
              if (b.price.pointsDiscount > 0) _r('Redeemed loyalty points', '-${rupee(b.price.pointsDiscount)}'),
              const Divider(),
              _r('Total', rupee(b.price.total), big: true),
            ]),
          ),
          if (b.status == BookingStatus.confirmed && !b.date.isBefore(DateTime.now().subtract(const Duration(days: 1)))) ...[
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: () {
                s.update(() => b.status = BookingStatus.cancelled);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking cancelled (mock refund initiated)')));
              },
              child: const Text('Cancel booking', style: TextStyle(color: AppColors.red)),
            ),
          ],
          if (b.squad.isNotEmpty) ...[
            const SizedBox(height: 20),
            Row(children: [
              const Text('Squad Members', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              const Spacer(),
              Text('${b.paidCount} paid \u00B7 ${b.squad.length - b.paidCount} pending',
                  style: const TextStyle(color: Colors.grey)),
            ]),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: b.paidCount / b.squad.length,
                minHeight: 8,
                color: AppColors.green,
                backgroundColor: AppColors.greenSoft,
              ),
            ),
            const SizedBox(height: 12),
            for (final m in b.squad)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(children: [
                    CircleAvatar(
                      backgroundColor: m.paid ? AppColors.greenSoft : const Color(0xFFFEF9C3),
                      child: Text(m.name[0],
                          style: TextStyle(fontWeight: FontWeight.w900, color: m.paid ? AppColors.greenDark : Colors.red.shade800)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(m.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                        Text(m.isOrganiser ? 'Organiser' : m.phone, style: const TextStyle(color: Colors.grey)),
                      ]),
                    ),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text(rupee(m.amount), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                      if (m.paid)
                        const Text('\u2713 Paid', style: TextStyle(color: AppColors.greenDark, fontWeight: FontWeight.w700))
                      else
                        TextButton(
                          style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 24)),
                          onPressed: () {
                            s.markMemberPaid(b, m);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(b.status == BookingStatus.confirmed
                                    ? 'All paid \u2014 booking auto-confirmed \u2705'
                                    : '${m.name} paid ${rupee(m.amount)}')));
                          },
                          child: const Text('\u23F3 Pending (simulate pay)',
                              style: TextStyle(color: AppColors.orange, fontSize: 12, fontWeight: FontWeight.w700)),
                        ),
                    ]),
                  ]),
                ),
              ),
            const SizedBox(height: 4),
            const Text(
              'Demo: tap "Pending" to simulate a teammate paying their UPI link. In production this is a Razorpay webhook.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }

  Widget _r(String l, String v, {bool big = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [
          Expanded(child: Text(l, style: TextStyle(fontSize: big ? 18 : 15, fontWeight: big ? FontWeight.w900 : FontWeight.w500))),
          Text(v, style: TextStyle(fontSize: big ? 20 : 15, fontWeight: FontWeight.w800, color: big ? AppColors.green : null)),
        ]),
      );
}
