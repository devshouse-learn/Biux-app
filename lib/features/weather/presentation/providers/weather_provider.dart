
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class WeatherProvider extends ChangeNotifier {
  Map<String, dynamic>? _weatherData;
  bool _loading = false;
  String? _error;

  Map<String, dynamic>? get weatherData => _weatherData;
  bool get loading => _loading;
  String? get error => _error;

  // Weather condition helpers
  String get temperature => _weatherData != null ? '${(_weatherData!['main']['temp'] as num).round()}°C' : '--';
  String get description => _weatherData?['weather']?[0]?['description'] ?? '';
  String get icon => _weatherData?['weather']?[0]?['icon'] ?? '01d';
  String get city => _weatherData?['name'] ?? '';
  double get windSpeed => (_weatherData?['wind']?['speed'] as num?)?.toDouble() ?? 0;
  int get humidity => (_weatherData?['main']?['humidity'] as num?)?.toInt() ?? 0;
  double get feelsLike => (_weatherData?['main']?['feels_like'] as num?)?.toDouble() ?? 0;

  String get weatherEmoji {
    final main = _weatherData?['weather']?[0]?['main'] ?? '';
    switch (main) {
      case 'Clear': return '☀️';
      case 'Clouds': return '☁️';
      case 'Rain': return '🌧️';
      case 'Drizzle': return '🌦️';
      case 'Thunderstorm': return '⛈️';
      case 'Snow': return '❄️';
      case 'Mist': case 'Fog': return '🌫️';
      default: return '🌤️';
    }
  }

  bool get isSafeToRide {
    final main = _weatherData?['weather']?[0]?['main'] ?? '';
    return main != 'Thunderstorm' && main != 'Snow' && windSpeed < 50;
  }

  String get rideAdvice {
    if (_weatherData == null) return '';
    final main = _weatherData!['weather']?[0]?['main'] ?? '';
    if (main == 'Thunderstorm') return '⚠️ No se recomienda rodar con tormenta';
    if (main == 'Rain') return '🌧️ Lleva impermeable y cuidado con el piso mojado';
    if (main == 'Clear' && feelsLike > 30) return '☀️ Lleva protector solar e hidrátate bien';
    if (windSpeed > 30) return '💨 Viento fuerte, cuidado en zonas abiertas';
    if (main == 'Clear') return '✅ Excelente día para rodar';
    return '🚴 Buen día para rodar';
  }

  Future<void> loadWeather() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
      );

      // Using Open-Meteo API (free, no API key needed)
      final url = 'https://api.open-meteo.com/v1/forecast?latitude=${position.latitude}&longitude=${position.longitude}&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m&timezone=auto';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final current = data['current'];
        
        // Map to our format
        _weatherData = {
          'main': {
            'temp': current['temperature_2m'],
            'feels_like': current['apparent_temperature'],
            'humidity': current['relative_humidity_2m'],
          },
          'weather': [_mapWeatherCode(current['weather_code'] as int)],
          'wind': {'speed': current['wind_speed_10m']},
          'name': 'Tu ubicación',
        };
      }
    } catch (e) {
      _error = 'Error al cargar el clima: $e';
      debugPrint(_error);
    }

    _loading = false;
    notifyListeners();
  }

  Map<String, String> _mapWeatherCode(int code) {
    if (code == 0) return {'main': 'Clear', 'description': 'Despejado', 'icon': '01d'};
    if (code <= 3) return {'main': 'Clouds', 'description': 'Nublado', 'icon': '03d'};
    if (code <= 49) return {'main': 'Mist', 'description': 'Niebla', 'icon': '50d'};
    if (code <= 59) return {'main': 'Drizzle', 'description': 'Llovizna', 'icon': '09d'};
    if (code <= 69) return {'main': 'Rain', 'description': 'Lluvia', 'icon': '10d'};
    if (code <= 79) return {'main': 'Snow', 'description': 'Nieve', 'icon': '13d'};
    if (code <= 84) return {'main': 'Rain', 'description': 'Lluvia fuerte', 'icon': '10d'};
    if (code <= 99) return {'main': 'Thunderstorm', 'description': 'Tormenta', 'icon': '11d'};
    return {'main': 'Clear', 'description': 'Despejado', 'icon': '01d'};
  }
}
