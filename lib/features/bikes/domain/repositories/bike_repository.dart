import 'package:biux/features/bikes/domain/entities/bike_entity.dart';
import 'package:biux/features/bikes/domain/entities/bike_theft_entity.dart';
import 'package:biux/features/bikes/domain/entities/bike_transfer_entity.dart';
import 'package:biux/features/bikes/domain/entities/bike_sighting_entity.dart';
import 'package:biux/features/bikes/domain/entities/bike_verification_entity.dart';

/// Repositorio abstracto para la gestión de bicicletas
abstract class BikeRepository {
  // ========== Gestión de bicicletas ==========

  /// Registra una nueva bicicleta
  Future<BikeEntity> registerBike(BikeEntity bike);

  /// Obtiene todas las bicicletas de un usuario
  Future<List<BikeEntity>> getUserBikes(String userId);

  /// Obtiene una bicicleta por ID
  Future<BikeEntity?> getBikeById(String bikeId);

  /// Obtiene una bicicleta por código QR
  Future<BikeEntity?> getBikeByQR(String qrCode);

  /// Actualiza una bicicleta
  Future<BikeEntity> updateBike(BikeEntity bike);

  /// Elimina una bicicleta
  Future<void> deleteBike(String bikeId);

  /// Genera un código QR único
  Future<String> generateUniqueQR();

  // ========== Gestión de robos ==========

  /// Reporta el robo de una bicicleta
  Future<BikeTheftEntity> reportTheft(BikeTheftEntity theft);

  /// Marca una bicicleta como recuperada
  Future<BikeEntity> markAsRecovered(String bikeId, String userId);

  /// Obtiene reportes de robo por bicicleta
  Future<List<BikeTheftEntity>> getTheftReports(String bikeId);

  /// Obtiene todas las bicicletas robadas en una ciudad
  Future<List<BikeEntity>> getStolenBikes(String city);

  // ========== Gestión de transferencias ==========

  /// Solicita transferencia de propiedad
  Future<BikeTransferEntity> requestTransfer(BikeTransferEntity transfer);

  /// Acepta una transferencia de propiedad
  Future<BikeTransferEntity> acceptTransfer(String transferId, String userId);

  /// Rechaza una transferencia de propiedad
  Future<BikeTransferEntity> rejectTransfer(
    String transferId,
    String userId,
    String reason,
  );

  /// Cancela una transferencia de propiedad
  Future<BikeTransferEntity> cancelTransfer(String transferId, String userId);

  /// Obtiene transferencias pendientes para un usuario
  Future<List<BikeTransferEntity>> getPendingTransfers(String userId);

  /// Obtiene historial de transferencias de una bicicleta
  Future<List<BikeTransferEntity>> getBikeTransferHistory(String bikeId);

  // ========== Gestión de avistamientos ==========

  /// Reporta avistamiento de bicicleta
  Future<BikeSightingEntity> reportSighting(BikeSightingEntity sighting);

  /// Obtiene avistamientos de una bicicleta
  Future<List<BikeSightingEntity>> getBikeSightings(String bikeId);

  /// Marca avistamiento como procesado (dueño notificado)
  Future<BikeSightingEntity> markSightingAsNotified(String sightingId);

  // ========== Gestión de verificaciones ==========

  /// Verifica una bicicleta por tienda aliada
  Future<BikeVerificationEntity> verifyBike(
    BikeVerificationEntity verification,
  );

  /// Obtiene verificaciones de una bicicleta
  Future<List<BikeVerificationEntity>> getBikeVerifications(String bikeId);

  /// Obtiene bicicletas verificadas por una tienda
  Future<List<BikeEntity>> getStoreVerifiedBikes(String storeId);

  // ========== Utilidades ==========

  /// Obtiene estadísticas de bicicletas por usuario
  Future<Map<String, int>> getUserBikeStats(String userId);

  /// Busca bicicletas por criterios múltiples
  Future<List<BikeEntity>> searchBikes({
    String? brand,
    String? model,
    String? color,
    String? city,
    String? frameSerial,
  });
}
