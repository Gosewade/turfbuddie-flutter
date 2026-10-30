import 'package:flutter/foundation.dart';

class Turf {
  final String id, name, area, image;
  final int price;
  final double rating;
  final List<String> sports, amenities;
  const Turf({
    required this.id,
    required this.name,
    required this.area,
    required this.image,
    required this.price,
    required this.rating,
    required this.sports,
    required this.amenities,
  });
}

const turfs = <Turf>[
  Turf(
    id: 't1',
    name: 'Ashoka Turf',
    area: 'Near Wardha Road, Nagpur',
    image: 'assets/turf_1.jpg',
    price: 1200,
    rating: 4.6,
    sports: ['Football', 'Box Cricket'],
    amenities: ['Floodlights', 'Parking', 'Washroom', 'Drinking water'],
  ),
  Turf(
    id: 't2',
    name: 'Box Story Turf',
    area: 'Chapru Nagar, Nagpur',
    image: 'assets/turf_2.jpg',
    price: 900,
    rating: 4.4,
    sports: ['Box Cricket'],
    amenities: ['Floodlights', 'Artificial grass', 'Seating'],
  ),
  Turf(
    id: 't3',
    name: 'CC Turf',
    area: 'Dharampeth, Nagpur',
    image: 'assets/turf_3.jpg',
    price: 1000,
    rating: 4.2,
    sports: ['Football', 'Pickleball'],
    amenities: ['Parking', 'Washroom', 'Changing room'],
  ),
];

const sportsList = ['All', 'Football', 'Box Cricket', 'Pickleball'];

class Booking {
  final String id, payment;
  final Turf turf;
  final DateTime date;
  final int hour, amount;
  Booking({
    required this.id,
    required this.turf,
    required this.date,
    required this.hour,
    required this.amount,
    required this.payment,
  });
}

class BookingsRepo extends ChangeNotifier {
  static final BookingsRepo instance = BookingsRepo._();
  BookingsRepo._();
  final List<Booking> _items = [];
  List<Booking> get items => List.unmodifiable(_items);
  void add(Booking b) {
    _items.insert(0, b);
    notifyListeners();
  }
}

const _months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
const _days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];

String fmtDate(DateTime d) => '${_days[d.weekday - 1]}, ${d.day} ${_months[d.month - 1]}';

String _h(int x) {
  final hh = x % 12 == 0 ? 12 : x % 12;
  final s = (x >= 12 && x < 24) ? 'PM' : 'AM';
  return '$hh $s';
}

String slotLabel(int h) => '${_h(h)} - ${_h(h + 1)}';
