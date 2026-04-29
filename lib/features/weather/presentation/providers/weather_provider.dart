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
      ? '${(_weatherData!["main"]["temp"] as num).round()}\u00b0C'
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

  String get cyclingCondition {
    if (_weatherData == null) return "desconocido";
    final windKmh = windSpeed * 3.6;
    final gustsKmh = windGusts * 3.6;
    final main = _weatherData?["weather"]?[0]?["main"] ?? "";
    final temp = (_weatherData?["main"]?["temp"] as num?)?.toDouble() ?? 20;

    if (isFreezingCondition || main == "Thunderstorm") return "peligroso";
    if (main == "Snow" || gustsKmh > 60 || temp < 2) return "peligroso";
    if (main == "Rain" || windKmh > 40 || temp > 38) return "malo";
    if (main == "Drizzle" || windKmh > 25 || temp > 33 || humidity > 85) {
      return "regular";
    }
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
      _cyclistAlerts.add("\u26a0\ufe0f Lluvia helada - No recomendado salir");
    }
    if (main == "Thunderstorm") {
      _cyclistAlerts.add(
        "\u26c8\ufe0f Tormenta el\u00e9ctrica - Permanece en interior",
      );
    }
    if (main == "Snow") {
      _cyclistAlerts.add(
        "\u2744\ufe0f Nieve - Riesgo de ca\u00edda en piso resbaladizo",
      );
    }
    if (gustsKmh > 50) {
      _cyclistAlerts.add(
        "\u{1f4a8} R\u00e1fagas de ${gustsKmh.toInt()} km/h - Peligroso",
      );
    } else if (windKmh > 30) {
      _cyclistAlerts.add(
        "\u{1f32c}\ufe0f Viento fuerte ${windKmh.toInt()} km/h - Precauci\u00f3n",
      );
    }
    if (main == "Rain") {
      _cyclistAlerts.add(
        "\u{1f327}\ufe0f Lluvia - Piso resbaladizo, reduce velocidad",
      );
    }
    if (uvIndex > 8) {
      _cyclistAlerts.add(
        "\u2600\ufe0f UV muy alto (${uvIndex.toInt()}) - Usa protector solar",
      );
    }
    if (temp > 35) {
      _cyclistAlerts.add(
        "\u{1f321}\ufe0f Calor extremo ${temp.toInt()}\u00b0C - Hidrataci\u00f3n constante",
      );
    }
    if (temp < 5) {
      _cyclistAlerts.add(
        "\u{1f976} Temperatura baja ${temp.toInt()}\u00b0C - Abr\u00edgate bien",
      );
    }
    if (visibility < 1000) {
      _cyclistAlerts.add(
        "\u{1f32b}\ufe0f Visibilidad reducida - Usa luces y reflectores",
      );
    }
    if (precipitationProbability > 60) {
      _cyclistAlerts.add(
        "\u2614 $precipitationProbability% probabilidad de lluvia",
      );
    }
  }

  Future<void> loadWeather() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _error = "Activa la ubicaci\u00f3n en tu dispositivo para ver el clima";
        _loading = false;
        notifyListeners();
        return;
      }

      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        _error = "Se necesita permiso de ubicaci\u00f3n para mostrar el clima";
        _loading = false;
        notifyListeners();
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 10),
        ),
      );

      // Open-Meteo: gratuito, sin API key, datos completos para ciclistas
      final weatherUrl =
          "https://api.open-meteo.com/v1/forecast"
          "?latitude=${pos.latitude}&longitude=${pos.longitude}"
          "&current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,weather_code,wind_speed_10m,wind_direction_10m,wind_gusts_10m,surface_pressure"
          "&hourly=temperature_2m,precipitation_probability,precipitation,weather_code,wind_gusts_10m"
          "&daily=uv_index_max"
          "&timezone=auto&forecast_days=1";

      final res = await http.get(Uri.parse(weatherUrl));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final current = data["current"] ?? {};
        final hourly = data["hourly"] ?? {};
        final daily = data["daily"] ?? {};

        final weatherCode = (current["weather_code"] as num?)?.toInt() ?? 0;
        final weatherInfo = _weatherCodeToInfo(weatherCode);

        _weatherData = {
          "main": {
            "temp": current["temperature_2m"] ?? 0,
            "humidity": current["relative_humidity_2m"] ?? 0,
            "feels_like": current["apparent_temperature"] ?? 0,
            "pressure": current["surface_pressure"] ?? 0,
          },
          "wind": {
            "speed": ((current["wind_speed_10m"] ?? 0) as num).toDouble() / 3.6,
            "gusts": ((current["wind_gusts_10m"] ?? 0) as num).toDouble() / 3.6,
            "direction": current["wind_direction_10m"] ?? 0,
          },
          "weather": [
            {
              "main": weatherInfo["main"],
              "description": weatherInfo["description"],
            }
          ],
          "visibility": 10000,
          "is_day": (current["is_day"] ?? 1) == 1,
          "uv_index": (daily["uv_index_max"] != null &&
                  (daily["uv_index_max"] as List).isNotEmpty)
              ? daily["uv_index_max"][0]
              : 0,
          "precipitation": current["precipitation"] ?? 0,
          "precipitation_probability": 0,
        };

        // Pronostico horario
        _hourlyForecast = [];
        final times = hourly["time"] as List? ?? [];
        final temps = hourly["temperature_2m"] as List? ?? [];
        final precProbs = hourly["precipitation_probability"] as List? ?? [];
        final gusts = hourly["wind_gusts_10m"] as List? ?? [];
        final codes = hourly["weather_code"] as List? ?? [];

        final now = DateTime.now();
        int startIdx = 0;
        for (int i = 0; i < times.length; i++) {
          final t = DateTime.tryParse(times[i] ?? "");
          if (t != null && t.isAfter(now)) {
            startIdx = i;
            break;
          }
        }

        for (int i = startIdx; i < times.length && i < startIdx + 12; i++) {
          final t = DateTime.tryParse(times[i] ?? "");
          final hour = t != null ? "${t.hour}:00" : "--";
          final code = i < codes.length ? (codes[i] as num).toInt() : 0;
          _hourlyForecast.add({
            "hour": hour,
            "temp": "${(temps.length > i ? (temps[i] as num).round() : 0)}\u00b0C",
            "emoji": _weatherCodeToInfo(code)["emoji"] ?? "\u{1f321}\ufe0f",
            "precProb": precProbs.length > i ? precProbs[i] : 0,
            "gusts": gusts.length > i ? gusts[i] : 0,
          });
        }

        // Probabilidad de precipitacion maxima proximas horas
        if (precProbs.isNotEmpty) {
          int maxProb = 0;
          for (int i = startIdx; i < precProbs.length && i < startIdx + 6; i++) {
            final p = (precProbs[i] as num).toInt();
            if (p > maxProb) maxProb = p;
          }
          _weatherData!["precipitation_probability"] = maxProb;
        }

        // Geocoding inverso para nombre de ciudad
        try {
          final geoUrl =
              "https://nominatim.openstreetmap.org/reverse?lat=${pos.latitude}&lon=${pos.longitude}&format=json&zoom=10";
          final geoRes = await http.get(
            Uri.parse(geoUrl),
            headers: {"User-Agent": "BiuxApp/1.0"},
          );
          if (geoRes.statusCode == 200) {
            final geoData = jsonDecode(geoRes.body);
            _cityName = geoData["address"]?["city"] ??
                geoData["address"]?["town"] ??
                geoData["address"]?["state"] ??
                "";
          }
        } catch (_) {}

        _computeCyclistAlerts();
      } else {
        _error = "Error al obtener el clima (c\u00f3digo ${res.statusCode})";
      }
    } catch (e) {
      _error = "Error: $e";
    }

    _loading = false;
    notifyListeners();
  }

  bool get isSafeToRide {
    final c = cyclingCondition;
    return c == 'ideal' || c == 'bueno';
  }

  String get weatherEmoji {
    if (_weatherData == null) return '\u{1f321}\ufe0f';
    final main = _weatherData?['weather']?[0]?['main'] ?? '';
    switch (main) {
      case 'Clear':
        return isDay ? '\u2600\ufe0f' : '\u{1f319}';
      case 'Clouds':
        return '\u2601\ufe0f';
      case 'Rain':
        return '\u{1f327}\ufe0f';
      case 'Drizzle':
        return '\u{1f326}\ufe0f';
      case 'Thunderstorm':
        return '\u26c8\ufe0f';
      case 'Snow':
        return '\u2744\ufe0f';
      case 'Mist':
      case 'Fog':
        return '\u{1f32b}\ufe0f';
      default:
        return '\u{1f321}\ufe0f';
    }
  }

  String get uvAdvice {
    if (uvIndex >= 11) return 'UV extremo - usa ropa protectora y SPF 50+';
    if (uvIndex >= 8) return 'UV muy alto - aplica bloqueador cada hora';
    if (uvIndex >= 6) return 'UV alto - usa bloqueador SPF 30+';
    if (uvIndex >= 3) return 'UV moderado - bloqueador recomendado';
    return 'UV bajo - condiciones seguras';
  }

  String get rideAdvice {
    switch (cyclingCondition) {
      case 'ideal':
        return '\u00a1Condiciones perfectas para pedalear! \u{1f6b4}';
      case 'bueno':
        return 'Buenas condiciones, disfruta la rodada \u{1f44d}';
      case 'regular':
        return 'Condiciones aceptables, ve con precauci\u00f3n \u26a0\ufe0f';
      case 'malo':
        return 'No recomendado salir, espera mejores condiciones \u{1f327}\ufe0f';
      case 'peligroso':
        return 'Peligroso para ciclistas - permanece en interior \u26d4';
      default:
        return 'Cargando condiciones...';
    }
  }

  Map<String, String> _weatherCodeToInfo(int code) {
    if (code == 0) {
      return {"main": "Clear", "description": "Despejado", "emoji": "\u2600\ufe0f"};
    }
    if (code <= 3) {
      return {"main": "Clouds", "description": "Parcialmente nublado", "emoji": "\u26c5"};
    }
    if (code <= 49) {
      return {"main": "Fog", "description": "Niebla", "emoji": "\u{1f32b}\ufe0f"};
    }
    if (code <= 59) {
      return {"main": "Drizzle", "description": "Llovizna", "emoji": "\u{1f326}\ufe0f"};
    }
    if (code <= 69) {
      return {"main": "Rain", "description": "Lluvia", "emoji": "\u{1f327}\ufe0f"};
    }
    if (code <= 79) {
      return {"main": "Snow", "description": "Nieve", "emoji": "\u2744\ufe0f"};
    }
    if (code <= 84) {
      return {"main": "Rain", "description": "Lluvia fuerte", "emoji": "\u{1f327}\ufe0f"};
    }
    if (code <= 86) {
      return {"main": "Snow", "description": "Nevada fuerte", "emoji": "\u2744\ufe0f"};
    }
    if (code <= 90) {
      return {"main": "Rain", "description": "Aguacero", "emoji": "\u{1f327}\ufe0f"};
    }
    if (code <= 95) {
      return {"main": "Thunderstorm", "description": "Tormenta el\u00e9ctrica", "emoji": "\u26c8\ufe0f"};
    }
    if (code <= 99) {
      return {"main": "Thunderstorm", "description": "Tormenta con granizo", "emoji": "\u26c8\ufe0f"};
    }
    return {"main": "Clear", "description": "Despejado", "emoji": "\u{1f321}\ufe0f"};
  }
}
