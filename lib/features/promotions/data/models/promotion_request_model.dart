class PromotionRequestModel {
  String id;
  String title;
  String description;
  String type; // 'negocio' | 'evento'
  String? contact;
  String? imageUrl;
  String? location;
  DateTime? eventDate;
  String? eventTime;
  int? maxAttendees;
  List<String> attendees; // UIDs de usuarios registrados
  String status; // 'pending' | 'approved' | 'rejected'
  String ownerUid; // UID del usuario que creó la solicitud
  String ownerName; // Nombre del creador
  bool isPromoter; // Si el creador es promotor verificado
  DateTime createdAt;

  PromotionRequestModel({
    this.id = '',
    required this.title,
    required this.description,
    required this.type,
    this.contact,
    this.imageUrl,
    this.location,
    this.eventDate,
    this.eventTime,
    this.maxAttendees,
    List<String>? attendees,
    this.status = 'pending',
    this.ownerUid = '',
    this.ownerName = '',
    this.isPromoter = false,
    DateTime? createdAt,
  })  : attendees = attendees ?? [],
        createdAt = createdAt ?? DateTime.now();

  bool get isFull => maxAttendees != null && attendees.length >= maxAttendees!;
  int get spotsLeft => maxAttendees != null ? maxAttendees! - attendees.length : -1;

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'type': type,
      'contact': contact,
      'imageUrl': imageUrl,
      'location': location,
      'eventDate': eventDate?.toIso8601String(),
      'eventTime': eventTime,
      'maxAttendees': maxAttendees,
      'attendees': attendees,
      'status': status,
      'ownerUid': ownerUid,
      'ownerName': ownerName,
      'isPromoter': isPromoter,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
