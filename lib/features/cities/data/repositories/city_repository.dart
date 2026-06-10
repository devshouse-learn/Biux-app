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
    } on FirebaseException catch (e) {
      debugPrint('Error obteniendo ciudades: $e');
      return [];
    }
  }

  // Crear ciudad
  Future<bool> createCity(CityModel city) async {
    try {
      await _firestore.collection(_collection).add(city.toFirestore());
      return true;
    } on FirebaseException catch (e) {
      debugPrint('Error creando ciudad: $e');
      return false;
    }
  }

  // RENDIMIENTO: Chunk batch operations (max 500 per batch)
  Future<bool> createCities(List<CityModel> cities) async {
    try {
      const int batchSize = 500;

      for (int i = 0; i < cities.length; i += batchSize) {
        WriteBatch batch = _firestore.batch();
        final chunk = cities.sublist(
          i,
          (i + batchSize).clamp(0, cities.length),
        );

        for (CityModel city in chunk) {
          DocumentReference docRef = _firestore.collection(_collection).doc();
          batch.set(docRef, city.toFirestore());
        }

        await batch.commit();
      }
      return true;
    } on FirebaseException catch (e) {
      debugPrint('Error creando ciudades en lote: $e');
      return false;
    }
  }

  // Verificar si ya existen ciudades
  Future<bool> citiesExist() async {
    try {
      final snapshot = await _firestore.collection(_collection).limit(1).get();
      return snapshot.docs.isNotEmpty;
    } on FirebaseException catch (e) {
      debugPrint('Error verificando ciudades: $e');
      return false;
    }
  }
}

