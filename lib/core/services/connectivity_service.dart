import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:biux/core/services/app_logger.dart';

/// Estado de conectividad
enum ConnectivityStatus { online, offline, checking }

/// Servicio que monitorea la conectividad a internet.
/// Usa polling ligero contra DNS para detectar estado real de red.
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final _controller = StreamController<ConnectivityStatus>.broadcast();
  Timer? _pollingTimer;
  ConnectivityStatus _status = ConnectivityStatus.checking;
  bool _isInitialized = false;

  /// Stream de cambios de conectividad
  Stream<ConnectivityStatus> get statusStream => _controller.stream;

  /// Estado actual
  ConnectivityStatus get status => _status;

  /// Si hay conexión
  bool get isOnline => _status == ConnectivityStatus.online;

  /// Inicializa el monitoreo de conectividad
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    // Check inicial
    await _checkConnectivity();

    // Polling cada 15 segundos
    _pollingTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _checkConnectivity();
    });
  }

  /// Verifica manualmente la conectividad
  Future<bool> checkNow() async {
    await _checkConnectivity();
    return isOnline;
  }

  Future<void> _checkConnectivity() async {
    if (kIsWeb) {
      _updateStatus(ConnectivityStatus.online);
      return;
    }

    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 5));
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        _updateStatus(ConnectivityStatus.online);
      } else {
        _updateStatus(ConnectivityStatus.offline);
      }
    } on SocketException catch (_) {
      _updateStatus(ConnectivityStatus.offline);
    } on TimeoutException catch (_) {
      _updateStatus(ConnectivityStatus.offline);
    } catch (_) {
      _updateStatus(ConnectivityStatus.offline);
    }
  }

  void _updateStatus(ConnectivityStatus newStatus) {
    if (_status != newStatus) {
      final oldStatus = _status;
      _status = newStatus;
      _controller.add(newStatus);

      if (newStatus == ConnectivityStatus.online &&
          oldStatus == ConnectivityStatus.offline) {
        AppLogger.info('Conexión restaurada', tag: 'Connectivity');
      } else if (newStatus == ConnectivityStatus.offline) {
        AppLogger.warning('Sin conexión a internet', tag: 'Connectivity');
      }
    }
  }

  void dispose() {
    _pollingTimer?.cancel();
    _controller.close();
  }
}
