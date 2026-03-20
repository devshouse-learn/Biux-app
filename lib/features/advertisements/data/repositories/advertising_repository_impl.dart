import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:biux/features/advertisements/data/models/advertising.dart';

/// Implementación del repositorio de publicidades usando Firestore.
///
/// Colección: `publicidades`
class AdvertisingRepositoryImpl {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'publicidades';

  /// Obtiene anuncios activos (con dinero > 0) de Firestore.
  Future<List<Advertising>> fetchAdvertisements({int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('money', isGreaterThan: 0.0)
          .limit(limit)
          .get();

      return snapshot.docs
          .map(
            (doc) => Advertising.fromJsonMap(json: doc.data(), docId: doc.id),
          )
          .toList();
    } catch (e) {
      throw Exception('Error obteniendo publicidades: $e');
    }
  }

  /// Obtiene un anuncio aleatorio (para mostrar en la UI).
  Future<Advertising?> getRandomAdvertisement() async {
    try {
      final ads = await fetchAdvertisements();
      if (ads.isEmpty) return null;
      ads.shuffle();
      return ads.first;
    } catch (e) {
      throw Exception('Error obteniendo anuncio aleatorio: $e');
    }
  }

  /// Registra una visualización de anuncio.
  Future<void> recordImpression(String adId) async {
    try {
      final docRef = _firestore.collection(_collection).doc(adId);
      await docRef.update({'impressions': FieldValue.increment(1)});
    } catch (e) {
      throw Exception('Error registrando impresión: $e');
    }
  }

  /// Registra un clic/apertura de anuncio y descuenta el costo.
  Future<void> recordClick(String adId) async {
    try {
      final docRef = _firestore.collection(_collection).doc(adId);
      final doc = await docRef.get();

      if (!doc.exists) {
        throw Exception('Anuncio no encontrado: $adId');
      }

      final data = doc.data()!;
      final costOpen = (data['costOpen'] as num?)?.toDouble() ?? 0.0;
      final currentMoney = (data['money'] as num?)?.toDouble() ?? 0.0;

      await docRef.update({
        'clicks': FieldValue.increment(1),
        'money': currentMoney - costOpen,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error registrando clic: $e');
    }
  }

  /// Actualiza los datos de un anuncio.
  Future<Advertising> updateAdvertisement(Advertising advertising) async {
    try {
      await _firestore.collection(_collection).doc(advertising.docId).update({
        'title': advertising.title,
        'description': advertising.description,
        'photoAd': advertising.photoAd,
        'url': advertising.url,
        'textButton': advertising.textButton,
        'costOpen': advertising.costOpen,
        'costWatch': advertising.costWatch,
        'money': advertising.money,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return advertising;
    } catch (e) {
      throw Exception('Error actualizando anuncio: $e');
    }
  }
}
