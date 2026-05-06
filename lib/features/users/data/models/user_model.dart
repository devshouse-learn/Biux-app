import 'package:biux/features/users/domain/entities/user_entity.dart';

class UserModel {
  final String uid;
  final String? name;
  final String? email;
  final String? photoUrl;
  final String? coverPhotoUrl;
  final String phoneNumber;
  final String? username;
  final bool isDeleting;
  final DateTime? deletionRequestDate;
  final bool isAdmin; // Campo para administradores
  final bool canSellProducts; // Campo para vendedores autorizados
  final String? role; // Nuevo: "user", "seller", "admin"
  final bool autorizadoPorAdmin; // Nuevo: Si fue autorizado por admin
  final String? description; // Nuevo: Descripción/Bio del usuario
  final Map<String, dynamic>? followers; // Nuevo: Mapa de seguidores
  final Map<String, dynamic>? following; // Nuevo: Mapa de seguidos
  final DateTime? birthDate; // Fecha de nacimiento
  final String profileVisibility; // 'public' o 'private'

  UserModel({
    required this.uid,
    this.name,
    this.email,
    this.photoUrl,
    this.coverPhotoUrl,
    required this.phoneNumber,
    this.username,
    this.isDeleting = false,
    this.deletionRequestDate,
    this.isAdmin = false,
    this.canSellProducts = false,
    this.role,
    this.autorizadoPorAdmin = false,
    this.description,
    this.followers,
    this.following,
    this.birthDate,
    this.profileVisibility = 'public',
  });

  // Getter para rol enum
  UserRole get userRole {
    // Prioridad: usar campo 'role' nuevo, luego legacy
    if (role != null) {
      switch (role!.toLowerCase()) {
        case 'admin':
          return UserRole.admin;
        case 'seller':
          return UserRole.seller;
        default:
          return UserRole.user;
      }
    }
    // Fallback a campos legacy
    if (isAdmin) return UserRole.admin;
    if (canSellProducts) return UserRole.seller;
    return UserRole.user;
  }

  // Getter compatible con UserEntity
  bool get isAdministrador => isAdmin || userRole == UserRole.admin;

  // Getter para verificar si puede crear productos
  bool get canCreateProducts =>
      isAdmin ||
      canSellProducts ||
      userRole == UserRole.admin ||
      userRole == UserRole.seller;

  // Convertir a UserEntity
  UserEntity toEntity() {
    return UserEntity(
      id: uid,
      fullName: name ?? '',
      userName: username ?? '',
      email: email ?? '',
      photo: photoUrl ?? '',
      role: userRole,
      autorizadoPorAdmin: autorizadoPorAdmin,
      isAdmin: isAdmin,
      canSellProducts: canSellProducts,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'coverPhotoUrl': coverPhotoUrl,
      'phoneNumber': phoneNumber,
      'username': username,
      'isDeleting': isDeleting,
      'deletionRequestDate': deletionRequestDate?.toIso8601String(),
      'isAdmin': isAdmin,
      'canSellProducts': canSellProducts,
      'role': role ?? userRole.name, // Guardar rol como string
      'autorizadoPorAdmin': autorizadoPorAdmin,
      'description': description,
      'followers': followers,
      'following': following,
      'birthDate': birthDate?.toIso8601String(),
      'profileVisibility': profileVisibility,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'],
      email: map['email'],
      photoUrl: map['photoUrl'],
      coverPhotoUrl: map['coverPhotoUrl'],
      phoneNumber: map['phoneNumber'] ?? map['phone'] ?? '',
      username: map['username'],
      isDeleting: map['isDeleting'] ?? false,
      deletionRequestDate: map['deletionRequestDate'] != null
          ? DateTime.parse(map['deletionRequestDate'])
          : null,
      isAdmin: map['isAdmin'] ?? false,
      canSellProducts: map['canSellProducts'] ?? false,
      role: map['role'],
      autorizadoPorAdmin: map['autorizadoPorAdmin'] ?? false,
      description: map['description'],
      followers: map['followers'],
      following: map['following'],
      birthDate: map['birthDate'] != null
          ? DateTime.tryParse(map['birthDate'])
          : null,
      profileVisibility: map['profileVisibility'] ?? 'public',
    );
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? photoUrl,
    String? coverPhotoUrl,
    String? phoneNumber,
    String? username,
    bool? isDeleting,
    DateTime? deletionRequestDate,
    bool? isAdmin,
    bool? canSellProducts,
    String? role,
    bool? autorizadoPorAdmin,
    String? description,
    Map<String, dynamic>? followers,
    Map<String, dynamic>? following,
    DateTime? birthDate,
    String? profileVisibility,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      coverPhotoUrl: coverPhotoUrl ?? this.coverPhotoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      username: username ?? this.username,
      isDeleting: isDeleting ?? this.isDeleting,
      deletionRequestDate: deletionRequestDate ?? this.deletionRequestDate,
      isAdmin: isAdmin ?? this.isAdmin,
      canSellProducts: canSellProducts ?? this.canSellProducts,
      role: role ?? this.role,
      autorizadoPorAdmin: autorizadoPorAdmin ?? this.autorizadoPorAdmin,
      description: description ?? this.description,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      birthDate: birthDate ?? this.birthDate,
      profileVisibility: profileVisibility ?? this.profileVisibility,
    );
  }
}
