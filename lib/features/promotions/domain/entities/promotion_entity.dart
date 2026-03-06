/// Entidad de dominio para promoción/solicitud de promoción
class PromotionEntity {
  final String id;
  final String title;
  final String description;
  final String type; // 'negocio' | 'evento'
  final String? contact;
  final String? imageUrl;
  final String? location;
  final DateTime? eventDate;
  final String? eventTime;
  final int? maxAttendees;
  final List<String> attendees;
  final String status; // 'pending' | 'approved' | 'rejected'
  final String ownerUid;
  final String ownerName;
  final bool isPromoter;
  final DateTime createdAt;

  const PromotionEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.contact,
    this.imageUrl,
    this.location,
    this.eventDate,
    this.eventTime,
    this.maxAttendees,
    this.attendees = const [],
    required this.status,
    required this.ownerUid,
    required this.ownerName,
    this.isPromoter = false,
    required this.createdAt,
  });

  bool get isFull => maxAttendees != null && attendees.length >= maxAttendees!;
  int get spotsLeft =>
      maxAttendees != null ? maxAttendees! - attendees.length : -1;
  bool get isEvent => type == 'evento';
  bool get isBusiness => type == 'negocio';
  bool get isApproved => status == 'approved';
  bool get isPending => status == 'pending';
}
