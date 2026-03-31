import 'package:biux/features/bikes/domain/entities/bike_entity.dart';
import 'package:biux/features/bikes/domain/entities/bike_enums.dart';

/// Modelo de datos para la bicicleta (capa de datos)
/// Corresponde a BikeEntity del dominio pero con serialización JSON
class BikeModel {
  final String id;
  final String qrCode;
  final String ownerId;

  // Campos obligatorios
  final String brand;
  final String model;
  final int year;
  final String color;
  final String size;
  final String type; // Almacenado como string para Firebase
  final String frameSerial;
  final String mainPhoto;
  final String city;

  // Campos muy recomendados
  final String? serialPhoto;
  final String? neighborhood;
  final List<String>? additionalPhotos;

  // Campos opcionales
  final String? invoice;
  final String? purchaseDate; // Almacenado como string ISO
  final String? purchasePlace;
  final String? featuredComponents;

  // Campos del sistema
  final String status; // Almacenado como string para Firebase
  final String? verifiedBy;
  final String registrationDate; // Almacenado como string ISO
  final String? lastUpdated;

  const BikeModel({
    required this.id,
    required this.qrCode,
    required this.ownerId,
    required this.brand,
    required this.model,
    required this.year,
    required this.color,
    required this.size,
    required this.type,
    required this.frameSerial,
    required this.mainPhoto,
    required this.city,
    this.serialPhoto,
    this.neighborhood,
    this.additionalPhotos,
    this.invoice,
    this.purchaseDate,
    this.purchasePlace,
    this.featuredComponents,
    required this.status,
    this.verifiedBy,
    required this.registrationDate,
    this.lastUpdated,
  });

  /// Factory constructor desde JSON
  factory BikeModel.fromJson(Map<String, dynamic> json) {
    return BikeModel(
      id: json['id'] ?? '',
      qrCode: json['qrCode'] ?? '',
      ownerId: json['ownerId'] ?? '',
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      year: json['year'] ?? 0,
      color: json['color'] ?? '',
      size: json['size'] ?? '',
      type: json['type'] ?? 'other',
      frameSerial: json['frameSerial'] ?? '',
      mainPhoto: json['mainPhoto'] ?? '',
      city: json['city'] ?? '',
      serialPhoto: json['serialPhoto'],
      neighborhood: json['neighborhood'],
      additionalPhotos: json['additionalPhotos'] != null
          ? List<String>.from(json['additionalPhotos'])
          : null,
      invoice: json['invoice'],
      purchaseDate: json['purchaseDate'],
      purchasePlace: json['purchasePlace'],
      featuredComponents: json['featuredComponents'],
      status: json['status'] ?? 'active',
      verifiedBy: json['verifiedBy'],
      registrationDate:
          json['registrationDate'] ?? DateTime.now().toIso8601String(),
      lastUpdated: json['lastUpdated'],
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'qrCode': qrCode,
      'ownerId': ownerId,
      'brand': brand,
      'model': model,
      'year': year,
      'color': color,
      'size': size,
      'type': type,
      'frameSerial': frameSerial,
      'mainPhoto': mainPhoto,
      'city': city,
      'serialPhoto': serialPhoto,
      'neighborhood': neighborhood,
      'additionalPhotos': additionalPhotos,
      'invoice': invoice,
      'purchaseDate': purchaseDate,
      'purchasePlace': purchasePlace,
      'featuredComponents': featuredComponents,
      'status': status,
      'verifiedBy': verifiedBy,
      'registrationDate': registrationDate,
      'lastUpdated': lastUpdated,
    };
  }

  /// Convertir a entidad de dominio
  BikeEntity toEntity() {
    return BikeEntity(
      id: id,
      qrCode: qrCode,
      ownerId: ownerId,
      brand: brand,
      model: model,
      year: year,
      color: color,
      size: size,
      type: _stringToBikeType(type),
      frameSerial: frameSerial,
      mainPhoto: mainPhoto,
      city: city,
      serialPhoto: serialPhoto,
      neighborhood: neighborhood,
      additionalPhotos: additionalPhotos,
      invoice: invoice,
      purchaseDate: purchaseDate != null
          ? DateTime.tryParse(purchaseDate!)
          : null,
      purchasePlace: purchasePlace,
      featuredComponents: featuredComponents,
      status: _stringToBikeStatus(status),
      verifiedBy: verifiedBy,
      registrationDate: DateTime.parse(registrationDate),
      lastUpdated: lastUpdated != null ? DateTime.tryParse(lastUpdated!) : null,
    );
  }

