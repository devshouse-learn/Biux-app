import 'package:biux/features/bikes/domain/entities/bike_transfer_entity.dart';
import 'package:biux/features/bikes/domain/repositories/bike_repository.dart';

/// Caso de uso para transferir propiedad de una bicicleta
class TransferBikeOwnershipUseCase {
  final BikeRepository repository;

  TransferBikeOwnershipUseCase(this.repository);

  Future<BikeTransferEntity> call({
    required String bikeId,
    required String fromUserId,
    required String toUserId,
    String? toUserEmail,
    String? message,
  }) async {
    // Validaciones
    if (bikeId.trim().isEmpty) {
      throw ArgumentError('El ID de la bicicleta es requerido');
    }
    if (fromUserId.trim().isEmpty) {
      throw ArgumentError('El ID del usuario origen es requerido');
    }
    if (toUserId.trim().isEmpty) {
      throw ArgumentError('El ID del usuario destino es requerido');
    }
    if (fromUserId == toUserId) {
      throw ArgumentError('No puedes transferir una bicicleta a ti mismo');
    }

    // Verificar que la bicicleta existe y pertenece al usuario
    final bike = await repository.getBikeById(bikeId);
    if (bike == null) {
      throw ArgumentError('La bicicleta no existe');
    }
    if (bike.ownerId != fromUserId) {
      throw ArgumentError('Solo el propietario puede transferir la bicicleta');
    }
    if (!bike.canBeTransferred) {
      throw ArgumentError(
        'Esta bicicleta no puede ser transferida en su estado actual',
      );
    }

    // Verificar que no hay transferencias pendientes
    final pendingTransfers = await repository.getBikeTransferHistory(bikeId);
    final hasPendingTransfer = pendingTransfers.any((t) => t.isPending);
    if (hasPendingTransfer) {
      throw ArgumentError(
        'Ya hay una transferencia pendiente para esta bicicleta',
      );
    }

    // Crear solicitud de transferencia
    final transfer = BikeTransferEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      bikeId: bikeId,
      fromUserId: fromUserId,
      toUserId: toUserId,
      toUserEmail: toUserEmail?.trim(),
      requestDate: DateTime.now(),
      message: message?.trim(),
    );

    return await repository.requestTransfer(transfer);
  }
}
