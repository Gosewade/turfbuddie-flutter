import 'package:flutter/material.dart';
import 'package:turfbuddie_mock/core/config.dart';
import 'package:turfbuddie_mock/core/formatters.dart';
import 'package:turfbuddie_mock/core/theme.dart';
import 'package:turfbuddie_mock/models/models.dart';
import 'package:turfbuddie_mock/screens/booking_detail_screen.dart';
import 'package:turfbuddie_mock/state/app_state.dart';
import 'package:turfbuddie_mock/widgets/common.dart';

class SplitPayScreen extends StatefulWidget {
  const SplitPayScreen({
    super.key,
    required this.turf,
    required this.date,
    required this.hours,
    required this.price,
    this.couponCode,
    this.pointsUsed = 0,
  });
  final Turf turf;
  final DateTime date;
  final List<int> hours;
  final PriceBreakdown price;
  final String? couponCode;
  final int pointsUsed;

  @override
  State<SplitPayScreen> createState() => _SplitPayScreenState();
}

class _SplitPayScreenState extends State<SplitPayScreen> {
  final phoneCtrl = TextEditingController();
  final List<String> phones = []; // teammates (organiser is implicit)
  String? error;
  bool sending = false;

  @override
  void dispose() {
    phoneCtrl.dispose();
    super.dispose();
  }

  int get count => phones.length + 1;
  double get share => (widget.price.total / count).ceilToDouble();

  String _fmt(String p) => '+91 ${p.substring(0, 5)} ${p.substring(5)}';

  void _add() {
    final p = phoneCtrl.text.replaceAll(RegExp(r'\D'), '');
    final ten = p.length > 10 ? p.substring(p.length - 10) : p;
    if (ten.length != 10) {
      setState(() => error = 'Enter a valid 10-digit number');
      return;
    }
    if (phones.contains(ten)) {
      setState(() => error = 'Number already added');
      return;
    }
    if (count >= Config.splitMaxPlayers) {
      setState(() => error = 'Max ${Config.splitMaxPlayers} players');
      return;
    }
    setState(() {
      phones.add(ten);
      phoneCtrl.clear();
      error = null;
    });
  }

  void _demo() => setState(() {
        for (final p in ['9876543210', '8765432109', '7654321098']) {
          if (!phones.contains(p)) phones.add(p);
        }
      });

  Future<void> _send(AppState s) async {
    final nav = Navigator.of(context);
    final shareNow = share;
    final ok = await showPaymentSheet(context, amount: shareNow, title: 'Pay your share');
    if (ok != true) return;
    setState(() => sending = true);

    const names = ['Aryan K.', 'Rohit S.', 'Vikram P.', 'Sneha D.', 'Kunal M.'];
    final squad = <SquadMember>[
      SquadMember(name: s.userName, phone: 'You', amount: shareNow, paid: true, isOrganiser: true),
      for (var i = 0; i < phones.length; i++)
        SquadMember(
            name: i < names.length ? names[i] : 'Player ${i + 2}',
            phone: _fmt(phones[i]),
            amount: shareNow),
    ];
    final booking = Booking(
      id: s.newBookingId(),
      turf: widget.turf,
      date: widget.date,
      hours: widget.hours,
      price: widget.price,
      status: BookingStatus.awaitingSplit,
      squad: squad,
      couponCode: widget.couponCode,
      pointsUsed: widget.pointsUsed,
    );
    await s.service.sendSplitLinks(booking);
    s.addBooking(booking);
    s.update(() => s.tab = AppState.tabBooking);
    nav.popUntil((r) => r.isFirst);
    nav.push(MaterialPageRoute(builder: (_) => BookingDetailScreen(booking: booking)));
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Split Payment', style: TextStyle(fontWeight: FontWeight.w800))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Text('Everyone pays their share via WhatsApp + UPI.',
              style: TextStyle(fontSize: 16, color: cs.onSurface.withAlpha(180))),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: AppColors.green, borderRadius: BorderRadius.circular(18)),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${widget.turf.name}',
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text('${shortDate(widget.date)} \u00B7 ${hoursSummary(widget.hours)}',
                      style: const TextStyle(color: Colors.white70)),
                ]),
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                const Text('Total', style: TextStyle(color: Colors.white70, fontSize: 12)),
                Text(rupee(widget.price.total),
                    style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
              ]),
            ]),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Row(children: [
              const Text('Split between', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              const Spacer(),
              Text('$count', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
              const Text(' players'),
            ]),
          ),
          const SizedBox(height: 10),
          AppCard(
            color: AppColors.greenSoft.withAlpha(60),
            child: Row(children: [
              Expanded(child: Text('${rupee(widget.price.total)} \u00F7 $count players', style: const TextStyle(fontSize: 16))),
              Text(rupee(share), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.greenDark)),
              const Text(' each'),
            ]),
          ),
          const SizedBox(height: 20),
          const Text('Squad Members', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          _member(s.userName, 'Organiser', 'You pay first'),
          for (var i = 0; i < phones.length; i++)
            _member('Player ${i + 2}', _fmt(phones[i]), 'Pending', onRemove: () => setState(() => phones.removeAt(i))),
          const SizedBox(height: 8),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                onSubmitted: (_) => _add(),
                decoration: InputDecoration(
                  hintText: '+ Add teammate phone number',
                  errorText: error,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 56,
              child: FilledButton(
                onPressed: _add,
                style: FilledButton.styleFrom(
                    backgroundColor: AppColors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: const Text('Add', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          ]),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(onPressed: _demo, child: const Text('Add 3 demo teammates', style: TextStyle(color: AppColors.greenDark))),
          ),
          const SizedBox(height: 8),
          GreenButton(
            label: 'Pay your share & send WhatsApp links',
            icon: '\u{1F4AC}',
            color: AppColors.whatsapp,
            onPressed: phones.isEmpty || sending ? null : () => _send(s),
          ),
          if (phones.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Center(child: Text('Add at least one teammate', style: TextStyle(color: Colors.grey, fontSize: 12))),
            ),
        ],
      ),
    );
  }

  Widget _member(String name, String sub, String status, {VoidCallback? onRemove}) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(children: [
            CircleAvatar(
                backgroundColor: AppColors.greenSoft,
                child: Text(name[0], style: const TextStyle(color: AppColors.greenDark, fontWeight: FontWeight.w900))),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                Text(sub, style: const TextStyle(color: Colors.grey)),
              ]),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(rupee(share), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              Text(status, style: const TextStyle(color: AppColors.orange, fontSize: 12, fontWeight: FontWeight.w700)),
            ]),
            if (onRemove != null)
              IconButton(onPressed: onRemove, icon: const Icon(Icons.close, size: 18)),
          ]),
        ),
      );
}
