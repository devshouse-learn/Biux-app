import 'dart:async';

class PaymentsFirebaseRepositoryImpl {
  /// IMPLEMENTADO (STUB): Simula payment intent.
  Future<Map<String, dynamic>> createPaymentIntent({required double amount, required String currency}) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return {
      'id': 'stub_pi',
      'amount': amount,
      'currency': currency,
      'status': 'requires_confirmation',
    };
  }

  Future<bool> confirmPayment(String paymentId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return true;
  }
}
