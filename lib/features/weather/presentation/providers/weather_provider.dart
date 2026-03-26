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

  String get weatherEmoji {
    final main = _weatherData?['weather']?[0]?['main'] ?? '';
    switch (main) {
      case 'Clear':
        return '☀️';
      case 'Clouds':
        return '☁️';
      case 'Rain':
        return '🌧️';
      case 'Drizzle':
        return '🌦️';
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

  bool get isSafeToRide {
    final main = _weatherData?['weather']?[0]?['main'] ?? '';
    return main != 'Thunderstorm' && main != 'Snow' && windSpeed < 50;
  }

  String get rideAdvice {
    if (_weatherData == null) return '';
    final main = _weatherData!['weather']?[0]?['main'] ?? '';
    if (main == 'Thunderstorm')
      return 'No es seguro pedalear con tormenta eléctrica';
    if (main == 'Rain') return 'Precaución: carretera mojada, reduce velocidad';
    if (main == 'Clear' && feelsLike > 30)
      return 'Hidrátate constantemente, hace mucho calor';
    if (windSpeed > 30) return 'Viento fuerte, ten cuidado en zonas abiertas';
    if (main == 'Clear') return '¡Excelente día para rodar!';
    return 'Buen día para pedalear con precaución';
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

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
        ),
      );

      final lat = position.latitude;
      final lon = position.longitude;

      // Obtener datos climáticos completos de Open-Meteo
      final weatherUrl =
          'https://api.open-meteo.com/v1/forecast'
          '?latitude=$lat&longitude=$lon'
          '&current=temperature_2m,relative_humidity_2m,apparent_temperature,'
          'weather_code,wind_speed_10m,surface_pressure,precipitation,'
          'uv_index,visibility'
          '&hourly=temperature_2m,weather_code,precipitation_probability'
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
          'wind': {'speed': current['wind_speed_10m']},
          'uv_index': current['uv_index'] ?? 0,
          'visibility': (current['visibility'] ?? 10000) / 1000, // a km
          'precipitation': current['precipitation'] ?? 0,
          'precipitation_probability': 0,
        };

        // Parsear pronóstico horario (próximas 24h)
        _hourlyForecast = [];
        if (hourly != null) {
          final times = hourly['time'] as List? ?? [];
          final temps = hourly['temperature_2m'] as List? ?? [];
          final codes = hourly['weather_code'] as List? ?? [];
          final precProbs = hourly['precipitation_probability'] as List? ?? [];
          final now = DateTime.now();

          for (int i = 0; i < times.length && i < 24; i++) {
            final time = DateTime.tryParse(times[i] ?? '');
            if (time == null || time.isBefore(now)) continue;
            final code = (codes.length > i ? codes[i] : 0) as int;
            final info = _mapWeatherCode(code);
            _hourlyForecast.add({
              'hour': '${time.hour.toString().padLeft(2, '0')}:00',
              'temp': '${(temps.length > i ? temps[i] as num : 0).round()}°',
              'emoji': _emojiFromMain(info['main'] ?? ''),
              'precProb': precProbs.length > i ? precProbs[i] : 0,
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

  Map<String, String> _mapWeatherCode(int code) {
    if (code == 0)
      return {'main': 'Clear', 'description': 'Despejado', 'icon': '01d'};
    if (code <= 3)
      return {'main': 'Clouds', 'description': 'Nublado', 'icon': '03d'};
    if (code <= 49)
      return {'main': 'Mist', 'description': 'Niebla', 'icon': '50d'};
    if (code <= 55)
      return {'main': 'Drizzle', 'description': 'Llovizna', 'icon': '09d'};
    if (code <= 59)
      return {
        'main': 'Drizzle',
        'description': 'Llovizna intensa',
        'icon': '09d',
      };
    if (code <= 65)
      return {'main': 'Rain', 'description': 'Lluvia', 'icon': '10d'};
    if (code <= 69)
      return {'main': 'Rain', 'description': 'Lluvia intensa', 'icon': '10d'};
    if (code <= 75)
      return {'main': 'Snow', 'description': 'Nieve', 'icon': '13d'};
    if (code <= 79)
      return {'main': 'Snow', 'description': 'Granizo', 'icon': '13d'};
    if (code <= 84)
      return {'main': 'Rain', 'description': 'Aguacero', 'icon': '10d'};
    if (code <= 99)
      return {
        'main': 'Thunderstorm',
        'description': 'Tormenta eléctrica',
        'icon': '11d',
      };
    return {'main': 'Clear', 'description': 'Despejado', 'icon': '01d'};
  }
}
