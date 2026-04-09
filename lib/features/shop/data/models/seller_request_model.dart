import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:biux/features/shop/domain/entities/seller_request_entity.dart';

/// Modelo de datos para solicitud de vendedor
class SellerRequestModel extends SellerRequestEntity {
  const SellerRequestModel({
    required super.id,
    required super.userId,
    required super.userName,
    required super.userPhoto,
    required super.userEmail,
    required super.message,
    required super.status,
    required super.createdAt,
    super.reviewedAt,
    super.reviewedBy,
    super.reviewComment,
  });

  /// Crea un modelo desde un documento de Firestore
  factory SellerRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return SellerRequestModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'no_name',
      userPhoto: data['userPhoto'] ?? '',
      userEmail: data['userEmail'] ?? '',
      message: data['message'] ?? '',
      status: _parseStatus(data['status']),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      reviewedAt: (data['reviewedAt'] as Timestamp?)?.toDate(),
      reviewedBy: data['reviewedBy'],
      reviewComment: data['reviewComment'],
    );
  }

  /// Crea un modelo desde un Map
  factory SellerRequestModel.fromMap(Map<String, dynamic> map, String id) {
    return SellerRequestModel(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'no_name',
      userPhoto: map['userPhoto'] ?? '',
      userEmail: map['userEmail'] ?? '',
      message: map['message'] ?? '',
      status: _parseStatus(map['status']),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      reviewedAt: (map['reviewedAt'] as Timestamp?)?.toDate(),
      reviewedBy: map['reviewedBy'],
      reviewComment: map['reviewComment'],
    );
  }

  /// Convierte el modelo a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhoto': userPhoto,
      'userEmail': userEmail,
      'message': message,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'reviewedAt': reviewedAt != null ? Timestamp.fromDate(reviewedAt!) : null,
      'reviewedBy': reviewedBy,
      'reviewComment': reviewComment,
    };
  }

  /// Parsea el estado desde string
  static SellerRequestStatus _parseStatus(dynamic status) {
    if (status == null) return SellerRequestStatus.pending;

    switch (status.toString().toLowerCase()) {
      case 'approved':
        return SellerRequestStatus.approved;
      case 'rejected':
        return SellerRequestStatus.rejected;
      default:
        return SellerRequestStatus.pending;
    }
  }

  /// Crea una copia del modelo con nuevos valores
  @override
  SellerRequestModel copyWith({
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
    return SellerRequestModel(
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
