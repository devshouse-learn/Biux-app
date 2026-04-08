import 'package:firebase_auth/firebase_auth.dart';
import 'package:biux/core/services/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:biux/features/groups/data/models/group_model.dart';
import 'package:biux/features/rides/data/models/ride_model.dart';
import 'package:biux/features/users/data/models/user_model.dart';

// Use Cases
import 'package:biux/features/groups/domain/usecases/create_group_usecase.dart';
import 'package:biux/features/groups/domain/usecases/get_groups_usecase.dart';
import 'package:biux/features/groups/domain/usecases/join_group_usecase.dart';
import 'package:biux/features/groups/domain/usecases/leave_group_usecase.dart';
import 'package:biux/features/groups/domain/usecases/delete_group_usecase.dart';
import 'package:biux/features/groups/domain/usecases/edit_group_usecase.dart';
import 'package:biux/features/groups/domain/usecases/get_group_by_id_usecase.dart';
import 'package:biux/features/groups/domain/usecases/approve_join_request_usecase.dart';
import 'package:biux/features/groups/domain/usecases/reject_join_request_usecase.dart';
import 'package:biux/features/groups/domain/usecases/cancel_join_request_usecase.dart';
import 'package:biux/features/groups/domain/usecases/search_groups_usecase.dart';

// Repositories (para creación de use cases y operaciones cross-feature)
import 'package:biux/features/groups/data/repositories/group_repository.dart';
import 'package:biux/features/rides/data/repositories/ride_repository.dart';
import 'package:biux/features/users/data/repositories/user_repository.dart';

enum GroupMembershipStatus { admin, member, pending, notMember }

class GroupProvider extends ChangeNotifier {
  // Repositorios auxiliares (otros features — no pasan por use cases de grupos)
  final UserRepository _userRepository;
  final RideRepository _rideRepository;
  final ImagePicker _imagePicker;

  // ─── Use Cases ────────────────────────────────────────────────────────
  final CreateGroupUseCase _createGroupUseCase;
  final GetGroupsUseCase _getGroupsUseCase;
  final JoinGroupUseCase _joinGroupUseCase;
  final LeaveGroupUseCase _leaveGroupUseCase;
  final DeleteGroupUseCase _deleteGroupUseCase;
  final EditGroupUseCase _editGroupUseCase;
  final GetGroupByIdUseCase _getGroupByIdUseCase;
  final ApproveJoinRequestUseCase _approveJoinRequestUseCase;
  final RejectJoinRequestUseCase _rejectJoinRequestUseCase;
  final CancelJoinRequestUseCase _cancelJoinRequestUseCase;
  final SearchGroupsUseCase _searchGroupsUseCase;

  // ─── Estado ───────────────────────────────────────────────────────────
  List<GroupModel> _allGroups = [];
  List<GroupModel> _userGroups = [];
  List<GroupModel> _adminGroups = [];
  List<GroupModel> _searchResults = [];
  bool _isLoading = false;
  String? _error;
  GroupModel? _selectedGroup;
  final Map<String, UserModel> _userCache = {};

  // ─── Constructor (compatible sin parámetros para main.dart) ───────────
  GroupProvider({
    GroupRepository? repository,
    UserRepository? userRepository,
    RideRepository? rideRepository,
    ImagePicker? imagePicker,
  })  : _userRepository = userRepository ?? UserRepository(),
        _rideRepository = rideRepository ?? RideRepository(),
        _imagePicker = imagePicker ?? ImagePicker(),
        _createGroupUseCase =
            CreateGroupUseCase(repository ?? GroupRepository()),
        _getGroupsUseCase = GetGroupsUseCase(repository ?? GroupRepository()),
        _joinGroupUseCase = JoinGroupUseCase(repository ?? GroupRepository()),
        _leaveGroupUseCase = LeaveGroupUseCase(repository ?? GroupRepository()),
        _deleteGroupUseCase =
            DeleteGroupUseCase(repository ?? GroupRepository()),
        _editGroupUseCase = EditGroupUseCase(repository ?? GroupRepository()),
        _getGroupByIdUseCase =
            GetGroupByIdUseCase(repository ?? GroupRepository()),
        _approveJoinRequestUseCase =
            ApproveJoinRequestUseCase(repository ?? GroupRepository()),
        _rejectJoinRequestUseCase =
            RejectJoinRequestUseCase(repository ?? GroupRepository()),
        _cancelJoinRequestUseCase =
            CancelJoinRequestUseCase(repository ?? GroupRepository()),
        _searchGroupsUseCase =
            SearchGroupsUseCase(repository ?? GroupRepository());

