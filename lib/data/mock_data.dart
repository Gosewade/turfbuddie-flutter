import 'package:turfbuddie_mock/models/models.dart';

const mockTurfs = <Turf>[
  Turf(id: 't1', name: 'Greenfield Sports Arena', area: 'Dharampeth', rating: 4.7, distanceKm: 2.1, pricePerHour: 1000,
      sports: ['Football', 'Cricket'], formats: ['5v5', '7v7'],
      amenities: ['Floodlights', 'Washroom', 'Parking', 'Caf\u00E9'], openFrom: 6, openTo: 23, colorIndex: 0),
  Turf(id: 't2', name: 'Box Story Turf', area: 'Chapru Nagar, Nagpur', rating: 3.5, distanceKm: 3.8, pricePerHour: 1100,
      sports: ['Football', 'Cricket'], formats: ['5v5', '7v7'],
      amenities: ['Floodlights', 'Parking', 'Drinking Water'], openFrom: 6, openTo: 23, colorIndex: 1),
  Turf(id: 't3', name: 'CC Turf', area: 'Ram Nagar', rating: 4.2, distanceKm: 1.4, pricePerHour: 500,
      sports: ['Football'], formats: ['5v5'],
      amenities: ['Floodlights', 'Drinking Water'], openFrom: 6, openTo: 23, colorIndex: 2),
  Turf(id: 't4', name: 'Futebox Sports Academy', area: 'Manish Nagar', rating: 4.5, distanceKm: 5.6, pricePerHour: 900,
      sports: ['Football'], formats: ['5v5', '7v7', '11v11'],
      amenities: ['Floodlights', 'Washroom', 'Parking', 'Caf\u00E9', 'Drinking Water'], openFrom: 5, openTo: 23, colorIndex: 3),
  Turf(id: 't5', name: 'Ashoka Turf', area: 'Wardha Road', rating: 4.3, distanceKm: 6.2, pricePerHour: 800,
      sports: ['Cricket', 'Football'], formats: ['7v7', '11v11'],
      amenities: ['Floodlights', 'Washroom', 'Parking'], openFrom: 6, openTo: 23, colorIndex: 0),
  Turf(id: 't6', name: 'Smash Court', area: 'Sadar', rating: 4.4, distanceKm: 2.9, pricePerHour: 600,
      sports: ['Badminton', 'Tennis'], formats: [],
      amenities: ['Washroom', 'Parking', 'Drinking Water'], openFrom: 6, openTo: 22, colorIndex: 1),
  Turf(id: 't7', name: 'Hoops Arena', area: 'Sitabuldi', rating: 4.0, distanceKm: 3.3, pricePerHour: 700,
      sports: ['Basketball'], formats: [],
      amenities: ['Floodlights', 'Parking'], openFrom: 6, openTo: 22, colorIndex: 2),
  Turf(id: 't8', name: 'Kick Off Arena', area: 'Trimurti Nagar', rating: 3.9, distanceKm: 8.7, pricePerHour: 700,
      sports: ['Football'], formats: ['5v5', '7v7'],
      amenities: ['Floodlights', 'Parking'], openFrom: 6, openTo: 23, colorIndex: 3),
];

List<Tournament> buildMockTournaments() {
  final now = DateTime.now();
  return [
    Tournament(id: 'tr1', sport: 'Cricket', title: 'Ashoka Premier League Women',
        tagline: 'Feel the Heat. Play like a Champion.', prize: 10000, entryFee: 2100,
        date: DateTime(now.year, 1, 24), venue: 'Ashoka Turf, Near Wardha Road',
        capacity: 8, registered: 5, done: true),
    Tournament(id: 'tr2', sport: 'Cricket', title: 'Ashoka Premier League',
        tagline: 'Feel the Heat. Play like a Champion.', prize: 20000, entryFee: 2500,
        date: DateTime(now.year, 1, 24), venue: 'Ashoka Turf, Near Wardha Road',
        capacity: 16, registered: 16, done: true),
    Tournament(id: 'tr3', sport: 'Football', title: 'Nagpur 5v5 Night Cup',
        tagline: 'Under the lights. One city. One champion.', prize: 15000, entryFee: 1500,
        date: now.add(const Duration(days: 12)), venue: 'Futebox Sports Academy, Manish Nagar',
        capacity: 12, registered: 7, done: false),
    Tournament(id: 'tr4', sport: 'Cricket', title: 'Box Cricket Bash',
        tagline: '6 overs. Zero mercy.', prize: 8000, entryFee: 1200,
        date: now.add(const Duration(days: 20)), venue: 'Box Story Turf, Chapru Nagar',
        capacity: 8, registered: 3, done: false),
    Tournament(id: 'tr5', sport: 'Basketball', title: '3x3 Street Hoops',
        tagline: 'Ball is life.', prize: 6000, entryFee: 800,
        date: now.add(const Duration(days: 30)), venue: 'Hoops Arena, Sitabuldi',
        capacity: 8, registered: 8, done: false),
  ];
}

List<Player> buildMockPlayers() => [
      Player(name: 'Aryan K.', sport: 'Football', skill: 'Intermediate', area: 'Dharampeth'),
      Player(name: 'Rohit S.', sport: 'Cricket', skill: 'Advanced', area: 'Ram Nagar'),
      Player(name: 'Vikram P.', sport: 'Football', skill: 'Beginner', area: 'Manish Nagar'),
      Player(name: 'Sneha D.', sport: 'Badminton', skill: 'Intermediate', area: 'Sadar'),
      Player(name: 'Kunal M.', sport: 'Basketball', skill: 'Advanced', area: 'Sitabuldi'),
      Player(name: 'Isha R.', sport: 'Tennis', skill: 'Beginner', area: 'Civil Lines'),
      Player(name: 'Dev T.', sport: 'Cricket', skill: 'Intermediate', area: 'Wardha Road'),
    ];
