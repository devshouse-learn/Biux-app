/// Entidad de dominio para punto de encuentro
class MeetingPointEntity {
  final String id;
  final String name;
  final String description;
  final double latitude;
  final double longitude;

  const MeetingPointEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
  });
}
