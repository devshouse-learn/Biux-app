import 'dart:async';
import 'package:biux/features/advertisements/data/repositories/advertising_repository.dart';
import 'package:biux/core/services/app_logger.dart';

class AdvertisingRepositoryImpl {
  final AdvertisingRepository _repository = AdvertisingRepository();

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
}
