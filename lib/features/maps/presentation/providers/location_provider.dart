import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

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

  /// Solicita permisos de ubicación solo cuando se necesite
  Future<bool> requestLocationPermission() async {
    if (_permissionRequested && _hasPermission) {
      return true;
    }

    _permissionRequested = true;
    _setLoading(true);
    _error = null;

    try {
      // Verificar si el servicio de ubicación está habilitado
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _error =
            'El servicio de ubicación está deshabilitado. Actívalo en configuración.';
        _setLoading(false);
        return false;
      }

      // Verificar permisos actuales
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _error = 'Permisos de ubicación denegados';
          _setLoading(false);
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _error =
            'Permisos de ubicación denegados permanentemente. Ve a configuración para habilitarlos.';
        _setLoading(false);
        return false;
      }

      _hasPermission = true;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = 'Error al solicitar permisos: $e';
      _setLoading(false);
      return false;
    }
  }

  /// Obtiene la ubicación actual del usuario
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
    } catch (e) {
      _error = 'Error al obtener ubicación: $e';
      _setLoading(false);
      return null;
    }
  }

  /// Centra el mapa en la ubicación del usuario si tiene permisos
  Future<Position?> getLocationForMap() async {
    // Solo solicitar ubicación si el usuario ya está en el mapa
    if (_hasPermission || _permissionRequested) {
      return await getCurrentLocation();
    }

    // Si no se han solicitado permisos, devolver null para usar ubicación por defecto
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

  /// Reinicia el estado de permisos (útil para testing)
  void resetPermissions() {
    _hasPermission = false;
    _permissionRequested = false;
    _currentPosition = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
