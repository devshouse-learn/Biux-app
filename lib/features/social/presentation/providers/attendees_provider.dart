import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/attendee_entity.dart';
import '../../domain/repositories/attendees_repository.dart';
// import '../../domain/repositories/notifications_repository.dart'; // ✅ Not needed - Cloud Functions handle notifications
// import '../../domain/entities/notification_entity.dart'; // ✅ Not needed - Cloud Functions handle notifications
import '../../data/datasources/attendees_firestore_adapter.dart';
import '../../../users/domain/repositories/user_repository.dart';

/// Provider para gestionar asistentes a rodadas
class AttendeesProvider extends ChangeNotifier {
  final AttendeesRepository _repository;
  // final NotificationsRepository _notificationsRepository; // ✅ Not needed - Cloud Functions handle notifications
  final AttendeesFirestoreAdapter _firestoreAdapter;
  final UserRepository? _userRepository;
  final String userId;

  // Variables para caché de datos del usuario
  String? _cachedUserName;
  String? _cachedUserPhoto;
  bool _userDataLoaded = false;

  // Track de rodadas ya sincronizadas
  final Set<String> _syncedRides = {};

  AttendeesProvider({
    required AttendeesRepository repository,
    // required NotificationsRepository notificationsRepository, // ✅ Not needed
    AttendeesFirestoreAdapter? firestoreAdapter,
    UserRepository? userRepository,
    required this.userId,
  }) : _repository = repository,
       // _notificationsRepository = notificationsRepository, // ✅ Not needed
       _firestoreAdapter = firestoreAdapter ?? AttendeesFirestoreAdapter(),
       _userRepository = userRepository;

  /// Obtiene los datos del usuario desde Firestore (se ejecuta una sola vez)
  Future<void> _loadUserData() async {
    if (_userDataLoaded) return;

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        _cachedUserName = 'Usuario';
        _cachedUserPhoto = null;
        _userDataLoaded = true;
        return;
      }

      // Obtener datos desde Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      final userData = userDoc.data();

      if (userData != null && userData.isNotEmpty) {
        String? name = userData['name'];
        String? username = userData['username'];
        String? phoneNumber = userData['phoneNumber'];

        _cachedUserName =
            (name != null && name.trim().isNotEmpty ? name : null) ??
            (username != null && username.trim().isNotEmpty
                ? username
                : null) ??
            currentUser.displayName ??
            (phoneNumber != null && phoneNumber.trim().isNotEmpty
                ? phoneNumber.replaceAll('phone_', '').replaceAll('+57', '')
                : null) ??
            currentUser.email?.split('@').first ??
            'Usuario';

        _cachedUserPhoto = userData['photoUrl'] ?? userData['photo'];
      } else {
        _cachedUserName =
            currentUser.displayName ??
            currentUser.phoneNumber
                ?.replaceAll('phone_', '')
                .replaceAll('+57', '') ??
            currentUser.email?.split('@').first ??
            'Usuario';
        _cachedUserPhoto = currentUser.photoURL;
      }

