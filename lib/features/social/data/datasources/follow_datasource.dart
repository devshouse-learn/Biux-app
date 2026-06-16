import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:biux/core/exceptions/authorization_exceptions.dart';
import 'package:biux/core/services/app_logger.dart';

class FollowDatasource {
  final _fs = FirebaseFirestore.instance;

  /// CRÍTICO #4: Usar transacción para garantizar consistencia
  Future<void> followUser(String currentUid, String targetUid) async {
    try {
      // Validar que no sea seguimiento a sí mismo
      if (currentUid == targetUid) {
        throw InvalidOperationException('No puedes seguirte a ti mismo');
      }

      // Usar transacción para garantizar atomicidad
      await _fs.runTransaction<void>((transaction) async {
        // Verificar que el usuario target exista
        final targetUserDoc = await transaction.get(
          _fs.collection('users').doc(targetUid),
        );

        if (!targetUserDoc.exists) {
          throw ResourceNotFoundException('Usuario a seguir');
        }

        // Verificar que no ya esté siguiendo
        final isAlreadyFollowing = await transaction.get(
          _fs
              .collection('users')
              .doc(currentUid)
              .collection('following')
              .doc(targetUid),
        );

        if (isAlreadyFollowing.exists) {
          throw InvalidOperationException('Ya estás siguiendo a este usuario');
        }

        // Operación 1: Agregar a colección following (transacción atómica)
        transaction.set(
          _fs
              .collection('users')
              .doc(currentUid)
              .collection('following')
              .doc(targetUid),
          {'uid': targetUid, 'createdAt': FieldValue.serverTimestamp()},
        );

        // Operación 2: Agregar a colección followers (mismo bloque transaccional)
        transaction.set(
          _fs
              .collection('users')
              .doc(targetUid)
              .collection('followers')
              .doc(currentUid),
          {'uid': currentUid, 'createdAt': FieldValue.serverTimestamp()},
        );

        // Operación 3: Actualizar contador del usuario actual
        transaction.update(_fs.collection('users').doc(currentUid), {
          'followingCount': FieldValue.increment(1),
        });

        // Operación 4: Actualizar contador del usuario seguido
        transaction.update(_fs.collection('users').doc(targetUid), {
          'followersCount': FieldValue.increment(1),
        });
      });

      AppLogger.info(
        'Usuario $currentUid ahora sigue a $targetUid',
        tag: 'FollowDatasource',
      );
    } on InvalidOperationException catch (e) {
      AppLogger.warning(
        'Operación no válida: ${e.message}',
        tag: 'FollowDatasource',
      );
      rethrow;
    } on ResourceNotFoundException catch (e) {
      AppLogger.warning(
        'Recurso no encontrado: ${e.message}',
        tag: 'FollowDatasource',
      );
      rethrow;
    } catch (e) {
      AppLogger.error(
        'Error siguiendo usuario: $e',
        tag: 'FollowDatasource',
        error: e,
      );
      throw TransactionFailedException('No se pudo completar el seguimiento');
    }
  }

  /// Dejar de seguir a un usuario - también usa transacción para consistencia
  Future<void> unfollowUser(String currentUid, String targetUid) async {
    try {
      await _fs.runTransaction<void>((transaction) async {
        // Verificar que sí está siguiendo
        final isFollowingDoc = await transaction.get(
          _fs
              .collection('users')
              .doc(currentUid)
              .collection('following')
              .doc(targetUid),
        );

        if (!isFollowingDoc.exists) {
          throw InvalidOperationException('No estás siguiendo a este usuario');
        }

        // Todas las operaciones en una transacción atómica
        transaction.delete(
          _fs
              .collection('users')
              .doc(currentUid)
              .collection('following')
              .doc(targetUid),
        );
        transaction.delete(
          _fs
              .collection('users')
              .doc(targetUid)
              .collection('followers')
              .doc(currentUid),
        );
        transaction.update(_fs.collection('users').doc(currentUid), {
          'followingCount': FieldValue.increment(-1),
        });
        transaction.update(_fs.collection('users').doc(targetUid), {
          'followersCount': FieldValue.increment(-1),
        });
      });

      AppLogger.info(
        'Usuario $currentUid dejó de seguir a $targetUid',
        tag: 'FollowDatasource',
      );
    } catch (e) {
      AppLogger.error(
        'Error dejando de seguir usuario: $e',
        tag: 'FollowDatasource',
        error: e,
      );
      rethrow;
    }
  }

  Future<bool> isFollowing(String currentUid, String targetUid) async {
    final doc = await _fs
        .collection('users')
        .doc(currentUid)
        .collection('following')
        .doc(targetUid)
        .get();
    return doc.exists;
  }

  Future<List<String>> getFollowers(String uid) async {
    final snap = await _fs
        .collection('users')
        .doc(uid)
        .collection('followers')
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((d) => d.id).toList();
  }

  Future<List<String>> getFollowing(String uid) async {
    final snap = await _fs
        .collection('users')
        .doc(uid)
        .collection('following')
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((d) => d.id).toList();
  }

  Stream<int> followersCountStream(String uid) {
    return _fs
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((s) => (s.data()?['followersCount'] as num?)?.toInt() ?? 0);
  }

  Stream<int> followingCountStream(String uid) {
    return _fs
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((s) => (s.data()?['followingCount'] as num?)?.toInt() ?? 0);
  }
}
