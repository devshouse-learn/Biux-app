import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../data/models/group_model.dart';
import '../data/repositories/group_repository.dart';

class GroupProvider extends ChangeNotifier {
  final GroupRepository _repository = GroupRepository();
  final ImagePicker _imagePicker = ImagePicker();

  // Estado
  List<GroupModel> _allGroups = [];
  List<GroupModel> _userGroups = [];
  List<GroupModel> _adminGroups = [];
  List<GroupModel> _searchResults = [];
  bool _isLoading = false;
  String? _error;
  GroupModel? _selectedGroup;

  // Getters
  List<GroupModel> get allGroups => _allGroups;
  List<GroupModel> get userGroups => _userGroups;
  List<GroupModel> get adminGroups => _adminGroups;
  List<GroupModel> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get error => _error;
  GroupModel? get selectedGroup => _selectedGroup;

  String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;

  // Cargar todos los grupos
  void loadAllGroups() {
    _repository.getGroups().listen((groups) {
      _allGroups = groups;
      notifyListeners();
    });
  }

  // Cargar grupos del usuario
  void loadUserGroups() {
    if (currentUserId != null) {
      _repository.getUserGroups(currentUserId!).listen((groups) {
        _userGroups = groups;
        notifyListeners();
      });
    }
  }

  // Cargar grupos administrados
  void loadAdminGroups() {
    if (currentUserId != null) {
      _repository.getAdminGroups(currentUserId!).listen((groups) {
        _adminGroups = groups;
        notifyListeners();
      });
    }
  }

  // Crear grupo
  Future<bool> createGroup({
    required String name,
    required String description,
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
        logoFile: logoFile,
        coverFile: coverFile,
      );

      _setLoading(false);
      return groupId != null;
    } catch (e) {
      _setError('Error al crear el grupo: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Seleccionar grupo
  Future<void> selectGroup(String groupId) async {
    _setLoading(true);
    try {
      _selectedGroup = await _repository.getGroup(groupId);
    } catch (e) {
      _setError('Error al cargar el grupo: ${e.toString()}');
    }
    _setLoading(false);
  }

  // Solicitar unirse a grupo
  Future<bool> requestJoinGroup(String groupId) async {
    if (currentUserId == null) return false;

    _setLoading(true);
    _clearError();

    try {
      final success =
          await _repository.requestJoinGroup(groupId, currentUserId!);
      if (success) {
        // Actualizar el grupo seleccionado si está cargado
        if (_selectedGroup?.id == groupId) {
          await selectGroup(groupId);
        }
      }
      _setLoading(false);
      return success;
    } catch (e) {
      _setError('Error al solicitar ingreso: ${e.toString()}');
      _setLoading(false);
      return false;
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
      _setError('Error al aprobar solicitud: ${e.toString()}');
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
      _setError('Error al rechazar solicitud: ${e.toString()}');
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
      final success =
          await _repository.cancelJoinRequest(groupId, currentUserId!);
      if (success) {
        // Actualizar el grupo seleccionado si está cargado
        if (_selectedGroup?.id == groupId) {
          await selectGroup(groupId);
        }
      }
      _setLoading(false);
      return success;
    } catch (e) {
      _setError('Error al cancelar solicitud: ${e.toString()}');
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
      _setLoading(false);
      return success;
    } catch (e) {
      _setError('Error al salir del grupo: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Buscar grupos
  Future<void> searchGroups(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      _searchResults = await _repository.searchGroups(query);
    } catch (e) {
      _setError('Error en la búsqueda: ${e.toString()}');
    }
    _setLoading(false);
  }

  // Seleccionar imagen
  Future<XFile?> pickImage(ImageSource source) async {
    try {
      return await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
    } catch (e) {
      _setError('Error al seleccionar imagen: ${e.toString()}');
      return null;
    }
  }

  // Obtener estado del usuario en un grupo
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

  // Métodos auxiliares
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
  }

  void clearSelectedGroup() {
    _selectedGroup = null;
    notifyListeners();
  }

  void clearSearchResults() {
    _searchResults = [];
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}

enum GroupMembershipStatus {
  admin,
  member,
  pending,
  notMember,
}
