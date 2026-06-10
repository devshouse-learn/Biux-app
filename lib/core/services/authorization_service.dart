import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:biux/core/exceptions/authorization_exceptions.dart';

/// Servicio centralizado de autorización y permisos
class AuthorizationService {
  static final AuthorizationService _instance = AuthorizationService._internal();

  factory AuthorizationService() {
    return _instance;
  }

  AuthorizationService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Obtiene el UID del usuario actual, lanza excepción si no está autenticado
  String getCurrentUserId() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw NotAuthenticatedException();
    }
    return uid;
  }

  /// Verifica que el usuario esté autenticado
  void requireAuthenticated() {
    if (_auth.currentUser == null) {
      throw NotAuthenticatedException();
    }
  }

  /// Verifica que el usuario sea administrador
  Future<void> requireAdmin() async {
    final uid = getCurrentUserId();
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      final isAdmin = userDoc.get('isAdmin') ?? false;
      if (!isAdmin) {
        throw NotAdminException();
      }
    } catch (e) {
      if (e is NotAdminException) rethrow;
      throw InvalidOperationException('No se pudo verificar permisos de admin');
    }
  }

  /// Verifica que el usuario sea propietario del recurso
  void requireOwnership(String resourceOwnerId) {
    final uid = getCurrentUserId();
    if (uid != resourceOwnerId) {
      throw UnauthorizedException('modificar este recurso');
    }
  }

  /// Verifica que el usuario sea miembro de un grupo
  Future<void> requireGroupMembership(String groupId) async {
    final uid = getCurrentUserId();
    try {
      final groupDoc = await _firestore.collection('groups').doc(groupId).get();
      final members = groupDoc.get('members') as List? ?? [];
      if (!members.contains(uid)) {
        throw UnauthorizedException('acceder a este grupo');
      }
    } catch (e) {
      if (e is UnauthorizedException) rethrow;
      throw InvalidOperationException('No se pudo verificar membresía');
    }
  }

  /// Verifica que el usuario sea admin del grupo
  Future<void> requireGroupAdmin(String groupId) async {
    final uid = getCurrentUserId();
    try {
      final groupDoc = await _firestore.collection('groups').doc(groupId).get();
      final adminId = groupDoc.get('adminId');
      if (adminId != uid) {
        throw UnauthorizedException('administrar este grupo');
      }
    } catch (e) {
      if (e is UnauthorizedException) rethrow;
      throw InvalidOperationException('No se pudo verificar permisos de grupo');
    }
  }

  /// Verifica que el usuario tenga acceso a ver el perfil
  Future<bool> canViewProfile(String targetUserId) async {
    final uid = getCurrentUserId();

    // El usuario siempre puede ver su propio perfil
    if (uid == targetUserId) return true;

    try {
      final targetUserDoc = await _firestore.collection('users').doc(targetUserId).get();
      final isPrivate = targetUserDoc.get('profileVisibility') == 'private';

      if (!isPrivate) return true;

      // Si es privado, verificar si es seguidor
      final followers = targetUserDoc.get('followers') as List? ?? [];
      return followers.contains(uid);
    } catch (e) {
      throw InvalidOperationException('No se pudo verificar acceso al perfil');
    }
  }

  /// Verifica que el usuario pueda listar usuarios (solo admins)
  Future<void> requireCanListUsers() async {
    await requireAdmin();
  }
}
