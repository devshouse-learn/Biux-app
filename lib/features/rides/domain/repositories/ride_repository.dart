import 'package:biux/features/rides/domain/entities/ride_entity.dart';

/// Interfaz del repositorio de rodadas (contrato para la capa de datos)
abstract class RideRepository {
  Future<String?> createRide(RideEntity ride);
  Stream<List<RideEntity>> getGroupRides(String groupId);
  Stream<List<RideEntity>> getAllRides();
  Future<RideEntity?> getRideById(String rideId);
  Future<void> joinRide(String rideId, String userId);
  Future<void> leaveRide(String rideId, String userId);
  Future<void> updateRide(String rideId, Map<String, dynamic> data);
  Future<void> cancelRide(String rideId);
  Future<void> deleteRide(String rideId);
  Stream<List<RideEntity>> getUserRides(String userId);
  Stream<List<RideEntity>> getUpcomingRides();
}
