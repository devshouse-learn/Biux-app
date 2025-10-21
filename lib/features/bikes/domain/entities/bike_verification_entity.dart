/// Entidad para verificación de bicicleta por tienda aliada
class BikeVerificationEntity {
  final String id;
  final String bikeId;
  final String storeId; // ID de la tienda aliada
  final String storeName; // Nombre de la tienda
  final String verifierId; // ID del empleado que verificó
  final String verifierName; // Nombre del empleado
  final DateTime verificationDate;
  final String? notes; // Notas de la verificación
  final List<String>? verificationPhotos; // Fotos de la verificación
  final bool isActive; // Si la verificación está activa

  const BikeVerificationEntity({
    required this.id,
    required this.bikeId,
    required this.storeId,
    required this.storeName,
    required this.verifierId,
    required this.verifierName,
    required this.verificationDate,
    this.notes,
    this.verificationPhotos,
    this.isActive = true,
  });

  /// Texto para mostrar en la UI
  String get displayText => 'Verificada por $storeName';

  BikeVerificationEntity copyWith({
    String? id,
    String? bikeId,
    String? storeId,
    String? storeName,
    String? verifierId,
    String? verifierName,
    DateTime? verificationDate,
    String? notes,
    List<String>? verificationPhotos,
    bool? isActive,
  }) {
    return BikeVerificationEntity(
      id: id ?? this.id,
      bikeId: bikeId ?? this.bikeId,
      storeId: storeId ?? this.storeId,
      storeName: storeName ?? this.storeName,
      verifierId: verifierId ?? this.verifierId,
      verifierName: verifierName ?? this.verifierName,
      verificationDate: verificationDate ?? this.verificationDate,
      notes: notes ?? this.notes,
      verificationPhotos: verificationPhotos ?? this.verificationPhotos,
      isActive: isActive ?? this.isActive,
    );
  }
}
