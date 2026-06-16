import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:biux/core/services/app_logger.dart';
import 'package:biux/core/exceptions/authorization_exceptions.dart';

class ReportDatasource {
  final _fs = FirebaseFirestore.instance;

  /// ALTO: Validar entrada y agregar logging
  Future<void> reportContent({
    required String reporterId,
    required String reportedUserId,
    required String contentId,
    required String type,
    required String reason,
    String? details,
  }) async {
    try {
      if (reporterId.isEmpty || reportedUserId.isEmpty || contentId.isEmpty) {
        throw ValidationException(
          'ids',
          'Reporter ID, reported User ID y content ID son requeridos',
        );
      }

      if (type.isEmpty || reason.isEmpty) {
        throw ValidationException(
          'content',
          'Tipo y razón del reporte son requeridos',
        );
      }

      if (reason.length > 1000) {
        throw ValidationException(
          'reason',
          'La razón no puede exceder 1000 caracteres',
        );
      }

      await _fs.collection('reports').add({
        'reporterId': reporterId,
        'reportedUserId': reportedUserId,
        'reportedContentId': contentId,
        'reportType': type,
        'reason': reason,
        'details': details,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });

      AppLogger.info(
        'Contenido reportado: $contentId',
        tag: 'ReportDatasource',
      );
    } on ValidationException catch (e) {
      AppLogger.warning(
        'Validación fallida: ${e.message}',
        tag: 'ReportDatasource',
      );
      rethrow;
    } on FirebaseException catch (e) {
      AppLogger.error(
        'Error reportando contenido: $e',
        tag: 'ReportDatasource',
        error: e,
      );
      rethrow;
    }
  }

  /// ALTO: Validar entrada y agregar logging
  Future<void> blockUser(String currentUid, String blockedUid) async {
    try {
      if (currentUid.isEmpty || blockedUid.isEmpty) {
        throw ValidationException(
          'ids',
          'Current UID y blocked UID son requeridos',
        );
      }

      if (currentUid == blockedUid) {
        throw ValidationException('same', 'No puedes bloquearte a ti mismo');
      }

      await _fs
          .collection('users')
          .doc(currentUid)
          .collection('blocked')
          .doc(blockedUid)
          .set({'uid': blockedUid, 'blockedAt': FieldValue.serverTimestamp()});

      AppLogger.info('Usuario bloqueado: $blockedUid', tag: 'ReportDatasource');
    } on ValidationException catch (e) {
      AppLogger.warning(
        'Validación fallida: ${e.message}',
        tag: 'ReportDatasource',
      );
      rethrow;
    } on FirebaseException catch (e) {
      AppLogger.error(
        'Error bloqueando usuario: $e',
        tag: 'ReportDatasource',
        error: e,
      );
      rethrow;
    }
  }

  /// ALTO: Validar entrada y agregar logging
  Future<void> unblockUser(String currentUid, String blockedUid) async {
    try {
      if (currentUid.isEmpty || blockedUid.isEmpty) {
        throw ValidationException(
          'ids',
          'Current UID y blocked UID son requeridos',
        );
      }

      await _fs
          .collection('users')
          .doc(currentUid)
          .collection('blocked')
          .doc(blockedUid)
          .delete();

      AppLogger.info(
        'Usuario desbloqueado: $blockedUid',
        tag: 'ReportDatasource',
      );
    } on ValidationException catch (e) {
      AppLogger.warning(
        'Validación fallida: ${e.message}',
        tag: 'ReportDatasource',
      );
      rethrow;
    } on FirebaseException catch (e) {
      AppLogger.error(
        'Error desbloqueando usuario: $e',
        tag: 'ReportDatasource',
        error: e,
      );
      rethrow;
    }
  }

  /// ALTO: Validar entrada y error handling
  Future<bool> isBlocked(String currentUid, String targetUid) async {
    try {
      if (currentUid.isEmpty || targetUid.isEmpty) {
        throw ValidationException(
          'ids',
          'Current UID y target UID son requeridos',
        );
      }

      final doc = await _fs
          .collection('users')
          .doc(currentUid)
          .collection('blocked')
          .doc(targetUid)
          .get();
      return doc.exists;
    } on ValidationException catch (e) {
      AppLogger.warning(
        'Validación fallida: ${e.message}',
        tag: 'ReportDatasource',
      );
      return false;
    } catch (e) {
      AppLogger.error(
        'Error verificando bloqueo: $e',
        tag: 'ReportDatasource',
        error: e,
      );
      return false;
    }
  }

  /// ALTO: Validar entrada y agregar logging
  Future<List<String>> getBlockedUsers(String uid) async {
    try {
      if (uid.isEmpty) {
        throw ValidationException('uid', 'UID no puede estar vacío');
      }

      final snap = await _fs
          .collection('users')
          .doc(uid)
          .collection('blocked')
          .get();

      final blocked = snap.docs.map((d) => d.id).toList();

      AppLogger.debug(
        'Usuarios bloqueados: ${blocked.length}',
        tag: 'ReportDatasource',
      );
      return blocked;
    } on ValidationException catch (e) {
      AppLogger.warning(
        'Validación fallida: ${e.message}',
        tag: 'ReportDatasource',
      );
      return [];
    } catch (e) {
      AppLogger.error(
        'Error obteniendo usuarios bloqueados: $e',
        tag: 'ReportDatasource',
        error: e,
      );
      return [];
    }
  }
}
