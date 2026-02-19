/// Estado de la bicicleta
enum BikeStatus { active, stolen, recovered, sold }

/// Entidad de bicicleta registrada para sistema anti-robo
class RegisteredBikeEntity {
  final String id;
  final String ownerId;
  final String ownerName;
  final String brand;
  final String model;
  final String? color;
  final String? frameSerial;
  final String? size;
  final int? year;
  final String? description;
  final List<String> photos;
  final BikeStatus status;
  final DateTime registeredAt;
  final DateTime? stolenAt;
  final String? stolenLocation;
  final String? stolenDescription;
  final String? qrCode;
  final String? insuranceInfo;
  final Map<String, String> customFields;

  const RegisteredBikeEntity({
    required this.id,
    required this.ownerId,
    required this.ownerName,
    required this.brand,
    required this.model,
    this.color,
    this.frameSerial,
    this.size,
    this.year,
    this.description,
    this.photos = const [],
    this.status = BikeStatus.active,
    required this.registeredAt,
    this.stolenAt,
    this.stolenLocation,
    this.stolenDescription,
    this.qrCode,
    this.insuranceInfo,
    this.customFields = const {},
  });

  bool get isStolen => status == BikeStatus.stolen;
  bool get isActive => status == BikeStatus.active;

  String get statusLabel {
    switch (status) {
      case BikeStatus.active:
        return '✅ Activa';
      case BikeStatus.stolen:
        return '🚨 Robada';
      case BikeStatus.recovered:
        return '🔄 Recuperada';
      case BikeStatus.sold:
        return '💰 Vendida';
    }
  }

  String get fullName => '$brand $model${year != null ? ' ($year)' : ''}';
}
