class PromotionRequestModel {
  String id;
  String title;
  String description;
  String type; // 'anuncio' | 'evento'
  String? contact;
  DateTime? eventDate;
  String status; // 'pending' | 'approved' | 'rejected'
  DateTime createdAt;

  PromotionRequestModel({
    this.id = '',
    required this.title,
    required this.description,
    required this.type,
    this.contact,
    this.eventDate,
    this.status = 'pending',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
