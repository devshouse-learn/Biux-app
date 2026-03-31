import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:biux/features/groups/data/models/group_model.dart';
import 'package:biux/features/rides/data/models/ride_model.dart';
import 'package:biux/features/users/data/models/user_model.dart';
import '../../data/repositories/group_repository.dart';
import 'package:biux/features/rides/data/repositories/ride_repository.dart';
import 'package:biux/features/users/data/repositories/user_repository.dart';

enum GroupMembershipStatus { admin, member, pending, notMember }

class GroupProvider extends ChangeNotifier {
  final GroupRepository _repository = GroupRepository();
  final UserRepository _userRepository = UserRepository();
  final RideRepository _rideRepository = RideRepository();
  final ImagePicker _imagePicker = ImagePicker();

  // Estado
  List<GroupModel> _allGroups = [];
  List<GroupModel> _userGroups = [];
  List<GroupModel> _adminGroups = [];
  List<GroupModel> _searchResults = [];
  bool _isLoading = false;
  String? _error;
  GroupModel? _selectedGroup;
  Map<String, UserModel> _userCache = {}; // Cache de usuarios

  // Getters
  List<GroupModel> get allGroups => _allGroups;
  List<GroupModel> get userGroups => _userGroups;
  List<GroupModel> get adminGroups => _adminGroups;
  List<GroupModel> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get error => _error;
  GroupModel? get selectedGroup => _selectedGroup;

  String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;

  // NUEVO: Verificar si el usuario ya es admin de algún grupo
  bool get isAdminOfAnyGroup => _adminGroups.isNotEmpty;

  // NUEVO: Verificar si el usuario puede crear un grupo (no es admin de ninguno)
  bool get canCreateGroup => !isAdminOfAnyGroup;

  // Cargar todos los grupos
  void loadAllGroups() {
    _repository.getGroups().listen((groups) {
      // Ordenar por cantidad de miembros (de mayor a menor)
      groups.sort((a, b) => b.memberIds.length.compareTo(a.memberIds.length));
      _allGroups = groups;
      notifyListeners();
    });
  }

  // Cargar grupos del usuario
  void loadUserGroups() {
    if (currentUserId != null) {
      _repository.getUserGroups(currentUserId!).listen((groups) {
        // Ordenar por cantidad de miembros (de mayor a menor)
        groups.sort((a, b) => b.memberIds.length.compareTo(a.memberIds.length));
        _userGroups = groups;
        notifyListeners();
      });
    }
  }

  // Cargar grupos administrados
  void loadAdminGroups() {
    if (currentUserId != null) {
      _repository.getAdminGroups(currentUserId!).listen((groups) {
        // Ordenar por cantidad de miembros (de mayor a menor)
        groups.sort((a, b) => b.memberIds.length.compareTo(a.memberIds.length));
        _adminGroups = groups;
        notifyListeners();
      });
    }
  }

  // Crear grupo
  Future<bool> createGroup({
    required String name,
    required String description,
    required String cityId, // NUEVO PARÁMETRO REQUERIDO
    XFile? logoFile,
    XFile? coverFile,
  }) async {
    if (currentUserId == null) return false;

    _setLoading(true);
    _clearError();

    try {
      final groupId = await _repository.createGroup(
        name: name,
        description: description,
        adminId: currentUserId!,
        cityId: cityId, // PASAR CIUDAD AL REPOSITORIO
        logoFile: logoFile,
        coverFile: coverFile,
      );

      _setLoading(false);
      return groupId != null;
    } catch (e) {
      _setError('group_error_create');
      _setLoading(false);
      return false;
    }
  }

  // NUEVO: Cargar grupos por ciudad
  void loadGroupsByCity(String cityId) {
    _repository.getGroupsByCity(cityId).listen((groups) {
      // Ordenar por cantidad de miembros (de mayor a menor)
      groups.sort((a, b) => b.memberIds.length.compareTo(a.memberIds.length));
      _allGroups = groups;
      notifyListeners();
    });
  }

  // NUEVO: Editar grupo (solo para administradores)
  Future<bool> editGroup({
    required String groupId,
    String? name,
    String? description,
    XFile? logoFile,
    XFile? coverFile,
  }) async {
    if (currentUserId == null) return false;

    _setLoading(true);
    _clearError();

    try {
      final success = await _repository.updateGroup(
        groupId: groupId,
        name: name,
        description: description,
        logoFile: logoFile,
        coverFile: coverFile,
      );

      if (success) {
        // Actualizar el grupo seleccionado si está cargado
        if (_selectedGroup?.id == groupId) {
          await selectGroup(groupId);
        }
      }

      _setLoading(false);
      return success;
    } catch (e) {
      _setError('group_error_edit');
      _setLoading(false);
      return false;
    }
  }

