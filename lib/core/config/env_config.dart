/// Configuración centralizada de claves de API.
///
/// Los valores pueden sobreescribirse en tiempo de compilación con `--dart-define`:
/// ```
/// flutter run --dart-define=MAPS_API_KEY=<otra_clave>
/// ```
///
/// La API key de Maps también se configura a nivel nativo en
/// AndroidManifest.xml y AppDelegate.swift; aquí se centraliza para las
/// llamadas HTTP de Dart (Directions, Places, Geocode, Static Maps).
class EnvConfig {
  EnvConfig._();

  /// Google Maps API key (Directions, Places, Geocode, Static Maps).
  static const String mapsApiKey = String.fromEnvironment(
    'MAPS_API_KEY',
    defaultValue: 'AIzaSyDiMK4kwhaIkuMxAcioRonPzaozDRJtO20',
  );

  /// PayU API Login.
  static const String payuApiLogin = String.fromEnvironment(
    'PAYU_API_LOGIN',
    defaultValue: 'pRRXKOl8ikMmt9u',
  );

  /// PayU API Key.
  static const String payuApiKey = String.fromEnvironment(
    'PAYU_API_KEY',
    defaultValue: '4Vj8eK4rloUd272L48hsrarnUA',
  );
}
