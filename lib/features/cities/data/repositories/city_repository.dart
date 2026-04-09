import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:biux/features/cities/data/models/city_model.dart';
import "package:flutter/foundation.dart";

class CityRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'cities';

  // Obtener todas las ciudades ordenadas por prioridad
  Future<List<CityModel>> getCities() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('priority')
          .orderBy('name')
          .get();

      return snapshot.docs
          .map((doc) => CityModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error obteniendo ciudades: $e');
      return [];
    }
  }

  // Crear ciudad
  Future<bool> createCity(CityModel city) async {
    try {
      await _firestore.collection(_collection).add(city.toFirestore());
      return true;
    } catch (e) {
      debugPrint('Error creando ciudad: $e');
      return false;
    }
  }

  // Crear múltiples ciudades (para el script inicial)
  Future<bool> createCities(List<CityModel> cities) async {
    try {
      WriteBatch batch = _firestore.batch();

      for (CityModel city in cities) {
        DocumentReference docRef = _firestore.collection(_collection).doc();
        batch.set(docRef, city.toFirestore());
      }

      await batch.commit();
      return true;
    } catch (e) {
      debugPrint('Error creando ciudades en lote: $e');
      return false;
    }
  }

  // Verificar si ya existen ciudades
  Future<bool> citiesExist() async {
    try {
      final snapshot = await _firestore.collection(_collection).limit(1).get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Error verificando ciudades: $e');
      return false;
    }
  }
}