  // ─── Getters ──────────────────────────────────────────────────────────
  List<GroupModel> get allGroups => _allGroups;
  List<GroupModel> get userGroups => _userGroups;
  List<GroupModel> get adminGroups => _adminGroups;
  List<GroupModel> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get error => _error;
  GroupModel? get selectedGroup => _selectedGroup;

  String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;

  bool get isAdminOfAnyGroup => _adminGroups.isNotEmpty;
  bool get canCreateGroup => !isAdminOfAnyGroup;

  // ─── Cargar grupos (Use Case: GetGroupsUseCase) ──────────────────────

  void loadAllGroups() {
    _getGroupsUseCase.call().listen((groups) {
      groups.sort((a, b) => b.memberIds.length.compareTo(a.memberIds.length));
      _allGroups = groups;
      notifyListeners();
    });
  }

  void loadUserGroups() {
    if (currentUserId != null) {
      _getGroupsUseCase.byUser(currentUserId!).listen((groups) {
        groups.sort(
            (a, b) => b.memberIds.length.compareTo(a.memberIds.length));
        _userGroups = groups;
        notifyListeners();
      });
    }
  }

  void loadAdminGroups() {
    if (currentUserId != null) {
      _getGroupsUseCase.adminGroups(currentUserId!).listen((groups) {
        groups.sort(
            (a, b) => b.memberIds.length.compareTo(a.memberIds.length));
        _adminGroups = groups;
        notifyListeners();
      });
    }
  }

  void loadGroupsByCity(String cityId) {
    _getGroupsUseCase.byCity(cityId).listen((groups) {
      groups.sort((a, b) => b.memberIds.length.compareTo(a.memberIds.length));
      _allGroups = groups;
      notifyListeners();
    });
  }

  // ─── Crear grupo (Use Case: CreateGroupUseCase) ──────────────────────

