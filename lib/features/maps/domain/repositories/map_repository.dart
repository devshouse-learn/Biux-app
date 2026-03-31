import 'package:biux/features/maps/domain/entities/meeting_point_entity.dart';

/// Interfaz del repositorio de mapas (contrato para la capa de datos)
abstract class MapRepository {
  Stream<List<MeetingPointEntity>> getMeetingPoints();
  Future<MeetingPointEntity?> getMeetingPoint(String id);
}
