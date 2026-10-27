import 'package:turfbuddie_mock/models/models.dart';

class AuthResult {
  const AuthResult({this.user, this.error});
  final AppUser? user;
  final String? error;
}

/// ============================================================
/// AUTH CONTRACT - developer: implement with Firebase Auth
/// (email+password, phone OTP). UI only talks to this interface.
/// ============================================================
abstract class AuthService {
  Future<AuthResult> loginWithEmail(String email, String password);
  Future<String?> sendOtp(String phone); // null = success, else error text
  Future<AuthResult> verifyOtpLogin(String phone, String otp);
  Future<AuthResult> verifyOtpSignup(AppUser pending, String otp);
  Future<void> logout();
}

class MockAuthService implements AuthService {
  static const demoOtp = '1234';
  static const demoEmail = 'demo@turfbuddie.in';
  static const demoPassword = 'demo123';
  final List<AppUser> _users = [];

  Future<void> _wait() => Future.delayed(const Duration(milliseconds: 500));

  @override
  Future<AuthResult> loginWithEmail(String email, String password) async {
    await _wait();
    final e = email.trim().toLowerCase();
    if (e == demoEmail && password == demoPassword) {
      return AuthResult(user: AppUser(name: 'Demo Player', phone: '9876543210', email: e));
    }
    for (final u in _users) {
      if (u.email == e && u.password == password) return AuthResult(user: u);
    }
    return const AuthResult(error: 'Wrong email or password (demo: demo@turfbuddie.in / demo123)');
  }

  @override
  Future<String?> sendOtp(String phone) async {
    await _wait();
    return null;
  }

  @override
  Future<AuthResult> verifyOtpLogin(String phone, String otp) async {
    await _wait();
    if (otp != demoOtp) return const AuthResult(error: 'Wrong OTP (demo OTP is 1234)');
    for (final u in _users) {
      if (u.phone == phone) return AuthResult(user: u);
    }
    return AuthResult(user: AppUser(name: 'Player ${phone.substring(6)}', phone: phone));
  }

  @override
  Future<AuthResult> verifyOtpSignup(AppUser pending, String otp) async {
    await _wait();
    if (otp != demoOtp) return const AuthResult(error: 'Wrong OTP (demo OTP is 1234)');
    if (_users.any((u) => u.email == pending.email)) {
      return const AuthResult(error: 'An account with this email already exists');
    }
    _users.add(pending);
    return AuthResult(user: pending);
  }

  @override
  Future<void> logout() async {}
}