  /// Factory constructor desde entidad de dominio
  factory BikeModel.fromEntity(BikeEntity entity) {
    return BikeModel(
      id: entity.id,
      qrCode: entity.qrCode,
      ownerId: entity.ownerId,
      brand: entity.brand,
      model: entity.model,
      year: entity.year,
      color: entity.color,
      size: entity.size,
      type: _bikeTypeToString(entity.type),
      frameSerial: entity.frameSerial,
      mainPhoto: entity.mainPhoto,
      city: entity.city,
      serialPhoto: entity.serialPhoto,
      neighborhood: entity.neighborhood,
      additionalPhotos: entity.additionalPhotos,
      invoice: entity.invoice,
      purchaseDate: entity.purchaseDate?.toIso8601String(),
      purchasePlace: entity.purchasePlace,
      featuredComponents: entity.featuredComponents,
      status: _bikeStatusToString(entity.status),
      verifiedBy: entity.verifiedBy,
      registrationDate: entity.registrationDate.toIso8601String(),
      lastUpdated: entity.lastUpdated?.toIso8601String(),
    );
  }

  /// Helpers para conversión de enums
  static BikeType _stringToBikeType(String typeString) {
    switch (typeString.toLowerCase()) {
      case 'mtb':
        return BikeType.mtb;
      case 'road':
        return BikeType.road;
      case 'urban':
        return BikeType.urban;
      case 'electric':
        return BikeType.electric;
      case 'kids':
        return BikeType.kids;
      default:
        return BikeType.other;
    }
  }

  static String _bikeTypeToString(BikeType type) {
    switch (type) {
      case BikeType.mtb:
        return 'mtb';
      case BikeType.road:
        return 'road';
      case BikeType.urban:
        return 'urban';
      case BikeType.electric:
        return 'electric';
      case BikeType.kids:
        return 'kids';
      case BikeType.other:
        return 'other';
    }
  }

  static BikeStatus _stringToBikeStatus(String statusString) {
    switch (statusString.toLowerCase()) {
      case 'stolen':
        return BikeStatus.stolen;
      case 'recovered':
        return BikeStatus.recovered;
      case 'verified':
        return BikeStatus.verified;
      default:
        return BikeStatus.active;
    }
  }

  static String _bikeStatusToString(BikeStatus status) {
    switch (status) {
      case BikeStatus.active:
        return 'active';
      case BikeStatus.stolen:
        return 'stolen';
      case BikeStatus.recovered:
        return 'recovered';
      case BikeStatus.verified:
        return 'verified';
    }
  }

  BikeModel copyWith({
    String? id,
    String? qrCode,
    String? ownerId,
    String? brand,
    String? model,
    int? year,
    String? color,
    String? size,
    String? type,
    String? frameSerial,
    String? mainPhoto,
    String? city,
    String? serialPhoto,
    String? neighborhood,
    List<String>? additionalPhotos,
    String? invoice,
    String? purchaseDate,
    String? purchasePlace,
    String? featuredComponents,
    String? status,
    String? verifiedBy,
    String? registrationDate,
    String? lastUpdated,
  }) {
    return BikeModel(
      id: id ?? this.id,
      qrCode: qrCode ?? this.qrCode,
      ownerId: ownerId ?? this.ownerId,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      color: color ?? this.color,
      size: size ?? this.size,
      type: type ?? this.type,
      frameSerial: frameSerial ?? this.frameSerial,
      mainPhoto: mainPhoto ?? this.mainPhoto,
      city: city ?? this.city,
      serialPhoto: serialPhoto ?? this.serialPhoto,
      neighborhood: neighborhood ?? this.neighborhood,
      additionalPhotos: additionalPhotos ?? this.additionalPhotos,
      invoice: invoice ?? this.invoice,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      purchasePlace: purchasePlace ?? this.purchasePlace,
      featuredComponents: featuredComponents ?? this.featuredComponents,
      status: status ?? this.status,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      registrationDate: registrationDate ?? this.registrationDate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
