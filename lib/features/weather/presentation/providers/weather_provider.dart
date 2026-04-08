
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

  // Alertas para ciclistas
  List<String> _cyclistAlerts = [];

  Map<String, dynamic>? get weatherData => _weatherData;
  bool get loading => _loading;
  String? get error => _error;
  String get cityName => _cityName;
  List<Map<String, dynamic>> get hourlyForecast => _hourlyForecast;
  List<String> get cyclistAlerts => _cyclistAlerts;
  bool get hasAlerts => _cyclistAlerts.isNotEmpty;

  String get temperature => _weatherData != null
      ? '\${(_weatherData!["main"]["temp"] as num).round()}Â°C'
      : "--";
  String get description => _weatherData?["weather"]?[0]?["description"] ?? "";
  double get windSpeed =>
      (_weatherData?["wind"]?["speed"] as num?)?.toDouble() ?? 0;
  double get windGusts =>
      (_weatherData?["wind"]?["gusts"] as num?)?.toDouble() ?? 0;
  int get windDirection =>
      (_weatherData?["wind"]?["direction"] as num?)?.toInt() ?? 0;
  int get humidity =>
      (_weatherData?["main"]?["humidity"] as num?)?.toInt() ?? 0;
  double get feelsLike =>
      (_weatherData?["main"]?["feels_like"] as num?)?.toDouble() ?? 0;
  double get uvIndex => (_weatherData?["uv_index"] as num?)?.toDouble() ?? 0;
  double get visibility =>
      (_weatherData?["visibility"] as num?)?.toDouble() ?? 10;
  double get pressure =>
      (_weatherData?["main"]?["pressure"] as num?)?.toDouble() ?? 0;
  int get precipitationProbability =>
      (_weatherData?["precipitation_probability"] as num?)?.toInt() ?? 0;
  double get precipitation =>
      (_weatherData?["precipitation"] as num?)?.toDouble() ?? 0;
  bool get isDay => (_weatherData?["is_day"] as bool?) ?? true;

  bool get isFreezingCondition {
    final main = _weatherData?["weather"]?[0]?["main"] ?? "";
    return main == "FreezingRain";
  }

  String get windDirectionLabel {
    final d = windDirection;
    if (d >= 337 || d < 22) return "N";
    if (d < 67) return "NE";
    if (d < 112) return "E";
    if (d < 157) return "SE";
    if (d < 202) return "S";
    if (d < 247) return "SO";
    if (d < 292) return "O";
    return "NO";
  }

  /// Condiciones de ciclismo: ideal | bueno | regular | malo | peligroso
  String get cyclingCondition {
    if (_weatherData == null) return "desconocido";
    final windKmh = windSpeed * 3.6;
    final gustsKmh = windGusts * 3.6;
    final main = _weatherData?["weather"]?[0]?["main"] ?? "";
    final temp = (_weatherData?["main"]?["temp"] as num?)?.toDouble() ?? 20;

    if (isFreezingCondition || main == "Thunderstorm") return "peligroso";
    if (main == "Snow" || gustsKmh > 60 || temp < 2) return "peligroso";
    if (main == "Rain" || windKmh > 40 || temp > 38) return "malo";
    if (main == "Drizzle" || windKmh > 25 || temp > 33 || humidity > 85) return "regular";
    if (windKmh > 15 || precipitationProbability > 40) return "bueno";
    return "ideal";
  }

  void _computeCyclistAlerts() {
    _cyclistAlerts = [];
    if (_weatherData == null) return;

    final windKmh = windSpeed * 3.6;
    final gustsKmh = windGusts * 3.6;
    final main = _weatherData?["weather"]?[0]?["main"] ?? "";
    final temp = (_weatherData?["main"]?["temp"] as num?)?.toDouble() ?? 20;

    if (isFreezingCondition) {
      _cyclistAlerts.add("âš ï¸ Lluvia helada â€” No recomendado salir");
    }
    if (main == "Thunderstorm") {
      _cyclistAlerts.add("â›ˆï¸ Tormenta elÃ©ctrica â€” Permanece en interior");
    }
    if (main == "Snow") {
      _cyclistAlerts.add("â„ï¸ Nieve â€” Riesgo de caÃ­da en piso resbaladizo");
    }
    if (gustsKmh > 50) {
      _cyclistAlerts.add("ðŸ’¨ RÃ¡fagas de \${gustsKmh.toInt()} km/h â€” Peligroso");
    } else if (windKmh > 30) {
      _cyclistAlerts.add("ðŸŒ¬ï¸ Viento fuerte \${windKmh.toInt()} km/h â€” PrecauciÃ³n");
    }
    if (main == "Rain") {
      _cyclistAlerts.add("ðŸŒ§ï¸ Lluvia â€” Piso resbaladizo, reduce velocidad");
    }
    if (uvIndex > 8) {
      _cyclistAlerts.add("â˜€ï¸ UV muy alto (\${uvIndex.toInt()}) â€” Usa protector solar");
    }
    if (temp > 35) {
      _cyclistAlerts.add("ðŸŒ¡ï¸ Calor extremo \${temp.toInt()}Â°C â€” HidrataciÃ³n constante");
    }
    if (temp < 5) {
      _cyclistAlerts.add("ðŸ¥¶ Temperatura baja \${temp.toInt()}Â°C â€” AbrÃ­gate bien");
    }
    if (visibility < 1000) {
      _cyclistAlerts.add("ðŸŒ«ï¸ Visibilidad reducida â€” Usa luces y reflectores");
    }
    if (precipitationProbability > 60) {
      _cyclistAlerts.add("â˜” \${precipitationProbability}% probabilidad de lluvia");
    }
  }

  Future<void> loadWeather() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
      );

      const apiKey = "5b8ae9b3d2804c5c9a65ccc18e4a2b1a";
      final url =
          "https://api.openweathermap.org/data/2.5/weather?lat=${pos.latitude}&lon=${pos.longitude}&appid=$apiKey&units=metric&lang=es";

      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        _weatherData = jsonDecode(res.body);
        _cityName = _weatherData?["name"] ?? "";
        _computeCyclistAlerts();
      } else {
        _error = "Error al obtener el clima";
      }
    } catch (e) {
      _error = "Error: \$e";
    }

    _loading = false;
    notifyListeners();
  }
  /// true si las condiciones son seguras para salir en bici
  bool get isSafeToRide {
    final c = cyclingCondition;
    return c == 'ideal' || c == 'bueno';
  }

  /// Emoji representativo del clima actual
  String get weatherEmoji {
    if (_weatherData == null) return 'ðŸŒ¡ï¸';
    final main = _weatherData?['weather']?[0]?['main'] ?? '';
    switch (main) {
      case 'Clear': return isDay ? 'â˜€ï¸' : 'ðŸŒ™';
      case 'Clouds': return 'â˜ï¸';
      case 'Rain': return 'ðŸŒ§ï¸';
      case 'Drizzle': return 'ðŸŒ¦ï¸';
      case 'Thunderstorm': return 'â›ˆï¸';
      case 'Snow': return 'â„ï¸';
      case 'Mist':
      case 'Fog': return 'ðŸŒ«ï¸';
      default: return 'ðŸŒ¡ï¸';
    }
  }

  /// Consejo sobre radiaciÃ³n UV para ciclistas
  String get uvAdvice {
    if (uvIndex >= 11) return 'UV extremo â€” usa ropa protectora y SPF 50+';
    if (uvIndex >= 8) return 'UV muy alto â€” aplica bloqueador cada hora';
    if (uvIndex >= 6) return 'UV alto â€” usa bloqueador SPF 30+';
    if (uvIndex >= 3) return 'UV moderado â€” bloqueador recomendado';
    return 'UV bajo â€” condiciones seguras';
  }

  /// Consejo general de rodada segÃºn condiciones
  String get rideAdvice {
    switch (cyclingCondition) {
      case 'ideal':
        return 'Â¡Condiciones perfectas para pedalear! ðŸš´';
      case 'bueno':
        return 'Buenas condiciones, disfruta la rodada ðŸ‘';
      case 'regular':
        return 'Condiciones aceptables, ve con precauciÃ³n âš ï¸';
      case 'malo':
        return 'No recomendado salir, espera mejores condiciones ðŸŒ§ï¸';
      case 'peligroso':
        return 'Peligroso para ciclistas â€” permanece en interior â›”';
      default:
        return 'Cargando condiciones...';
    }
  }

}
