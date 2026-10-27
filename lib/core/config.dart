/// Business constants. Move to remote config / backend when ready.
class Config {
  /// Website mock: Rs 4400 -> Rs 16.5 platform fee.
  static const double platformFeeRate = 0.00375;
  static const double gstRate = 0.0; // website checkout shows GST (0%)
  static const double loyaltyPointValue = 1; // 1 point = Rs 1
  static const int splitMinPlayers = 2;
  static const int splitMaxPlayers = 22;
}
