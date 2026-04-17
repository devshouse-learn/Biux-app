import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

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
    } catch (e) {
      debugPrint('Error con indice compuesto, intentando sin orderBy: $e');
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
        debugPrint('Error cargando reportes: $e2');
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
      debugPrint('Creando reporte: type=$type, lat=$lat, lng=$lng');
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
      debugPrint('Reporte creado exitosamente');
    } catch (e) {
      debugPrint('Error creando reporte: $e');
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
        debugPrint('Reporte no existe: $reportId');
        return false;
      }

      final data = snapshot.data()!;
      final List<dynamic> confirmedBy = data['confirmedBy'] ?? [];

      // Verificar si ya confirmo
      if (confirmedBy.contains(userId)) {
        debugPrint('Usuario $userId ya confirmo el reporte $reportId');
        return false;
      }

      // Agregar confirmacion con arrayUnion (atómico, evita duplicados)
      await docRef.update({
        'confirmations': FieldValue.increment(1),
        'confirmedBy': FieldValue.arrayUnion([userId]),
      });

      debugPrint('Reporte $reportId confirmado por $userId');
      return true;
    } catch (e) {
      debugPrint('Error confirmando reporte: $e');
      return false;
    }
  }

  Future<void> dismissReport(String id) async {
    try {
      await _fs.collection('road_reports').doc(id).update({'isActive': false});
    } catch (e) {
      debugPrint('Error desactivando reporte: $e');
      rethrow;
    }
  }
}
