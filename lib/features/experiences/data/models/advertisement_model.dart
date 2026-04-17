import 'package:biux/features/experiences/domain/entities/advertisement_entity.dart';

/// Modelo de publicidad para deserializar desde JSON
class AdvertisementModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String callToActionText;
  final String? callToActionUrl;
  final String? advertiserName;
  final DateTime createdAt;
  final int views;

  const AdvertisementModel({
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

  /// Deserializar desde JSON
  factory AdvertisementModel.fromJson(Map<String, dynamic> json) {
    return AdvertisementModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      callToActionText: json['callToActionText'] as String? ?? 'Ver más',
      callToActionUrl: json['callToActionUrl'] as String?,
      advertiserName: json['advertiserName'] as String?,
      createdAt: json['createdAt'] is DateTime
          ? json['createdAt'] as DateTime
          : DateTime.parse(
              json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
            ),
      views: json['views'] as int? ?? 0,
    );
  }

  /// Serializar a JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'imageUrl': imageUrl,
    'callToActionText': callToActionText,
    'callToActionUrl': callToActionUrl,
    'advertiserName': advertiserName,
    'createdAt': createdAt.toIso8601String(),
    'views': views,
  };

  /// Convertir a entidad
  AdvertisementEntity toEntity() => AdvertisementEntity(
    id: id,
    title: title,
    description: description,
    imageUrl: imageUrl,
    callToActionText: callToActionText,
    callToActionUrl: callToActionUrl,
    advertiserName: advertiserName,
    createdAt: createdAt,
    views: views,
  );
}
