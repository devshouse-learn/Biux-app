import 'package:biux/features/bikes/domain/entities/bike_theft_entity.dart';

class BikeTheftModel {
  final String id;
  final String bikeId;
  final String reporterId;
  final String theftDate; // ISO string
  final String reportDate; // ISO string
  final String location;
  final String description;
  final String? policeReportNumber;
  final bool isActive;

  const BikeTheftModel({
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

  factory BikeTheftModel.fromJson(Map<String, dynamic> json) {
    return BikeTheftModel(
      id: json['id'] ?? '',
      bikeId: json['bikeId'] ?? '',
      reporterId: json['reporterId'] ?? '',
      theftDate: json['theftDate'] ?? DateTime.now().toIso8601String(),
      reportDate: json['reportDate'] ?? DateTime.now().toIso8601String(),
      location: json['location'] ?? '',
      description: json['description'] ?? '',
      policeReportNumber: json['policeReportNumber'],
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bikeId': bikeId,
      'reporterId': reporterId,
      'theftDate': theftDate,
      'reportDate': reportDate,
      'location': location,
      'description': description,
      'policeReportNumber': policeReportNumber,
      'isActive': isActive,
    };
  }

  BikeTheftEntity toEntity() {
    return BikeTheftEntity(
      id: id,
      bikeId: bikeId,
      reporterId: reporterId,
      theftDate: DateTime.parse(theftDate),
      reportDate: DateTime.parse(reportDate),
      location: location,
      description: description,
      policeReportNumber: policeReportNumber,
      isActive: isActive,
    );
  }

  factory BikeTheftModel.fromEntity(BikeTheftEntity entity) {
    return BikeTheftModel(
      id: entity.id,
      bikeId: entity.bikeId,
      reporterId: entity.reporterId,
      theftDate: entity.theftDate.toIso8601String(),
      reportDate: entity.reportDate.toIso8601String(),
      location: entity.location,
      description: entity.description,
      policeReportNumber: entity.policeReportNumber,
      isActive: entity.isActive,
    );
  }
}
