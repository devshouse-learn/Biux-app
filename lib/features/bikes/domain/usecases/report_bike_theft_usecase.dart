import 'package:biux/features/bikes/domain/entities/bike_entity.dart';
import 'package:biux/features/bikes/domain/entities/bike_enums.dart';
import 'package:biux/features/bikes/domain/entities/bike_theft_entity.dart';
import 'package:biux/features/bikes/domain/repositories/bike_repository.dart';

/// Caso de uso para reportar el robo de una bicicleta
class ReportBikeTheftUseCase {
  final BikeRepository repository;

  ReportBikeTheftUseCase(this.repository);

  Future<BikeEntity> call({
    required String bikeId,
    required String reporterId,
    required DateTime theftDate,
    required String location,
    required String description,
    String? policeReportNumber,
  }) async {
    // Validaciones
    if (bikeId.trim().isEmpty) {
      throw ArgumentError('El ID de la bicicleta es requerido');
    }
    if (reporterId.trim().isEmpty) {
      throw ArgumentError('El ID del reportero es requerido');
    }
    if (location.trim().isEmpty) {
      throw ArgumentError('La ubicación del robo es requerida');
    }
    if (description.trim().isEmpty) {
      throw ArgumentError('La descripción del robo es requerida');
    }

    // Verificar que la bicicleta existe y pertenece al usuario
    final bike = await repository.getBikeById(bikeId);
    if (bike == null) {
      throw ArgumentError('La bicicleta no existe');
    }
    if (bike.ownerId != reporterId) {
      throw ArgumentError('Solo el propietario puede reportar el robo');
    }
    if (bike.status == BikeStatus.stolen) {
      throw ArgumentError('Esta bicicleta ya está reportada como robada');
    }

    // Crear reporte de robo
    final theft = BikeTheftEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      bikeId: bikeId,
      reporterId: reporterId,
      theftDate: theftDate,
      reportDate: DateTime.now(),
      location: location.trim(),
      description: description.trim(),
      policeReportNumber: policeReportNumber?.trim(),
    );

    // Reportar robo
    await repository.reportTheft(theft);

    // Actualizar estado de la bicicleta a robada
    final updatedBike = bike.copyWith(
      status: BikeStatus.stolen,
      lastUpdated: DateTime.now(),
    );

    return await repository.updateBike(updatedBike);
  }
}
