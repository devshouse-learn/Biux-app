/// Estados posibles de una transferencia
enum TransferStatus {
  pending, // Pendiente de aceptar
  accepted, // Aceptada
  rejected, // Rechazada
  cancelled, // Cancelada
}

/// Entidad para transferencia de propiedad de bicicleta
class BikeTransferEntity {
  final String id;
  final String bikeId;
  final String fromUserId; // Usuario que transfiere
  final String toUserId; // Usuario que recibe
  final String? toUserEmail; // Email del usuario destino (opcional)
  final DateTime requestDate;
  final DateTime? responseDate;
  final TransferStatus status;
  final String? message; // Mensaje opcional
  final String? rejectionReason; // Razón de rechazo si aplica

  const BikeTransferEntity({
    required this.id,
    required this.bikeId,
    required this.fromUserId,
    required this.toUserId,
    this.toUserEmail,
    required this.requestDate,
    this.responseDate,
    this.status = TransferStatus.pending,
    this.message,
    this.rejectionReason,
  });

  bool get isPending => status == TransferStatus.pending;
  bool get isAccepted => status == TransferStatus.accepted;
  bool get isRejected => status == TransferStatus.rejected;
  bool get isCancelled => status == TransferStatus.cancelled;

  BikeTransferEntity copyWith({
    String? id,
    String? bikeId,
    String? fromUserId,
    String? toUserId,
    String? toUserEmail,
    DateTime? requestDate,
    DateTime? responseDate,
    TransferStatus? status,
    String? message,
    String? rejectionReason,
  }) {
    return BikeTransferEntity(
      id: id ?? this.id,
      bikeId: bikeId ?? this.bikeId,
      fromUserId: fromUserId ?? this.fromUserId,
      toUserId: toUserId ?? this.toUserId,
      toUserEmail: toUserEmail ?? this.toUserEmail,
      requestDate: requestDate ?? this.requestDate,
      responseDate: responseDate ?? this.responseDate,
      status: status ?? this.status,
      message: message ?? this.message,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}

extension TransferStatusExtension on TransferStatus {
  String get displayName {
    switch (this) {
      case TransferStatus.pending:
        return 'transfer_status_pending';
      case TransferStatus.accepted:
        return 'transfer_status_accepted';
      case TransferStatus.rejected:
        return 'transfer_status_rejected';
      case TransferStatus.cancelled:
        return 'transfer_status_cancelled';
    }
  }
}
