class RoutePoint {
  final double latitude;
  final double longitude;

  RoutePoint({
    required this.latitude,
    required this.longitude,
  });

  factory RoutePoint.fromJson(Map<String, dynamic> json) {
    return RoutePoint(
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
      };
}

class BiuxRoute {
  final String id;
  final String name;
  final String description;
  final String level;
  final double destinationLatitude;
  final double destinationLongitude;

  BiuxRoute({
    required this.id,
    required this.name,
    required this.description,
    required this.level,
    required this.destinationLatitude,
    required this.destinationLongitude,
  });

  factory BiuxRoute.fromJson(Map<String, dynamic> json) {
    return BiuxRoute(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      level: json['level'] ?? '',
      destinationLatitude: (json['destinationLatitude'] ?? 0.0).toDouble(),
      destinationLongitude: (json['destinationLongitude'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'level': level,
        'destinationLatitude': destinationLatitude,
        'destinationLongitude': destinationLongitude,
      };
}
