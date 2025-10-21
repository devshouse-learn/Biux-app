import 'package:biux/features/bikes/domain/entities/bike_entity.dart';
import 'package:biux/features/bikes/domain/repositories/bike_repository.dart';

/// Caso de uso para obtener la ficha pública de una bicicleta (por QR)
class GetPublicBikeInfoUseCase {
  final BikeRepository repository;

  GetPublicBikeInfoUseCase(this.repository);

  Future<BikeEntity?> call(String qrCode) async {
    if (qrCode.trim().isEmpty) {
      throw ArgumentError('El código QR es requerido');
    }

    return await repository.getBikeByQR(qrCode);
  }
}
