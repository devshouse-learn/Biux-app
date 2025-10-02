import 'package:cloud_firestore/cloud_firestore.dart';

enum DifficultyLevel {
  easy,
  medium,
  hard,
  expert,
}

enum RideStatus {
  upcoming,
  ongoing,
  completed,
  cancelled,
}

class RideModel {
  final String id;
  final String name;
  final String groupId;
  final String meetingPointId;
  final DateTime dateTime;
  final DifficultyLevel difficulty;
  final double kilometers;
  final String instructions;
  final String recommendations;
  final String createdBy;
  final DateTime createdAt;
  final RideStatus status;
  final List<String> participants;
  final List<String> maybeParticipants;

  const RideModel({
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
  });

  factory RideModel.fromFirestore(Map<String, dynamic> data, String id) {
    return RideModel(
      id: id,
      name: data['name'] ?? '',
      groupId: data['groupId'] ?? '',
      meetingPointId: data['meetingPointId'] ?? '',
      dateTime: (data['dateTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      difficulty: DifficultyLevel.values.firstWhere(
        (e) => e.name == data['difficulty'],
        orElse: () => DifficultyLevel.easy,
      ),
      kilometers: (data['kilometers'] ?? 0.0).toDouble(),
      instructions: data['instructions'] ?? '',
      recommendations: data['recommendations'] ?? '',
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: RideStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => RideStatus.upcoming,
      ),
      participants: List<String>.from(data['participants'] ?? []),
      maybeParticipants: List<String>.from(data['maybeParticipants'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'groupId': groupId,
      'meetingPointId': meetingPointId,
      'dateTime': Timestamp.fromDate(dateTime),
      'difficulty': difficulty.name,
      'kilometers': kilometers,
      'instructions': instructions,
      'recommendations': recommendations,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status.name,
      'participants': participants,
      'maybeParticipants': maybeParticipants,
    };
  }

  // Getters adicionales para la UI
  String get difficultyDisplayName {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return 'Fácil';
      case DifficultyLevel.medium:
        return 'Medio';
      case DifficultyLevel.hard:
        return 'Difícil';
      case DifficultyLevel.expert:
        return 'Experto';
    }
  }

  int get participantCount => participants.length;

  int get maybeParticipantCount => maybeParticipants.length;

  int get totalPotentialParticipants =>
      participantCount + maybeParticipantCount;

  bool get isPastEvent => dateTime.isBefore(DateTime.now());

  bool get isUpcoming => status == RideStatus.upcoming && !isPastEvent;

  bool get canJoin => isUpcoming && status != RideStatus.cancelled;

  RideModel copyWith({
    String? id,
    String? name,
    String? groupId,
    String? meetingPointId,
    DateTime? dateTime,
    DifficultyLevel? difficulty,
    double? kilometers,
    String? instructions,
    String? recommendations,
    String? createdBy,
    DateTime? createdAt,
    RideStatus? status,
    List<String>? participants,
    List<String>? maybeParticipants,
  }) {
    return RideModel(
      id: id ?? this.id,
      name: name ?? this.name,
      groupId: groupId ?? this.groupId,
      meetingPointId: meetingPointId ?? this.meetingPointId,
      dateTime: dateTime ?? this.dateTime,
      difficulty: difficulty ?? this.difficulty,
      kilometers: kilometers ?? this.kilometers,
      instructions: instructions ?? this.instructions,
      recommendations: recommendations ?? this.recommendations,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      participants: participants ?? this.participants,
      maybeParticipants: maybeParticipants ?? this.maybeParticipants,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RideModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'RideModel(id: $id, name: $name, dateTime: $dateTime, difficulty: $difficulty)';
  }
}
