import 'dart:async';

class AdvertisingRepositoryImpl {
  /// IMPLEMENTADO (STUB): Devuelve anuncios de ejemplo.
  Future<List<Map<String, dynamic>>> fetchAdvertisements() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return [
      {'id': 'ad_stub_1', 'title': 'Anuncio de ejemplo', 'imageUrl': '', 'url': ''},
    ];
  }
}
