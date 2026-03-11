// Enums para el sistema de bicicletas

enum BikeStatus {
  active, // Activa: registro normal
  stolen, // Robada: tras reporte de robo
  recovered, // Recuperada: tras marcar recuperación
  verified, // Verificada: cuando una tienda aliada la confirma
}

enum BikeType {
  mtb, // MTB
  road, // Ruta
  urban, // Urbana
  electric, // Eléctrica
  kids, // Infantil
  other, // Otro
}

extension BikeStatusExtension on BikeStatus {
  String get displayName {
    switch (this) {
      case BikeStatus.active:
        return 'bike_status_active';
      case BikeStatus.stolen:
        return 'bike_status_stolen';
      case BikeStatus.recovered:
        return 'bike_status_recovered';
      case BikeStatus.verified:
        return 'bike_status_verified';
    }
  }

  String get description {
    switch (this) {
      case BikeStatus.active:
        return 'bike_status_active_desc';
      case BikeStatus.stolen:
        return 'bike_status_stolen_desc';
      case BikeStatus.recovered:
        return 'bike_status_recovered_desc';
      case BikeStatus.verified:
        return 'bike_status_verified_desc';
    }
  }
}

extension BikeTypeExtension on BikeType {
  String get displayName {
    switch (this) {
      case BikeType.mtb:
        return 'bike_type_mtb';
      case BikeType.road:
        return 'bike_type_road';
      case BikeType.urban:
        return 'bike_type_urban';
      case BikeType.electric:
        return 'bike_type_electric';
      case BikeType.kids:
        return 'bike_type_kids';
      case BikeType.other:
        return 'bike_type_other';
    }
  }
}
