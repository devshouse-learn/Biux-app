import 'package:shared_preferences/shared_preferences.dart';
import 'package:biux/features/users/data/models/user_model.dart';
import 'package:biux/core/services/app_logger.dart';
import 'package:biux/features/users/data/datasources/user_service.dart';
import 'package:biux/features/social/domain/entities/notification_entity.dart';
import 'package:biux/features/social/data/repositories/notifications_repository_impl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode;

class UserProvider extends ChangeNotifier {
  final UserService? _userService;
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
  UserProvider() : _userService = UserService() {
    AppLogger.debug('🟦 UserProvider constructor llamado');
    if (kIsWeb && !kReleaseMode) {
      AppLogger.debug(
        '🌐 Es WEB - Creando usuario admin de prueba automáticamente',
      );
      _createWebTestUser();
    } else {
      loadUserData();
    }
  }

  /// Constructor especial para pruebas que evita llamadas remotas si se solicita
  UserProvider.forTest({UserModel? initialUser, bool skipRemote = true})
    : _userService = null,
      super() {
    _user = initialUser;
    _isLoading = false;
    _skipRemoteCalls = skipRemote;
  }

  // 🔴 Crear usuario admin de prueba SOLO para Chrome web
  Future<void> _createWebTestUser() async {
    AppLogger.debug('🟦 Creando usuario admin para CHROME web (desarrollo)...');
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

      AppLogger.info('✅ Usuario admin de Chrome creado (SOLO WEB)');
      AppLogger.debug('👤 Nombre: ${_user!.name}');
      AppLogger.debug('🛡️ Es admin: ${_user!.isAdmin}');
      AppLogger.debug('🛒 Puede vender: ${_user!.canSellProducts}');
      AppLogger.info('✅ Puede crear productos: ${_user!.canCreateProducts}');
      AppLogger.debug('');
      AppLogger.warning('⚠️  IMPORTANTE:');
      AppLogger.debug('   - Este admin SOLO funciona en Chrome web');
      AppLogger.debug(
        '   - En simuladores móviles, los usuarios deben pedir permiso',
      );
      AppLogger.debug('');

      notifyListeners(); // ← IMPORTANTE: Notificar a los listeners
    } catch (e) {
      AppLogger.error('❌ Error creando usuario de prueba: $e');
      _error = 'user_error_creating_test';
    }

