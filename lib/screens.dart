import 'package:flutter/material.dart';
import 'data.dart';
import 'theme.dart';

// ───────────────────────── Shell (bottom nav) ─────────────────────────
class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _i = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _i,
          children: const [HomeScreen(), BookingsScreen(), ProfileScreen()],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _i,
        onDestinationSelected: (v) => setState(() => _i = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.event_note_outlined), selectedIcon: Icon(Icons.event_note), label: 'Bookings'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// ───────────────────────── Home ─────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _sport = 'All';
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final list = turfs
        .where((t) =>
            (_sport == 'All' || t.sports.contains(_sport)) &&
            (t.name.toLowerCase().contains(_q.toLowerCase()) ||
                t.area.toLowerCase().contains(_q.toLowerCase())))
        .toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        Row(children: [
          Image.asset('assets/logo.png', height: 48, width: 48),
          const SizedBox(width: 10),
          const Expanded(
            child: Text('TurfBuddie', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          ),
          const Icon(Icons.location_on_outlined, size: 18),
          const SizedBox(width: 2),
          const Text('Nagpur', style: TextStyle(fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 16),
        const _Hero(),
        const SizedBox(height: 16),
        TextField(
          onChanged: (v) => setState(() => _q = v),
          decoration: InputDecoration(
            hintText: 'Find turfs near you',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: sportsList.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final s = sportsList[i];
              final sel = s == _sport;
              return ChoiceChip(
                label: Text(s),
                selected: sel,
                showCheckmark: false,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: sel ? Colors.white : null,
                ),
                onSelected: (_) => setState(() => _sport = s),
              );
            },
          ),
        ),
        const SizedBox(height: 18),
        const Text('Turfs for you', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        if (list.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: Text('No turfs found')),
          ),
        for (final t in list) ...[
          _TurfCard(t),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [AppColors.green, AppColors.greenLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Book your turf.',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white)),
          SizedBox(height: 6),
          Text('Book the perfect ground for your next match.',
              style: TextStyle(fontSize: 14, color: Colors.white)),
        ],
      ),
    );
  }
}

class _RatingPill extends StatelessWidget {
  final double rating;
  const _RatingPill(this.rating);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.green.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.star_rounded, size: 16, color: AppColors.green),
        const SizedBox(width: 3),
        Text('$rating', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
      ]),
    );
  }
}

class _TurfCard extends StatelessWidget {
  final Turf t;
  const _TurfCard(this.t);
  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TurfDetailsScreen(t))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Image.asset(t.image, height: 160, width: double.infinity, fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(t.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text(t.area, style: const TextStyle(fontSize: 12.5)),
                  const SizedBox(height: 8),
                  Text('₹${t.price}/hr',
                      style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.green)),
                ]),
              ),
              _RatingPill(t.rating),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ───────────────────────── Turf details ─────────────────────────
class TurfDetailsScreen extends StatelessWidget {
  final Turf t;
  const TurfDetailsScreen(this.t, {super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Turf details')),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 0, 20, 24), children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(t.image, height: 200, width: double.infinity, fit: BoxFit.cover),
        ),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: Text(t.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900))),
          _RatingPill(t.rating),
        ]),
        const SizedBox(height: 4),
        Text(t.area),
        const SizedBox(height: 16),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final s in t.sports) Chip(label: Text(s), avatar: const Icon(Icons.sports_soccer, size: 16)),
        ]),
        const SizedBox(height: 20),
        const Text('Amenities', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final a in t.amenities) Chip(label: Text(a)),
        ]),
        const SizedBox(height: 20),
        Text('₹${t.price} / hour',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.green)),
      ]),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: FilledButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SlotScreen(t))),
            child: const Text('Book this turf'),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── Slot selection ─────────────────────────
class SlotScreen extends StatefulWidget {
  final Turf t;
  const SlotScreen(this.t, {super.key});
  @override
  State<SlotScreen> createState() => _SlotScreenState();
}

class _SlotScreenState extends State<SlotScreen> {
  int _day = 0;
  int? _hour;

  DateTime get _date {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day).add(Duration(days: _day));
  }

  bool _booked(int h) => (h + _date.day) % 4 == 0;

  bool _past(int h) {
    if (_day != 0) return false;
    return h <= DateTime.now().hour;
  }

  @override
  Widget build(BuildContext context) {
    final hours = [for (var h = 6; h < 24; h++) h];
    return Scaffold(
      appBar: AppBar(title: const Text('Select slot')),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 0, 20, 24), children: [
        const Text('Date', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 7,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final d = DateTime.now().add(Duration(days: i));
              final sel = i == _day;
              return ChoiceChip(
                label: Text(fmtDate(d)),
                selected: sel,
                showCheckmark: false,
                labelStyle: TextStyle(fontWeight: FontWeight.w700, color: sel ? Colors.white : null),
                onSelected: (_) => setState(() {
                  _day = i;
                  _hour = null;
                }),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        const Text('Available time slots', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final h in hours)
            ChoiceChip(
              label: Text(slotLabel(h)),
              selected: _hour == h,
              showCheckmark: false,
              labelStyle: TextStyle(
                fontWeight: FontWeight.w700,
                color: _hour == h ? Colors.white : null,
              ),
              onSelected: (_booked(h) || _past(h)) ? null : (_) => setState(() => _hour = h),
            ),
        ]),
        const SizedBox(height: 12),
        const Text('Greyed-out slots are already booked or passed.', style: TextStyle(fontSize: 12)),
      ]),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: FilledButton(
            onPressed: _hour == null
                ? null
                : () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SummaryScreen(widget.t, _date, _hour!)),
                    ),
            child: const Text('Continue'),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── Summary + payment ─────────────────────────
