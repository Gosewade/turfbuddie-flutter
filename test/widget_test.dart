import 'package:flutter_test/flutter_test.dart';
import 'package:turfbuddie_mock/models/models.dart';

void main() {
  test('price breakdown matches website checkout mock', () {
    final p = PriceBreakdown.calc(base: 4400);
    expect(p.platformFee, 16.5);
    expect(p.gst, 0);
    expect(p.total, 4416.5);
  });

  test('coupon and points reduce total', () {
    final p = PriceBreakdown.calc(base: 1000, couponDiscount: 100, pointsDiscount: 50);
    expect(p.total, 850 + p.platformFee);
  });
}