      _userDataLoaded = true;
    } catch (e) {
      debugPrint('⚠️ Error cargando datos de usuario en AttendeesProvider: $e');
      _cachedUserName = 'Usuario';
      _cachedUserPhoto = null;
      _userDataLoaded = true;
    }
  }

  bool _isJoining = false;
  bool _isLeaving = false;
  bool _isUpdating = false;
  String? _error;

  bool get isJoining => _isJoining;
  bool get isLeaving => _isLeaving;
  bool get isUpdating => _isUpdating;
  String? get error => _error;
  bool get isBusy => _isJoining || _isLeaving || _isUpdating;

  /// Unirse a una rodada
  Future<void> joinRide({
    required String rideId,
    required String rideOwnerId,
    String? fullName,
    String? bikeType,
    CyclingLevel? level,
    AttendeeStatus status = AttendeeStatus.confirmed,
  }) async {
    if (_isJoining) return;

    // Cargar datos del usuario si no están cargados
    await _loadUserData();

    try {
      _isJoining = true;
      _error = null;
      notifyListeners();

      // ⚠️ Obtener datos completos del usuario de Firestore si está disponible
      String finalUserName = _cachedUserName ?? 'Usuario';
      String? finalUserPhoto = _cachedUserPhoto;
      String? finalFullName = fullName;

      if (_userRepository != null) {
        try {
          final userEntity = await _userRepository.getUserById(userId);
          finalUserName = userEntity.userName.isNotEmpty
              ? userEntity.userName
              : _cachedUserName ?? 'Usuario';
          finalUserPhoto = userEntity.photo.isNotEmpty
              ? userEntity.photo
              : _cachedUserPhoto;
          finalFullName =
              fullName ??
              (userEntity.fullName.isNotEmpty ? userEntity.fullName : null);
        } catch (e) {
          // Si falla, usar los datos del provider
          debugPrint('⚠️ No se pudieron obtener datos del usuario: $e');
        }
      }

      await _repository.joinRide(
        rideId: rideId,
        userId: userId,
        userName: finalUserName,
        userPhoto: finalUserPhoto,
        fullName: finalFullName,
        bikeType: bikeType,
        level: level,
        status: status,
      );

      // ✅ NOTIFICATIONS NOW CREATED BY CLOUD FUNCTIONS
      // Cloud Function onRideJoinCreated handles notifications automatically
      // when a user joins a ride at: /attendees/rides/{rideId}/{userId}

      // Crear notificación solo si no es el propio usuario
      // if (rideOwnerId != userId) {
      //   // ⚠️ Asegurar que userName no esté vacío (Firebase rules lo requieren)
      //   final safeUserName = (_cachedUserName ?? '').trim().isNotEmpty
      //       ? _cachedUserName!
      //       : userId.split('_').last; // Fallback: usar parte del userId

      //   await _notificationsRepository.createNotification(
      //     userId: rideOwnerId,
      //     type: NotificationType.rideJoin,
      //     fromUserId: userId,
      //     fromUserName: safeUserName,
      //     fromUserPhoto: _cachedUserPhoto,
      //     targetType: NotificationTargetType.ride,
      //     targetId: rideId,
      //   );
      // }

      _isJoining = false;
      notifyListeners();
    } catch (e) {
      _error = 'attendees_join_error';
      _isJoining = false;
      notifyListeners();
    }
  }

  /// Actualizar estado de asistencia
  Future<void> updateStatus({
    required String rideId,
    required AttendeeStatus status,
  }) async {
    if (_isUpdating) return;

    try {
      _isUpdating = true;
      _error = null;
      notifyListeners();

      await _repository.updateAttendanceStatus(
        rideId: rideId,
        userId: userId,
        status: status,
      );

      _isUpdating = false;
      notifyListeners();
    } catch (e) {
      _error = 'attendees_update_error';
      _isUpdating = false;
      notifyListeners();
    }
  }

  /// Salir de una rodada
  Future<void> leaveRide(String rideId) async {
    if (_isLeaving) return;

    try {
      _isLeaving = true;
      _error = null;
      notifyListeners();

      await _repository.leaveRide(rideId: rideId, userId: userId);

      _isLeaving = false;
      notifyListeners();
    } catch (e) {
      _error = 'attendees_leave_error';
      _isLeaving = false;
      notifyListeners();
    }
  }

  /// Stream de asistentes
  Stream<List<AttendeeEntity>> watchAttendees(String rideId) {
    _ensureSync(rideId);
    return _repository.watchAttendees(rideId);
  }

  /// Stream del contador de confirmados
  Stream<int> watchConfirmedCount(String rideId) {
    _ensureSync(rideId);
    return _repository.watchConfirmedCount(rideId);
  }

  /// Stream para verificar si el usuario está asistiendo
  Stream<bool> watchUserIsAttending(String rideId) {
    _ensureSync(rideId);
    return _repository.watchUserIsAttending(rideId, userId);
  }

  /// Stream del estado de asistencia del usuario
  Stream<AttendeeStatus?> watchUserStatus(String rideId) {
    _ensureSync(rideId);
    return _repository.watchUserAttendanceStatus(rideId, userId);
  }

  /// Asegura que la sincronización esté activa para esta rodada
  void _ensureSync(String rideId) {
    if (!_syncedRides.contains(rideId)) {
      _firestoreAdapter.startSyncForRide(rideId);
      _syncedRides.add(rideId);
    }
  }

  /// Limpia el error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