  // Seleccionar grupo
  Future<void> selectGroup(String groupId) async {
    _setLoading(true);
    try {
      _selectedGroup = await _repository.getGroup(groupId);

      // Cargar información de usuarios para mostrar nombres
      if (_selectedGroup != null) {
        await _loadUsersForGroup(_selectedGroup!);
      }
    } catch (e) {
      _setError('group_error_load');
    }
    _setLoading(false);
  }

  // Solicitar unirse a grupo CON VALIDACIÓN DE NOMBRE
  Future<Map<String, dynamic>> requestJoinGroup(String groupId) async {
    if (currentUserId == null) {
      return {'success': false, 'error': 'group_error_not_authenticated'};
    }

    _setLoading(true);
    _clearError();

    try {
      // 1. VALIDAR QUE EL USUARIO TENGA NOMBRE
      final currentUser = await _userRepository.getUserById(currentUserId!);

      if (currentUser == null) {
        _setLoading(false);
        return {
          'success': false,
          'error': 'group_error_user_not_found',
          'requiresProfile': true,
        };
      }

      if (currentUser.name == null || currentUser.name!.trim().isEmpty) {
        _setLoading(false);
        return {
          'success': false,
          'error': 'group_error_complete_profile',
          'requiresProfile': true,
        };
      }

      // 2. Si tiene nombre, proceder con la solicitud
      final success = await _repository.requestJoinGroup(
        groupId,
        currentUserId!,
      );

      if (success) {
        // Actualizar el grupo seleccionado si está cargado
        if (_selectedGroup?.id == groupId) {
          await selectGroup(groupId);
        }
      }

      _setLoading(false);
      return {'success': success};
    } catch (e) {
      _setError('group_error_request_join');
      _setLoading(false);
      return {'success': false, 'error': e.toString()};
    }
  }

  // Aprobar solicitud (solo admin)
  Future<bool> approveJoinRequest(String groupId, String userId) async {
    if (currentUserId == null) return false;

    _setLoading(true);
    _clearError();

    try {
      final success = await _repository.approveJoinRequest(groupId, userId);
      if (success) {
        // Actualizar el grupo seleccionado si está cargado
        if (_selectedGroup?.id == groupId) {
          await selectGroup(groupId);
        }
      }
      _setLoading(false);
      return success;
    } catch (e) {
      _setError('group_error_approve');
      _setLoading(false);
      return false;
    }
  }

  // Rechazar solicitud (solo admin)
  Future<bool> rejectJoinRequest(String groupId, String userId) async {
    if (currentUserId == null) return false;

    _setLoading(true);
    _clearError();

    try {
      final success = await _repository.rejectJoinRequest(groupId, userId);
      if (success) {
        // Actualizar el grupo seleccionado si está cargado
        if (_selectedGroup?.id == groupId) {
          await selectGroup(groupId);
        }
      }
      _setLoading(false);
      return success;
    } catch (e) {
      _setError('group_error_reject');
      _setLoading(false);
      return false;
    }
  }

  // Cancelar solicitud
  Future<bool> cancelJoinRequest(String groupId) async {
    if (currentUserId == null) return false;

    _setLoading(true);
    _clearError();

    try {
      final success = await _repository.cancelJoinRequest(
        groupId,
        currentUserId!,
      );
      if (success) {
        // Actualizar el grupo seleccionado si está cargado
        if (_selectedGroup?.id == groupId) {
          await selectGroup(groupId);
        }
      }
      _setLoading(false);
      return success;
    } catch (e) {
      _setError('group_error_cancel_request');
      _setLoading(false);
      return false;
    }
  }

  // Salir del grupo
  Future<bool> leaveGroup(String groupId) async {
    if (currentUserId == null) return false;

    _setLoading(true);
    _clearError();

    try {
      final success = await _repository.leaveGroup(groupId, currentUserId!);
      if (success) {
        // Actualizar listas
        loadUserGroups();
        if (_selectedGroup?.id == groupId) {
          await selectGroup(groupId);
        }
      }
      _setLoading(false);
      return success;
    } catch (e) {
      _setError('group_error_leave');
      _setLoading(false);
      return false;
    }
  }

  // Buscar grupos
  Future<void> searchGroups(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    try {
      _searchResults = await _repository.searchGroups(query);
      notifyListeners();
    } catch (e) {
      debugPrint('Error buscando grupos: $e');
    }
  }

  void clearSearchResults() {
    _searchResults = [];
    notifyListeners();
  }

  // Obtener estado de membresía del usuario
  GroupMembershipStatus getUserStatus(GroupModel group) {
    if (currentUserId == null) return GroupMembershipStatus.notMember;

    if (group.isAdmin(currentUserId!)) {
      return GroupMembershipStatus.admin;
    } else if (group.isMember(currentUserId!)) {
      return GroupMembershipStatus.member;
    } else if (group.hasPendingRequest(currentUserId!)) {
      return GroupMembershipStatus.pending;
    } else {
      return GroupMembershipStatus.notMember;
    }
  }

