/// Entidad para avistamiento de bicicleta (acción "La vi")
class BikeSightingEntity {
  final String id;
  final String bikeId;
  final String reporterId; // Usuario que reporta el avistamiento
  final DateTime sightingDate;
  final String location; // Ubicación del avistamiento
  final String? description; // Descripción opcional del avistamiento
  final double? latitude;
  final double? longitude;
  final List<String>? photos; // Fotos del avistamiento
  final bool ownerNotified; // Si el dueño fue notificado

  const BikeSightingEntity({
    required this.id,
    required this.bikeId,
    required this.reporterId,
    required this.sightingDate,
    required this.location,
    this.description,
    this.latitude,
    this.longitude,
    this.photos,
    this.ownerNotified = false,
  });

  BikeSightingEntity copyWith({
    String? id,
    String? bikeId,
    String? reporterId,
    DateTime? sightingDate,
    String? location,
    String? description,
    double? latitude,
    double? longitude,
    List<String>? photos,
    bool? ownerNotified,
  }) {
    return BikeSightingEntity(
      id: id ?? this.id,
      bikeId: bikeId ?? this.bikeId,
      reporterId: reporterId ?? this.reporterId,
      sightingDate: sightingDate ?? this.sightingDate,
      location: location ?? this.location,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      photos: photos ?? this.photos,
      ownerNotified: ownerNotified ?? this.ownerNotified,
    );
  }
}
