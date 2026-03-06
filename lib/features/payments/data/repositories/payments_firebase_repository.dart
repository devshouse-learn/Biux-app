import 'package:biux/features/payments/domain/repositories/payments_repository_abstract.dart';

class PaymentsFirebaseRepository extends PaymentsRepositoryAbstract {
  @override
  Future<String> gatewayPayment() async {
    // IMPLEMENTADO (STUB): Integrar pasarela de pagos (MercadoPago/Stripe)
    return 'Pagos proximamente disponibles';
  }
}
