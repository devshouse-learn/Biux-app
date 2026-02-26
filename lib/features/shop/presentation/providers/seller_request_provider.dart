import 'package:flutter/foundation.dart';
import '../../domain/entities/seller_request_entity.dart';
import '../../data/datasources/seller_request_service.dart';

/// Provider para gestionar solicitudes de vendedores
class SellerRequestProvider with ChangeNotifier {
  final SellerRequestService _service = SellerRequestService();

  List<SellerRequestEntity> _requests = [];
  List<SellerRequestEntity> _pendingRequests = [];
  bool _isLoading = false;
  String? _error;
  int _pendingCount = 0;

  // Getters
  List<SellerRequestEntity> get requests => _requests;
  List<SellerRequestEntity> get pendingRequests => _pendingRequests;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get pendingCount => _pendingCount;
  bool get hasError => _error != null;

  /// Inicializa los listeners de solicitudes
  void initialize() {
    print('🔔 Inicializando SellerRequestProvider');
    _listenToPendingRequests();
    _listenToAllRequests();
    _listenToPendingCount();
  }

  /// Escucha las solicitudes pendientes
  void _listenToPendingRequests() {
    _service.getPendingRequests().listen(
      (requests) {
        _pendingRequests = requests;
        print('📋 Solicitudes pendientes actualizadas: ${requests.length}');
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        print('❌ Error escuchando solicitudes pendientes: $error');
        notifyListeners();
      },
    );
  }

  /// Escucha todas las solicitudes
  void _listenToAllRequests() {
    _service.getAllRequests().listen(
      (requests) {
        _requests = requests;
        print('📋 Todas las solicitudes actualizadas: ${requests.length}');
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        print('❌ Error escuchando todas las solicitudes: $error');
        notifyListeners();
      },
    );
  }

  /// Escucha el conteo de solicitudes pendientes
  void _listenToPendingCount() {
    _service.getPendingRequestsCount().listen((count) {
      _pendingCount = count;
      notifyListeners();
    });
  }

  /// Crea una nueva solicitud de vendedor
  Future<bool> createRequest({
    required String userId,
    required String userName,
    required String userPhoto,
    required String userEmail,
    required String message,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _service.createSellerRequest(
        userId: userId,
        userName: userName,
        userPhoto: userPhoto,
        userEmail: userEmail,
        message: message,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      print('❌ Error creando solicitud: $e');
      notifyListeners();
      return false;
    }
  }

  /// Aprueba una solicitud
  Future<bool> approveRequest({
    required String requestId,
    required String adminId,
    String? comment,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _service.approveRequest(
        requestId: requestId,
        adminId: adminId,
        comment: comment,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      print('❌ Error aprobando solicitud: $e');
      notifyListeners();
      return false;
    }
  }

  /// Rechaza una solicitud
  Future<bool> rejectRequest({
    required String requestId,
    required String adminId,
    String? comment,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _service.rejectRequest(
        requestId: requestId,
        adminId: adminId,
        comment: comment,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      print('❌ Error rechazando solicitud: $e');
      notifyListeners();
      return false;
    }
  }

  /// Elimina una solicitud
  Future<bool> deleteRequest(String requestId) async {
    try {
      await _service.deleteRequest(requestId);
      return true;
    } catch (e) {
      _error = e.toString();
      print('❌ Error eliminando solicitud: $e');
      notifyListeners();
      return false;
    }
  }

  /// Verifica si un usuario tiene solicitud pendiente
  Future<bool> hasPendingRequest(String userId) async {
    return await _service.hasPendingRequest(userId);
  }

  /// Limpia el error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
