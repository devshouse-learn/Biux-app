import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:biux/core/services/app_logger.dart';

/// Servicio de configuraciÃ³n remota usando Firestore.
/// Permite configurar valores dinÃ¡micamente sin recompilar la app.
class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._internal();
  factory RemoteConfigService() => _instance;
  RemoteConfigService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic> _config = {};
  bool _isInitialized = false;

  /// Inicializa cargando la configuraciÃ³n desde Firestore
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final doc = await _firestore
          .collection('app_config')
          .doc('settings')
          .get();

      if (doc.exists) {
        _config = doc.data() ?? {};
      }
      _isInitialized = true;
      AppLogger.info('RemoteConfig cargado', tag: 'RemoteConfig');
    } on FirebaseException catch (e) {
      AppLogger.warning(
        'No se pudo cargar RemoteConfig, usando defaults',
        tag: 'RemoteConfig',
        error: e,
      );
      _isInitialized = true; // Continuar con defaults
    }
  }

  /// Obtiene la lista de telÃ©fonos admin (Firestore: app_config/settings.adminPhones)
  List<String> get adminPhones {
    final phones = _config['adminPhones'];
    if (phones is List) {
      return phones.map((e) => e.toString()).toList();
    }
    return [];
  }

  /// Verifica si un nÃºmero de telÃ©fono es admin
  bool isAdminPhone(String phone) {
    final cleaned = phone.replaceAll('+', '').replaceAll(' ', '').trim();
    return adminPhones.any((adminPhone) {
      final adminCleaned = adminPhone
          .replaceAll('+', '')
          .replaceAll(' ', '')
          .trim();
      return cleaned == adminCleaned ||
          cleaned.endsWith(adminCleaned) ||
          adminCleaned.endsWith(cleaned);
    });
  }

  /// Obtiene un valor string
  String getString(String key, {String defaultValue = ''}) {
    return _config[key]?.toString() ?? defaultValue;
  }

  /// Obtiene un valor bool
  bool getBool(String key, {bool defaultValue = false}) {
    return _config[key] as bool? ?? defaultValue;
  }

  /// Obtiene un valor int
  int getInt(String key, {int defaultValue = 0}) {
    return _config[key] as int? ?? defaultValue;
  }

  /// Verificar si una feature estÃ¡ habilitada (usa Firestore config)
  bool getFeatureFlag(String key, {bool defaultValue = true}) {
    return _config[key] as bool? ?? defaultValue;
  }

  /// Feature flags disponibles
  bool get isShopEnabled => getFeatureFlag('shop_enabled');
  bool get isWeatherEnabled =>
      getFeatureFlag('weather_enabled', defaultValue: true);
  bool get isChatEnabled => getFeatureFlag('chat_enabled', defaultValue: true);
  bool get isAchievementsEnabled =>
      getFeatureFlag('achievements_enabled', defaultValue: true);
}


