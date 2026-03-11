/// Estados de una solicitud de vendedor
enum SellerRequestStatus {
  pending, // Pendiente de revisión
  approved, // Aprobada
  rejected; // Rechazada

  String get displayName {
    switch (this) {
      case SellerRequestStatus.pending:
        return 'seller_status_pending';
      case SellerRequestStatus.approved:
        return 'seller_status_approved';
      case SellerRequestStatus.rejected:
        return 'seller_status_rejected';
    }
  }

  String get emoji {
    switch (this) {
      case SellerRequestStatus.pending:
        return '⏳';
      case SellerRequestStatus.approved:
        return '✅';
      case SellerRequestStatus.rejected:
        return '❌';
    }
  }
}

/// Entidad de dominio para solicitud de vendedor
class SellerRequestEntity {
  final String id;
  final String userId; // ID del usuario que solicita
  final String userName; // Nombre del usuario
  final String userPhoto; // Foto del usuario
  final String userEmail; // Email del usuario
  final String message; // Mensaje de la solicitud
  final SellerRequestStatus status;
  final DateTime createdAt;
  final DateTime? reviewedAt; // Cuándo fue revisada
  final String? reviewedBy; // ID del admin que revisó
  final String? reviewComment; // Comentario del admin

  const SellerRequestEntity({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhoto,
    required this.userEmail,
    required this.message,
    required this.status,
    required this.createdAt,
    this.reviewedAt,
    this.reviewedBy,
    this.reviewComment,
  });

  /// Verifica si la solicitud está pendiente
  bool get isPending => status == SellerRequestStatus.pending;

  /// Verifica si la solicitud fue aprobada
  bool get isApproved => status == SellerRequestStatus.approved;

  /// Verifica si la solicitud fue rechazada
  bool get isRejected => status == SellerRequestStatus.rejected;

  /// Copia la entidad con nuevos valores
  SellerRequestEntity copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userPhoto,
    String? userEmail,
    String? message,
    SellerRequestStatus? status,
    DateTime? createdAt,
    DateTime? reviewedAt,
    String? reviewedBy,
    String? reviewComment,
  }) {
    return SellerRequestEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhoto: userPhoto ?? this.userPhoto,
      userEmail: userEmail ?? this.userEmail,
      message: message ?? this.message,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewComment: reviewComment ?? this.reviewComment,
    );
  }
}
