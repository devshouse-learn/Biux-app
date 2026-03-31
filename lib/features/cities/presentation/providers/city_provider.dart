import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/city_model.dart';
import '../../data/repositories/city_repository.dart';

class CityProvider extends ChangeNotifier {
  final CityRepository _repository = CityRepository();
  static const String _cacheKey = 'cached_cities';
  static const String _cacheTimeKey = 'cities_cache_time';
  static const int _cacheValidityHours = 24; // Caché válido por 24 horas

  List<CityModel> _cities = [];
  CityModel? _selectedCity;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<CityModel> get cities => _cities;
  CityModel? get selectedCity => _selectedCity;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Cargar ciudades con sistema de caché
  Future<void> loadCities({bool forceRefresh = false}) async {
    if (_isLoading) return;

    _setLoading(true);
    _clearError();

    try {
      // Intentar cargar desde caché primero
      if (!forceRefresh) {
        final cachedCities = await _loadFromCache();
        if (cachedCities.isNotEmpty) {
          _cities = cachedCities;
          _setLoading(false);
          debugPrint('✅ Ciudades cargadas desde caché: ${_cities.length}');
          return;
        }
      }

      // Si no hay caché válido, cargar desde Firestore
      debugPrint('🔄 Cargando ciudades desde Firestore...');
      final cities = await _repository.getCities();

      if (cities.isNotEmpty) {
        _cities = cities;
        await _saveToCache(cities);
        debugPrint('✅ Ciudades cargadas desde Firestore: ${_cities.length}');
      } else {
        _setError('No se pudieron cargar las ciudades');
      }
    } catch (e) {
      _setError('Error al cargar ciudades: ${e.toString()}');
      debugPrint('❌ Error cargando ciudades: $e');
    }

    _setLoading(false);
  }

  // Inicializar ciudades por primera vez
  Future<void> initializeCities() async {
    try {
      // Verificar si ya existen ciudades en Firestore
      final exist = await _repository.citiesExist();
      if (!exist) {
        debugPrint('🏙️ Creando ciudades iniciales...');
        await _createInitialCities();
      }

      // Cargar ciudades
      await loadCities();
    } catch (e) {
      debugPrint('❌ Error inicializando ciudades: $e');
      _setError('Error al inicializar ciudades');
    }
  }

  // Crear ciudades iniciales en Firestore
  Future<void> _createInitialCities() async {
    final initialCities = [
      CityModel(
        id: '',
        name: 'Ibagué',
        department: 'Tolima',
        isCapital: true,
        priority: 0, // Siempre primera
      ),
      CityModel(
        id: '',
        name: 'Bogotá',
        department: 'Cundinamarca',
        isCapital: true,
        priority: 1,
      ),
      CityModel(
        id: '',
        name: 'Medellín',
        department: 'Antioquia',
        isCapital: true,
        priority: 2,
      ),
      CityModel(
        id: '',
        name: 'Cali',
        department: 'Valle del Cauca',
        isCapital: true,
        priority: 3,
      ),
      CityModel(
        id: '',
        name: 'Barranquilla',
        department: 'Atlántico',
        isCapital: true,
        priority: 4,
      ),
      CityModel(
        id: '',
        name: 'Cartagena',
        department: 'Bolívar',
        isCapital: true,
        priority: 5,
      ),
      CityModel(
        id: '',
        name: 'Bucaramanga',
        department: 'Santander',
        isCapital: true,
        priority: 6,
      ),
      CityModel(
        id: '',
        name: 'Pereira',
        department: 'Risaralda',
        isCapital: true,
        priority: 7,
      ),
      CityModel(
        id: '',
        name: 'Manizales',
        department: 'Caldas',
        isCapital: true,
        priority: 8,
      ),
      CityModel(
        id: '',
        name: 'Armenia',
        department: 'Quindío',
        isCapital: true,
        priority: 9,
      ),
    ];

    final success = await _repository.createCities(initialCities);
    if (success) {
      debugPrint('✅ Ciudades iniciales creadas exitosamente');
    } else {
      throw Exception('Error creando ciudades iniciales');
    }
  }

  // Cargar ciudades desde caché local
  Future<List<CityModel>> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheTime = prefs.getInt(_cacheTimeKey) ?? 0;
      final currentTime = DateTime.now().millisecondsSinceEpoch;

      // Verificar si el caché es válido (menos de 24 horas)
      if (currentTime - cacheTime < (_cacheValidityHours * 60 * 60 * 1000)) {
        final cachedData = prefs.getString(_cacheKey);
        if (cachedData != null) {
          final List<dynamic> jsonList = json.decode(cachedData);
          return jsonList
              .map(
                (json) => CityModel.fromFirestore(
                  Map<String, dynamic>.from(json),
                  json['id'] ?? '',
                ),
              )
              .toList();
        }
      }

      return [];
    } catch (e) {
      debugPrint('❌ Error cargando caché de ciudades: $e');
      return [];
    }
  }

  // Guardar ciudades en caché local
  Future<void> _saveToCache(List<CityModel> cities) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = cities
          .map((city) => {'id': city.id, ...city.toFirestore()})
          .toList();

      await prefs.setString(_cacheKey, json.encode(jsonList));
      await prefs.setInt(_cacheTimeKey, DateTime.now().millisecondsSinceEpoch);

      debugPrint('💾 Ciudades guardadas en caché');
    } catch (e) {
      debugPrint('❌ Error guardando caché de ciudades: $e');
    }
  }

  // Seleccionar ciudad
  void selectCity(CityModel? city) {
    _selectedCity = city;
    notifyListeners();
  }

  // Limpiar caché
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      await prefs.remove(_cacheTimeKey);
      debugPrint('🗑️ Caché de ciudades limpiado');
    } catch (e) {
      debugPrint('❌ Error limpiando caché: $e');
    }
  }

  // Métodos privados
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
    notifyListeners();
  }
}
