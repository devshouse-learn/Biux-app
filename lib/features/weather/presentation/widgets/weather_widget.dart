import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biux/core/design_system/locale_notifier.dart';

class WeatherWidget extends StatelessWidget {
  final double? temperature;
  final String? condition;
  final int? windSpeed, humidity;
  const WeatherWidget({
    Key? key,
    this.temperature,
    this.condition,
    this.windSpeed,
    this.humidity,
  }) : super(key: key);
  String get _icon =>
      {
        'sunny': '☀️',
        'clear': '☀️',
        'cloudy': '☁️',
        'rain': '🌧️',
        'storm': '⛈️',
        'wind': '💨',
        'fog': '🌫️',
      }[condition?.toLowerCase()] ??
      '🌤️';
  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(_icon, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  temperature != null ? '${temperature!.toInt()}°C' : '--°C',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  condition ?? l.t('loading'),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          if (windSpeed != null)
            Column(
              children: [
                const Icon(Icons.air, size: 16, color: Colors.blueGrey),
                Text('$windSpeed km/h', style: const TextStyle(fontSize: 10)),
              ],
            ),
          if (humidity != null) ...[
            const SizedBox(width: 12),
            Column(
              children: [
                const Icon(Icons.water_drop, size: 16, color: Colors.blue),
                Text('$humidity%', style: const TextStyle(fontSize: 10)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
