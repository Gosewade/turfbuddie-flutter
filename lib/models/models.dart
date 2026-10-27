import 'package:turfbuddie_mock/core/config.dart';

enum BookingStatus { confirmed, awaitingSplit, cancelled }

class Turf {
  const Turf({
    required this.id,
    required this.name,
    required this.area,
    required this.rating,
    required this.distanceKm,
    required this.pricePerHour,
    required this.sports,
    required this.formats,
    required this.amenities,
    required this.openFrom,
    required this.openTo,
    required this.colorIndex,
  });

  final String id, name, area;
  final double rating, distanceKm;
  final int pricePerHour;
  final List<String> sports, formats, amenities;
  final int openFrom, openTo; // 24h, openTo exclusive
  final int colorIndex;

  bool get isOpenNow {
    final h = DateTime.now().hour;
    return h >= openFrom && h < openTo;
  }

  List<int> get slotHours => [for (var h = openFrom; h < openTo; h++) h];
}

class SquadMember {
  SquadMember({
    required this.name,
    required this.phone,
    required this.amount,
    this.paid = false,
    this.isOrganiser = false,
  });
  String name, phone;
  double amount;
  bool paid;
  final bool isOrganiser;
}

class PriceBreakdown {
  const PriceBreakdown({
    required this.base,
    required this.couponDiscount,
    required this.pointsDiscount,
    required this.platformFee,
    required this.gst,
    required this.total,
  });

  final double base, couponDiscount, pointsDiscount, platformFee, gst, total;

  factory PriceBreakdown.calc({
    required double base,
    double couponDiscount = 0,
    double pointsDiscount = 0,
  }) {
    final fee = (base * Config.platformFeeRate * 2).round() / 2; // nearest 0.5
    final taxable = base - couponDiscount - pointsDiscount + fee;
    final gst = taxable * Config.gstRate;
    return PriceBreakdown(
      base: base,
      couponDiscount: couponDiscount,
      pointsDiscount: pointsDiscount,
      platformFee: fee,
      gst: gst,
      total: taxable + gst,
    );
  }
}

class Booking {
  Booking({
    required this.id,
    required this.turf,
    required this.date,
    required this.hours,
    required this.price,
    required this.status,
    this.squad = const [],
    this.couponCode,
    this.pointsUsed = 0,
  });

  final String id;
  final String txn = 'pay_${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}';
  final Turf turf;
  final DateTime date;
  final List<int> hours;
  final PriceBreakdown price;
  BookingStatus status;
  final List<SquadMember> squad;
  final String? couponCode;
  final int pointsUsed;

  int get paidCount => squad.where((m) => m.paid).length;
}

class Tournament {
  Tournament({
    required this.id,
    required this.sport,
    required this.title,
    required this.tagline,
    required this.prize,
    required this.entryFee,
    required this.date,
    required this.venue,
    required this.capacity,
    required this.registered,
    required this.done,
  });

  final String id, sport, title, tagline, venue;
  final int prize, entryFee, capacity;
  final DateTime date;
  final bool done;
  int registered;
  bool isRegistered = false;
  int get spotsLeft => capacity - registered;
}

class Player {
  Player({required this.name, required this.sport, required this.skill, required this.area});
  final String name, sport, skill, area;
  bool invited = false;
}

class AppUser {
  AppUser({
    required this.name,
    required this.phone,
    this.email = '',
    this.password = '', // MOCK ONLY - never store plain passwords; use Firebase Auth
    this.city = 'Nagpur',
    this.role = 'Player',
  });
  final String name, phone, email, password, city, role;
  String get firstName => name.trim().split(' ').first;
}

class Team {
  Team({required this.name, required this.sport, required this.skill, required this.playersNeeded});
  String name, sport, skill;
  int playersNeeded;
  final List<String> invited = [];
}
