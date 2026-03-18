import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:biux/features/bikes/domain/entities/bike_entity.dart';
import 'package:biux/features/bikes/domain/entities/bike_enums.dart';
import 'package:biux/shared/widgets/optimized_network_image.dart';

/// Widget de tarjeta de bicicleta para listas y grids
class BikeCard extends StatelessWidget {
  final BikeEntity bike;
  final VoidCallback? onTap;
  final bool showStatus;
  final bool compact;

  const BikeCard({
    super.key,
    required this.bike,
    this.onTap,
    this.showStatus = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitle(),
                  const SizedBox(height: 4),
                  _buildSubtitle(),
                  if (showStatus) ...[
                    const SizedBox(height: 8),
                    _buildStatusChip(),
                  ],
                  if (!compact) ...[const SizedBox(height: 8), _buildDetails()],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: AspectRatio(
        aspectRatio: compact ? 16 / 10 : 16 / 12,
        child: OptimizedNetworkImage(
          imageUrl: bike.mainPhoto,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      '${bike.brand} ${bike.model}',
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildSubtitle() {
    return Text(
      '${bike.year} • ${bike.color} • ${bike.size}',
      style: TextStyle(fontSize: 14, color: ColorTokens.neutral70),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildStatusChip() {
    Color chipColor;
    IconData chipIcon;

    switch (bike.status) {
      case BikeStatus.active:
        chipColor = Colors.green;
        chipIcon = Icons.check_circle;
        break;
      case BikeStatus.stolen:
        chipColor = Colors.red;
        chipIcon = Icons.warning;
        break;
      case BikeStatus.recovered:
        chipColor = Colors.orange;
        chipIcon = Icons.restore;
        break;
      case BikeStatus.verified:
        chipColor = Colors.blue;
        chipIcon = Icons.verified;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(chipIcon, size: 14, color: chipColor),
          const SizedBox(width: 4),
          Text(
            bike.status.displayName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: chipColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.location_on, size: 14, color: ColorTokens.neutral70),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                bike.city,
                style: TextStyle(fontSize: 12, color: ColorTokens.neutral70),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.directions_bike, size: 14, color: ColorTokens.neutral70),
            const SizedBox(width: 4),
            Text(
              bike.type.displayName,
              style: TextStyle(fontSize: 12, color: ColorTokens.neutral70),
            ),
          ],
        ),
      ],
    );
  }
}

/// Widget de información mínima de bicicleta para vista pública
class PublicBikeCard extends StatelessWidget {
  final BikeEntity bike;

  const PublicBikeCard({super.key, required this.bike});

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.verified, color: ColorTokens.primary30, size: 24),
                const SizedBox(width: 8),
                Text(
                  l.t('bike_registered_in_biux'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ColorTokens.primary30,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '${bike.brand} ${bike.model}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoGrid() {
    return Builder(
      builder: (context) {
        final l = Provider.of<LocaleNotifier>(context, listen: false);
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    l.t('year_label'),
                    bike.year.toString(),
                  ),
                ),
                Expanded(child: _buildInfoItem(l.t('color_label'), bike.color)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildInfoItem(l.t('size_label'), bike.size)),
                Expanded(
                  child: _buildInfoItem(
                    l.t('type_label'),
                    l.t(bike.type.displayName),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoItem(l.t('city_label'), bike.city, fullWidth: true),
          ],
        );
      },
    );
  }

  Widget _buildInfoItem(String label, String value, {bool fullWidth = false}) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorTokens.neutral95,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: ColorTokens.neutral70,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
