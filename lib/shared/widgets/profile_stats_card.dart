import 'package:flutter/material.dart';

/// Tarjetas de estadísticas para el perfil de usuario
class ProfileStatsCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;

  const ProfileStatsCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const primaryColor = Color(0xFF16242D);
    final cardColor = color ?? primaryColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: cardColor.withValues(alpha: isDark ? 0.2 : 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: cardColor.withValues(alpha: isDark ? 0.3 : 0.1),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 22,
              color: cardColor.withValues(alpha: isDark ? 0.8 : 0.7),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : primaryColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: (isDark ? Colors.white : primaryColor).withValues(
                  alpha: 0.6,
                ),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Fila de estadísticas del perfil
class ProfileStatsRow extends StatelessWidget {
  final int rides;
  final double km;
  final int groups;
  final VoidCallback? onRidesTap;
  final VoidCallback? onKmTap;
  final VoidCallback? onGroupsTap;

  const ProfileStatsRow({
    super.key,
    required this.rides,
    required this.km,
    required this.groups,
    this.onRidesTap,
    this.onKmTap,
    this.onGroupsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: ProfileStatsCard(
              label: 'Rodadas',
              value: rides.toString(),
              icon: Icons.directions_bike_rounded,
              color: const Color(0xFF1976D2),
              onTap: onRidesTap,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ProfileStatsCard(
              label: 'Km totales',
              value: km >= 1000
                  ? '${(km / 1000).toStringAsFixed(1)}k'
                  : km.toStringAsFixed(0),
              icon: Icons.speed_rounded,
              color: const Color(0xFF388E3C),
              onTap: onKmTap,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ProfileStatsCard(
              label: 'Grupos',
              value: groups.toString(),
              icon: Icons.group_rounded,
              color: const Color(0xFFE64A19),
              onTap: onGroupsTap,
            ),
          ),
        ],
      ),
    );
  }
}
