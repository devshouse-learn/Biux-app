import 'package:biux/features/promotions/domain/entities/promotion_entity.dart';

/// Interfaz del repositorio de promociones (contrato para la capa de datos)
abstract class PromotionRepository {
  Future<List<PromotionEntity>> getPromotions();
  Future<void> addPromotion(PromotionEntity promotion);
  Future<void> approvePromotion(String id);
  Future<void> rejectPromotion(String id);
  Future<void> registerToEvent(String promotionId, String userId);
  Future<void> unregisterFromEvent(String promotionId, String userId);
  Future<bool> isVerifiedPromoter(String userId);
  Future<void> requestPromoterStatus(String userId, String name);
}
