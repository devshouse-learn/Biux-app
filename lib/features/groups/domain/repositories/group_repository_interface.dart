import 'package:image_picker/image_picker.dart';
import 'package:biux/features/groups/data/models/group_model.dart';

/// Interfaz abstracta del repositorio de grupos.
/// La capa de dominio depende de esta abstracción, no de la implementación.
abstract class GroupRepositoryInterface {
  // ─── Consultas (Streams) ──────────────────────────────────────────────
  Stream<List<GroupModel>> getGroups();
  Stream<List<GroupModel>> getUserGroups(String userId);
  Stream<List<GroupModel>> getAdminGroups(String userId);
  Stream<List<GroupModel>> getGroupsByCity(String cityId);

  // ─── Consultas (Futures) ──────────────────────────────────────────────
  Future<GroupModel?> getGroup(String groupId);
  Future<List<GroupModel>> searchGroups(String query);

  // ─── Mutaciones ───────────────────────────────────────────────────────
  Future<String?> createGroup({
    required String name,
    required String description,
    required String adminId,
    required String cityId,
    XFile? logoFile,
    XFile? coverFile,
  });

  Future<bool> updateGroup({
    required String groupId,
    String? name,
    String? description,
    XFile? logoFile,
    XFile? coverFile,
  });

  Future<bool> deleteGroup(String groupId);

  // ─── Membresía ────────────────────────────────────────────────────────
  Future<bool> requestJoinGroup(String groupId, String userId);
  Future<bool> approveJoinRequest(String groupId, String userId);
  Future<bool> rejectJoinRequest(String groupId, String userId);
  Future<bool> cancelJoinRequest(String groupId, String userId);
  Future<bool> leaveGroup(String groupId, String userId);
}
