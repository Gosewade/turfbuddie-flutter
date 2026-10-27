import 'package:flutter/material.dart';
import 'package:turfbuddie_mock/core/formatters.dart';
import 'package:turfbuddie_mock/core/theme.dart';
import 'package:turfbuddie_mock/models/models.dart';
import 'package:turfbuddie_mock/screens/turf_detail_screen.dart';
import 'package:turfbuddie_mock/state/app_state.dart';

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.onTap, this.color});
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(20);
    return Material(
      color: color ?? cs.surface,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(borderRadius: radius, border: Border.all(color: cs.outlineVariant)),
          child: child,
        ),
      ),
    );
  }
}

class Pill extends StatelessWidget {
  const Pill(this.label, {super.key, this.selected = false, this.onTap, this.strike = false});
  final String label;
  final bool selected, strike;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fg = selected
        ? Colors.white
        : (strike ? cs.onSurface.withAlpha(110) : cs.onSurface);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: strike ? null : onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.green : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: selected ? AppColors.green : cs.outlineVariant),
          ),
          child: Text(label,
              style: TextStyle(
                  color: fg,
                  fontWeight: FontWeight.w600,
                  decoration: strike ? TextDecoration.lineThrough : null)),
        ),
      ),
    );
  }
}

class GreenButton extends StatelessWidget {
  const GreenButton({super.key, required this.label, required this.onPressed, this.outlined = false, this.icon, this.compact = false, this.color});
  final String label;
  final VoidCallback? onPressed;
  final bool outlined, compact;
  final String? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.green;
    final child = Text(icon == null ? label : '$icon  $label',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700));
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(compact ? 12 : 16));
    final size = Size(compact ? 0 : double.infinity, compact ? 40 : 54);
    if (outlined) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
            minimumSize: size, shape: shape, foregroundColor: c, side: BorderSide(color: c, width: 1.5)),
        child: child,
      );
    }
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
          minimumSize: size, shape: shape, backgroundColor: c, foregroundColor: Colors.white),
      child: child,
    );
  }
}

class SectionTag extends StatelessWidget {
  const SectionTag(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.greenSoft,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.green.withAlpha(90)),
        ),
        child: Text(text,
            style: const TextStyle(
                color: AppColors.greenDark, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 0.6)),
      );
}

class TitleGreen extends StatelessWidget {
  const TitleGreen(this.black, this.green, {super.key, this.size = 30});
  final String black, green;
  final double size;
  @override
  Widget build(BuildContext context) => Text.rich(TextSpan(
        style: TextStyle(fontSize: size, fontWeight: FontWeight.w900, height: 1.15),
        children: [
          TextSpan(text: '$black '),
          TextSpan(text: green, style: const TextStyle(color: AppColors.green)),
        ],
      ));
}

const _gradients = [
  [Color(0xFF14532D), Color(0xFF22C55E)],
  [Color(0xFF065F46), Color(0xFF34D399)],
  [Color(0xFF166534), Color(0xFF86EFAC)],
  [Color(0xFF0F3D2E), Color(0xFF16A34A)],
];

class TurfThumb extends StatelessWidget {
  const TurfThumb(this.turf, {super.key, this.height = 150});
  final Turf turf;
  final double height;
  @override
  Widget build(BuildContext context) => Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
              colors: _gradients[turf.colorIndex % _gradients.length],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
        ),
        alignment: Alignment.center,
        child: Text(sportEmoji[turf.sports.first] ?? '\u26BD', style: const TextStyle(fontSize: 56)),
      );
}

class RatingChip extends StatelessWidget {
  const RatingChip(this.rating, {super.key});
  final double rating;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: AppColors.greenSoft, borderRadius: BorderRadius.circular(999)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.star, size: 15, color: AppColors.green),
          const SizedBox(width: 3),
          Text('$rating',
              style: const TextStyle(color: AppColors.greenDark, fontWeight: FontWeight.w800)),
        ]),
      );
}

class PriceChip extends StatelessWidget {
  const PriceChip(this.price, {super.key});
  final int price;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: AppColors.green, borderRadius: BorderRadius.circular(12)),
        child: Text('${rupee(price)}/hr',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
      );
}

class TurfCard extends StatelessWidget {
  const TurfCard(this.turf, {super.key});
  final Turf turf;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AppCard(
      padding: const EdgeInsets.all(12),
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => TurfDetailScreen(turf: turf))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TurfThumb(turf),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
              child: Text(turf.name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
          RatingChip(turf.rating),
        ]),
        const SizedBox(height: 6),
        Row(children: [
          const Icon(Icons.location_on, size: 16, color: AppColors.red),
          const SizedBox(width: 4),
          Expanded(
              child: Text('${turf.distanceKm} km \u00B7 ${turf.area}',
                  style: TextStyle(color: cs.onSurface.withAlpha(180)))),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Text(turf.sports.map((s) => sportEmoji[s] ?? '').join(' '),
              style: const TextStyle(fontSize: 18)),
          const Spacer(),
          if (turf.isOpenNow)
            const Padding(
              padding: EdgeInsets.only(right: 10),
              child: Text('\u25CF Open now',
                  style: TextStyle(color: AppColors.green, fontWeight: FontWeight.w700, fontSize: 12)),
            ),
          PriceChip(turf.pricePerHour),
        ]),
      ]),
    );
  }
}

