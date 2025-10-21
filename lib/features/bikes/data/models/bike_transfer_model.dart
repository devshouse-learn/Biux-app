import 'package:biux/features/bikes/domain/entities/bike_transfer_entity.dart';

class BikeTransferModel {
  final String id;
  final String bikeId;
  final String fromUserId;
  final String toUserId;
  final String? toUserEmail;
  final String requestDate; // ISO string
  final String? responseDate; // ISO string
  final String status; // String representation of TransferStatus
  final String? message;
  final String? rejectionReason;

  const BikeTransferModel({
    required this.id,
    required this.bikeId,
    required this.fromUserId,
    required this.toUserId,
    this.toUserEmail,
    required this.requestDate,
    this.responseDate,
    this.status = 'pending',
    this.message,
    this.rejectionReason,
  });

  factory BikeTransferModel.fromJson(Map<String, dynamic> json) {
    return BikeTransferModel(
      id: json['id'] ?? '',
      bikeId: json['bikeId'] ?? '',
      fromUserId: json['fromUserId'] ?? '',
      toUserId: json['toUserId'] ?? '',
      toUserEmail: json['toUserEmail'],
      requestDate: json['requestDate'] ?? DateTime.now().toIso8601String(),
      responseDate: json['responseDate'],
      status: json['status'] ?? 'pending',
      message: json['message'],
      rejectionReason: json['rejectionReason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bikeId': bikeId,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'toUserEmail': toUserEmail,
      'requestDate': requestDate,
      'responseDate': responseDate,
      'status': status,
      'message': message,
      'rejectionReason': rejectionReason,
    };
  }

  BikeTransferEntity toEntity() {
    return BikeTransferEntity(
      id: id,
      bikeId: bikeId,
      fromUserId: fromUserId,
      toUserId: toUserId,
      toUserEmail: toUserEmail,
      requestDate: DateTime.parse(requestDate),
      responseDate: responseDate != null ? DateTime.parse(responseDate!) : null,
      status: _stringToTransferStatus(status),
      message: message,
      rejectionReason: rejectionReason,
    );
  }

  factory BikeTransferModel.fromEntity(BikeTransferEntity entity) {
    return BikeTransferModel(
      id: entity.id,
      bikeId: entity.bikeId,
      fromUserId: entity.fromUserId,
      toUserId: entity.toUserId,
      toUserEmail: entity.toUserEmail,
      requestDate: entity.requestDate.toIso8601String(),
      responseDate: entity.responseDate?.toIso8601String(),
      status: _transferStatusToString(entity.status),
      message: entity.message,
      rejectionReason: entity.rejectionReason,
    );
  }

  static TransferStatus _stringToTransferStatus(String statusString) {
    switch (statusString.toLowerCase()) {
      case 'accepted':
        return TransferStatus.accepted;
      case 'rejected':
        return TransferStatus.rejected;
      case 'cancelled':
        return TransferStatus.cancelled;
      default:
        return TransferStatus.pending;
    }
  }

  static String _transferStatusToString(TransferStatus status) {
    switch (status) {
      case TransferStatus.pending:
        return 'pending';
      case TransferStatus.accepted:
        return 'accepted';
      case TransferStatus.rejected:
        return 'rejected';
      case TransferStatus.cancelled:
        return 'cancelled';
    }
  }
}
