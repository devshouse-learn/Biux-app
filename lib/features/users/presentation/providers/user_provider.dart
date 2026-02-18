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
    print('🟦 UserProvider constructor llamado');
    if (kIsWeb) {
      print('🌐 Es WEB - Creando usuario admin de prueba automáticamente');
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
    print('🟦 Creando usuario admin para CHROME web (desarrollo)...');
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

      print('✅ Usuario admin de Chrome creado (SOLO WEB)');
      print('👤 Nombre: ${_user!.name}');
      print('🛡️ Es admin: ${_user!.isAdmin}');
      print('🛒 Puede vender: ${_user!.canSellProducts}');
      print('✅ Puede crear productos: ${_user!.canCreateProducts}');
      print('');
      print('⚠️  IMPORTANTE:');
      print('   - Este admin SOLO funciona en Chrome web');
      print('   - En simuladores móviles, los usuarios deben pedir permiso');
      print('');

      notifyListeners(); // ← IMPORTANTE: Notificar a los listeners
    } catch (e) {
      print('❌ Error creando usuario de prueba: $e');
      _error = 'Error creando usuario de prueba';
    }

    _setLoading(false);
  }

  Future<void> loadUserData() async {
    if (_skipRemoteCalls) return;

    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    print('');
    print('�' * 30);
    print('� SIMULADOR MÓVIL - Sistema de Permisos');
    print('📱 TU UID ES: $uid');
    print('�');
    print('📱 ⚠️  IMPORTANTE:');
    print('📱 - Por defecto, NO eres administrador');
    print('📱 - NO puedes subir productos automáticamente');
    print('📱 - Debes solicitar permisos a un administrador');
    print('📱');
    print('📱 Para solicitar permisos:');
    print('📱 1. Ve a tu perfil');
    print('📱 2. Solicita ser vendedor');
    print('📱 3. Un admin debe aprobar tu solicitud');
    print('�' * 30);
    print('');

    _setLoading(true);
    _error = null;

    try {
      UserModel? userData = await _userService.getUserData(uid);
      _user = userData;

      if (_user != null) {
        print('👤 Usuario cargado: ${_user!.name ?? "Sin nombre"}');
        print('🛡️ Es admin: ${_user!.isAdmin}');
        print('🛒 Puede vender: ${_user!.canSellProducts}');
        print('✅ Puede crear productos: ${_user!.canCreateProducts}');

        if (!_user!.canCreateProducts) {
          print('');
          print('⚠️  NO PUEDES SUBIR PRODUCTOS');
          print('   Necesitas autorización de un administrador');
          print('');
        }
      }
    } catch (e) {
      _error = 'Error cargando datos del usuario';
      print('Error en loadUserData: $e');
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
        print('🔄 Datos de usuario actualizados en tiempo real');
      });
    } catch (e) {
      print('Error configurando listener: $e');
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
    print('🔍 ====== USER PROVIDER: updateProfile ======');
    print('📝 Nombre recibido: "$name"');
    print('📧 Email recibido: "$email"');
    print('📋 Descripción recibida: "$description"');
    print('👤 Username recibido: "$username"');
    print('🖼️ Foto de perfil recibida: "$photoUrl"');
    print('🏞️ Foto de portada recibida: "$coverPhotoUrl"');

    // SIEMPRE usar Firebase Auth como fuente de verdad
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      print('❌ ERROR CRÍTICO: No hay usuario autenticado en Firebase Auth');
      _error = 'No has iniciado sesión. Por favor, inicia sesión primero.';
      notifyListeners();
      return false;
    }

    final uid = firebaseUser.uid;
    print('✅ Usuario autenticado encontrado');
    print('🆔 UID de Firebase Auth: $uid');
    print('📞 Teléfono: ${firebaseUser.phoneNumber}');

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
      print('❌ ERROR: Todos los campos vacíos');
      _error = 'Por favor ingresa al menos un campo para actualizar';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _error = null;
    notifyListeners();

    try {
      print('📝 Iniciando actualización de perfil...');
      print('   Foto de perfil: "$photoUrl"');
      print('   Foto de portada: "$coverPhotoUrl"');

      bool success = await _userService.updateUserProfile(
        uid: uid,
        name: name,
        email: email,
        description: description,
        username: username,
        photoUrl: photoUrl,
        coverPhotoUrl: coverPhotoUrl,
      );

      print('📊 Respuesta del servicio: $success');

      if (success) {
        print('✅ Actualización exitosa, recargando datos...');
        // Recargar datos del usuario desde Firebase
        await loadUserData();

        print('✅ Datos recargados:');
        print('   Nombre actual: ${_user?.name}');
        print('   Email actual: ${_user?.email}');
        print('   Username actual: ${_user?.username}');
        print('   Descripción actual: ${_user?.description}');
        print('   Foto de perfil actual: ${_user?.photoUrl}');
        print('   Foto de portada actual: ${_user?.coverPhotoUrl}');

        _error = null;
      } else {
        print('❌ El servicio retornó false');
        _error = 'Error al actualizar el perfil. Intenta nuevamente.';
      }

      _setLoading(false);
      notifyListeners();
      print(
        '🔍 ====== FIN updateProfile (${success ? "ÉXITO" : "ERROR"}) ======\n',
      );
      return success;
    } catch (e) {
      print('❌ EXCEPCIÓN en updateProfile: $e');
      print('   Tipo: ${e.runtimeType}');
      _error = 'Error al actualizar perfil: ${e.toString()}';
      _setLoading(false);
      notifyListeners();
      print('🔍 ====== FIN updateProfile (EXCEPCIÓN) ======\n');
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
      _error = 'Error subiendo imagen';
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
      _error = 'Error solicitando eliminación';
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
      _error = 'Solo los administradores pueden autorizar vendedores';
      notifyListeners();
      return false;
    }
    if (_skipRemoteCalls) return true;

    _setLoading(true);
    _error = null;

    try {
      bool success = await _userService.updateSellerPermission(userId, true);

      if (!success) {
        _error = 'Error al autorizar vendedor';
      }

      _setLoading(false);
      notifyListeners();
      return success;
    } catch (e) {
      _error = 'Error al autorizar vendedor: $e';
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// Revocar autorización de vendedor (solo administradores)
  Future<bool> revokeSellerPermission(String userId) async {
    if (_user == null || !_user!.isAdmin) {
      _error = 'Solo los administradores pueden revocar permisos';
      notifyListeners();
      return false;
    }
    if (_skipRemoteCalls) return true;

    _setLoading(true);
    _error = null;

    try {
      bool success = await _userService.updateSellerPermission(userId, false);

      if (!success) {
        _error = 'Error al revocar permiso';
      }

      _setLoading(false);
      notifyListeners();
      return success;
    } catch (e) {
      _error = 'Error al revocar permiso: $e';
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// Obtener lista de todos los usuarios (solo administradores)
  Future<List<UserModel>> getAllUsers() async {
    if (_user == null || !_user!.isAdmin) {
      _error = 'Solo los administradores pueden ver la lista de usuarios';
      notifyListeners();
      return [];
    }
    if (_skipRemoteCalls) return [];

    try {
      return await _userService.getAllUsers();
    } catch (e) {
      _error = 'Error al cargar usuarios: $e';
      notifyListeners();
      return [];
    }
  }

  /// Seguir a un usuario
  Future<bool> followUser(String userIdToFollow) async {
    // Obtener el UID del usuario actual autenticado desde FirebaseAuth
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      _error = 'No estás autenticado';
      notifyListeners();
      return false;
    }

    final currentUserId = currentUser.uid;
    print(
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
        print('✅ Ya sigues a $userIdToFollow');
      } else {
        _error = 'Error al seguir al usuario';
      }

      _setLoading(false);
      notifyListeners();
      return success;
    } catch (e) {
      _error = 'Error al seguir: $e';
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
      _error = 'No estás autenticado';
      notifyListeners();
      return false;
    }

    final currentUserId = currentUser.uid;
    print(
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
        print('✅ Dejaste de seguir a $userIdToUnfollow');
      } else {
        _error = 'Error al dejar de seguir';
      }

      _setLoading(false);
      notifyListeners();
      return success;
    } catch (e) {
      _error = 'Error al dejar de seguir: $e';
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
