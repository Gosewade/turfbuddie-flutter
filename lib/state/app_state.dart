import 'package:flutter/material.dart';
import 'package:turfbuddie_mock/core/config.dart';
import 'package:turfbuddie_mock/core/formatters.dart';
import 'package:turfbuddie_mock/models/models.dart';
import 'package:turfbuddie_mock/services/auth_service.dart';
import 'package:turfbuddie_mock/services/booking_service.dart';

enum SortBy { nearest, priceLow, rating }

class AppState extends ChangeNotifier {
  AppState(this.service, this.auth);
  final BookingService service;
  final AuthService auth;

  // ---- account / team ----
  AppUser? user;
  Team? myTeam;

  // ---- global ----
  ThemeMode themeMode = ThemeMode.light;
  static const tabTurfs = 0, tabBooking = 1, tabHome = 2, tabTournaments = 3, tabProfile = 4;
  int tab = tabHome;
  String query = '';
  String city = 'Nagpur';
  bool loading = true;
  String get userName => user?.name ?? 'Guest';
  int loyaltyPoints = 50;

  // ---- data ----
  List<Turf> turfs = [];
  List<Tournament> tournaments = [];
  List<Player> players = [];
  final List<Booking> bookings = [];

  // ---- filters ----
  final Set<String> fSports = {};
  final Set<String> fFormats = {};
  final Set<String> fAmenities = {};
  double fMaxKm = 10;
  double fMaxPrice = 1200;
  String? fAvailability; // Open Now / Morning / Evening
  SortBy sort = SortBy.nearest;
  bool filtersOpen = false;

  Future<void> init() async {
    final r = await Future.wait([
      service.fetchTurfs(),
      service.fetchTournaments(),
      service.fetchPlayers(),
    ]);
    turfs = r[0] as List<Turf>;
    tournaments = r[1] as List<Tournament>;
    players = r[2] as List<Player>;
    if (bookings.isEmpty && turfs.length > 1) _seed();
    loading = false;
    notifyListeners();
  }

  void setUser(AppUser u) {
    user = u;
    city = u.city;
    notifyListeners();
  }

  Future<void> logout() async {
    await auth.logout();
    user = null;
    myTeam = null;
    for (final p in players) {
      p.invited = false;
    }
    notifyListeners();
  }

  void _seed() {
    final t = turfs[1];
    final now = DateTime.now();
    PriceBreakdown pb() => PriceBreakdown.calc(base: t.pricePerHour.toDouble());
    bookings.addAll([
      Booking(id: 'TB100231', turf: t, date: now.subtract(const Duration(days: 20)), hours: [8], price: pb(), status: BookingStatus.confirmed),
      Booking(id: 'TB100198', turf: t, date: now.subtract(const Duration(days: 9)), hours: [15], price: pb(), status: BookingStatus.cancelled),
    ]);
  }

  void update(VoidCallback fn) {
    fn();
    notifyListeners();
  }

  void toggleTheme() => update(() =>
      themeMode = themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light);

  void resetFilters() => update(() {
        fSports.clear();
        fFormats.clear();
        fAmenities.clear();
        fMaxKm = 10;
        fMaxPrice = 1200;
        fAvailability = null;
      });

  List<Turf> get filteredTurfs {
    final list = turfs.where((t) {
      if (fSports.isNotEmpty && !t.sports.any(fSports.contains)) return false;
      if (query.isNotEmpty && !('${t.name} ${t.area}'.toLowerCase().contains(query.toLowerCase()))) return false;
      if (t.distanceKm > fMaxKm) return false;
      if (t.pricePerHour > fMaxPrice) return false;
      if (fFormats.isNotEmpty && !t.formats.any(fFormats.contains)) return false;
      if (!fAmenities.every(t.amenities.contains)) return false;
      if (fAvailability == 'Open Now' && !t.isOpenNow) return false;
      if (fAvailability == 'Morning' && t.openFrom > 9) return false;
      if (fAvailability == 'Evening' && t.openTo < 21) return false;
      return true;
    }).toList();
    switch (sort) {
      case SortBy.nearest:
        list.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
      case SortBy.priceLow:
        list.sort((a, b) => a.pricePerHour.compareTo(b.pricePerHour));
      case SortBy.rating:
        list.sort((a, b) => b.rating.compareTo(a.rating));
    }
    return list;
  }

  Future<Set<int>> bookedHours(Turf t, DateTime d) async {
    final remote = await service.fetchBookedHours(t, d);
    final local = bookings
        .where((b) => b.turf.id == t.id && sameDay(b.date, d) && b.status != BookingStatus.cancelled)
        .expand((b) => b.hours);
    return {...remote, ...local};
  }

  String newBookingId() => 'TB${DateTime.now().millisecondsSinceEpoch % 1000000}';

  void _earnPoints(Booking b) =>
      loyaltyPoints += (b.price.total / 100).floor();

  void addBooking(Booking b) {
    bookings.insert(0, b);
    loyaltyPoints -= b.pointsUsed;
    if (b.status == BookingStatus.confirmed) _earnPoints(b);
    notifyListeners();
  }

  /// In production this is triggered by a Razorpay webhook, not by the UI.
  void markMemberPaid(Booking b, SquadMember m) {
    m.paid = true;
    if (b.squad.every((s) => s.paid) && b.status != BookingStatus.confirmed) {
      b.status = BookingStatus.confirmed;
      _earnPoints(b);
    }
    notifyListeners();
  }

  double get pointValue => Config.loyaltyPointValue;
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
      : super(notifier: state);

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
