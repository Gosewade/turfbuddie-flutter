import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:turfbuddie_mock/core/config.dart';
import 'package:turfbuddie_mock/core/formatters.dart';
import 'package:turfbuddie_mock/core/theme.dart';
import 'package:turfbuddie_mock/models/models.dart';
import 'package:turfbuddie_mock/screens/auth_screen.dart';
import 'package:turfbuddie_mock/screens/split_pay_screen.dart';
import 'package:turfbuddie_mock/state/app_state.dart';
import 'package:turfbuddie_mock/widgets/common.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key, required this.turf, required this.date, required this.hours});
  final Turf turf;
  final DateTime date;
  final List<int> hours;
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final couponCtrl = TextEditingController();
  bool usePoints = false;
  bool applying = false;
  double couponDiscount = 0;
  String? couponCode;
  String? couponMsg;
  bool couponOk = false;

  @override
  void dispose() {
    couponCtrl.dispose();
    super.dispose();
  }

  double get base => (widget.turf.pricePerHour * widget.hours.length).toDouble();

  int _pointsToUse(AppState s) {
    if (!usePoints) return 0;
    final maxByAmount = ((base - couponDiscount) / Config.loyaltyPointValue).floor();
    return math.min(s.loyaltyPoints, math.max(0, maxByAmount));
  }

  PriceBreakdown _price(AppState s) => PriceBreakdown.calc(
        base: base,
        couponDiscount: couponDiscount,
        pointsDiscount: _pointsToUse(s) * Config.loyaltyPointValue,
      );

  Future<void> _applyCoupon(AppState s) async {
    if (couponCtrl.text.trim().isEmpty) return;
    setState(() => applying = true);
    final r = await s.service.validateCoupon(couponCtrl.text, base);
    if (!mounted) return;
    setState(() {
      applying = false;
      couponOk = r.valid;
      couponMsg = r.message;
      couponDiscount = r.valid ? r.discount : 0;
      couponCode = r.valid ? couponCtrl.text.trim().toUpperCase() : null;
    });
  }

  Future<void> _payFull(AppState s, PriceBreakdown pb) async {
    if (!await requireLogin(context)) return;
    if (!mounted) return;
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showPaymentSheet(context, amount: pb.total, title: 'Pay for booking');
    if (ok != true) return;
    s.addBooking(Booking(
      id: s.newBookingId(),
      turf: widget.turf,
      date: widget.date,
      hours: widget.hours,
      price: pb,
      status: BookingStatus.confirmed,
      couponCode: couponCode,
      pointsUsed: _pointsToUse(s),
    ));
    nav.popUntil((r) => r.isFirst);
    s.update(() => s.tab = AppState.tabBooking);
    messenger.showSnackBar(const SnackBar(
        content: Text('Booking confirmed \u2705  WhatsApp confirmation within 30 seconds')));
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final cs = Theme.of(context).colorScheme;
    final pb = _price(s);

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.w800))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Text('Review your booking details and complete payment',
              style: TextStyle(fontSize: 16, color: cs.onSurface.withAlpha(180))),
          const SizedBox(height: 16),
          AppCard(
            padding: const EdgeInsets.all(18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('\u{1F552} Booking Summary', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
              const SizedBox(height: 16),
              _row('Turf', widget.turf.name),
              _row('Date', longDate(widget.date)),
              _row('Slots', hoursSummary(widget.hours)),
              const Divider(height: 28),
              _row('Base Price (${widget.hours.length} slots)', rupee(pb.base)),
              if (pb.couponDiscount > 0)
                _row('Coupon ($couponCode)', '-${rupee(pb.couponDiscount)}', valueColor: AppColors.green),
              if (pb.pointsDiscount > 0)
                _row('Loyalty points', '-${rupee(pb.pointsDiscount)}', valueColor: AppColors.green),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: AppColors.green,
                value: usePoints,
                onChanged: s.loyaltyPoints == 0 ? null : (v) => setState(() => usePoints = v ?? false),
                title: Text(
                    'Redeem ${s.loyaltyPoints} loyalty points (-${rupee(s.loyaltyPoints * Config.loyaltyPointValue)})'),
              ),
              const SizedBox(height: 4),
              const Text('Coupon Code', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: couponCtrl,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'ENTER COUPON CODE',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 52,
                  child: FilledButton(
                    onPressed: applying ? null : () => _applyCoupon(s),
                    style: FilledButton.styleFrom(
                        backgroundColor: AppColors.green,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    child: applying
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Apply', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ]),
              if (couponMsg != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(couponMsg!, style: TextStyle(color: couponOk ? AppColors.green : AppColors.red, fontSize: 13)),
                ),
              const Text('Try: TURF10 or FIRST50', style: TextStyle(fontSize: 11, color: Colors.grey)),
              const Divider(height: 28),
              _row('GST (${(Config.gstRate * 100).round()}%)', rupee(pb.gst), bold: true),
              _row('Platform Fee', rupee(pb.platformFee), bold: true),
              const SizedBox(height: 6),
              Row(children: [
                const Text('Total Amount', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
                const Spacer(),
                Text(rupee(pb.total),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.green)),
              ]),
            ]),
          ),
          const SizedBox(height: 20),
          GreenButton(label: 'Pay ${rupee(pb.total)}', icon: '\u{1F512}', onPressed: () => _payFull(s, pb)),
          const SizedBox(height: 10),
          const Center(child: Text('\u2014 or \u2014', style: TextStyle(color: Colors.grey))),
          const SizedBox(height: 10),
          GreenButton(
            label: 'Split with Teammates',
            icon: '\u{1F4B8}',
            outlined: true,
            onPressed: () async {
              if (!await requireLogin(context)) return;
              if (!mounted) return;
              Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => SplitPayScreen(
                turf: widget.turf,
                date: widget.date,
                hours: widget.hours,
                price: pb,
                couponCode: couponCode,
                pointsUsed: _pointsToUse(s),
              ),
            ));
            },
          ),
          const SizedBox(height: 14),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            for (final m in ['UPI', 'GPay', 'PhonePe', 'Card'])
              Text(m, style: TextStyle(color: cs.onSurface.withAlpha(150))),
          ]),
          const SizedBox(height: 14),
          AppCard(
            child: const Text('\u{1F514} You\'ll receive a WhatsApp confirmation within 30 seconds',
                textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }

  Widget _row(String l, String v, {bool bold = false, Color? valueColor}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
              child: Text(l, style: TextStyle(fontSize: 16, fontWeight: bold ? FontWeight.w800 : FontWeight.w500))),
          const SizedBox(width: 12),
          Flexible(
            child: Text(v,
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 16, fontWeight: bold ? FontWeight.w800 : FontWeight.w600, color: valueColor)),
          ),
        ]),
      );
}
