/// Entidad de dominio para Rodada (independiente de Firestore)
class RideEntity {
  final String id;
  final String name;
  final String groupId;
  final String meetingPointId;
  final DateTime dateTime;
  final String difficulty;
  final double kilometers;
  final String instructions;
  final String recommendations;
  final String createdBy;
  final DateTime createdAt;
  final String status;
  final List<String> participants;
  final List<String> maybeParticipants;
  final String? imageUrl;

  const RideEntity({
    required this.id,
    required this.name,
    required this.groupId,
    required this.meetingPointId,
    required this.dateTime,
    required this.difficulty,
    required this.kilometers,
    required this.instructions,
    required this.recommendations,
    required this.createdBy,
    required this.createdAt,
    required this.status,
    required this.participants,
    required this.maybeParticipants,
    this.imageUrl,
  });

  int get participantCount => participants.length;
  bool get isPastEvent => dateTime.isBefore(DateTime.now());
  bool get isUpcoming => status == 'upcoming' && !isPastEvent;
  bool get isCancelled => status == 'cancelled';
}
