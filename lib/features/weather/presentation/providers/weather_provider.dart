import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class WeatherProvider extends ChangeNotifier {
  Map<String, dynamic>? _weatherData;
  bool _loading = false;
  String? _error;
  String _cityName = '';
  List<Map<String, dynamic>> _hourlyForecast = [];

  Map<String, dynamic>? get weatherData => _weatherData;
  bool get loading => _loading;
  String? get error => _error;
  String get cityName => _cityName;
  List<Map<String, dynamic>> get hourlyForecast => _hourlyForecast;

  String get temperature => _weatherData != null
      ? '${(_weatherData!['main']['temp'] as num).round()}°C'
      : '--';
  String get description => _weatherData?['weather']?[0]?['description'] ?? '';
  double get windSpeed =>
      (_weatherData?['wind']?['speed'] as num?)?.toDouble() ?? 0;

  /// Ráfagas de viento (km/h) — más peligrosas que el viento sostenido para ciclistas
  double get windGusts =>
      (_weatherData?['wind']?['gusts'] as num?)?.toDouble() ?? 0;

  /// Dirección del viento en grados (0=Norte, 90=Este, 180=Sur, 270=Oeste)
  int get windDirection =>
      (_weatherData?['wind']?['direction'] as num?)?.toInt() ?? 0;
  int get humidity =>
      (_weatherData?['main']?['humidity'] as num?)?.toInt() ?? 0;
  double get feelsLike =>
      (_weatherData?['main']?['feels_like'] as num?)?.toDouble() ?? 0;
  double get uvIndex => (_weatherData?['uv_index'] as num?)?.toDouble() ?? 0;
  double get visibility =>
      (_weatherData?['visibility'] as num?)?.toDouble() ?? 10;
  double get pressure =>
      (_weatherData?['main']?['pressure'] as num?)?.toDouble() ?? 0;
  int get precipitationProbability =>
      (_weatherData?['precipitation_probability'] as num?)?.toInt() ?? 0;
  double get precipitation =>
      (_weatherData?['precipitation'] as num?)?.toDouble() ?? 0;
  bool get isDay => (_weatherData?['is_day'] as bool?) ?? true;

  /// Condición de lluvia o llovizna helada — extremadamente peligrosa para ciclistas
  bool get isFreezingCondition {
    final main = _weatherData?['weather']?[0]?['main'] ?? '';
    return main == 'FreezingRain';
  }

  /// Denominación legible de la dirección del viento
  String get windDirectionLabel {
    final d = windDirection;
    if (d >= 337 || d < 22) return 'N';
    if (d < 67) return 'NE';
    if (d < 112) return 'E';
    if (d < 157) return 'SE';
    if (d < 202) return 'S';
    if (d < 247) return 'SO';
    if (d < 292) return 'O';
    return 'NO';
  }

  String get weatherEmoji {
    final main = _weatherData?['weather']?[0]?['main'] ?? '';
    switch (main) {
      case 'Clear':
        return isDay ? '☀️' : '🌙';
      case 'Clouds':
        return '☁️';
      case 'Rain':
        return '🌧️';
      case 'Drizzle':
        return '🌦️';
      case 'FreezingRain':
        return '🌨️';
      case 'Thunderstorm':
        return '⛈️';
      case 'Snow':
        return '❄️';
      case 'Mist':
      case 'Fog':
        return '🌫️';
      default:
        return '🌤️';
    }
  }

  /// Determina si las condiciones son seguras para rodar en bicicleta.
  /// Criterios conservadores pensados para proteger la salud y vida del ciclista.
  bool get isSafeToRide {
    final main = _weatherData?['weather']?[0]?['main'] ?? '';
    if (main == 'Thunderstorm') return false;
    if (main == 'Snow') return false;
    if (main == 'FreezingRain') return false; // lluvia/llovizna helada
    if (windSpeed >= 40) return false; // viento sostenido muy fuerte
    if (windGusts >= 55) return false; // ráfagas peligrosas
    if (visibility < 1.0) return false; // visibilidad crítica
    return true;
  }

  /// Primer consejo de seguridad priorizando la condición más peligrosa presente.
  String get rideAdvice {
    if (_weatherData == null) return '';
    final main = _weatherData!['weather']?[0]?['main'] ?? '';

    // Condiciones que impiden pedalear con seguridad
    if (main == 'Thunderstorm')
      return '⛈️ PELIGRO: Tormenta eléctrica. No salgas a rodar.';
    if (main == 'FreezingRain')
      return '🧊 PELIGRO: Lluvia helada. La calzada puede estar congelada.';
    if (main == 'Snow')
      return '❄️ PELIGRO: Nieve en calzada, alta probabilidad de caída.';
    if (windGusts >= 55)
      return '💨 PELIGRO: Ráfagas de ${windGusts.round()} km/h. Riesgo de caída.';
    if (windSpeed >= 40)
      return '💨 PELIGRO: Viento sostenido de ${windSpeed.round()} km/h. No es seguro.';
    if (visibility < 1.0)
      return '🌫️ PELIGRO: Visibilidad menor a 1 km. No salgas sin luces potentes.';

    // Advertencias importantes
    if (windGusts >= 40)
      return '💨 Ráfagas de hasta ${windGusts.round()} km/h. Precaución en zonas expuestas.';
    if (main == 'Rain' && precipitation >= 5)
      return '🌧️ Lluvia intensa (${precipitation} mm). Frena con más anticipación.';
    if (main == 'Rain')
      return '🌧️ Carretera mojada. Reduce velocidad y distancia de frenado.';
    if (main == 'Drizzle')
      return '🌦️ Llovizna: superficie resbaladiza, especialmente en pintura y rejillas.';
    if (visibility < 3.0)
      return '🌫️ Visibilidad reducida (${visibility.toStringAsFixed(1)} km). Usa luces y ropa reflectante.';
    if (feelsLike >= 35)
      return '🥵 Sensación de ${feelsLike.round()}°C. Hidrátate cada 15-20 min, busca sombra.';
    if (feelsLike >= 30)
      return '☀️ Calor intenso. Bebe agua con electrolitos y usa protector solar.';
    if (uvIndex >= 8)
      return '☀️ UV ${uvAdvice} (${uvIndex.toStringAsFixed(1)}). Usa protector solar SPF 50+.';
    if (feelsLike <= 5)
      return '🥶 Temperatura muy baja. Abrígate bien, los músculos fríos se lesionan más.';
    if (windSpeed >= 25)
      return '💨 Viento moderado-fuerte desde el $windDirectionLabel. Espera mayor esfuerzo.';

    // Sin alertas
    if (main == 'Clear' && feelsLike < 30)
      return '✅ Condiciones ideales. ¡Disfruta la rodada!';
    return '✅ Buen momento para pedalear. Lleva siempre agua e identificación.';
  }

  String get uvAdvice {
    if (uvIndex <= 2) return 'Bajo';
    if (uvIndex <= 5) return 'Moderado';
    if (uvIndex <= 7) return 'Alto';
    if (uvIndex <= 10) return 'Muy alto';
    return 'Extremo';
  }

  Future<void> loadWeather() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      // Verificar y solicitar permisos de ubicación
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _error = 'Activa los servicios de ubicación para ver el clima';
        _loading = false;
        notifyListeners();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _error = 'Se necesita permiso de ubicación para mostrar el clima';
          _loading = false;
          notifyListeners();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _error =
            'Permiso de ubicación denegado permanentemente. Habilítalo en Configuración';
        _loading = false;
        notifyListeners();
        return;
      }

      // LocationAccuracy.best usa GPS de alta precisión — fundamental para
      // obtener datos climáticos hiperlocales y proteger al ciclista.
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
        ),
      );

      final lat = position.latitude;
      final lon = position.longitude;

      // Obtener datos climáticos completos de Open-Meteo.
      // Se incluyen ráfagas de viento (wind_gusts_10m) y dirección (wind_direction_10m)
      // porque son factores críticos de seguridad para ciclistas.
      final weatherUrl =
          'https://api.open-meteo.com/v1/forecast'
          '?latitude=$lat&longitude=$lon'
          '&current=temperature_2m,relative_humidity_2m,apparent_temperature,'
          'weather_code,wind_speed_10m,wind_gusts_10m,wind_direction_10m,'
          'surface_pressure,precipitation,uv_index,visibility,is_day,snowfall'
          '&hourly=temperature_2m,weather_code,precipitation_probability,'
          'wind_speed_10m,wind_gusts_10m'
          '&forecast_hours=24'
          '&timezone=auto';

      // Obtener nombre de ciudad con geocoding inverso (Nominatim/OSM, gratuito)
      final reverseGeoUrl =
          'https://nominatim.openstreetmap.org/reverse'
          '?lat=$lat&lon=$lon&format=json&accept-language=es';

      final responses = await Future.wait([
        http.get(Uri.parse(weatherUrl)),
        http.get(
          Uri.parse(reverseGeoUrl),
          headers: {'User-Agent': 'BiuxApp/1.0'},
        ),
      ]);

      final weatherResponse = responses[0];
      final geoResponse = responses[1];

      if (weatherResponse.statusCode == 200) {
        final data = json.decode(weatherResponse.body);
        final current = data['current'];
        final hourly = data['hourly'];

        final weatherInfo = _mapWeatherCode(current['weather_code'] as int);

        _weatherData = {
          'main': {
            'temp': current['temperature_2m'],
            'feels_like': current['apparent_temperature'],
            'humidity': current['relative_humidity_2m'],
            'pressure': current['surface_pressure'],
          },
          'weather': [weatherInfo],
          'wind': {
            'speed': current['wind_speed_10m'],
            'gusts': current['wind_gusts_10m'] ?? 0,
            'direction': current['wind_direction_10m'] ?? 0,
          },
          'uv_index': current['uv_index'] ?? 0,
          'visibility': (current['visibility'] ?? 10000) / 1000, // a km
          'precipitation': current['precipitation'] ?? 0,
          'precipitation_probability': 0,
          'is_day': (current['is_day'] as num?)?.toInt() == 1,
        };

        // Parsear pronóstico horario (próximas 24h)
        _hourlyForecast = [];
        if (hourly != null) {
          final times = hourly['time'] as List? ?? [];
          final temps = hourly['temperature_2m'] as List? ?? [];
          final codes = hourly['weather_code'] as List? ?? [];
          final precProbs = hourly['precipitation_probability'] as List? ?? [];
          final hourlyGusts = hourly['wind_gusts_10m'] as List? ?? [];
          final now = DateTime.now();

          for (int i = 0; i < times.length && i < 24; i++) {
            final time = DateTime.tryParse(times[i] ?? '');
            if (time == null || time.isBefore(now)) continue;
            final code = (codes.length > i ? codes[i] : 0) as int;
            final info = _mapWeatherCode(code);
            final gust = hourlyGusts.length > i
                ? (hourlyGusts[i] as num).toDouble()
                : 0.0;
            _hourlyForecast.add({
              'hour': '${time.hour.toString().padLeft(2, '0')}:00',
              'temp': '${(temps.length > i ? temps[i] as num : 0).round()}°',
              'emoji': _emojiFromMain(info['main'] ?? ''),
              'precProb': precProbs.length > i ? precProbs[i] : 0,
              'gusts': gust,
            });
          }

          // Actualizar probabilidad de precipitación con la hora actual
          if (precProbs.isNotEmpty) {
            // Encontrar la hora más cercana al ahora
            for (int i = 0; i < times.length; i++) {
              final t = DateTime.tryParse(times[i] ?? '');
              if (t != null &&
                  t.isAfter(now.subtract(const Duration(minutes: 30)))) {
                _weatherData!['precipitation_probability'] = precProbs[i];
                break;
              }
            }
          }
        }
      }

      // Parsear nombre de ciudad
      if (geoResponse.statusCode == 200) {
        final geoData = json.decode(geoResponse.body);
        final city =
            geoData['address']?['city'] ??
            geoData['address']?['town'] ??
            geoData['address']?['village'] ??
            geoData['address']?['municipality'] ??
            '';
        final state = geoData['address']?['state'] ?? '';
        _cityName = city.isNotEmpty
            ? (state.isNotEmpty ? '$city, $state' : city)
            : 'Tu ubicación';
      } else {
        _cityName = 'Tu ubicación';
      }
    } catch (e) {
      _error = 'Error al cargar el clima. Verifica tu conexión';
      debugPrint('WeatherProvider error: $e');
    }

    _loading = false;
    notifyListeners();
  }

  String _emojiFromMain(String main) {
    switch (main) {
      case 'Clear':
        return '☀️';
      case 'Clouds':
        return '☁️';
      case 'Rain':
        return '🌧️';
      case 'Drizzle':
        return '🌦️';
      case 'FreezingRain':
        return '🌨️';
      case 'Thunderstorm':
        return '⛈️';
      case 'Snow':
        return '❄️';
      case 'Mist':
      case 'Fog':
        return '🌫️';
      default:
        return '🌤️';
    }
  }

  /// Mapeo completo de códigos meteorológicos WMO usados por Open-Meteo.
  /// Referencia: https://open-meteo.com/en/docs#weathervariables
  Map<String, String> _mapWeatherCode(int code) {
    switch (code) {
      case 0:
        return {
          'main': 'Clear',
          'description': 'Cielo despejado',
          'icon': '01d',
        };
      case 1:
        return {
          'main': 'Clear',
          'description': 'Mayormente despejado',
          'icon': '01d',
        };
      case 2:
        return {
          'main': 'Clouds',
          'description': 'Parcialmente nublado',
          'icon': '02d',
        };
      case 3:
        return {
          'main': 'Clouds',
          'description': 'Cielo cubierto',
          'icon': '04d',
        };
      case 45:
        return {'main': 'Fog', 'description': 'Niebla', 'icon': '50d'};
      case 48:
        return {'main': 'Fog', 'description': 'Niebla densa', 'icon': '50d'};
      case 51:
        return {'main': 'Drizzle', 'description': 'Lluvia fina', 'icon': '09d'};
      case 53:
        return {
          'main': 'Drizzle',
          'description': 'Lluvia fina moderada',
          'icon': '09d',
        };
      case 55:
        return {
          'main': 'Drizzle',
          'description': 'Lluvia fina persistente',
          'icon': '09d',
        };
      // ⚠️ Lluvia helada — PELIGROSA para ciclistas (calzada congelada)
      case 56:
        return {
          'main': 'FreezingRain',
          'description': 'Lluvia helada',
          'icon': '13d',
        };
      case 57:
        return {
          'main': 'FreezingRain',
          'description': 'Lluvia helada intensa',
          'icon': '13d',
        };
      case 61:
        return {'main': 'Rain', 'description': 'Lluvia ligera', 'icon': '10d'};
      case 63:
        return {
          'main': 'Rain',
          'description': 'Lluvia moderada',
          'icon': '10d',
        };
      case 65:
        return {'main': 'Rain', 'description': 'Lluvia fuerte', 'icon': '10d'};
      // ⚠️ Lluvia helada — PELIGROSA para ciclistas
      case 66:
        return {
          'main': 'FreezingRain',
          'description': 'Lluvia helada',
          'icon': '13d',
        };
      case 67:
        return {
          'main': 'FreezingRain',
          'description': 'Lluvia helada fuerte',
          'icon': '13d',
        };
      case 71:
        return {'main': 'Snow', 'description': 'Nieve ligera', 'icon': '13d'};
      case 73:
        return {'main': 'Snow', 'description': 'Nieve moderada', 'icon': '13d'};
      case 75:
        return {'main': 'Snow', 'description': 'Nieve intensa', 'icon': '13d'};
      case 77:
        return {'main': 'Snow', 'description': 'Aguanieve', 'icon': '13d'};
      case 80:
        return {'main': 'Rain', 'description': 'Lluvia leve', 'icon': '10d'};
      case 81:
        return {
          'main': 'Rain',
          'description': 'Lluvia moderada',
          'icon': '10d',
        };
      case 82:
        return {'main': 'Rain', 'description': 'Lluvia fuerte', 'icon': '10d'};
      // ✅ Correctamente diferenciado de tormentas eléctricas
      case 85:
        return {'main': 'Snow', 'description': 'Nevada ligera', 'icon': '13d'};
      case 86:
        return {'main': 'Snow', 'description': 'Nevada fuerte', 'icon': '13d'};
      case 95:
        return {
          'main': 'Thunderstorm',
          'description': 'Tormenta eléctrica',
          'icon': '11d',
        };
      case 96:
        return {
          'main': 'Thunderstorm',
          'description': 'Tormenta con granizo',
          'icon': '11d',
        };
      case 99:
        return {
          'main': 'Thunderstorm',
          'description': 'Tormenta severa con granizo',
          'icon': '11d',
        };
      default:
        if (code <= 3)
          return {
            'main': 'Clouds',
            'description': 'Cielo cubierto',
            'icon': '03d',
          };
        if (code <= 49)
          return {'main': 'Fog', 'description': 'Niebla', 'icon': '50d'};
        if (code <= 59)
          return {
            'main': 'Drizzle',
            'description': 'Lluvia fina',
            'icon': '09d',
          };
        if (code <= 69)
          return {'main': 'Rain', 'description': 'Lluvia', 'icon': '10d'};
        if (code <= 79)
          return {'main': 'Snow', 'description': 'Nieve', 'icon': '13d'};
        if (code <= 84)
          return {
            'main': 'Rain',
            'description': 'Lluvia fuerte',
            'icon': '10d',
          };
        if (code <= 86)
          return {'main': 'Snow', 'description': 'Nevada', 'icon': '13d'};
        return {
          'main': 'Thunderstorm',
          'description': 'Tormenta eléctrica',
          'icon': '11d',
        };
    }
  }
}
