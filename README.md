# HANDOFF - TurfBuddie Flutter Mock (read first)

Includes: 5-tab app (Turfs, Booking, Home, Tournaments, Profile), Login/Signup/OTP, Find Player
(account -> team -> invite), booking + split payment, tournaments, Match Calculator.
`docs/ui_mock_reference.html` = clickable HTML version of the same UI (open in browser) - use as design reference.

Quick start:
1. `flutter create . --org com.turfbuddie --platforms=android,ios`  (generates android/ios folders)
2. `flutter pub get && flutter run`   (needs Flutter 3.22+)
3. Demo login: demo@turfbuddie.in / demo123, OTP 1234, coupons TURF10 / FIRST50.
4. Replace mocks: `lib/services/booking_service.dart` and `lib/services/auth_service.dart` (see TODO list below).
Static check done: `dart analyze` against Flutter stable framework sources = 0 errors (only 1 deprecation info for `Switch.activeColor`). Not yet run on a real device/emulator.

---
# TurfBuddie - Flutter Mock App (Player side)

Working UI mock built from the TurfBuddie website design. All data is mock/in-memory.
Goal: developer replaces the mock service with real backend and polishes UI.

## Run
```bash
# 1. generate platform folders (android/ios/web) - they are not in this zip
flutter create . --org com.turfbuddie --project-name turfbuddie_mock --platforms=android,ios
# 2. run
flutter pub get
flutter run
```
Min Flutter 3.22+ / Dart 3.4+ (uses WidgetStateProperty). Logo: `assets/logo.png` (already in pubspec).
NOTE: code was written without a local Flutter SDK; if `flutter analyze` shows small issues, fix them first.

## Screens / flow (matches website)
1. Home - hero, stats, featured turf, features, "How Split Payment Works"
2. Turfs - sort + filters (sport, distance, price/hr, format, amenities, availability)
3. Turf detail - date strip + calendar, multi-select 1-hr slots, booked/past disabled
4. Checkout - summary, loyalty points, coupon (try `TURF10`, `FIRST50`), platform fee, GST
5. Pay full (mock Razorpay sheet) OR Split with teammates
6. Split - add phone numbers, equal share, organiser pays first, "WhatsApp links" sent
7. Booking detail - squad paid/pending; tap "Pending" to simulate a webhook; auto-confirms at 100%
8. Tournaments - register team + entry fee payment
9. Find Player - filter by sport, invite
10. Bookings tab, light/dark toggle, city picker

## Structure
```
lib/
  main.dart                      app + AppScope + service injection point
  core/    config.dart (fees)  theme.dart  formatters.dart
  models/  models.dart           Turf, Booking, PriceBreakdown, Tournament...
  data/    mock_data.dart        mock turfs/tournaments/players
  services/booking_service.dart  *** BACKEND CONTRACT ***
  state/   app_state.dart        ChangeNotifier + filters + bookings
  screens/ shell home turfs turf_detail checkout split_pay booking_detail bookings tournaments players
  widgets/ common.dart           AppCard, Pill, GreenButton, TurfCard, payment sheet
```

## Developer TODO (replace mocks)
1. Implement `BookingService` (Firebase `turfbuddieonnodejs` / Node API) and swap it in `main.dart`.
   - `fetchTurfs`, `fetchBookedHours` (real-time via Firestore snapshots recommended)
   - `validateCoupon`, `fetchTournaments`, `fetchPlayers`
2. `pay()` -> Razorpay Flutter SDK (test mode first). Create order server-side.
3. `sendSplitLinks()` -> backend sends WhatsApp (Meta Cloud API) with per-player UPI link.
   Member payment status must come from a Razorpay webhook -> Firestore, not from the UI
   (`AppState.markMemberPaid` is only a demo shortcut).
4. Add Auth (phone OTP). Website shows "Login to Pay" for guests.
5. Booking must lock slots server-side (transaction) to avoid double booking; unpaid split
   bookings need a hold/expiry timer.
6. Fees in `core/config.dart`: platform fee rate 0.375% and GST 0% match the website checkout
   mock (Rs 4400 -> Rs 16.5). Website's other screen shows Rs 10 fee + 18% GST - confirm final business rule.
7. Split share uses `ceil(total / players)`; decide rounding / custom split rules.
8. Real turf images (network/Storage) instead of gradient thumbs; Inter font via `google_fonts`; location via `geolocator`.
9. Add state management of your choice (Provider/Riverpod/Bloc) if desired - current `AppState` is simple.

## Review notes (before production)
- Money is stored as `double` here for the mock. Use integer paise end-to-end (Razorpay uses paise).
- `TextEditingController` in tournaments dialog is not disposed - move into a StatefulWidget.
- No slot locking/expiry yet; unpaid split bookings must hold the slot for a limited time server-side.
- No tests, no error/offline states, no auth - all planned for the real build.

## v2 - Login + Team gating (new)
- `lib/services/auth_service.dart` = AUTH CONTRACT (swap with Firebase Auth: email/password + phone OTP).
  Mock: demo login `demo@turfbuddie.in` / `demo123`, OTP `1234`.
- `lib/screens/auth_screen.dart` = Login / Signup / OTP screen + `requireLogin(context)` helper.
  Used before: Pay, Split, Tournament register, Invite player. "Continue as guest" supported.
- Find Player: 3-step setup card (Account -> Create team -> Invite). Invite is locked until
  the user has an account AND a team (tapping Invite starts the missing step automatically).
- Header shows Login / user name; tap name -> profile sheet with Logout.
- Mock stores password in plain text - production must use Firebase Auth (never store passwords yourself).

## v3 - Restyled to match the live Play Store app
- Bottom nav (same as live app): Turfs | Booking | Home | Tournaments | Profile (default = Home).
- Green header on every tab, search bar, "Top Rated Turfs" carousel + "Turfs Near You" list,
  "Find Turfs Near You" with Filter Turfs dropdown, My Bookings with chips (All/Confirmed/Cancelled/Previous) and Txn id.
- Profile tab: login/logout, menu, dark mode, Find Players (account -> team -> invite flow).
- Turf cards use gradient placeholders: swap `TurfThumb` for `Image.network(turf.imageUrl)` when real photos are wired.
- Booking can be cancelled from booking detail (mock). Two demo bookings are seeded (previous + cancelled).

## v3.1 - Match Calculator
`lib/screens/match_calc_screen.dart`: (1) Cost Split - turf + hours + players + extras -> total, per player, per team (uses same fee logic as checkout);
(2) Cricket Run Rate - CRR, projected score, required run rate for a target. Entry: Home quick card + Profile menu.

## Build APK without installing Flutter (GitHub Actions)
1. Create a free GitHub repo, upload this whole project (make sure `.github/workflows/build.yml` is included).
2. Open the repo -> Actions tab -> "Build TurfBuddie APK + Web" -> Run workflow (also runs on every push).
3. After ~5-8 min open the finished run -> Artifacts -> download `TurfBuddie-APK` (zip containing app-release.apk) and install on Android.
   `TurfBuddie-Web` is the browser build. APK is signed with the debug key: fine for testing, not for Play Store.
iOS (.ipa) needs a Mac + Apple Developer account (paid); not covered here.
