import 'package:biux/features/bikes/domain/entities/bike_entity.dart';
import 'package:biux/features/bikes/domain/entities/bike_enums.dart';
import 'package:biux/features/bikes/domain/repositories/bike_repository.dart';

/// Caso de uso para marcar una bicicleta robada como recuperada
class MarkAsRecoveredUseCase {
  final BikeRepository repository;

  MarkAsRecoveredUseCase(this.repository);

  Future<BikeEntity> call({
    required String bikeId,
    required String userId,
  }) async {
    // Validaciones
    if (bikeId.trim().isEmpty) {
      throw ArgumentError('El ID de la bicicleta es requerido');
    }
    if (userId.trim().isEmpty) {
      throw ArgumentError('El ID del usuario es requerido');
    }

    // Verificar que la bicicleta existe y pertenece al usuario
    final bike = await repository.getBikeById(bikeId);
    if (bike == null) {
      throw ArgumentError('La bicicleta no existe');
    }
    if (bike.ownerId != userId) {
      throw ArgumentError('Solo el propietario puede marcar como recuperada');
    }
    if (bike.status != BikeStatus.stolen) {
      throw ArgumentError('Solo se pueden recuperar bicicletas robadas');
    }

    // Delegar al repositorio
    return await repository.markAsRecovered(bikeId, userId);
  }
}
