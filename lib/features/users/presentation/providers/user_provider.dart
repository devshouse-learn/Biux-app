import 'package:biux/features/users/data/models/user_model.dart';
import 'package:biux/shared/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class UserProvider extends ChangeNotifier {
  final UserService _userService = UserService();
  // Flag para evitar llamadas remotas en tests
  bool _skipRemoteCalls = false;

  /// Constructor de producción
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 🔴 Constructor que auto-inicializa en web
  UserProvider() {
    debugPrint('🟦 UserProvider constructor llamado');
    if (kIsWeb) {
      debugPrint('🌐 Es WEB - Creando usuario admin de prueba automáticamente');
      _createWebTestUser();
    } else {
      loadUserData();
    }
  }

  /// Constructor especial para pruebas que evita llamadas remotas si se solicita
  UserProvider.forTest({UserModel? initialUser, bool skipRemote = true}) {
    _user = initialUser;
    _isLoading = false;
    _skipRemoteCalls = skipRemote;
  }

  // 🔴 Crear usuario admin de prueba SOLO para Chrome web
  Future<void> _createWebTestUser() async {
    debugPrint('🟦 Creando usuario admin para CHROME web (desarrollo)...');
    _setLoading(true);

    try {
      // ⚠️ IMPORTANTE: Este usuario SOLO existe en Chrome
      // En simuladores móviles, los usuarios deben solicitar permisos a través de Firebase
      _user = UserModel(
        uid: 'web-chrome-admin-uid',
        name: 'Admin Chrome (Desarrollo)',
        email: 'admin.chrome@biux.dev',
        phoneNumber: '+1234567890',
        isAdmin: true, // ← ADMIN SOLO EN CHROME WEB
        canSellProducts: true,
      );

      debugPrint('✅ Usuario admin de Chrome creado (SOLO WEB)');
      debugPrint('👤 Nombre: ${_user!.name}');
      debugPrint('🛡️ Es admin: ${_user!.isAdmin}');
      debugPrint('🛒 Puede vender: ${_user!.canSellProducts}');
      debugPrint('✅ Puede crear productos: ${_user!.canCreateProducts}');
      debugPrint('');
      debugPrint('⚠️  IMPORTANTE:');
      debugPrint('   - Este admin SOLO funciona en Chrome web');
      debugPrint(
        '   - En simuladores móviles, los usuarios deben pedir permiso',
      );
      debugPrint('');

      notifyListeners(); // ← IMPORTANTE: Notificar a los listeners
    } catch (e) {
      debugPrint('❌ Error creando usuario de prueba: $e');
      _error = 'user_error_creating_test';
    }

    _setLoading(false);
  }

  Future<void> loadUserData() async {
    if (_skipRemoteCalls) return;

    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    debugPrint('');
    debugPrint('�' * 30);
    debugPrint('� SIMULADOR MÓVIL - Sistema de Permisos');
    debugPrint('📱 TU UID ES: $uid');
    debugPrint('�');
    debugPrint('📱 ⚠️  IMPORTANTE:');
    debugPrint('📱 - Por defecto, NO eres administrador');
    debugPrint('📱 - NO puedes subir productos automáticamente');
    debugPrint('📱 - Debes solicitar permisos a un administrador');
    debugPrint('📱');
    debugPrint('📱 Para solicitar permisos:');
    debugPrint('📱 1. Ve a tu perfil');
    debugPrint('📱 2. Solicita ser vendedor');
    debugPrint('📱 3. Un admin debe aprobar tu solicitud');
    debugPrint('�' * 30);
    debugPrint('');

    _setLoading(true);
    _error = null;

    try {
      UserModel? userData = await _userService.getUserData(uid);
      _user = userData;

      if (_user != null) {
        debugPrint('👤 Usuario cargado: ${_user!.name ?? "Sin nombre"}');
        debugPrint('🛡️ Es admin: ${_user!.isAdmin}');
        debugPrint('🛒 Puede vender: ${_user!.canSellProducts}');
        debugPrint('✅ Puede crear productos: ${_user!.canCreateProducts}');

        if (!_user!.canCreateProducts) {
          debugPrint('');
          debugPrint('⚠️  NO PUEDES SUBIR PRODUCTOS');
          debugPrint('   Necesitas autorización de un administrador');
          debugPrint('');
        }
      }
    } catch (e) {
      _error = 'user_error_loading_data';
      debugPrint('Error en loadUserData: $e');
    }

    _setLoading(false);

    // Iniciar listener en tiempo real
    _listenToCurrentUser();
  }

  // Escuchar cambios en tiempo real del usuario actual
  void _listenToCurrentUser() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || _skipRemoteCalls) return;

    try {
      _userService.listenToUser(uid, (userData) {
        _user = userData;
        notifyListeners();
        debugPrint('🔄 Datos de usuario actualizados en tiempo real');
      });
    } catch (e) {
      debugPrint('Error configurando listener: $e');
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? email,
    String? description,
    String? username,
    String? photoUrl,
    String? coverPhotoUrl,
  }) async {
    debugPrint('🔍 ====== USER PROVIDER: updateProfile ======');
    debugPrint('📝 Nombre recibido: "$name"');
    debugPrint('📧 Email recibido: "$email"');
    debugPrint('📋 Descripción recibida: "$description"');
    debugPrint('👤 Username recibido: "$username"');
    debugPrint('🖼️ Foto de perfil recibida: "$photoUrl"');
    debugPrint('🏞️ Foto de portada recibida: "$coverPhotoUrl"');

    // SIEMPRE usar Firebase Auth como fuente de verdad
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      debugPrint(
        '❌ ERROR CRÍTICO: No hay usuario autenticado en Firebase Auth',
      );
      _error = 'user_error_not_logged_in';
      notifyListeners();
      return false;
    }

    final uid = firebaseUser.uid;
    debugPrint('✅ Usuario autenticado encontrado');
    debugPrint('🆔 UID de Firebase Auth: $uid');
    debugPrint('📞 Teléfono: ${firebaseUser.phoneNumber}');

    // Validar que al menos uno de los campos tenga valor
    // Permitir null/empty para fotos (para poder eliminarlas)
    bool hasTextUpdate =
        (name != null && name.isNotEmpty) ||
        (email != null && email.isNotEmpty) ||
        (description != null && description.isNotEmpty) ||
        (username != null && username.isNotEmpty);

    // Una foto es actualización si: no es null (nuevo valor) O si es cadena vacía (eliminación)
    bool hasPhotoUpdate = photoUrl != null || coverPhotoUrl != null;

    if (!hasTextUpdate && !hasPhotoUpdate) {
      debugPrint('❌ ERROR: Todos los campos vacíos');
      _error = 'user_error_empty_fields';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _error = null;
    notifyListeners();

    try {
      debugPrint('📝 Iniciando actualización de perfil...');
      debugPrint('   Foto de perfil: "$photoUrl"');
      debugPrint('   Foto de portada: "$coverPhotoUrl"');

      bool success = await _userService.updateUserProfile(
        uid: uid,
        name: name,
        email: email,
        description: description,
        username: username,
        photoUrl: photoUrl,
        coverPhotoUrl: coverPhotoUrl,
      );

      debugPrint('📊 Respuesta del servicio: $success');

      if (success) {
        debugPrint('✅ Actualización exitosa, recargando datos...');
        // Recargar datos del usuario desde Firebase
        await loadUserData();

        debugPrint('✅ Datos recargados:');
        debugPrint('   Nombre actual: ${_user?.name}');
        debugPrint('   Email actual: ${_user?.email}');
        debugPrint('   Username actual: ${_user?.username}');
        debugPrint('   Descripción actual: ${_user?.description}');
        debugPrint('   Foto de perfil actual: ${_user?.photoUrl}');
        debugPrint('   Foto de portada actual: ${_user?.coverPhotoUrl}');

        _error = null;
      } else {
        debugPrint('❌ El servicio retornó false');
        _error = 'user_error_update_profile';
      }

      _setLoading(false);
      notifyListeners();
      debugPrint(
        '🔍 ====== FIN updateProfile (${success ? "ÉXITO" : "ERROR"}) ======\n',
      );
      return success;
    } catch (e) {
      debugPrint('❌ EXCEPCIÓN en updateProfile: $e');
      debugPrint('   Tipo: ${e.runtimeType}');
      _error = 'user_error_update_profile';
      _setLoading(false);
      notifyListeners();
      debugPrint('🔍 ====== FIN updateProfile (EXCEPCIÓN) ======\n');
      return false;
    }
  }

  Future<bool> uploadProfileImage() async {
    if (_user == null) return false;

    _setLoading(true);
    _error = null;

    try {
      String? imageUrl = await _userService.uploadProfileImage(_user!.uid);

      if (imageUrl != null) {
        _user = _user!.copyWith(photoUrl: imageUrl);
        _setLoading(false);
        return true;
      }

      _setLoading(false);
      return false;
    } catch (e) {
      _error = 'user_error_upload_image';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> requestAccountDeletion() async {
    if (_user == null) return false;

    _setLoading(true);
    _error = null;

    try {
      bool success = await _userService.requestAccountDeletion(_user!.uid);

      if (success) {
        _user = _user!.copyWith(
          isDeleting: true,
          deletionRequestDate: DateTime.now(),
        );
      }

      _setLoading(false);
      return success;
    } catch (e) {
      _error = 'user_error_request_deletion';
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    await _userService.signOut();
    _user = null;
    notifyListeners();
  }

  Future<void> createUserIfNotExists(String uid, String phoneNumber) async {
    await _userService.createUserIfNotExists(uid, phoneNumber);
    await loadUserData();
  }

  /// Autorizar a un usuario para vender productos (solo administradores)
  Future<bool> authorizeSeller(String userId) async {
    if (_user == null || !_user!.isAdmin) {
      _error = 'user_error_admin_only_authorize';
      notifyListeners();
      return false;
    }
    if (_skipRemoteCalls) return true;

    _setLoading(true);
    _error = null;

    try {
      bool success = await _userService.updateSellerPermission(userId, true);

      if (!success) {
        _error = 'user_error_authorize_seller';
      }

      _setLoading(false);
      notifyListeners();
      return success;
    } catch (e) {
      _error = 'user_error_authorize_seller';
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// Revocar autorización de vendedor (solo administradores)
  Future<bool> revokeSellerPermission(String userId) async {
    if (_user == null || !_user!.isAdmin) {
      _error = 'user_error_admin_only_revoke';
      notifyListeners();
      return false;
    }
    if (_skipRemoteCalls) return true;

    _setLoading(true);
    _error = null;

    try {
      bool success = await _userService.updateSellerPermission(userId, false);

      if (!success) {
        _error = 'user_error_revoke_permission';
      }

      _setLoading(false);
      notifyListeners();
      return success;
    } catch (e) {
      _error = 'user_error_revoke_permission';
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// Obtener lista de todos los usuarios (solo administradores)
  Future<List<UserModel>> getAllUsers() async {
    if (_user == null || !_user!.isAdmin) {
      _error = 'user_error_admin_only_list';
      notifyListeners();
      return [];
    }
    if (_skipRemoteCalls) return [];

    try {
      return await _userService.getAllUsers();
    } catch (e) {
      _error = 'user_error_load_users';
      notifyListeners();
      return [];
    }
  }

  /// Seguir a un usuario
  Future<bool> followUser(String userIdToFollow) async {
    // Obtener el UID del usuario actual autenticado desde FirebaseAuth
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      _error = 'user_error_not_authenticated';
      notifyListeners();
      return false;
    }

    final currentUserId = currentUser.uid;
    debugPrint(
      '📱 followUser: currentUserId=$currentUserId, userIdToFollow=$userIdToFollow',
    );

    _setLoading(true);
    _error = null;

    try {
      bool success = await _userService.followUser(
        currentUserId: currentUserId,
        userIdToFollow: userIdToFollow,
      );

      if (success) {
        // Actualizar la lista de seguidos localmente
        await loadUserData();
        debugPrint('✅ Ya sigues a $userIdToFollow');
      } else {
        _error = 'user_error_follow';
      }

      _setLoading(false);
      notifyListeners();
      return success;
    } catch (e) {
      _error = 'user_error_follow';
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// Dejar de seguir a un usuario
  Future<bool> unfollowUser(String userIdToUnfollow) async {
    // Obtener el UID del usuario actual autenticado desde FirebaseAuth
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      _error = 'user_error_not_authenticated';
      notifyListeners();
      return false;
    }

    final currentUserId = currentUser.uid;
    debugPrint(
      '📱 unfollowUser: currentUserId=$currentUserId, userIdToUnfollow=$userIdToUnfollow',
    );

    _setLoading(true);
    _error = null;

    try {
      bool success = await _userService.unfollowUser(
        currentUserId: currentUserId,
        userIdToUnfollow: userIdToUnfollow,
      );

      if (success) {
        // Actualizar la lista de seguidos localmente
        await loadUserData();
        debugPrint('✅ Dejaste de seguir a $userIdToUnfollow');
      } else {
        _error = 'user_error_unfollow';
      }

      _setLoading(false);
      notifyListeners();
      return success;
    } catch (e) {
      _error = 'user_error_unfollow';
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

// Resolución de conflictos: Mantener la lógica más reciente y relevante para el proyecto.