/// Mock Razorpay sheet. Replace body with Razorpay checkout call.
Future<bool?> showPaymentSheet(BuildContext context, {required double amount, String title = 'Complete payment'}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _PaymentSheet(amount: amount, title: title),
  );
}

class _PaymentSheet extends StatefulWidget {
  const _PaymentSheet({required this.amount, required this.title});
  final double amount;
  final String title;
  @override
  State<_PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<_PaymentSheet> {
  String method = 'UPI';
  bool busy = false;

  Future<void> _pay() async {
    setState(() => busy = true);
    final ok = await AppScope.of(context).service.pay(amount: widget.amount, method: method);
    if (mounted) Navigator.pop(context, ok);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(widget.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(rupee(widget.amount),
            style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: AppColors.green)),
        const SizedBox(height: 14),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final m in ['UPI', 'GPay', 'PhonePe', 'Card'])
            Pill(m, selected: method == m, onTap: busy ? null : () => setState(() => method = m)),
        ]),
        const SizedBox(height: 8),
        const Text('Mock payment (Razorpay test mode placeholder)',
            style: TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 16),
        busy
            ? const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator()))
            : GreenButton(label: 'Pay ${rupee(widget.amount)}', icon: '\u{1F512}', onPressed: _pay),
      ]),
    );
  }
}


class GreenHeader extends StatelessWidget {
  const GreenHeader(this.title, {super.key, this.subtitle, this.icon, this.onTap, this.dark = false, this.tall = false});
  final String title;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool dark, tall;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: tall ? 190 : 0),
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 28, 20, 22),
      decoration: BoxDecoration(
        color: dark ? null : AppColors.header,
        gradient: dark
            ? const LinearGradient(colors: [Color(0xFF2B3B2F), Color(0xFF0F1A12)], begin: Alignment.topCenter, end: Alignment.bottomCenter)
            : null,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
        if (tall) const SizedBox(height: 60),
        if (subtitle != null)
          Text(subtitle!, style: const TextStyle(color: Colors.white70, fontSize: 17, fontWeight: FontWeight.w500)),
        GestureDetector(
          onTap: onTap,
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (icon != null) ...[Icon(icon, color: Colors.white, size: 24), const SizedBox(width: 4)],
            Flexible(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900))),
          ]),
        ),
      ]),
    );
  }
}

class SearchBox extends StatelessWidget {
  const SearchBox({super.key, required this.hint, this.onChanged, this.onTap, this.readOnly = false});
  final String hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  @override
  Widget build(BuildContext context) => AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: TextField(
          readOnly: readOnly,
          onTap: onTap,
          onChanged: onChanged,
          decoration: InputDecoration(
            icon: const Icon(Icons.search, color: AppColors.green),
            hintText: hint,
            border: InputBorder.none,
          ),
        ),
      );
}

class TurfRowCard extends StatelessWidget {
  const TurfRowCard(this.turf, {super.key});
  final Turf turf;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: const EdgeInsets.all(10),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => TurfDetailScreen(turf: turf))),
        child: Row(children: [
          SizedBox(width: 96, height: 100, child: TurfThumb(turf, height: 100)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(turf.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800))),
                RatingChip(turf.rating),
              ]),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 3),
                Expanded(child: Text(turf.area, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey, fontSize: 12))),
              ]),
              const SizedBox(height: 2),
              Row(children: [
                const Icon(Icons.directions_walk, size: 14, color: AppColors.green),
                Text(' ${turf.distanceKm} km', style: const TextStyle(color: AppColors.green, fontSize: 12)),
              ]),
              const SizedBox(height: 6),
              Row(children: [
                Text('${rupee(turf.pricePerHour)} / hour', style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.w800)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: AppColors.greenSoft, borderRadius: BorderRadius.circular(12)),
                  child: const Text('Book Now', style: TextStyle(color: AppColors.greenDark, fontWeight: FontWeight.w700, fontSize: 12)),
                ),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

void pickCity(BuildContext context) {
  final s = AppScope.of(context);
  showDialog(
    context: context,
    builder: (ctx) => SimpleDialog(
      title: const Text('Select city'),
      children: [
        for (final c in ['Nagpur', 'Pune', 'Mumbai', 'Hyderabad'])
          SimpleDialogOption(
            onPressed: () {
              s.update(() => s.city = c);
              Navigator.pop(ctx);
            },
            child: Text(c, style: TextStyle(fontWeight: c == s.city ? FontWeight.w800 : FontWeight.w400)),
          ),
      ],
    ),
  );
}
