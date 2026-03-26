import 'package:cloud_firestore/cloud_firestore.dart';

enum DifficultyLevel { easy, medium, hard, expert }

enum RideStatus { upcoming, ongoing, completed, cancelled }

// Metadata simplificada de usuario para evitar consultas excesivas
class ParticipantMetadata {
  final String userId;
  final String userName;
  final String? photoUrl;

  const ParticipantMetadata({
    required this.userId,
    required this.userName,
    this.photoUrl,
  });

  factory ParticipantMetadata.fromMap(Map<String, dynamic> map) {
    return ParticipantMetadata(
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      photoUrl: map['photoUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      if (photoUrl != null) 'photoUrl': photoUrl,
    };
  }
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
  final List<String> participants; // Mantener para lógica
  final List<String> maybeParticipants; // Mantener para lógica
  final String? imageUrl; // Imagen opcional de la rodada

  // METADATA de participantes para evitar consultas excesivas
  final List<ParticipantMetadata> participantsMetadata;
  final List<ParticipantMetadata> maybeParticipantsMetadata;

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
    this.imageUrl, // Opcional
    this.participantsMetadata = const [],
    this.maybeParticipantsMetadata = const [],
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
      imageUrl: data['imageUrl'] as String?, // Puede ser null
      participantsMetadata:
          (data['participantsMetadata'] as List?)
              ?.map(
                (e) => ParticipantMetadata.fromMap(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      maybeParticipantsMetadata:
          (data['maybeParticipantsMetadata'] as List?)
              ?.map(
                (e) => ParticipantMetadata.fromMap(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
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
      'participantsMetadata': participantsMetadata
          .map((e) => e.toMap())
          .toList(),
      'maybeParticipantsMetadata': maybeParticipantsMetadata
          .map((e) => e.toMap())
          .toList(),
      if (imageUrl != null) 'imageUrl': imageUrl, // Solo incluir si no es null
    };
  }

  // Getters adicionales para la UI
  String get difficultyDisplayName {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return 'difficulty_easy';
      case DifficultyLevel.medium:
        return 'difficulty_medium';
      case DifficultyLevel.hard:
        return 'difficulty_hard';
      case DifficultyLevel.expert:
        return 'difficulty_expert';
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
    String? imageUrl,
    List<ParticipantMetadata>? participantsMetadata,
    List<ParticipantMetadata>? maybeParticipantsMetadata,
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
      imageUrl: imageUrl ?? this.imageUrl,
      participantsMetadata: participantsMetadata ?? this.participantsMetadata,
      maybeParticipantsMetadata:
          maybeParticipantsMetadata ?? this.maybeParticipantsMetadata,
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
