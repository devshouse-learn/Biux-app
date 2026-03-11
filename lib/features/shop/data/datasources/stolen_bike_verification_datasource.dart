import 'package:biux/features/bikes/domain/repositories/bike_repository.dart';
import 'package:biux/features/bikes/domain/entities/bike_entity.dart';
import 'package:biux/features/bikes/domain/entities/bike_theft_entity.dart';
import 'package:biux/shared/services/notification_service.dart';
import "package:flutter/foundation.dart";

/// Servicio para verificar si una bicicleta está reportada como robada
/// antes de permitir su publicación en la tienda
class StolenBikeVerificationService {
  final BikeRepository bikeRepository;
  final NotificationService _notificationService = NotificationService();

  StolenBikeVerificationService({required this.bikeRepository});

  /// Verifica si una bicicleta está reportada como robada
  /// basándose en el número de serie del cuadro
  Future<VerificationResult> verifyBikeNotStolen({
    required String frameSerial,
    String? brand,
    String? model,
    String? color,
    String? sellerUid,
    String? sellerName,
  }) async {
    try {
      debugPrint('🔍 Verificando bicicleta con número de serie: $frameSerial');

      // Buscar bicicletas registradas con ese número de serie
      final bikes = await bikeRepository.searchBikes(frameSerial: frameSerial);

      if (bikes.isEmpty) {
        debugPrint('✅ No se encontró la bicicleta registrada en el sistema');
        return VerificationResult(
          isStolen: false,
          isRegistered: false,
          message: 'Bicicleta no registrada en el sistema Biux',
        );
      }

      debugPrint(
        '📋 Encontradas ${bikes.length} bicicleta(s) con ese número de serie',
      );

      // Verificar cada bicicleta encontrada
      for (final bike in bikes) {
        // Verificar si la bicicleta está actualmente reportada como robada
        if (bike.status.toString().contains('stolen')) {
          debugPrint('⚠️ ¡ALERTA! Bicicleta reportada como robada');

          // Obtener detalles del reporte de robo
          final theftReports = await bikeRepository.getTheftReports(bike.id);
          final activeReport = theftReports.firstWhere(
            (report) => report.isActive,
            orElse: () => theftReports.first,
          );

          // 🚨 NUEVA FUNCIONALIDAD: Notificar al propietario y administradores
          if (sellerUid != null && sellerName != null) {
            await _notificationService.notifyStolenBikeSaleAttempt(
              bikeOwnerId: bike.ownerId,
              bikeFrameSerial: frameSerial,
              bikeBrand: brand ?? bike.brand,
              bikeModel: model ?? bike.model,
              sellerUid: sellerUid,
              sellerName: sellerName,
            );

            await _notificationService.notifyAdminsAboutTheftAttempt(
              bikeFrameSerial: frameSerial,
              bikeBrand: brand ?? bike.brand,
              bikeModel: model ?? bike.model,
              sellerUid: sellerUid,
              sellerName: sellerName,
            );
          }

          return VerificationResult(
            isStolen: true,
            isRegistered: true,
            bike: bike,
            theftReport: activeReport,
            message: '⚠️ BICICLETA REPORTADA COMO ROBADA',
            details:
                'Esta bicicleta fue reportada como robada el ${_formatDate(activeReport.theftDate)}. '
                'Ubicación del robo: ${activeReport.location}. '
                'No se permite la venta de bicicletas robadas.\n\n'
                '🚨 El propietario y los administradores han sido notificados de este intento.',
          );
        }

        // Verificar coincidencias adicionales para mayor seguridad
        if (_matchesBikeDescription(bike, brand, model, color)) {
          debugPrint('✅ Bicicleta registrada y NO robada');
          return VerificationResult(
            isStolen: false,
            isRegistered: true,
            bike: bike,
            message: 'Bicicleta registrada en Biux y verificada como segura',
            details: 'Propietario registrado: ${bike.ownerId}',
          );
        }
      }

      // Si hay bikes pero no coinciden exactamente
      debugPrint('⚠️ Se encontraron bicicletas con número de serie similar');
      return VerificationResult(
        isStolen: false,
        isRegistered: true,
        message: 'Verificación parcial completada',
        details:
            'Se encontraron bicicletas registradas con número de serie similar. '
            'Recomendamos verificación manual.',
      );
    } catch (e) {
      debugPrint('❌ Error en verificación: $e');
      return VerificationResult(
        isStolen: false,
        isRegistered: false,
        hasError: true,
        message: 'Error al verificar la bicicleta',
        details: e.toString(),
      );
    }
  }

  /// Obtiene lista de todas las bicicletas robadas en una ciudad
  Future<List<BikeEntity>> getStolenBikesInCity(String city) async {
    try {
      return await bikeRepository.getStolenBikes(city);
    } catch (e) {
      debugPrint('❌ Error obteniendo bicicletas robadas: $e');
      return [];
    }
  }

  /// Obtiene todos los reportes de robo activos
  Future<List<StolenBikeInfo>> getAllStolenBikes() async {
    try {
      // Obtener todas las ciudades (simplificado - en producción sería una consulta más eficiente)
      final cities = [
        'Bogotá',
        'Medellín',
        'Cali',
        'Barranquilla',
        'Cartagena',
      ];
      final allStolenBikes = <StolenBikeInfo>[];

      for (final city in cities) {
        final stolenInCity = await bikeRepository.getStolenBikes(city);

        for (final bike in stolenInCity) {
          final theftReports = await bikeRepository.getTheftReports(bike.id);
          final activeReport = theftReports
              .where((r) => r.isActive)
              .firstOrNull;

          if (activeReport != null) {
            allStolenBikes.add(
              StolenBikeInfo(bike: bike, theftReport: activeReport),
            );
          }
        }
      }

      return allStolenBikes;
    } catch (e) {
      debugPrint('❌ Error obteniendo todas las bicicletas robadas: $e');
      return [];
    }
  }

  bool _matchesBikeDescription(
    BikeEntity bike,
    String? brand,
    String? model,
    String? color,
  ) {
    if (brand != null && bike.brand.toLowerCase() != brand.toLowerCase()) {
      return false;
    }
    if (model != null && bike.model.toLowerCase() != model.toLowerCase()) {
      return false;
    }
    if (color != null && bike.color.toLowerCase() != color.toLowerCase()) {
      return false;
    }
    return true;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Resultado de la verificación de una bicicleta
class VerificationResult {
  final bool isStolen; // Si está reportada como robada
  final bool isRegistered; // Si está registrada en el sistema
  final BikeEntity? bike; // Datos de la bicicleta si existe
  final BikeTheftEntity? theftReport; // Reporte de robo si existe
  final String message; // Mensaje principal
  final String? details; // Detalles adicionales
  final bool hasError; // Si hubo un error en la verificación

  const VerificationResult({
    required this.isStolen,
    required this.isRegistered,
    this.bike,
    this.theftReport,
    required this.message,
    this.details,
    this.hasError = false,
  });

  bool get canBeSold => !isStolen && !hasError;
}

/// Información combinada de bicicleta robada y su reporte
class StolenBikeInfo {
  final BikeEntity bike;
  final BikeTheftEntity theftReport;

  const StolenBikeInfo({required this.bike, required this.theftReport});
}
