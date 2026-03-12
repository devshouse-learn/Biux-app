
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/features/weather/presentation/providers/weather_provider.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({Key? key}) : super(key: key);
  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherProvider>().loadWeather();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTokens.neutral99,
      appBar: AppBar(
        backgroundColor: ColorTokens.primary30,
        foregroundColor: Colors.white,
        title: const Text('Clima para Ciclismo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<WeatherProvider>().loadWeather(),
          ),
        ],
      ),
      body: Consumer<WeatherProvider>(
        builder: (ctx, wp, _) {
          if (wp.loading) return const Center(child: CircularProgressIndicator());
          if (wp.error != null) {
            return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(wp.error!, style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: () => wp.loadWeather(), child: const Text('Reintentar')),
            ]));
          }
          if (wp.weatherData == null) {
            return const Center(child: Text('Cargando clima...'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Main weather card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: wp.isSafeToRide
                          ? [const Color(0xFF1565C0), const Color(0xFF42A5F5)]
                          : [const Color(0xFF616161), const Color(0xFF9E9E9E)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.blue.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 8))],
                  ),
                  child: Column(
                    children: [
                      Text(wp.weatherEmoji, style: const TextStyle(fontSize: 72)),
                      const SizedBox(height: 8),
                      Text(wp.temperature, style: const TextStyle(fontSize: 56, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text(wp.description, style: const TextStyle(fontSize: 18, color: Colors.white70)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _weatherDetail('💨', 'Viento', '${wp.windSpeed.toStringAsFixed(1)} km/h'),
                          _weatherDetail('💧', 'Humedad', '${wp.humidity}%'),
                          _weatherDetail('🌡️', 'Sensación', '${wp.feelsLike.round()}°C'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Ride advice
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: wp.isSafeToRide ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: wp.isSafeToRide ? Colors.green.withValues(alpha: 0.3) : Colors.orange.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        wp.isSafeToRide ? Icons.check_circle : Icons.warning,
                        color: wp.isSafeToRide ? Colors.green : Colors.orange,
                        size: 36,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        wp.isSafeToRide ? 'Buen clima para rodar' : 'Precaución al rodar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: wp.isSafeToRide ? Colors.green[800] : Colors.orange[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(wp.rideAdvice, style: TextStyle(color: Colors.grey[600], fontSize: 14), textAlign: TextAlign.center),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Tips card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('🚴 Consejos según el clima', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      _tipItem('Lleva siempre agua suficiente'),
                      _tipItem('Usa protector solar en días soleados'),
                      _tipItem('Con lluvia, frena con anticipación'),
                      _tipItem('Usa luces si hay poca visibilidad'),
                      _tipItem('Viste capas en clima frío'),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _weatherDetail(String emoji, String label, String value) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
      ],
    );
  }

  Widget _tipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
