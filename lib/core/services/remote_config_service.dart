import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:biux/core/services/app_logger.dart';

/// Servicio de configuración remota usando Firestore.
/// Permite configurar valores dinámicamente sin recompilar la app.
class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._internal();
  factory RemoteConfigService() => _instance;
  RemoteConfigService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic> _config = {};
  bool _isInitialized = false;

  /// Inicializa cargando la configuración desde Firestore
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
    } catch (e) {
      AppLogger.warning(
        'No se pudo cargar RemoteConfig, usando defaults',
        tag: 'RemoteConfig',
        error: e,
      );
      _isInitialized = true; // Continuar con defaults
    }
  }

  /// Obtiene la lista de teléfonos admin (Firestore: app_config/settings.adminPhones)
  List<String> get adminPhones {
    final phones = _config['adminPhones'];
    if (phones is List) {
      return phones.map((e) => e.toString()).toList();
    }
    return [];
  }

  /// Verifica si un número de teléfono es admin
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
}
