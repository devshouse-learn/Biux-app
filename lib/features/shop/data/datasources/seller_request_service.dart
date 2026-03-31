import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:biux/features/shop/domain/entities/seller_request_entity.dart';

/// Servicio para gestión de solicitudes de vendedor.
/// STUB — pendiente de implementación real con Firestore.
class SellerRequestService {
  SellerRequestService();

  /// Stream de solicitudes pendientes.
  Stream<List<SellerRequestEntity>> getPendingRequests() {
    debugPrint(
      '⚠️ SellerRequestService.getPendingRequests() — STUB: sin implementar',
    );
    return Stream.value([]);
  }

  /// Stream de todas las solicitudes.
  Stream<List<SellerRequestEntity>> getAllRequests() {
    debugPrint(
      '⚠️ SellerRequestService.getAllRequests() — STUB: sin implementar',
    );
    return Stream.value([]);
  }

  /// Stream del conteo de solicitudes pendientes.
  Stream<int> getPendingRequestsCount() {
    debugPrint(
      '⚠️ SellerRequestService.getPendingRequestsCount() — STUB: sin implementar',
    );
    return Stream.value(0);
  }

  /// Crea una nueva solicitud de vendedor.
  Future<void> createSellerRequest({
    required String userId,
    required String userName,
    required String userPhoto,
    required String userEmail,
    required String message,
  }) async {
    debugPrint(
      '⚠️ SellerRequestService.createSellerRequest() — STUB: sin implementar',
    );
  }

  /// Aprueba una solicitud de vendedor.
  Future<void> approveRequest({
    required String requestId,
    required String adminId,
    String? comment,
  }) async {
    debugPrint(
      '⚠️ SellerRequestService.approveRequest() — STUB: sin implementar',
    );
  }

  /// Rechaza una solicitud de vendedor.
  Future<void> rejectRequest({
    required String requestId,
    required String adminId,
    String? comment,
  }) async {
    debugPrint(
      '⚠️ SellerRequestService.rejectRequest() — STUB: sin implementar',
    );
  }

  /// Elimina una solicitud.
  Future<void> deleteRequest(String requestId) async {
    debugPrint(
      '⚠️ SellerRequestService.deleteRequest() — STUB: sin implementar',
    );
  }

  /// Verifica si un usuario tiene una solicitud pendiente.
  Future<bool> hasPendingRequest(String userId) async {
    debugPrint(
      '⚠️ SellerRequestService.hasPendingRequest() — STUB: sin implementar',
    );
    return false;
  }
}
