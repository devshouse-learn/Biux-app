import 'package:cloud_firestore/cloud_firestore.dart';

class GroupModel {
  final String id;
  final String name;
  final String description;
  final String? logoUrl;
  final String? coverUrl;
  final String adminId;
  final String cityId; // NUEVO CAMPO PARA CIUDAD
  final List<String> memberIds;
  final List<String> pendingRequestIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  GroupModel({
    required this.id,
    required this.name,
    required this.description,
    this.logoUrl,
    this.coverUrl,
    required this.adminId,
    required this.cityId, // REQUERIDO
    required this.memberIds,
    required this.pendingRequestIds,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  factory GroupModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GroupModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      logoUrl: data['logoUrl'],
      coverUrl: data['coverUrl'],
      adminId: data['adminId'] ?? '',
      cityId: data['cityId'] ?? '', // NUEVO CAMPO
      memberIds: List<String>.from(data['memberIds'] ?? []),
      pendingRequestIds: List<String>.from(data['pendingRequestIds'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'logoUrl': logoUrl,
      'coverUrl': coverUrl,
      'adminId': adminId,
      'cityId': cityId, // NUEVO CAMPO
      'memberIds': memberIds,
      'pendingRequestIds': pendingRequestIds,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
    };
  }

  GroupModel copyWith({
    String? id,
    String? name,
    String? description,
    String? logoUrl,
    String? coverUrl,
    String? adminId,
    String? cityId, // NUEVO CAMPO
    List<String>? memberIds,
    List<String>? pendingRequestIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return GroupModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      adminId: adminId ?? this.adminId,
      cityId: cityId ?? this.cityId, // NUEVO CAMPO
      memberIds: memberIds ?? this.memberIds,
      pendingRequestIds: pendingRequestIds ?? this.pendingRequestIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  int get memberCount => memberIds.length;
  int get pendingRequestCount => pendingRequestIds.length;

  bool isMember(String userId) => memberIds.contains(userId);
  bool hasPendingRequest(String userId) => pendingRequestIds.contains(userId);
  bool isAdmin(String userId) => adminId == userId;
}
