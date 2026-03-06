
import 'package:flutter/foundation.dart';
import 'package:biux/features/emergency/domain/entities/emergency_contact_entity.dart';
import 'package:biux/features/emergency/data/datasources/emergency_datasource.dart';

class EmergencyProvider with ChangeNotifier {
  final EmergencyDatasource _datasource = EmergencyDatasource();

  List<EmergencyContactEntity> _contacts = [];
  bool _isLoading = false;
  bool _sosActive = false;
  String? _activeSosId;
  String? _error;

  List<EmergencyContactEntity> get contacts => _contacts;
  bool get isLoading => _isLoading;
  bool get sosActive => _sosActive;
  String? get error => _error;

  Future<void> loadContacts(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _datasource.getContacts(userId);
      _contacts = data.map((m) => EmergencyContactEntity.fromMap(m)).toList();
    } catch (e) {
      _error = 'Error: \$e';
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
      await _datasource.saveContacts(userId, _contacts.map((c) => c.toMap()).toList());
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
    try {
      await _datasource.sendSOS(userId,
        userName: userName,
        latitude: latitude,
        longitude: longitude,
        message: message,
      );
      _sosActive = true;
      notifyListeners();
    } catch (e) {
      _error = 'Error al enviar SOS: \$e';
      notifyListeners();
    }
  }

  Future<void> cancelSOS() async {
    if (_activeSosId != null) {
      await _datasource.cancelSOS(_activeSosId!);
    }
    _sosActive = false;
    _activeSosId = null;
    notifyListeners();
  }
}