  Future<bool> createGroup({
    required String name,
    required String description,
    required String cityId,
    XFile? logoFile,
    XFile? coverFile,
  }) async {
    if (currentUserId == null) return false;

    _setLoading(true);
    _clearError();

    try {
      final groupId = await _createGroupUseCase(
        name: name,
        description: description,
        adminId: currentUserId!,
        cityId: cityId,
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

  // ─── Editar grupo (Use Case: EditGroupUseCase) ────────────────────────

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
      final success = await _editGroupUseCase(
        groupId: groupId,
        name: name,
        description: description,
        logoFile: logoFile,
        coverFile: coverFile,
      );

      if (success) {
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

  // ─── Seleccionar grupo (Use Case: GetGroupByIdUseCase) ───────────────

  Future<void> selectGroup(String groupId) async {
    _setLoading(true);
    try {
      _selectedGroup = await _getGroupByIdUseCase(groupId);

      if (_selectedGroup != null) {
        await _loadUsersForGroup(_selectedGroup!);
      }
    } catch (e) {
      _setError('group_error_load');
    }
    _setLoading(false);
  }

  // ─── Solicitar unirse (Use Case: JoinGroupUseCase) ────────────────────

  Future<Map<String, dynamic>> requestJoinGroup(String groupId) async {
    if (currentUserId == null) {
      return {'success': false, 'error': 'group_error_not_authenticated'};
    }

    _setLoading(true);
    _clearError();

    try {
      // 1. Validar que el usuario tenga nombre (cross-feature: UserRepository)
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

      // 2. Proceder con la solicitud via Use Case
      final success = await _joinGroupUseCase(groupId, currentUserId!);

      if (success) {
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

  // ─── Aprobar solicitud (Use Case: ApproveJoinRequestUseCase) ──────────

  Future<bool> approveJoinRequest(String groupId, String userId) async {
    if (currentUserId == null) return false;

    _setLoading(true);
    _clearError();

    try {
      final success = await _approveJoinRequestUseCase(groupId, userId);
      if (success) {
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

  // ─── Rechazar solicitud (Use Case: RejectJoinRequestUseCase) ──────────

  Future<bool> rejectJoinRequest(String groupId, String userId) async {
    if (currentUserId == null) return false;

    _setLoading(true);
    _clearError();

    try {
      final success = await _rejectJoinRequestUseCase(groupId, userId);
      if (success) {
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

  // ─── Cancelar solicitud (Use Case: CancelJoinRequestUseCase) ─────────

  Future<bool> cancelJoinRequest(String groupId) async {
    if (currentUserId == null) return false;

    _setLoading(true);
    _clearError();

    try {
      final success =
          await _cancelJoinRequestUseCase(groupId, currentUserId!);
      if (success) {
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

  // ─── Salir del grupo (Use Case: LeaveGroupUseCase) ────────────────────

  Future<bool> leaveGroup(String groupId) async {
    if (currentUserId == null) return false;

    _setLoading(true);
    _clearError();

    try {
      final success = await _leaveGroupUseCase(groupId, currentUserId!);
      if (success) {
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

  // ─── Eliminar grupo (Use Case: DeleteGroupUseCase) ────────────────────

  Future<bool> deleteGroup(String groupId) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _deleteGroupUseCase(groupId);
      if (success) {
        _allGroups.removeWhere((g) => g.id == groupId);
        _adminGroups.removeWhere((g) => g.id == groupId);
        _userGroups.removeWhere((g) => g.id == groupId);
        if (_selectedGroup?.id == groupId) _selectedGroup = null;
        notifyListeners();
      }
      _setLoading(false);
      return success;
    } catch (e) {
      _setError('group_error_delete');
      _setLoading(false);
      return false;
    }
  }

  // ─── Buscar grupos (Use Case: SearchGroupsUseCase) ────────────────────

  Future<void> searchGroups(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    try {
      _searchResults = await _searchGroupsUseCase(query);
      notifyListeners();
    } catch (e) {
      AppLogger.debug('Error buscando grupos: $e');
    }
  }

  void clearSearchResults() {
    _searchResults = [];
    notifyListeners();
  }

  // ─── Estado de membresía (lógica pura, sin repositorio) ──────────────

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

  // ─── Cache de usuarios (cross-feature: UserRepository) ────────────────

  Future<UserModel?> getUserInfo(String userId) async {
    if (_userCache.containsKey(userId)) {
      return _userCache[userId];
    }

    try {
      final user = await _userRepository.getUserById(userId);
      if (user != null) {
        _userCache[userId] = user;
      }
      return user;
    } catch (e) {
      AppLogger.debug('Error obteniendo usuario $userId: $e');
      return null;
    }
  }

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

  Future<List<Map<String, dynamic>>> getMembersWithNames(
    GroupModel group,
  ) async {
    List<Map<String, dynamic>> members = [];

    for (String userId in group.memberIds) {
      final user = await getUserInfo(userId);
      members.add({
        'userId': userId,
        'userName': user?.name ?? '',
        'userPhoto': user?.photoUrl,
        'phoneNumber': user?.phoneNumber ?? '',
        'isAdmin': group.isAdmin(userId),
        'hasName': user?.name != null && user!.name!.trim().isNotEmpty,
      });
    }

    return members;
  }

  Future<void> _loadUsersForGroup(GroupModel group) async {
    await getUserInfo(group.adminId);
    for (String memberId in group.memberIds) {
      await getUserInfo(memberId);
    }
    for (String requestId in group.pendingRequestIds) {
      await getUserInfo(requestId);
    }
  }

  void clearUserCache() {
    _userCache.clear();
  }

  // ─── Utilidades ───────────────────────────────────────────────────────

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
      AppLogger.debug('Error seleccionando imagen: $e');
      _setError('group_error_select_image');
      return null;
    }
  }

  // ─── Cross-feature: Rodadas del grupo (RideRepository) ────────────────

  Future<List<RideModel>> getRidesByGroup(GroupModel group) async {
    try {
      final stream = _rideRepository.getGroupRides(group.id);
      return await stream.first;
    } catch (e) {
      AppLogger.debug('Error obteniendo rodadas del grupo: $e');
      return [];
    }
  }

  // ─── Cross-feature: Info del admin (UserRepository) ───────────────────

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
      AppLogger.debug('Error obteniendo info del admin: $e');
      return {
        'fullName': '',
        'userName': '',
        'photo': '',
        'email': '',
        'hasName': false,
      };
    }
  }

  // ─── Métodos privados ─────────────────────────────────────────────────

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
}
