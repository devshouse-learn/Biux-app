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

// Repositories (para creaciÃ³n de use cases y operaciones cross-feature)
import 'package:biux/features/groups/data/repositories/group_repository.dart';
import 'package:biux/features/rides/data/repositories/ride_repository.dart';
import 'package:biux/features/users/data/repositories/user_repository.dart';

enum GroupMembershipStatus { admin, member, pending, notMember }

class GroupProvider extends ChangeNotifier {
  // Repositorios auxiliares (otros features â€” no pasan por use cases de grupos)
  final UserRepository _userRepository;
  final RideRepository _rideRepository;
  final ImagePicker _imagePicker;

  // â”€â”€â”€ Use Cases â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

  // â”€â”€â”€ Estado â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  List<GroupModel> _allGroups = [];
  List<GroupModel> _userGroups = [];
  List<GroupModel> _adminGroups = [];
  List<GroupModel> _searchResults = [];
  bool _isLoading = false;
  String? _error;
  GroupModel? _selectedGroup;
  final Map<String, UserModel> _userCache = {};

  // â”€â”€â”€ Constructor (compatible sin parÃ¡metros para main.dart) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  GroupProvider({
    GroupRepository? repository,
    UserRepository? userRepository,
    RideRepository? rideRepository,
    ImagePicker? imagePicker,
  }) : _userRepository = userRepository ?? UserRepository(),
       _rideRepository = rideRepository ?? RideRepository(),
       _imagePicker = imagePicker ?? ImagePicker(),
       _createGroupUseCase = CreateGroupUseCase(
         repository ?? GroupRepository(),
       ),
       _getGroupsUseCase = GetGroupsUseCase(repository ?? GroupRepository()),
       _joinGroupUseCase = JoinGroupUseCase(repository ?? GroupRepository()),
       _leaveGroupUseCase = LeaveGroupUseCase(repository ?? GroupRepository()),
       _deleteGroupUseCase = DeleteGroupUseCase(
         repository ?? GroupRepository(),
       ),
       _editGroupUseCase = EditGroupUseCase(repository ?? GroupRepository()),
       _getGroupByIdUseCase = GetGroupByIdUseCase(
         repository ?? GroupRepository(),
       ),
       _approveJoinRequestUseCase = ApproveJoinRequestUseCase(
         repository ?? GroupRepository(),
       ),
       _rejectJoinRequestUseCase = RejectJoinRequestUseCase(
         repository ?? GroupRepository(),
       ),
       _cancelJoinRequestUseCase = CancelJoinRequestUseCase(
         repository ?? GroupRepository(),
       ),
       _searchGroupsUseCase = SearchGroupsUseCase(
         repository ?? GroupRepository(),
       );

  // â”€â”€â”€ Getters â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

  // â”€â”€â”€ Cargar grupos (Use Case: GetGroupsUseCase) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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
        groups.sort((a, b) => b.memberIds.length.compareTo(a.memberIds.length));
        _userGroups = groups;
        notifyListeners();
      });
    }
  }

  void loadAdminGroups() {
    if (currentUserId != null) {
      _getGroupsUseCase.adminGroups(currentUserId!).listen((groups) {
        groups.sort((a, b) => b.memberIds.length.compareTo(a.memberIds.length));
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

  // â”€â”€â”€ Crear grupo (Use Case: CreateGroupUseCase) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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
    } on FirebaseException catch (e) {
      _setError('group_error_create');
      _setLoading(false);
      return false;
    }
  }

  // â”€â”€â”€ Editar grupo (Use Case: EditGroupUseCase) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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
    } on FirebaseException catch (e) {
      _setError('group_error_edit');
      _setLoading(false);
      return false;
    }
  }

  // â”€â”€â”€ Seleccionar grupo (Use Case: GetGroupByIdUseCase) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<void> selectGroup(String groupId) async {
    _setLoading(true);
    try {
      _selectedGroup = await _getGroupByIdUseCase(groupId);

      if (_selectedGroup != null) {
        await _loadUsersForGroup(_selectedGroup!);
      }
    } on FirebaseException catch (e) {
      _setError('group_error_load');
    }
    _setLoading(false);
  }

  // â”€â”€â”€ Solicitar unirse (Use Case: JoinGroupUseCase) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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
    } on FirebaseException catch (e) {
      _setError('group_error_request_join');
      _setLoading(false);
      return {'success': false, 'error': e.toString()};
    }
  }

  // â”€â”€â”€ Aprobar solicitud (Use Case: ApproveJoinRequestUseCase) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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
    } on FirebaseException catch (e) {
      _setError('group_error_approve');
      _setLoading(false);
      return false;
    }
  }

  // â”€â”€â”€ Rechazar solicitud (Use Case: RejectJoinRequestUseCase) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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
    } on FirebaseException catch (e) {
      _setError('group_error_reject');
      _setLoading(false);
      return false;
    }
  }

  // â”€â”€â”€ Cancelar solicitud (Use Case: CancelJoinRequestUseCase) â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<bool> cancelJoinRequest(String groupId) async {
    if (currentUserId == null) return false;

    _setLoading(true);
    _clearError();

    try {
      final success = await _cancelJoinRequestUseCase(groupId, currentUserId!);
      if (success) {
        if (_selectedGroup?.id == groupId) {
          await selectGroup(groupId);
        }
      }
      _setLoading(false);
      return success;
    } on FirebaseException catch (e) {
      _setError('group_error_cancel_request');
      _setLoading(false);
      return false;
    }
  }

  // â”€â”€â”€ Salir del grupo (Use Case: LeaveGroupUseCase) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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
    } on FirebaseException catch (e) {
      _setError('group_error_leave');
      _setLoading(false);
      return false;
    }
  }

  // â”€â”€â”€ Eliminar grupo (Use Case: DeleteGroupUseCase) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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
    } on FirebaseException catch (e) {
      _setError('group_error_delete');
      _setLoading(false);
      return false;
    }
  }

  // â”€â”€â”€ Buscar grupos (Use Case: SearchGroupsUseCase) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<void> searchGroups(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    try {
      _searchResults = await _searchGroupsUseCase(query);
      notifyListeners();
    } on FirebaseException catch (e) {
      AppLogger.debug('Error buscando grupos: $e');
    }
  }

  void clearSearchResults() {
    _searchResults = [];
    notifyListeners();
  }

  // â”€â”€â”€ Estado de membresÃ­a (lÃ³gica pura, sin repositorio) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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

  // â”€â”€â”€ Cache de usuarios (cross-feature: UserRepository) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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
    } on FirebaseException catch (e) {
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

  // â”€â”€â”€ Utilidades â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<XFile?> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      return image;
    } on FirebaseException catch (e) {
      AppLogger.debug('Error seleccionando imagen: $e');
      _setError('group_error_select_image');
      return null;
    }
  }

  // â”€â”€â”€ Cross-feature: Rodadas del grupo (RideRepository) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<List<RideModel>> getRidesByGroup(GroupModel group) async {
    try {
      final stream = _rideRepository.getGroupRides(group.id);
      return await stream.first;
    } on FirebaseException catch (e) {
      AppLogger.debug('Error obteniendo rodadas del grupo: $e');
      return [];
    }
  }

  // â”€â”€â”€ Cross-feature: Info del admin (UserRepository) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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
    } on FirebaseException catch (e) {
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

  // â”€â”€â”€ MÃ©todos privados â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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

  /// Total de miembros del grupo seleccionado
  int get selectedGroupMemberCount {
    final g = selectedGroup;
    if (g == null) return 0;
    return g.memberIds.length + 1; // +1 admin
  }
}

