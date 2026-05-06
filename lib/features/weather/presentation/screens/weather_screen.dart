import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/features/weather/presentation/providers/weather_provider.dart';
import 'package:biux/core/design_system/locale_notifier.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({Key? key}) : super(key: key);
  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  LocaleNotifier get l => Provider.of<LocaleNotifier>(context);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherProvider>().loadWeather();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? ColorTokens.neutral10 : Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: ColorTokens.primary30,
        foregroundColor: Colors.white,
        title: Text(l.t('weather_for_cyclists')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<WeatherProvider>().loadWeather(),
          ),
        ],
      ),
      body: Consumer<WeatherProvider>(
        builder: (ctx, wp, _) {
          if (wp.loading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    l.t('getting_location_weather'),
                    style: TextStyle(
                      color: isDark ? ColorTokens.neutral70 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }
          if (wp.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_off,
                      size: 64,
                      color: isDark ? ColorTokens.neutral60 : Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      wp.error!,
                      style: TextStyle(
                        color: isDark
                            ? ColorTokens.neutral80
                            : Colors.grey[700],
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => wp.loadWeather(),
                      icon: Icon(Icons.refresh),
                      label: Text(l.t('retry')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorTokens.primary30,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          if (wp.weatherData == null) {
            return Center(child: Text(l.t('loading_weather_msg')));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // === UBICACIÓN ===
                if (wp.cityName.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 18,
                          color: isDark
                              ? ColorTokens.neutral70
                              : Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            wp.cityName,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? ColorTokens.neutral80
                                  : Colors.grey[700],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                // === TARJETA PRINCIPAL DE CLIMA ===
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: wp.isSafeToRide
                          ? [const Color(0xFF1565C0), const Color(0xFF42A5F5)]
                          : [const Color(0xFF616161), const Color(0xFF9E9E9E)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: (wp.isSafeToRide ? Colors.blue : Colors.grey)
                            .withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        wp.weatherEmoji,
                        style: const TextStyle(fontSize: 72),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        wp.temperature,
                        style: const TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        wp.description,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${l.t('feels_like')} · ${wp.feelsLike.round()}°C',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.white60,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // === MÉTRICAS RÁPIDAS ===
                _metricsRow(wp, isDark),

                const SizedBox(height: 24),

                // === DETALLES ADICIONALES ===
                Row(
                  children: [
                    Expanded(
                      child: _infoCard(
                        isDark: isDark,
                        icon: Icons.wb_sunny_outlined,
                        iconColor: _uvColor(wp.uvIndex),
                        title: l.t('uv_index'),
                        value: wp.uvIndex.toStringAsFixed(1),
                        subtitle: wp.uvAdvice,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _infoCard(
                        isDark: isDark,
                        icon: Icons.water_drop_outlined,
                        iconColor: Colors.blue,
                        title: l.t('precipitation'),
                        value: '${wp.precipitationProbability}%',
                        subtitle: '${wp.precipitation} mm',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _infoCard(
                        isDark: isDark,
                        icon: Icons.visibility_outlined,
                        iconColor: Colors.teal,
                        title: l.t('visibility_label'),
                        value: '${wp.visibility.toStringAsFixed(1)} km',
                        subtitle: wp.visibility >= 10
                            ? l.t('excellent')
                            : wp.visibility >= 5
                            ? l.t('good')
                            : l.t('reduced'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _infoCard(
                        isDark: isDark,
                        icon: Icons.speed_outlined,
                        iconColor: Colors.deepPurple,
                        title: l.t('pressure'),
                        value: '${wp.pressure.round()} hPa',
                        subtitle: wp.pressure >= 1013
                            ? l.t('high')
                            : l.t('low'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // === PRONÓSTICO HORARIO ===
                if (wp.hourlyForecast.isNotEmpty) ...[
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          color: ColorTokens.primary30,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l.t('hourly_forecast'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? ColorTokens.neutral90
                              : ColorTokens.neutral10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 128,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: wp.hourlyForecast.length,
                      itemBuilder: (ctx, i) {
                        final h = wp.hourlyForecast[i];
                        return Container(
                          width: 76,
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? ColorTokens.neutral20
                                : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                h['hour'] as String,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? ColorTokens.neutral70
                                      : Colors.grey[600],
                                ),
                              ),
                              Text(
                                h['emoji'] as String,
                                style: const TextStyle(fontSize: 24),
                              ),
                              Text(
                                h['temp'] as String,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? ColorTokens.neutral100
                                      : ColorTokens.neutral10,
                                ),
                              ),
                              if ((h['precProb'] as num) > 0)
                                Text(
                                  '💧${h['precProb']}%',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.blue[400],
                                  ),
                                ),
                              // Alerta visual si hay ráfagas fuertes en esa hora
                              if ((h['gusts'] as num) >= 40)
                                Text(
                                  '💨${(h['gusts'] as num).round()}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // === CONSEJO DE RODADA ===
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: wp.isSafeToRide
                        ? Colors.green.withValues(alpha: isDark ? 0.2 : 0.1)
                        : Colors.orange.withValues(alpha: isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: wp.isSafeToRide
                          ? Colors.green.withValues(alpha: 0.3)
                          : Colors.orange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        wp.isSafeToRide
                            ? Icons.directions_bike
                            : Icons.warning_amber_rounded,
                        color: wp.isSafeToRide ? Colors.green : Colors.orange,
                        size: 36,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              wp.isSafeToRide
                                  ? l.t('good_weather_ride')
                                  : l.t('caution_cycling'),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: wp.isSafeToRide
                                    ? Colors.green[800]
                                    : Colors.orange[800],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              wp.rideAdvice,
                              style: TextStyle(
                                color: isDark
                                    ? ColorTokens.neutral70
                                    : Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // === TIPS DE CICLISMO ===
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? ColorTokens.neutral20 : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 20,
                            decoration: BoxDecoration(
                              color: ColorTokens.primary30,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            l.t('safety_recommendations'),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? ColorTokens.neutral100
                                  : ColorTokens.neutral10,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ..._getContextualTips(
                        wp,
                      ).map((tip) => _tipItem(tip, isDark)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  List<String> _getContextualTips(WeatherProvider wp) {
    final tips = <String>[];
    final main = wp.weatherData?['weather']?[0]?['main'] ?? '';

    if (wp.feelsLike > 28) tips.add(l.t('carry_water_hot'));
    if (wp.uvIndex > 3) tips.add('Usa protector solar y gafas');
    if (main == 'Rain' || main == 'Drizzle') {
      tips.add('Frena con anticipación en mojado');
      tips.add('Usa luces y ropa reflectiva');
    }
    if (wp.windSpeed > 20) tips.add('Anticipa ráfagas en zonas abiertas');
    if (wp.visibility < 5) tips.add('Usa luces delanteras y traseras');
    if (wp.feelsLike < 15) tips.add('Vístete por capas para el frío');
    if (wp.humidity > 80) tips.add(l.t('humidity_causes_fatigue'));

    // Tips generales si hay pocos contextual
    if (tips.length < 3) {
      tips.add('Revisa frenos y llantas antes de salir');
      tips.add('Lleva herramienta básica y parches');
    }
    return tips;
  }

  Color _uvColor(double uv) {
    if (uv <= 2) return Colors.green;
    if (uv <= 5) return Colors.yellow[700]!;
    if (uv <= 7) return Colors.orange;
    if (uv <= 10) return Colors.red;
    return Colors.purple;
  }

  Widget _infoCard({
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? ColorTokens.neutral20 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? ColorTokens.neutral60 : Colors.grey[500],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? ColorTokens.neutral100 : ColorTokens.neutral10,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? ColorTokens.neutral60 : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricsRow(WeatherProvider wp, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _statPill(
          Icons.water_drop_outlined,
          '${wp.humidity}%',
          l.t('humidity'),
          Color(0xFF1976D2),
          isDark,
        ),
        _statPill(
          Icons.air,
          '${wp.windSpeed.round()} km/h',
          l.t('wind'),
          const Color(0xFF0288D1),
          isDark,
        ),
        _statPill(
          Icons.storm,
          '${wp.windGusts.round()} km/h',
          l.t('gusts'),
          const Color(0xFFEF6C00),
          isDark,
        ),
        _statPill(
          Icons.explore_outlined,
          wp.windDirectionLabel,
          l.t('direction'),
          const Color(0xFF00796B),
          isDark,
        ),
      ],
    );
  }

  Widget _statPill(
    IconData icon,
    String value,
    String label,
    Color color,
    bool isDark,
  ) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.22 : 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, size: 24, color: color),
        ),
        const SizedBox(height: 7),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: isDark ? ColorTokens.neutral100 : ColorTokens.neutral10,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? ColorTokens.neutral60 : Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _tipItem(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? ColorTokens.neutral80 : ColorTokens.neutral10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
