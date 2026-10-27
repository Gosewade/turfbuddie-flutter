import 'package:turfbuddie_mock/data/mock_data.dart';
import 'package:turfbuddie_mock/models/models.dart';

class CouponResult {
  const CouponResult(this.valid, this.discount, this.message);
  final bool valid;
  final double discount;
  final String message;
}

/// ============================================================
/// BACKEND CONTRACT
/// Developer: implement this interface with Firebase/Firestore,
/// Node.js REST, Razorpay and Meta Cloud API (WhatsApp).
/// UI never talks to anything except this interface.
/// ============================================================
abstract class BookingService {
  Future<List<Turf>> fetchTurfs();
  Future<Set<int>> fetchBookedHours(Turf turf, DateTime date);
  Future<List<Tournament>> fetchTournaments();
  Future<List<Player>> fetchPlayers();
  Future<CouponResult> validateCoupon(String code, double base);

  /// Razorpay checkout. Return true when payment succeeded.
  Future<bool> pay({required double amount, required String method});

  /// Backend sends each squad member a WhatsApp message with a UPI link.
  Future<void> sendSplitLinks(Booking booking);
}

class MockBookingService implements BookingService {
  Future<void> _wait([int ms = 300]) => Future.delayed(Duration(milliseconds: ms));

  @override
  Future<List<Turf>> fetchTurfs() async {
    await _wait(500);
    return mockTurfs;
  }

  @override
  Future<Set<int>> fetchBookedHours(Turf turf, DateTime date) async {
    await _wait(200);
    final seed = turf.id.codeUnits.fold<int>(0, (a, b) => a + b);
    return {
      for (final h in turf.slotHours)
        if ((seed + date.day * 3 + h) % 4 == 0) h
    };
  }

  @override
  Future<List<Tournament>> fetchTournaments() async {
    await _wait();
    return buildMockTournaments();
  }

  @override
  Future<List<Player>> fetchPlayers() async {
    await _wait();
    return buildMockPlayers();
  }

  @override
  Future<CouponResult> validateCoupon(String code, double base) async {
    await _wait(400);
    switch (code.trim().toUpperCase()) {
      case 'TURF10':
        return CouponResult(true, (base * 0.10).roundToDouble(), 'TURF10 applied: 10% off');
      case 'FIRST50':
        return const CouponResult(true, 50, 'FIRST50 applied: \u20B950 off');
      default:
        return const CouponResult(false, 0, 'Invalid coupon code');
    }
  }

  @override
  Future<bool> pay({required double amount, required String method}) async {
    await _wait(1500);
    return true;
  }

  @override
  Future<void> sendSplitLinks(Booking booking) async {
    await _wait(600);
  }
}
