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
        return 'Activa';
      case BikeStatus.stolen:
        return 'Robada';
      case BikeStatus.recovered:
        return 'Recuperada';
      case BikeStatus.verified:
        return 'Verificada';
    }
  }

  String get description {
    switch (this) {
      case BikeStatus.active:
        return 'La bicicleta está registrada y activa';
      case BikeStatus.stolen:
        return 'Reportada como robada';
      case BikeStatus.recovered:
        return 'Recuperada después de robo';
      case BikeStatus.verified:
        return 'Verificada por tienda aliada';
    }
  }
}

extension BikeTypeExtension on BikeType {
  String get displayName {
    switch (this) {
      case BikeType.mtb:
        return 'MTB';
      case BikeType.road:
        return 'Ruta';
      case BikeType.urban:
        return 'Urbana';
      case BikeType.electric:
        return 'Eléctrica';
      case BikeType.kids:
        return 'Infantil';
      case BikeType.other:
        return 'Otro';
    }
  }
}
