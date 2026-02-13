import 'package:biux/features/bikes/domain/repositories/bike_repository.dart';

/// Use case para eliminar una bicicleta
class DeleteBikeUseCase {
  final BikeRepository repository;

  DeleteBikeUseCase(this.repository);

  Future<void> call(String bikeId) async {
    return await repository.deleteBike(bikeId);
  }
}
