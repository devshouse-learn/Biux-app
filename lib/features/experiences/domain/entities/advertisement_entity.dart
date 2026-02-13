/// Entidad para representar historias publicitarias en el feed
/// Las historias publicitarias se intercalan entre historias normales
class AdvertisementEntity {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String callToActionText;
  final String? callToActionUrl;
  final String? advertiserName;
  final DateTime createdAt;
  final int views;

  const AdvertisementEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.callToActionText,
    this.callToActionUrl,
    this.advertiserName,
    required this.createdAt,
    this.views = 0,
  });

  /// Crear copia con campos modificados
  AdvertisementEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    String? callToActionText,
    String? callToActionUrl,
    String? advertiserName,
    DateTime? createdAt,
    int? views,
  }) {
    return AdvertisementEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      callToActionText: callToActionText ?? this.callToActionText,
      callToActionUrl: callToActionUrl ?? this.callToActionUrl,
      advertiserName: advertiserName ?? this.advertiserName,
      createdAt: createdAt ?? this.createdAt,
      views: views ?? this.views,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AdvertisementEntity &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.imageUrl == imageUrl &&
        other.callToActionText == callToActionText &&
        other.callToActionUrl == callToActionUrl &&
        other.advertiserName == advertiserName &&
        other.createdAt == createdAt &&
        other.views == views;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        imageUrl.hashCode ^
        callToActionText.hashCode ^
        callToActionUrl.hashCode ^
        advertiserName.hashCode ^
        createdAt.hashCode ^
        views.hashCode;
  }

  @override
  String toString() {
    return 'AdvertisementEntity(id: $id, title: $title, views: $views)';
  }
}