  // Obtener información de usuario (con cache)
  Future<UserModel?> getUserInfo(String userId) async {
    // Verificar cache primero
    if (_userCache.containsKey(userId)) {
      return _userCache[userId];
    }

    try {
      final user = await _userRepository.getUserById(userId);
      if (user != null) {
        _userCache[userId] = user; // Guardar en cache
      }
      return user;
    } catch (e) {
      debugPrint('Error obteniendo usuario $userId: $e');
      return null;
    }
  }

  // Obtener nombres de usuarios para solicitudes pendientes
  Future<List<Map<String, dynamic>>> getPendingRequestsWithNames(
    GroupModel group,
  ) async {
    List<Map<String, dynamic>> requests = [];

    for (String userId in group.pendingRequestIds) {
      final user = await getUserInfo(userId);
      requests.add({
        'userId': userId,
        'userName': user?.name ?? '',
        'userPhoto': user?.photoUrl,
        'phoneNumber': user?.phoneNumber ?? '',
        'hasName': user?.name != null && user!.name!.trim().isNotEmpty,
      });
    }

    return requests;
  }

  // Obtener nombres de miembros del grupo
  Future<List<Map<String, dynamic>>> getMembersWithNames(
    GroupModel group,
  ) async {
    List<Map<String, dynamic>> members = [];

    debugPrint('=== OBTENIENDO MIEMBROS DEL GRUPO ===');
    debugPrint('Grupo: ${group.name}');
    debugPrint('Admin ID: ${group.adminId}');
    debugPrint('Member IDs: ${group.memberIds}');
    debugPrint('====================================');

    for (String userId in group.memberIds) {
      final user = await getUserInfo(userId);

      debugPrint('--- Procesando usuario $userId ---');
      debugPrint('Usuario obtenido: $user');
      debugPrint('Nombre: ${user?.name}');
      debugPrint('Foto: ${user?.photoUrl}');
      debugPrint('Teléfono: ${user?.phoneNumber}');
      debugPrint('Es admin: ${group.isAdmin(userId)}');
      debugPrint('--------------------------------');

      members.add({
        'userId': userId,
        'userName': user?.name ?? '',
        'userPhoto': user?.photoUrl,
        'phoneNumber': user?.phoneNumber ?? '',
        'isAdmin': group.isAdmin(userId),
        'hasName': user?.name != null && user!.name!.trim().isNotEmpty,
      });
    }

    debugPrint('=== RESULTADO FINAL ===');
    for (var member in members) {
      debugPrint(
        'Miembro: ${member['userName']} (${member['userId']}) - Admin: ${member['isAdmin']}',
      );
    }
    debugPrint('======================');

    return members;
  }

  // Cargar usuarios para un grupo específico
  Future<void> _loadUsersForGroup(GroupModel group) async {
    // Cargar admin
    await getUserInfo(group.adminId);

    // Cargar miembros
    for (String memberId in group.memberIds) {
      await getUserInfo(memberId);
    }

    // Cargar solicitudes pendientes
    for (String requestId in group.pendingRequestIds) {
      await getUserInfo(requestId);
    }
  }

  // Limpiar cache de usuarios
  void clearUserCache() {
    _userCache.clear();
  }

  Future<XFile?> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      return image;
    } catch (e) {
      debugPrint('Error seleccionando imagen: $e');
      _setError('group_error_select_image');
      return null;
    }
  }

  // Método para obtener las rodadas de un grupo
  Future<List<RideModel>> getRidesByGroup(GroupModel group) async {
    try {
      // Usar el método getGroupRides que ya existe en el repositorio
      // Como retorna un Stream, tomamos el primer valor
      final stream = _rideRepository.getGroupRides(group.id);
      return await stream.first;
    } catch (e) {
      debugPrint('Error obteniendo rodadas del grupo: $e');
      return [];
    }
  }

  // Obtener información del admin/creador del grupo
  Future<Map<String, dynamic>> getUserAdminInfo(String userId) async {
    try {
      final user = await _userRepository.getUserById(userId);

      if (user != null) {
        return {
          'fullName': user.name ?? '',
          'userName': user.username ?? '',
          'photo': user.photoUrl ?? '',
          'email': user.email ?? '',
          'hasName': user.name != null && user.name!.trim().isNotEmpty,
        };
      }

      return {
        'fullName': '',
        'userName': '',
        'photo': '',
        'email': '',
        'hasName': false,
      };
    } catch (e) {
      debugPrint('Error obteniendo info del admin: $e');
      return {
        'fullName': '',
        'userName': '',
        'photo': '',
        'email': '',
        'hasName': false,
      };
    }
  }

  // Métodos privados
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
