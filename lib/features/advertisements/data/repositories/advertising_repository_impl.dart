import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:biux/features/advertisements/data/models/advertising.dart';
import 'package:biux/features/advertisements/data/repositories/advertising_repository.dart';
import 'package:biux/core/services/app_logger.dart';

/// Implementación del repositorio de publicidades usando Firestore.
///
/// Colección: `publicidades`
class AdvertisingRepositoryImpl {
  final AdvertisingRepository _repository = AdvertisingRepository();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'publicidades';

  /// Obtiene publicidades desde la API real.
  Future<List<Map<String, dynamic>>> fetchAdvertisements() async {
    try {
      final ads = await _repository.getAdvertisements();
      return ads
          .map(
            (ad) => {
              'id': ad.docId,
              'title': ad.title,
              'imageUrl': ad.photoAd,
              'url': ad.url,
              'description': ad.description,
              'textButton': ad.textButton,
            },
          )
          .toList();
    } catch (e) {
      AppLogger.warning(
        'Error obteniendo publicidades, retornando lista vacía',
        tag: 'AdvertisingRepoImpl',
        error: e,
      );
      return [];
    }
  }

  /// Obtiene un anuncio aleatorio (para mostrar en la UI).
  Future<Advertising?> getRandomAdvertisement() async {
    try {
      final ads = await _repository.getAdvertisements();
      if (ads.isEmpty) return null;
      ads.shuffle();
      return ads.first;
    } catch (e) {
      AppLogger.warning(
        'Error obteniendo anuncio aleatorio',
        tag: 'AdvertisingRepoImpl',
        error: e,
      );
      return null;
    }
  }

  /// Registra una visualización de anuncio.
  Future<void> recordImpression(String adId) async {
    try {
      final docRef = _firestore.collection(_collection).doc(adId);
      await docRef.update({'impressions': FieldValue.increment(1)});
    } catch (e) {
      AppLogger.error(
        'Error registrando impresión',
        tag: 'AdvertisingRepoImpl',
        error: e,
      );
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
      AppLogger.error(
        'Error registrando clic',
        tag: 'AdvertisingRepoImpl',
        error: e,
      );
    }
  }
}