    _setLoading(false);
  }

  Future<void> loadUserData() async {
    if (_skipRemoteCalls) return;

    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    AppLogger.debug('');
    AppLogger.debug('�' * 30);
    AppLogger.debug('� SIMULADOR MÓVIL - Sistema de Permisos');
    AppLogger.debug('📱 TU UID ES: $uid');
    AppLogger.debug('�');
    AppLogger.debug('📱 ⚠️  IMPORTANTE:');
    AppLogger.debug('📱 - Por defecto, NO eres administrador');
    AppLogger.debug('📱 - NO puedes subir productos automáticamente');
    AppLogger.debug('📱 - Debes solicitar permisos a un administrador');
    AppLogger.debug('📱');
    AppLogger.debug('📱 Para solicitar permisos:');
    AppLogger.debug('📱 1. Ve a tu perfil');
    AppLogger.debug('📱 2. Solicita ser vendedor');
    AppLogger.debug('📱 3. Un admin debe aprobar tu solicitud');
    AppLogger.debug('�' * 30);
    AppLogger.debug('');

    _setLoading(true);
    _error = null;

    try {
      UserModel? userData = await _userService!.getUserData(uid);
      _user = userData;

      if (_user != null) {
        // Si el phoneNumber está vacío o no parece un teléfono válido,
        // intentar recuperarlo de FirebaseAuth o del propio UID
        final storedPhone = _user!.phoneNumber;
        final isPhoneInvalid =
            storedPhone.isEmpty ||
            (!storedPhone.startsWith('+') && storedPhone.length > 15);
        if (isPhoneInvalid) {
          String recoveredPhone = '';

          // Intento 1: FirebaseAuth (funciona con phone auth nativo)
          final authPhone =
              FirebaseAuth.instance.currentUser?.phoneNumber ?? '';
          if (authPhone.isNotEmpty) {
            recoveredPhone = authPhone;
          }

          // Intento 2: Extraer del UID (formato phone_57XXXXXXXXXX)
          if (recoveredPhone.isEmpty && uid.startsWith('phone_')) {
            recoveredPhone = '+${uid.substring(6)}';
          }

          if (recoveredPhone.isNotEmpty) {
            _user = _user!.copyWith(phoneNumber: recoveredPhone);
            // Persistir en Firestore para futuras lecturas
            _userService.updatePhoneNumber(uid, recoveredPhone);
          }
        }

        AppLogger.debug('👤 Usuario cargado: ${_user!.name ?? "Sin nombre"}');
        AppLogger.debug('🛡️ Es admin: ${_user!.isAdmin}');
        AppLogger.debug('🛒 Puede vender: ${_user!.canSellProducts}');
        AppLogger.info('✅ Puede crear productos: ${_user!.canCreateProducts}');

        if (!_user!.canCreateProducts) {
          AppLogger.debug('');
          AppLogger.warning('⚠️  NO PUEDES SUBIR PRODUCTOS');
          AppLogger.debug('   Necesitas autorización de un administrador');
          AppLogger.debug('');
        }
      }
    } catch (e) {
      _error = 'user_error_loading_data';
      AppLogger.debug('Error en loadUserData: $e');
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
      _userService!.listenToUser(uid, (userData) {
        _user = userData;
        notifyListeners();
        AppLogger.debug('🔄 Datos de usuario actualizados en tiempo real');
      });
    } catch (e) {
      AppLogger.debug('Error configurando listener: $e');
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? email,
    String? description,
    String? username,
    String? photoUrl,
    String? coverPhotoUrl,
    DateTime? birthDate,
  }) async {
    AppLogger.debug('🔍 ====== USER PROVIDER: updateProfile ======');
    AppLogger.debug('📝 Nombre recibido: "$name"');
    AppLogger.debug('📧 Email recibido: "$email"');
    AppLogger.debug('📋 Descripción recibida: "$description"');
    AppLogger.debug('👤 Username recibido: "$username"');
    AppLogger.debug('🖼️ Foto de perfil recibida: "$photoUrl"');
    AppLogger.debug('🏞️ Foto de portada recibida: "$coverPhotoUrl"');

    // SIEMPRE usar Firebase Auth como fuente de verdad
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      AppLogger.debug(
        '❌ ERROR CRÍTICO: No hay usuario autenticado en Firebase Auth',
      );
      _error = 'user_error_not_logged_in';
      notifyListeners();
      return false;
    }

    final uid = firebaseUser.uid;
    AppLogger.info('✅ Usuario autenticado encontrado');
    AppLogger.debug('🆔 UID de Firebase Auth: $uid');
    AppLogger.debug('📞 Teléfono: ${firebaseUser.phoneNumber}');

    // Validar que al menos uno de los campos tenga valor
    // Permitir null/empty para fotos (para poder eliminarlas)
    bool hasTextUpdate =
        (name != null && name.isNotEmpty) ||
        (email != null && email.isNotEmpty) ||
        (description != null && description.isNotEmpty) ||
        (username != null && username.isNotEmpty);

    // Una foto es actualización si: no es null (nuevo valor) O si es cadena vacía (eliminación)
    bool hasPhotoUpdate = photoUrl != null || coverPhotoUrl != null;

    bool hasBirthDateUpdate = birthDate != null;

    if (!hasTextUpdate && !hasPhotoUpdate && !hasBirthDateUpdate) {
      AppLogger.error('❌ ERROR: Todos los campos vacíos');
      _error = 'user_error_empty_fields';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _error = null;
    notifyListeners();

    try {
      AppLogger.debug('📝 Iniciando actualización de perfil...');
      AppLogger.debug('   Foto de perfil: "$photoUrl"');
      AppLogger.debug('   Foto de portada: "$coverPhotoUrl"');

      bool success = await _userService!.updateUserProfile(
        uid: uid,
        name: name,
        email: email,
        description: description,
        username: username,
        photoUrl: photoUrl,
        coverPhotoUrl: coverPhotoUrl,
        birthDate: birthDate,
      );

      AppLogger.debug('📊 Respuesta del servicio: $success');

      if (success) {
        AppLogger.info('✅ Actualización exitosa, recargando datos...');
        // Recargar datos del usuario desde Firebase
        await loadUserData();

        AppLogger.info('✅ Datos recargados:');
        AppLogger.debug('   Nombre actual: ${_user?.name}');
        AppLogger.debug('   Email actual: ${_user?.email}');
        AppLogger.debug('   Username actual: ${_user?.username}');
        AppLogger.debug('   Descripción actual: ${_user?.description}');
        AppLogger.debug('   Foto de perfil actual: ${_user?.photoUrl}');
        AppLogger.debug('   Foto de portada actual: ${_user?.coverPhotoUrl}');

        _error = null;
      } else {
        AppLogger.error('❌ El servicio retornó false');
        _error = 'user_error_update_profile';
      }

      _setLoading(false);
      notifyListeners();
      AppLogger.debug(
        '🔍 ====== FIN updateProfile (${success ? "ÉXITO" : "ERROR"}) ======\n',
      );
      return success;
    } catch (e) {
      AppLogger.error('❌ EXCEPCIÓN en updateProfile: $e');
      AppLogger.debug('   Tipo: ${e.runtimeType}');
      _error = 'user_error_update_profile';
      _setLoading(false);
      notifyListeners();
      AppLogger.debug('🔍 ====== FIN updateProfile (EXCEPCIÓN) ======\n');
      return false;
    }
  }

  Future<bool> uploadProfileImage() async {
    if (_user == null) return false;

    _setLoading(true);
    _error = null;

    try {
      String? imageUrl = await _userService!.uploadProfileImage(_user!.uid);

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
      bool success = await _userService!.requestAccountDeletion(_user!.uid);

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
    await _userService!.signOut();
    _user = null;
    notifyListeners();
  }

  Future<void> createUserIfNotExists(String uid, String phoneNumber) async {
    await _userService!.createUserIfNotExists(uid, phoneNumber);
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
      bool success = await _userService!.updateSellerPermission(userId, true);

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
      bool success = await _userService!.updateSellerPermission(userId, false);

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
      return await _userService!.getAllUsers();
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
    AppLogger.debug(
      '📱 followUser: currentUserId=$currentUserId, userIdToFollow=$userIdToFollow',
    );

    _setLoading(true);
    _error = null;

    try {
      bool success = await _userService!.followUser(
        currentUserId: currentUserId,
        userIdToFollow: userIdToFollow,
      );

      if (success) {
        // Crear notificación de follow para el usuario seguido
        try {
          final notificationsRepo = NotificationsRepositoryImpl();
          await notificationsRepo.createNotification(
            userId: userIdToFollow,
            type: NotificationType.follow,
            fromUserId: currentUserId,
            fromUserName: _user?.name ?? _user?.username ?? 'Usuario',
            fromUserPhoto: _user?.photoUrl,
          );
          AppLogger.info('🔔 Notificación de follow enviada a $userIdToFollow');
        } catch (e) {
          // No bloquear el follow si falla la notificación
          AppLogger.warning(
            'No se pudo crear notificación de follow: $e',
            tag: 'UserProvider',
          );
        }

        // Actualizar la lista de seguidos localmente
        await loadUserData();
        AppLogger.info('✅ Ya sigues a $userIdToFollow');
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
    AppLogger.debug(
      '📱 unfollowUser: currentUserId=$currentUserId, userIdToUnfollow=$userIdToUnfollow',
    );

    _setLoading(true);
    _error = null;

    try {
      bool success = await _userService!.unfollowUser(
        currentUserId: currentUserId,
        userIdToUnfollow: userIdToUnfollow,
      );

      if (success) {
        // Actualizar la lista de seguidos localmente
        await loadUserData();
        AppLogger.info('✅ Dejaste de seguir a $userIdToUnfollow');
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

  /// Porcentaje de completitud del perfil (0-100)
  int get profileCompletionPercent {
    if (_user == null) return 0;
    int total = 0;
    int completed = 0;
    final checks = <bool>[
      _user!.name?.isNotEmpty ?? false,
      _user!.username?.isNotEmpty ?? false,
      _user!.email?.isNotEmpty ?? false,
      _user!.phoneNumber.isNotEmpty,
      _user!.photoUrl?.isNotEmpty ?? false,
      _user!.description?.isNotEmpty ?? false,
    ];
    total = checks.length;
    completed = checks.where((c) => c).length;
    return ((completed / total) * 100).round();
  }

  /// Campos faltantes del perfil
  List<String> get missingProfileFields {
    if (_user == null) return [];
    final missing = <String>[];
    if (!(_user!.name?.isNotEmpty ?? false)) missing.add('Nombre');
    if (!(_user!.username?.isNotEmpty ?? false))
      missing.add('Nombre de usuario');
    if (!(_user!.photoUrl?.isNotEmpty ?? false)) missing.add('Foto de perfil');
    if (!(_user!.description?.isNotEmpty ?? false)) missing.add('Biografía');
    return missing;
  }

  bool get isProfileComplete => profileCompletionPercent >= 80;

  /// URL pública del perfil para compartir
  String get publicProfileUrl {
    final username = _user?.username ?? _user?.uid ?? '';
    return 'https://biux.app/u/$username';
  }

  String get shareProfileText {
    final name = _user?.name ?? 'Ciclista';
    return '¡Sígueme en Biux! �� $name\n$publicProfileUrl';
  }

  /// Guarda el UID del usuario en caché para acceso rápido al arranque
  // ignore: unused_element
  Future<void> _cacheUserLocally(String uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_uid', uid);
      await prefs.setString('cached_user_name', _user?.name ?? '');
      await prefs.setString('cached_user_photo', _user?.photoUrl ?? '');
    } catch (_) {}
  }

  /// Carga datos básicos del caché local para arranque rápido
  Future<void> loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('cached_uid');
      if (uid != null && _user == null) {
        // Datos mínimos mientras carga Firestore
        notifyListeners();
      }
    } catch (_) {}
  }
}
