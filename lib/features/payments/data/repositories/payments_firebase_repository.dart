import 'package:biux/features/payments/domain/repositories/payments_repository_abstract.dart';
import 'package:biux/features/payments/data/repositories/payments_firebase_repository_impl.dart';
import 'package:biux/core/services/app_logger.dart';

class PaymentsFirebaseRepository extends PaymentsRepositoryAbstract {
  final PaymentsFirebaseRepositoryImpl _impl = PaymentsFirebaseRepositoryImpl();

  @override
  Future<String> gatewayPayment() async {
    try {
      final result = await _impl.createPaymentIntent(
        amount: 0,
        currency: 'COP',
        description: 'Gateway payment request',
      );
      return result['id'] ?? '';
    } catch (e) {
      AppLogger.error(
        'Error en gatewayPayment',
        tag: 'PaymentsFirebaseRepo',
        error: e,
      );
      return '';
    }
  }
}
