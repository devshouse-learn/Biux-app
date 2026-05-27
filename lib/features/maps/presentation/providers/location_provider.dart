import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationProvider extends ChangeNotifier {
  Position? _currentPosition;
  bool _isLoading = false;
  String? _error;
  bool _hasPermission = false;
  bool _permissionRequested = false;

  Position? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasPermission => _hasPermission;
  bool get permissionRequested => _permissionRequested;

  /// Solicita permisos de ubicaciÃ³n solo cuando se necesite
  Future<bool> requestLocationPermission() async {
    if (_permissionRequested && _hasPermission) {
      return true;
    }

    _permissionRequested = true;
    _setLoading(true);
    _error = null;

    try {
      // Verificar si el servicio de ubicaciÃ³n estÃ¡ habilitado
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _error =
            'El servicio de ubicaciÃ³n estÃ¡ deshabilitado. ActÃ­valo en configuraciÃ³n.';
        _setLoading(false);
        return false;
      }

      // Verificar permisos actuales
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _error = 'Permisos de ubicaciÃ³n denegados';
          _setLoading(false);
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _error =
            'Permisos de ubicaciÃ³n denegados permanentemente. Ve a configuraciÃ³n para habilitarlos.';
        _setLoading(false);
        return false;
      }

      _hasPermission = true;
      _setLoading(false);
      return true;
    } on Exception catch (e) {
      _error = 'Error al solicitar permisos: $e';
      _setLoading(false);
      return false;
    }
  }

  /// Obtiene la ubicaciÃ³n actual del usuario
  Future<Position?> getCurrentLocation() async {
    if (!_hasPermission) {
      bool granted = await requestLocationPermission();
      if (!granted) return null;
    }

    _setLoading(true);
    _error = null;

    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      _currentPosition = position;
      _setLoading(false);
      return position;
    } on Exception catch (e) {
      _error = 'Error al obtener ubicaciÃ³n: $e';
      _setLoading(false);
      return null;
    }
  }

  /// Centra el mapa en la ubicaciÃ³n del usuario si tiene permisos
  Future<Position?> getLocationForMap() async {
    // Solo solicitar ubicaciÃ³n si el usuario ya estÃ¡ en el mapa
    if (_hasPermission || _permissionRequested) {
      return await getCurrentLocation();
    }

    // Si no se han solicitado permisos, devolver null para usar ubicaciÃ³n por defecto
    return null;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Reinicia el estado de permisos (Ãºtil para testing)
  void resetPermissions() {
    _hasPermission = false;
    _permissionRequested = false;
    _currentPosition = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}

