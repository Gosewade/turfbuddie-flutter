import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:turfbuddie_mock/core/theme.dart';
import 'package:turfbuddie_mock/models/models.dart';
import 'package:turfbuddie_mock/state/app_state.dart';
import 'package:turfbuddie_mock/widgets/common.dart';

/// Call before any action that needs an account (pay, split, register, invite).
/// Returns true if the user is logged in (already, or after login/signup).
Future<bool> requireLogin(BuildContext context) async {
  final s = AppScope.of(context);
  if (s.user != null) return true;
  await Navigator.of(context).push<bool>(
    MaterialPageRoute(fullscreenDialog: true, builder: (_) => const AuthScreen()),
  );
  return s.user != null;
}

enum _Mode { login, signup, otp }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  _Mode mode = _Mode.login;
  bool byEmail = true, busy = false;
  String city = 'Nagpur', role = 'Player';
  String? error;
  AppUser? pendingUser;
  String pendingPhone = '';
  final name = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();
  final pass = TextEditingController();
  final otp = TextEditingController();

  @override
  void dispose() {
    for (final c in [name, phone, email, pass, otp]) {
      c.dispose();
    }
    super.dispose();
  }

  void _go(_Mode m) => setState(() {
        mode = m;
        error = null;
        otp.clear();
      });

  void _snack(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  Future<void> _login() async {
    final s = AppScope.of(context);
    if (byEmail) {
      if (email.text.trim().isEmpty || pass.text.isEmpty) {
        return setState(() => error = 'Enter email and password');
      }
      setState(() {
        busy = true;
        error = null;
      });
      final r = await s.auth.loginWithEmail(email.text, pass.text);
      if (!mounted) return;
      setState(() => busy = false);
      if (r.user == null) return setState(() => error = r.error);
      _finish(s, r.user!);
    } else {
      if (phone.text.length != 10) return setState(() => error = 'Enter a valid 10-digit number');
      await _startOtp(s, phone.text, null);
    }
  }

  Future<void> _signup() async {
    final s = AppScope.of(context);
    if (name.text.trim().isEmpty) return setState(() => error = 'Enter your name');
    if (phone.text.length != 10) return setState(() => error = 'Enter a valid 10-digit number');
    if (!email.text.contains('@')) return setState(() => error = 'Enter a valid email');
    if (pass.text.length < 6) return setState(() => error = 'Password must be 6+ characters');
    final u = AppUser(
      name: name.text.trim(),
      phone: phone.text,
      email: email.text.trim().toLowerCase(),
      password: pass.text,
      city: city,
      role: role,
    );
    await _startOtp(s, phone.text, u);
  }

  Future<void> _startOtp(AppState s, String ph, AppUser? pending) async {
    setState(() {
      busy = true;
      error = null;
    });
    final err = await s.auth.sendOtp(ph);
    if (!mounted) return;
    setState(() {
      busy = false;
      if (err != null) {
        error = err;
      } else {
        pendingUser = pending;
        pendingPhone = ph;
        mode = _Mode.otp;
        otp.clear();
      }
    });
  }

  Future<void> _verify() async {
    final s = AppScope.of(context);
    if (otp.text.length != 4) return setState(() => error = 'Enter the 4-digit OTP');
    setState(() {
      busy = true;
      error = null;
    });
    final r = pendingUser != null
        ? await s.auth.verifyOtpSignup(pendingUser!, otp.text)
        : await s.auth.verifyOtpLogin(pendingPhone, otp.text);
    if (!mounted) return;
    setState(() => busy = false);
    if (r.user == null) return setState(() => error = r.error);
    _finish(s, r.user!);
  }

  void _finish(AppState s, AppUser u) {
    final messenger = ScaffoldMessenger.of(context);
    s.setUser(u);
    Navigator.pop(context, true);
    messenger.showSnackBar(SnackBar(content: Text('Welcome, ${u.firstName} \u{1F44B}')));
  }

  Widget _field(TextEditingController c, String hint,
      {TextInputType? type, int? max, bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        keyboardType: type,
        obscureText: obscure,
        maxLength: max,
        inputFormatters: type == TextInputType.phone || type == TextInputType.number
            ? [FilteringTextInputFormatter.digitsOnly]
            : null,
        decoration: InputDecoration(
          hintText: hint,
          counterText: '',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  Widget _err() => error == null
      ? const SizedBox(height: 4)
      : Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(error!, style: const TextStyle(color: AppColors.red, fontWeight: FontWeight.w600)),
        );

  Widget _link(String text, String action, VoidCallback onTap) => Center(
        child: Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
          Text('$text '),
          GestureDetector(
            onTap: onTap,
            child: Text(action, style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.w800)),
          ),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final mut = TextStyle(color: cs.onSurface.withAlpha(170), fontSize: 15);
    late final List<Widget> body;

    if (mode == _Mode.login) {
      body = [
        const Text('Welcome back \u{1F44B}', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
        const SizedBox(height: 6),
        Text('Login to book turfs, split payments and join tournaments.', style: mut),
        const SizedBox(height: 14),
        Wrap(spacing: 8, children: [
          Pill('\u2709\uFE0F Email & Password', selected: byEmail, onTap: () => setState(() { byEmail = true; error = null; })),
          Pill('\u{1F4F1} Phone OTP', selected: !byEmail, onTap: () => setState(() { byEmail = false; error = null; })),
        ]),
        const SizedBox(height: 14),
        if (byEmail) ...[
          _field(email, 'Email', type: TextInputType.emailAddress),
          _field(pass, 'Password', obscure: true),
          GestureDetector(
            onTap: () => _snack('Reset link sent (mock)'),
            child: const Text('Forgot password?', style: TextStyle(color: AppColors.green, fontWeight: FontWeight.w700)),
          ),
        ] else
          _field(phone, 'Mobile number (10 digits)', type: TextInputType.phone, max: 10),
        _err(),
        GreenButton(label: busy ? 'Please wait\u2026' : (byEmail ? 'Login' : 'Send OTP'), onPressed: busy ? null : _login),
        _link('New to TurfBuddie?', 'Sign up', () => _go(_Mode.signup)),
      ];
    } else if (mode == _Mode.signup) {
      body = [
        const Text('Create your account', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
        const SizedBox(height: 6),
        Text('Takes 30 seconds. Your phone is verified by OTP.', style: mut),
        const SizedBox(height: 14),
        _field(name, 'Full name'),
        _field(phone, 'Mobile number (10 digits)', type: TextInputType.phone, max: 10),
        _field(email, 'Email', type: TextInputType.emailAddress),
        _field(pass, 'Password (6+ characters)', obscure: true),
        const Text('City', style: TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Wrap(spacing: 8, children: [
          for (final c in ['Nagpur', 'Pune']) Pill('\u{1F4CD} $c', selected: city == c, onTap: () => setState(() => city = c)),
        ]),
        const SizedBox(height: 10),
        const Text('I am a', style: TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Wrap(spacing: 8, children: [
          Pill('\u{1F3C3} Player', selected: role == 'Player', onTap: () => setState(() => role = 'Player')),
          Pill('\u{1F3DF}\uFE0F Turf Owner', selected: role == 'Turf Owner', onTap: () => setState(() => role = 'Turf Owner')),
        ]),
        _err(),
        GreenButton(label: busy ? 'Please wait\u2026' : 'Create account & verify phone', onPressed: busy ? null : _signup),
        _link('Already have an account?', 'Login', () => _go(_Mode.login)),
      ];
    } else {
      body = [
        const Text('Verify your number', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
        const SizedBox(height: 6),
        Text('Enter the 4-digit OTP sent to +91 $pendingPhone (demo OTP: 1234)', style: mut),
        const SizedBox(height: 14),
        _field(otp, '\u2022 \u2022 \u2022 \u2022', type: TextInputType.number, max: 4),
        _err(),
        GreenButton(label: busy ? 'Please wait\u2026' : 'Verify & Continue', onPressed: busy ? null : _verify),
        Center(
          child: Wrap(children: [
            GestureDetector(
              onTap: () => _snack('OTP resent (mock)'),
              child: const Text('Resend OTP', style: TextStyle(color: AppColors.green, fontWeight: FontWeight.w700)),
            ),
            const Text('  \u00B7  '),
            GestureDetector(
              onTap: () => _go(pendingUser != null ? _Mode.signup : _Mode.login),
              child: const Text('Change number', style: TextStyle(color: AppColors.green, fontWeight: FontWeight.w700)),
            ),
          ]),
        ),
      ];
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(children: [
          Container(
            width: double.infinity,
            height: 200,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color(0xFF14532D), Color(0xFF22C55E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
            ),
            child: SafeArea(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: Image.asset('assets/logo.png', height: 104),
                ),
              ),
            ),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  ...body,
                  const SizedBox(height: 10),
                  GreenButton(label: 'Continue as guest', outlined: true, onPressed: () => Navigator.pop(context, false)),
                ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
