import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:biux/features/emergency/domain/entities/emergency_contact_entity.dart';
import 'package:biux/features/emergency/data/datasources/emergency_datasource.dart';

class EmergencyProvider with ChangeNotifier {
  final EmergencyDatasource _datasource = EmergencyDatasource();

  List<EmergencyContactEntity> _contacts = [];
  bool _isLoading = false;
  bool _sosActive = false;
  String? _activeSosId;
  String? _error;

  // Ubicación en tiempo real durante SOS
  StreamSubscription<Position>? _sosPosSubscription;
  Position? _lastSosPosition;
  Timer? _sosTimer;
  int _sosCountdown = 10;
  bool _sosCountingDown = false;

  // Detección de caída
  bool _fallDetectionEnabled = false;
  DateTime? _lastFallAlert;

  List<EmergencyContactEntity> get contacts => _contacts;
  bool get isLoading => _isLoading;
  bool get sosActive => _sosActive;
  String? get error => _error;
  Position? get lastSosPosition => _lastSosPosition;
  int get sosCountdown => _sosCountdown;
  bool get sosCountingDown => _sosCountingDown;
  bool get fallDetectionEnabled => _fallDetectionEnabled;

  void toggleFallDetection(bool value) {
    _fallDetectionEnabled = value;
    notifyListeners();
  }

  /// Inicia cuenta regresiva antes de enviar SOS (permite cancelar)
  void startSosCountdown({required String userId, required String userName}) {
    _sosCountdown = 10;
    _sosCountingDown = true;
    notifyListeners();

    _sosTimer = Timer.periodic(const Duration(seconds: 1), (t) async {
      _sosCountdown--;
      notifyListeners();
      if (_sosCountdown <= 0) {
        t.cancel();
        _sosCountingDown = false;
        await _triggerSOS(userId: userId, userName: userName);
      }
    });
  }

  /// Dispara SOS inmediatamente sin countdown (usado desde botón drawer)
  Future<void> triggerSosImmediate({
    required String userId,
    required String userName,
  }) async {
    _sosCountingDown = false;
    _sosCountdown = 0;
    notifyListeners();
    await _triggerSOS(
      userId: userId,
      userName: userName,
      message: 'SOS activado desde botón rápido',
    );
  }

  void cancelSosCountdown() {
    _sosTimer?.cancel();
    _sosCountingDown = false;
    _sosCountdown = 10;
    notifyListeners();
  }

  Future<void> _triggerSOS({
    required String userId,
    required String userName,
    String? message,
  }) async {
    try {
      Position pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      _lastSosPosition = pos;

      final docRef = await FirebaseFirestore.instance
          .collection('sos_alerts')
          .add({
            'userId': userId,
            'userName': userName,
            'latitude': pos.latitude,
            'longitude': pos.longitude,
            'message': message ?? 'SOS activado desde Biux',
            'active': true,
            'createdAt': FieldValue.serverTimestamp(),
            'contacts': _contacts.map((c) => c.toMap()).toList(),
          });

      _activeSosId = docRef.id;
      _sosActive = true;
      notifyListeners();

      // Actualizar ubicación cada 30 segundos mientras SOS activo
      _sosPosSubscription =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 20,
            ),
          ).listen((p) async {
            _lastSosPosition = p;
            if (_activeSosId != null) {
              await FirebaseFirestore.instance
                  .collection('sos_alerts')
                  .doc(_activeSosId)
                  .update({
                    'latitude': p.latitude,
                    'longitude': p.longitude,
                    'lastUpdate': FieldValue.serverTimestamp(),
                  });
            }
            notifyListeners();
          });
    } catch (e) {
      _error = 'Error al enviar SOS: \$e';
      notifyListeners();
    }
  }

  /// Notificar posible caída detectada por acelerómetro
  Future<void> notifyPossibleFall({
    required String userId,
    required String userName,
  }) async {
    if (!_fallDetectionEnabled) return;
    final now = DateTime.now();
    if (_lastFallAlert != null &&
        now.difference(_lastFallAlert!).inSeconds < 30)
      return;
    _lastFallAlert = now;
    startSosCountdown(userId: userId, userName: userName);
  }

  Future<void> loadContacts(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _datasource.getContacts(userId);
      _contacts = data.map((m) => EmergencyContactEntity.fromMap(m)).toList();
    } catch (e) {
      _error = '\$e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addContact(String userId, EmergencyContactEntity contact) async {
    _contacts.add(contact);
    await _saveContacts(userId);
    notifyListeners();
  }

  Future<void> removeContact(String userId, String contactId) async {
    _contacts.removeWhere((c) => c.id == contactId);
    await _saveContacts(userId);
    notifyListeners();
  }

  Future<void> _saveContacts(String userId) async {
    try {
      await _datasource.saveContacts(
        userId,
        _contacts.map((c) => c.toMap()).toList(),
      );
    } catch (e) {
      _error = 'Error al guardar: \$e';
      notifyListeners();
    }
  }

  Future<void> sendSOS({
    required String userId,
    required String userName,
    required double latitude,
    required double longitude,
    String? message,
  }) async {
    await _triggerSOS(userId: userId, userName: userName, message: message);
  }

  Future<void> cancelSOS() async {
    _sosPosSubscription?.cancel();
    _sosTimer?.cancel();
    if (_activeSosId != null) {
      await FirebaseFirestore.instance
          .collection('sos_alerts')
          .doc(_activeSosId)
          .update({
            'active': false,
            'cancelledAt': FieldValue.serverTimestamp(),
          });
    }
    _sosActive = false;
    _sosCountingDown = false;
    _sosCountdown = 10;
    _activeSosId = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _sosPosSubscription?.cancel();
    _sosTimer?.cancel();
    super.dispose();
  }
}
