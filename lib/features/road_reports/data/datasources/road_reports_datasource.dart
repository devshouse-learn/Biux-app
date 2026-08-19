import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:biux/core/services/app_logger.dart';

class RoadReportsDatasource {
  final _fs = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getReports() async {
    try {
      final s = await _fs
          .collection('road_reports')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(100)
          .get();
      return s.docs.map((d) => {'id': d.id, ...d.data()}).toList();
    } on FirebaseException catch (e) {
      AppLogger.warning(
        'Error con indice compuesto, intentando sin orderBy',
        error: e,
        tag: 'RoadReportsDatasource',
      );
      try {
        final s = await _fs
            .collection('road_reports')
            .where('isActive', isEqualTo: true)
            .limit(100)
            .get();
        final list = s.docs.map((d) => {'id': d.id, ...d.data()}).toList();
        list.sort((a, b) {
          final aTime = a['createdAt'] as Timestamp?;
          final bTime = b['createdAt'] as Timestamp?;
          if (aTime == null || bTime == null) return 0;
          return bTime.compareTo(aTime);
        });
        return list;
      } catch (e2) {
        AppLogger.error(
          'Error cargando reportes',
          error: e2,
          tag: 'RoadReportsDatasource',
        );
        return [];
      }
    }
  }

  Future<void> createReport({
    required String userId,
    required String userName,
    required String type,
    required String description,
    required double lat,
    required double lng,
  }) async {
    try {
      AppLogger.debug(
        'Creando reporte: type=$type, lat=$lat, lng=$lng',
        tag: 'RoadReportsDatasource',
      );
      await _fs.collection('road_reports').add({
        'userId': userId,
        'userName': userName,
        'type': type,
        'description': description,
        'latitude': lat,
        'longitude': lng,
        'confirmations': 0,
        'confirmedBy': <String>[],
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
      AppLogger.debug(
        'Reporte creado exitosamente',
        tag: 'RoadReportsDatasource',
      );
    } on FirebaseException catch (e) {
      AppLogger.error(
        'Error creando reporte',
        error: e,
        tag: 'RoadReportsDatasource',
      );
      rethrow;
    }
  }

  /// Confirma un reporte. Retorna true si se confirmo, false si ya habia confirmado.
  Future<bool> confirmReport(String reportId, String userId) async {
    try {
      final docRef = _fs.collection('road_reports').doc(reportId);

      // Primero leer el documento
      final snapshot = await docRef.get();
      if (!snapshot.exists) {
        AppLogger.warning(
          'Reporte no existe: $reportId',
          tag: 'RoadReportsDatasource',
        );
        return false;
      }

      final data = snapshot.data()!;
      final List<dynamic> confirmedBy = data['confirmedBy'] ?? [];

      // Verificar si ya confirmo
      if (confirmedBy.contains(userId)) {
        AppLogger.debug(
          'Usuario $userId ya confirmo el reporte $reportId',
          tag: 'RoadReportsDatasource',
        );
        return false;
      }

      // Agregar confirmacion con arrayUnion (atómico, evita duplicados)
      await docRef.update({
        'confirmations': FieldValue.increment(1),
        'confirmedBy': FieldValue.arrayUnion([userId]),
      });

      AppLogger.debug(
        'Reporte $reportId confirmado por $userId',
        tag: 'RoadReportsDatasource',
      );
      return true;
    } on FirebaseException catch (e) {
      AppLogger.error(
        'Error confirmando reporte',
        error: e,
        tag: 'RoadReportsDatasource',
      );
      return false;
    }
  }

  Future<void> dismissReport(String id) async {
    try {
      await _fs.collection('road_reports').doc(id).update({'isActive': false});
    } on FirebaseException catch (e) {
      AppLogger.error(
        'Error desactivando reporte',
        error: e,
        tag: 'RoadReportsDatasource',
      );
      rethrow;
    }
  }
}
