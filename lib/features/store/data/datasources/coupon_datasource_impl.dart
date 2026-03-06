import 'dart:async';

class CouponDatasourceImpl {
  /// IMPLEMENTADO (STUB): Retorna cupones fijos.
  Future<List<Map<String, dynamic>>> getAvailableCoupons() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return [
      {'code': 'BIUX10', 'discount': 10, 'description': '10% off demo'},
    ];
  }
}
