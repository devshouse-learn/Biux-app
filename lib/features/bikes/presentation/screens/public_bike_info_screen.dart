import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:biux/features/bikes/presentation/providers/bike_provider.dart';
import 'package:biux/features/bikes/domain/entities/bike_entity.dart';
import 'package:biux/features/bikes/domain/entities/bike_enums.dart';
import 'package:biux/shared/widgets/optimized_network_image.dart';

/// Pantalla pública de información de bicicleta accesible por QR
/// Muestra información básica sin datos personales
class PublicBikeInfoScreen extends StatefulWidget {
  final String qrCode;

  const PublicBikeInfoScreen({super.key, required this.qrCode});

  @override
  State<PublicBikeInfoScreen> createState() => _PublicBikeInfoScreenState();
}

class _PublicBikeInfoScreenState extends State<PublicBikeInfoScreen> {
  bool _isLoading = true;
  BikeEntity? _bike;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBikeByQR();
  }

  Future<void> _loadBikeByQR() async {
    try {
      final bikeProvider = context.read<BikeProvider>();
      await bikeProvider.getBikeByQRCode(widget.qrCode);

      if (mounted) {
        setState(() {
          _bike = bikeProvider.publicBike;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'could_not_load_bike_info';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildErrorView()
          : _bike != null
          ? _buildBikeView()
          : _buildNotFoundView(),
    );
  }

  Widget _buildErrorView() {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              l.t(_error!),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorTokens.primary30,
              ),
              child: Text(l.t('go_back')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundView() {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: ColorTokens.neutral70),
            const SizedBox(height: 16),
            Text(
              l.t('bike_not_found'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l.t('qr_not_registered'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: ColorTokens.neutral70,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorTokens.primary30,
              ),
              child: Text(l.t('go_back')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBikeView() {
    final bike = _bike!;

    return CustomScrollView(
      slivers: [
        _buildAppBar(bike),
        SliverToBoxAdapter(
          child: Column(
            children: [
              _buildStatusCard(bike),
              _buildPublicInfo(bike),
              if (bike.status == BikeStatus.stolen) _buildSightingSection(bike),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(BikeEntity bike) {
    return SliverAppBar(
      expandedHeight: 250,
      floating: false,
      pinned: true,
      backgroundColor: ColorTokens.primary30,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          '${bike.brand} ${bike.model}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(0, 1),
                blurRadius: 3,
                color: Colors.black54,
              ),
            ],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            OptimizedNetworkImage(imageUrl: bike.mainPhoto, fit: BoxFit.cover),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.5),
                  ],
                ),
              ),
            ),
            // Logo de Biux en la esquina superior derecha
            const Positioned(
              top: 60,
              right: 16,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified, color: Colors.white, size: 20),
                  SizedBox(width: 4),
                  Text(
                    'Biux',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(BikeEntity bike) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    Color statusColor;
    IconData statusIcon;
    String statusDescription;

    switch (bike.status) {
      case BikeStatus.active:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusDescription = l.t('bike_registered_in_biux');
        break;
      case BikeStatus.stolen:
        statusColor = Colors.red;
        statusIcon = Icons.warning;
        statusDescription = l.t('bike_reported_stolen_alert');
        break;
      case BikeStatus.recovered:
        statusColor = Colors.orange;
        statusIcon = Icons.restore;
        statusDescription = l.t('bike_recovered_after_theft');
        break;
      case BikeStatus.verified:
        statusColor = Colors.blue;
        statusIcon = Icons.verified;
        statusDescription = l.t('bike_verified_by_store');
        break;
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.t(bike.status.displayName),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
                Text(
                  statusDescription,
                  style: TextStyle(fontSize: 14, color: statusColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPublicInfo(BikeEntity bike) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.t('bike_info'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: ColorTokens.primary30,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(l.t('brand_label'), bike.brand),
          _buildInfoRow(l.t('model_label'), bike.model),
          _buildInfoRow(l.t('year_label'), bike.year.toString()),
          _buildInfoRow(l.t('color_label'), bike.color),
          _buildInfoRow(l.t('size_label'), bike.size),
          _buildInfoRow(l.t('type_label'), l.t(bike.type.displayName)),
          _buildInfoRow(l.t('city_label'), bike.city),
          const Divider(height: 24),
          Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: ColorTokens.neutral70),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l.t('public_info_note'),
                  style: TextStyle(
                    fontSize: 12,
                    color: ColorTokens.neutral70,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: ColorTokens.neutral70,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSightingSection(BikeEntity bike) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.visibility, color: Colors.red[600], size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l.t('have_you_seen_bike'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.red[600],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  l.t('report_sighting_help'),
                  style: TextStyle(fontSize: 14, color: Colors.red[600]),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showSightingDialog(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.add_location),
                    label: Text(
                      l.t('report_sighting'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSightingDialog() {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    final locationController = TextEditingController();
    final descriptionController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l.t('report_sighting')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.t('where_did_you_see'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: locationController,
              decoration: InputDecoration(
                labelText: l.t('location_label'),
                hintText: l.t('location_hint'),
                border: const OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: l.t('description_optional'),
                hintText: l.t('additional_details_hint'),
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l.t('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              final location = locationController.text.trim();
              final description = descriptionController.text.trim();
              Navigator.pop(dialogContext);
              _submitSighting(location: location, description: description);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[600]),
            child: Text(l.t('report_button')),
          ),
        ],
      ),
    );
  }

  Future<void> _submitSighting({
    required String location,
    String description = '',
  }) async {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    try {
      await FirebaseFirestore.instance.collection('bikeSightings').add({
        'qrCode': widget.qrCode,
        'reportedAt': FieldValue.serverTimestamp(),
        'reportedBy': FirebaseAuth.instance.currentUser?.uid ?? 'anonymous',
        'location': location.isNotEmpty ? location : l.t('location_label'),
        if (description.isNotEmpty) 'description': description,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l.t('sighting_reported')),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l.t('error_loading_bikes')}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