class SummaryScreen extends StatefulWidget {
  final Turf t;
  final DateTime date;
  final int hour;
  const SummaryScreen(this.t, this.date, this.hour, {super.key});
  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  String _pay = 'UPI';
  static const _fee = 20;

  Widget _line(String a, String b, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          Expanded(child: Text(a, style: TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w500))),
          Text(b, style: TextStyle(fontWeight: bold ? FontWeight.w900 : FontWeight.w600)),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final total = widget.t.price + _fee;
    return Scaffold(
      appBar: AppBar(title: const Text('Booking summary')),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 0, 20, 24), children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.t.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              Text(widget.t.area),
              const Divider(height: 24),
              _line('Date', fmtDate(widget.date)),
              _line('Time', slotLabel(widget.hour)),
            ]),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              _line('Turf charge (1 hr)', '₹${widget.t.price}'),
              _line('Convenience fee', '₹$_fee'),
              const Divider(height: 24),
              _line('Total payable', '₹$total', bold: true),
            ]),
          ),
        ),
        const SizedBox(height: 16),
        const Text('Payment method', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        for (final p in const ['UPI', 'Card', 'Pay at venue'])
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Card(
              child: ListTile(
                onTap: () => setState(() => _pay = p),
                title: Text(p, style: const TextStyle(fontWeight: FontWeight.w700)),
                trailing: Icon(
                  _pay == p ? Icons.check_circle : Icons.circle_outlined,
                  color: _pay == p ? AppColors.green : null,
                ),
              ),
            ),
          ),
        const SizedBox(height: 4),
        const Row(children: [
          Icon(Icons.lock_outline, size: 16),
          SizedBox(width: 6),
          Expanded(child: Text('Demo checkout - no real payment is taken.', style: TextStyle(fontSize: 12))),
        ]),
      ]),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: FilledButton(
            onPressed: () {
              final id = 'TB${DateTime.now().millisecondsSinceEpoch % 1000000}';
              final b = Booking(
                id: id,
                turf: widget.t,
                date: widget.date,
                hour: widget.hour,
                amount: total,
                payment: _pay,
              );
              BookingsRepo.instance.add(b);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => ConfirmationScreen(b)),
                (r) => r.isFirst,
              );
            },
            child: Text('Confirm booking  •  ₹$total'),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── Confirmation ─────────────────────────
class ConfirmationScreen extends StatelessWidget {
  final Booking b;
  const ConfirmationScreen(this.b, {super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.check_circle, size: 96, color: AppColors.green),
            const SizedBox(height: 16),
            const Text('Booking request created!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            const Text('Your slot is confirmed. Please reach 10 minutes early and show your booking ID.',
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  Text('Booking ID  ${b.id}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(b.turf.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text('${fmtDate(b.date)}  •  ${slotLabel(b.hour)}'),
                  Text('₹${b.amount}  •  ${b.payment}'),
                ]),
              ),
            ),
            const Spacer(),
            FilledButton(
              onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
              child: const Text('Back to turfs'),
            ),
          ]),
        ),
      ),
    );
  }
}

// ───────────────────────── Bookings tab ─────────────────────────
class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: BookingsRepo.instance,
      builder: (_, __) {
        final items = BookingsRepo.instance.items;
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text('Bookings', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          ),
          Expanded(
            child: items.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('Book a turf and your games will show up here.', textAlign: TextAlign.center),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final b = items[i];
                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(b.turf.image, width: 56, height: 56, fit: BoxFit.cover),
                          ),
                          title: Text(b.turf.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                          subtitle: Text('${fmtDate(b.date)} • ${slotLabel(b.hour)}\nID ${b.id}'),
                          isThreeLine: true,
                          trailing: Text('₹${b.amount}', style: const TextStyle(fontWeight: FontWeight.w800)),
                        ),
                      );
                    },
                  ),
          ),
        ]);
      },
    );
  }
}

// ───────────────────────── Profile ─────────────────────────
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(20), children: [
      const Text('Profile', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
      const SizedBox(height: 16),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            const CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.green,
              child: Icon(Icons.person, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Demo Player', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                Text('Nagpur'),
              ]),
            ),
          ]),
        ),
      ),
      const SizedBox(height: 12),
      Card(
        child: ValueListenableBuilder<ThemeMode>(
          valueListenable: themeMode,
          builder: (_, m, __) => SwitchListTile(
            title: const Text('Dark mode', style: TextStyle(fontWeight: FontWeight.w700)),
            value: m == ThemeMode.dark,
            activeColor: AppColors.green,
            onChanged: (v) => themeMode.value = v ? ThemeMode.dark : ThemeMode.light,
          ),
        ),
      ),
    ]);
  }
}
