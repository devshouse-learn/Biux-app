import 'package:biux/features/bikes/domain/entities/bike_entity.dart';
import 'package:biux/features/bikes/domain/repositories/bike_repository.dart';

/// Caso de uso para obtener todas las bicicletas de un usuario
class GetUserBikesUseCase {
  final BikeRepository repository;

  GetUserBikesUseCase(this.repository);

  Future<List<BikeEntity>> call(String userId) async {
    if (userId.trim().isEmpty) {
      throw ArgumentError('El ID del usuario es requerido');
    }

    return await repository.getUserBikes(userId);
  }
}
