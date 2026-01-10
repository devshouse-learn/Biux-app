import 'package:biux/features/roads/data/models/route.dart';

class MeetingPoint {
  final String id;
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final List<BiuxRoute> routes;

  MeetingPoint({
    required this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.routes,
  });

  factory MeetingPoint.fromJson(Map<String, dynamic> json) {
    return MeetingPoint(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      routes: (json['routes'] as List? ?? [])
          .map((route) => BiuxRoute.fromJson(route))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'latitude': latitude,
    'longitude': longitude,
    'routes': routes.map((route) => route.toJson()).toList(),
  };
}
