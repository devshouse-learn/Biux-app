import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

class FirebaseTestSetup {
  static const _firebaseOptions = FirebaseOptions(
    apiKey: "test-api-key",
    appId: "test-app-id",
    messagingSenderId: "test-sender-id",
    projectId: "test-project-id",
    storageBucket: "test-bucket",
  );

  static bool _isInitialized = false;

  /// Inicializa Firebase para pruebas
  static Future<void> initializeFirebase() async {
    if (_isInitialized) return;

    // Inicializar Firebase con configuración de prueba
    TestWidgetsFlutterBinding.ensureInitialized();

    try {
      await Firebase.initializeApp(options: _firebaseOptions);
      _isInitialized = true;
      print('🔥 Firebase inicializado para pruebas');
    } catch (e) {
      // Ya está inicializado
      print('🔥 Firebase ya estaba inicializado: $e');
      _isInitialized = true;
    }
  }

  /// Verifica si Firebase está inicializado
  static bool get isInitialized => _isInitialized;

  /// Resetea el estado para una nueva prueba
  static void reset() {
    // Para pruebas podemos mantener Firebase inicializado
    print('🔄 Reset de Firebase para nueva prueba');
  }
}
