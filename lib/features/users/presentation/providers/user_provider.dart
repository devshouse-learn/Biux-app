import 'package:biux/features/users/data/models/user_model.dart';
import 'package:biux/shared/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class UserProvider extends ChangeNotifier {
  final UserService _userService = UserService();

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
  }

  Future<bool> updateProfile({String? name, String? email}) async {
    print('🔍 ====== USER PROVIDER: updateProfile ======');
    print('👤 Usuario actual: $_user');
    print('📝 Nombre recibido: "$name"');
    print('📧 Email recibido: "$email"');

    if (_user == null) {
      print('❌ ERROR: _user es NULL');
      _error = 'Usuario no cargado';
      notifyListeners();
      return false;
    }

    // Validar que al menos uno de los campos tenga valor
    if ((name == null || name.isEmpty) && (email == null || email.isEmpty)) {
      print('❌ ERROR: Ambos campos vacíos');
      _error = 'Por favor ingresa al menos un campo para actualizar';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _error = null;

    try {
      print('📝 Iniciando actualización de perfil...');
      print('🆔 UID del usuario: ${_user!.uid}');

      bool success = await _userService.updateUserProfile(
        uid: _user!.uid,
        name: name,
        email: email,
      );

      print('📊 Respuesta del servicio: $success');

      if (success) {
        // Actualizar datos locales
        _user = _user!.copyWith(
          name: name ?? _user!.name,
          email: email ?? _user!.email,
        );
        print('✅ Perfil actualizado localmente');
        print('   Nuevo nombre: ${_user!.name}');
        print('   Nuevo email: ${_user!.email}');
      } else {
        print('❌ El servicio retornó false');
        _error = 'Error al actualizar el perfil. Intenta nuevamente.';
      }

      notifyListeners();
      _setLoading(false);
      return success;
    } catch (e) {
      print('❌ EXCEPCIÓN en updateProfile: $e');
      print('   Tipo: ${e.runtimeType}');
      _error = 'Error al actualizar perfil: ${e.toString()}';
      _setLoading(false);
      notifyListeners();
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

    try {
      return await _userService.getAllUsers();
    } catch (e) {
      _error = 'Error al cargar usuarios: $e';
      notifyListeners();
      return [];
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
