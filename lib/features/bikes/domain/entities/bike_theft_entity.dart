/// Entidad para reporte de robo de bicicleta
class BikeTheftEntity {
  final String id;
  final String bikeId;
  final String reporterId; // Usuario que reporta
  final DateTime theftDate;
  final DateTime reportDate;
  final String location; // Lugar del robo
  final String description;
  final String? policeReportNumber; // Número de denuncia policial
  final bool isActive; // Si el reporte está activo

  const BikeTheftEntity({
    required this.id,
    required this.bikeId,
    required this.reporterId,
    required this.theftDate,
    required this.reportDate,
    required this.location,
    required this.description,
    this.policeReportNumber,
    this.isActive = true,
  });

  BikeTheftEntity copyWith({
    String? id,
    String? bikeId,
    String? reporterId,
    DateTime? theftDate,
    DateTime? reportDate,
    String? location,
    String? description,
    String? policeReportNumber,
    bool? isActive,
  }) {
    return BikeTheftEntity(
      id: id ?? this.id,
      bikeId: bikeId ?? this.bikeId,
      reporterId: reporterId ?? this.reporterId,
      theftDate: theftDate ?? this.theftDate,
      reportDate: reportDate ?? this.reportDate,
      location: location ?? this.location,
      description: description ?? this.description,
      policeReportNumber: policeReportNumber ?? this.policeReportNumber,
      isActive: isActive ?? this.isActive,
    );
  }
}
