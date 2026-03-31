import 'bike_enums.dart';

/// Entidad de dominio para una bicicleta
/// Contiene todos los campos del MVP: obligatorios, recomendados y opcionales
class BikeEntity {
  final String id;
  final String qrCode; // QR único generado por el sistema
  final String ownerId; // ID del usuario propietario

  // Campos obligatorios (A)
  final String brand;
  final String model;
  final int year;
  final String color;
  final String size; // Talla
  final BikeType type;
  final String frameSerial;
  final String mainPhoto; // Foto principal
  final String city;

  // Campos muy recomendados (B)
  final String? serialPhoto; // Foto del número de serie
  final String? neighborhood; // Barrio
  final List<String>? additionalPhotos; // Fotos adicionales (2-4)

  // Campos opcionales (C)
  final String? invoice; // Factura o recibo
  final DateTime? purchaseDate; // Fecha de compra
  final String? purchasePlace; // Lugar de compra
  final String? featuredComponents; // Componentes destacados

  // Campos del sistema
  final BikeStatus status;
  final String? verifiedBy; // "Verificada por {Nombre Tienda}"
  final DateTime registrationDate;
  final DateTime? lastUpdated;

  const BikeEntity({
    required this.id,
    required this.qrCode,
    required this.ownerId,
    // Obligatorios
    required this.brand,
    required this.model,
    required this.year,
    required this.color,
    required this.size,
    required this.type,
    required this.frameSerial,
    required this.mainPhoto,
    required this.city,
    // Muy recomendados
    this.serialPhoto,
    this.neighborhood,
    this.additionalPhotos,
    // Opcionales
    this.invoice,
    this.purchaseDate,
    this.purchasePlace,
    this.featuredComponents,
    // Sistema
    this.status = BikeStatus.active,
    this.verifiedBy,
    required this.registrationDate,
    this.lastUpdated,
  });

  /// Indica si la bicicleta puede ser transferida
  /// Regla: bici en estado Robada no se transfiere ni se verifica hasta que vuelva a Recuperada/Activa
  bool get canBeTransferred => status != BikeStatus.stolen;

  /// Indica si la bicicleta puede ser verificada por tienda aliada
  bool get canBeVerified => status != BikeStatus.stolen;

  /// Indica si la bicicleta está verificada
  bool get isVerified => status == BikeStatus.verified;

  /// Indica si la bicicleta está robada
  bool get isStolen => status == BikeStatus.stolen;

  /// Obtiene la URL pública para el QR (sin datos personales)
  String get publicUrl => 'https://biux.app/bike/$qrCode';

  /// Copia la entidad con cambios específicos
  BikeEntity copyWith({
    String? id,
    String? qrCode,
    String? ownerId,
    String? brand,
    String? model,
    int? year,
    String? color,
    String? size,
    BikeType? type,
    String? frameSerial,
    String? mainPhoto,
    String? city,
    String? serialPhoto,
    String? neighborhood,
    List<String>? additionalPhotos,
    String? invoice,
    DateTime? purchaseDate,
    String? purchasePlace,
    String? featuredComponents,
    BikeStatus? status,
    String? verifiedBy,
    DateTime? registrationDate,
    DateTime? lastUpdated,
  }) {
    return BikeEntity(
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BikeEntity &&
        other.id == id &&
        other.qrCode == qrCode &&
        other.ownerId == ownerId;
  }

  @override
  int get hashCode => id.hashCode ^ qrCode.hashCode ^ ownerId.hashCode;

  @override
  String toString() {
    return 'BikeEntity(id: $id, brand: $brand, model: $model, status: $status)';
  }
}
