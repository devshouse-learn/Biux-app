import 'package:biux/features/bikes/domain/entities/bike_entity.dart';
import 'package:biux/features/bikes/domain/entities/bike_enums.dart';
import 'package:biux/features/bikes/domain/repositories/bike_repository.dart';

/// Caso de uso para registrar una nueva bicicleta
class RegisterBikeUseCase {
  final BikeRepository repository;

  RegisterBikeUseCase(this.repository);

  /// Registra una nueva bicicleta con validaciones
  Future<BikeEntity> call({
    required String ownerId,
    required String brand,
    required String model,
    required int year,
    required String color,
    required String size,
    required BikeType type,
    required String frameSerial,
    required String mainPhoto,
    required String city,
    String? serialPhoto,
    String? neighborhood,
    List<String>? additionalPhotos,
    String? invoice,
    DateTime? purchaseDate,
    String? purchasePlace,
    String? featuredComponents,
  }) async {
    // Validaciones de campos obligatorios
    if (brand.trim().isEmpty) {
      throw ArgumentError('La marca es obligatoria');
    }
    if (model.trim().isEmpty) {
      throw ArgumentError('El modelo es obligatorio');
    }
    if (year < 1900 || year > DateTime.now().year + 1) {
      throw ArgumentError(
        'El año debe estar entre 1900 y ${DateTime.now().year + 1}',
      );
    }
    if (color.trim().isEmpty) {
      throw ArgumentError('El color es obligatorio');
    }
    if (size.trim().isEmpty) {
      throw ArgumentError('La talla es obligatoria');
    }
    if (frameSerial.trim().isEmpty) {
      throw ArgumentError('El número de serie del marco es obligatorio');
    }
    if (mainPhoto.trim().isEmpty) {
      throw ArgumentError('La foto principal es obligatoria');
    }
    if (city.trim().isEmpty) {
      throw ArgumentError('La ciudad es obligatoria');
    }

    // Generar QR único
    final qrCode = await repository.generateUniqueQR();

    // Crear entidad
    final bike = BikeEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      qrCode: qrCode,
      ownerId: ownerId,
      brand: brand.trim(),
      model: model.trim(),
      year: year,
      color: color.trim(),
      size: size.trim(),
      type: type,
      frameSerial: frameSerial.trim(),
      mainPhoto: mainPhoto,
      city: city.trim(),
      serialPhoto: serialPhoto,
      neighborhood: neighborhood?.trim(),
      additionalPhotos: additionalPhotos,
      invoice: invoice,
      purchaseDate: purchaseDate,
      purchasePlace: purchasePlace?.trim(),
      featuredComponents: featuredComponents?.trim(),
      registrationDate: DateTime.now(),
    );

    // Registrar en el repositorio
    return await repository.registerBike(bike);
  }
}
