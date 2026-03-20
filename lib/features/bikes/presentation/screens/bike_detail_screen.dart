import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:biux/features/bikes/presentation/providers/bike_provider.dart';
import 'package:biux/features/bikes/domain/entities/bike_entity.dart';
import 'package:biux/features/bikes/domain/entities/bike_enums.dart';
import 'package:biux/shared/widgets/optimized_network_image.dart';
import 'package:biux/shared/widgets/photo_viewer.dart';

/// Pantalla de detalle de bicicleta con todas las acciones disponibles
class BikeDetailScreen extends StatefulWidget {
  final String bikeId;

  const BikeDetailScreen({super.key, required this.bikeId});

  @override
  State<BikeDetailScreen> createState() => _BikeDetailScreenState();
}

class _BikeDetailScreenState extends State<BikeDetailScreen> {
  BikeEntity? bike;

  @override
  void initState() {
    super.initState();
    _loadBike();
  }

  void _loadBike() {
    final bikeProvider = context.read<BikeProvider>();
    bike = bikeProvider.userBikes.firstWhere(
      (b) => b.id == widget.bikeId,
      orElse: () => throw Exception('bike_not_found'),
    );

    if (bike != null) {
      bikeProvider.selectBike(bike!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context);
    return Consumer<BikeProvider>(
      builder: (context, bikeProvider, child) {
        final currentBike = bikeProvider.currentBike ?? bike;

        if (currentBike == null) {
          return Scaffold(
            appBar: AppBar(
              title: Text(l.t('bike')),
              backgroundColor: ColorTokens.primary30,
            ),
            body: Center(child: Text(l.t('bike_not_found'))),
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          body: CustomScrollView(
            slivers: [
              _buildAppBar(currentBike),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildStatusCard(currentBike),
                    _buildBasicInfo(currentBike),
                    _buildPhotosSection(currentBike),
                    _buildAdditionalInfo(currentBike),
                    _buildQRSection(currentBike),
                    _buildActionsSection(currentBike, bikeProvider),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BikeEntity bike) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    final photos = <String>[
      bike.mainPhoto,
      if (bike.serialPhoto != null) bike.serialPhoto!,
      ...(bike.additionalPhotos ?? []),
    ];

    final photoLabels = <String>[
      l.t('main_photo_label'),
      if (bike.serialPhoto != null) l.t('serial_number_label'),
      ...List.generate(
        (bike.additionalPhotos ?? []).length,
        (i) => '${l.t('additional_photo')} ${i + 1}',
      ),
    ];

    return SliverAppBar(
      expandedHeight: 300,
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
        background: GestureDetector(
          onTap: () {
            context.openPhotoViewer(
              photoUrls: photos,
              initialIndex: 0,
              photoLabels: photoLabels,
            );
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              OptimizedNetworkImage(
                imageUrl: bike.mainPhoto,
                fit: BoxFit.cover,
              ),
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
              // Indicador de zoom en la esquina
              Positioned(
                bottom: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.zoom_in, size: 20, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        l.t('tap_to_enlarge'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () => _shareBike(bike),
        ),
        PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(value, bike),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  const Icon(Icons.edit),
                  const SizedBox(width: 8),
                  Text(l.t('edit_bike')),
                ],
              ),
            ),
            if (bike.canBeTransferred)
              PopupMenuItem(
                value: 'transfer',
                child: Row(
                  children: [
                    const Icon(Icons.swap_horiz),
                    const SizedBox(width: 8),
                    Text(l.t('transfer')),
                  ],
                ),
              ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(Icons.delete, color: ColorTokens.error50),
                  const SizedBox(width: 8),
                  Text(
                    l.t('delete'),
                    style: const TextStyle(color: ColorTokens.error50),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusCard(BikeEntity bike) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    Color statusColor;
    IconData statusIcon;
    String statusDescription;

    switch (bike.status) {
      case BikeStatus.active:
        statusColor = ColorTokens.success40;
        statusIcon = Icons.check_circle;
        statusDescription = l.t('bike_active_registered');
        break;
      case BikeStatus.stolen:
        statusColor = ColorTokens.error50;
        statusIcon = Icons.warning;
        statusDescription = l.t('reported_stolen');
        break;
      case BikeStatus.recovered:
        statusColor = Colors.orange;
        statusIcon = Icons.restore;
        statusDescription = l.t('recovered_after_theft');
        break;
      case BikeStatus.verified:
        statusColor = Colors.blue;
        statusIcon = Icons.verified;
        statusDescription = bike.verifiedBy ?? l.t('verified_by_store');
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
          Icon(statusIcon, color: statusColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.t(bike.status.displayName),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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

  Widget _buildBasicInfo(BikeEntity bike) {
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
            l.t('basic_info'),
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
          _buildInfoRow(l.t('serial_number_label'), bike.frameSerial),
          _buildInfoRow(l.t('city_label'), bike.city),
          if (bike.neighborhood != null)
            _buildInfoRow(l.t('neighborhood_label'), bike.neighborhood!),
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
            width: 120,
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
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosSection(BikeEntity bike) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    final photos = <String>[
      bike.mainPhoto,
      if (bike.serialPhoto != null) bike.serialPhoto!,
      ...(bike.additionalPhotos ?? []),
    ];

    final photoLabels = <String>[
      l.t('main_photo_label'),
      if (bike.serialPhoto != null) l.t('serial_number_label'),
      ...List.generate(
        (bike.additionalPhotos ?? []).length,
        (i) => '${l.t('additional_photo')} ${i + 1}',
      ),
    ];

    if (photos.length <= 1) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l.t('photos'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ColorTokens.primary30,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.zoom_in, size: 18, color: ColorTokens.neutral60),
              const SizedBox(width: 4),
              Text(
                l.t('tap_fullscreen'),
                style: TextStyle(fontSize: 12, color: ColorTokens.neutral60),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: photos.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () {
                      context.openPhotoViewer(
                        photoUrls: photos,
                        initialIndex: index,
                        photoLabels: photoLabels,
                      );
                    },
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: OptimizedNetworkImage(
                            imageUrl: photos[index],
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                        // Indicador de zoom
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(
                              Icons.zoom_out_map,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfo(BikeEntity bike) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    final hasAdditionalInfo =
        bike.purchaseDate != null ||
        bike.purchasePlace != null ||
        bike.featuredComponents != null;

    if (!hasAdditionalInfo) return const SizedBox.shrink();

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
            l.t('additional_info'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: ColorTokens.primary30,
            ),
          ),
          const SizedBox(height: 16),
          if (bike.purchaseDate != null)
            _buildInfoRow(
              l.t('purchase_date_label'),
              '${bike.purchaseDate!.day}/${bike.purchaseDate!.month}/${bike.purchaseDate!.year}',
            ),
          if (bike.purchasePlace != null)
            _buildInfoRow(l.t('purchase_place_label'), bike.purchasePlace!),
          if (bike.featuredComponents != null)
            _buildInfoRow(
              l.t('featured_components_label'),
              bike.featuredComponents!,
            ),
        ],
      ),
    );
  }

  Widget _buildQRSection(BikeEntity bike) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    return Container(
      margin: const EdgeInsets.all(16),
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
            l.t('bike_qr'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: ColorTokens.primary30,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ColorTokens.neutral90),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code, size: 60, color: ColorTokens.primary30),
                  const SizedBox(height: 8),
                  Text(
                    bike.qrCode,
                    style: TextStyle(
                      fontSize: 10,
                      color: ColorTokens.neutral70,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _downloadQR(bike),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorTokens.primary30,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.download),
                  label: Text(l.t('download_qr')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _requestSticker(bike),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ColorTokens.primary30,
                    side: const BorderSide(color: ColorTokens.primary30),
                  ),
                  icon: const Icon(Icons.local_shipping),
                  label: Text(l.t('request_sticker')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection(BikeEntity bike, BikeProvider bikeProvider) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.t('actions'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: ColorTokens.primary30,
            ),
          ),
          const SizedBox(height: 16),

          // Reportar robo / Marcar recuperada
          if (bike.status == BikeStatus.active ||
              bike.status == BikeStatus.verified)
            _buildActionButton(
              icon: Icons.warning,
              label: l.t('report_theft'),
              color: ColorTokens.error50,
              onPressed: () => _showTheftReportDialog(bike, bikeProvider),
            ),

          if (bike.status == BikeStatus.stolen)
            _buildActionButton(
              icon: Icons.restore,
              label: l.t('mark_recovered'),
              color: ColorTokens.success40,
              onPressed: () => _markAsRecovered(bike, bikeProvider),
            ),

          // Transferir propiedad
          if (bike.canBeTransferred)
            _buildActionButton(
              icon: Icons.swap_horiz,
              label: l.t('transfer_ownership'),
              color: Colors.blue,
              onPressed: () => _showTransferDialog(bike, bikeProvider),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: Icon(icon),
        label: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // Métodos de acción
  void _shareBike(BikeEntity bike) {
    // Implementar compartir bicicleta
  }

  void _handleMenuAction(String action, BikeEntity bike) {
    switch (action) {
      case 'edit':
        // Navegar a editar bicicleta
        break;
      case 'transfer':
        _showTransferDialog(bike, context.read<BikeProvider>());
        break;
      case 'delete':
        _showDeleteConfirmation(bike);
        break;
    }
  }

  void _showTheftReportDialog(BikeEntity bike, BikeProvider bikeProvider) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    final descriptionController = TextEditingController();
    final locationController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l.t('report_theft')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l.t('report_theft_confirm')),
            const SizedBox(height: 12),
            TextField(
              controller: locationController,
              decoration: InputDecoration(
                labelText: l.t('location'),
                hintText: l.t('theft_location_hint'),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: l.t('description'),
                hintText: l.t('theft_description_hint'),
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
            onPressed: () async {
              Navigator.pop(dialogContext);

              final location = locationController.text.trim();
              final description = descriptionController.text.trim();

              if (location.isEmpty || description.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l.t('fill_required_fields')),
                    backgroundColor: ColorTokens.error50,
                  ),
                );
                return;
              }

              final success = await bikeProvider.reportTheft(
                bikeId: bike.id,
                reporterId: bike.ownerId,
                theftDate: DateTime.now(),
                location: location,
                description: description,
              );

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? '✅ ${l.t('theft_reported_success')}'
                          : '❌ ${l.t('error_generic')}: ${bikeProvider.errorMessage}',
                    ),
                    backgroundColor: success
                        ? ColorTokens.success40
                        : ColorTokens.error50,
                  ),
                );
                if (success) setState(() {});
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorTokens.error50,
            ),
            child: Text(l.t('report')),
          ),
        ],
      ),
    );
  }

  void _markAsRecovered(BikeEntity bike, BikeProvider bikeProvider) async {
    final l = Provider.of<LocaleNotifier>(context, listen: false);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l.t('mark_recovered')),
        content: Text(l.t('mark_recovered_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l.t('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorTokens.success40,
            ),
            child: Text(l.t('confirm')),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await bikeProvider.markAsRecovered(
      bikeId: bike.id,
      userId: bike.ownerId,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? '✅ ${l.t('bike_recovered_success')}'
                : '❌ ${l.t('error_generic')}: ${bikeProvider.errorMessage}',
          ),
          backgroundColor: success
              ? ColorTokens.success40
              : ColorTokens.error50,
        ),
      );
      if (success) setState(() {});
    }
  }

  void _showTransferDialog(BikeEntity bike, BikeProvider bikeProvider) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    final userIdController = TextEditingController();
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l.t('transfer_ownership')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l.t('transfer_confirm')),
            const SizedBox(height: 12),
            TextField(
              controller: userIdController,
              decoration: InputDecoration(
                labelText: l.t('new_owner_id'),
                hintText: l.t('enter_user_id'),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: messageController,
              decoration: InputDecoration(labelText: l.t('message_optional')),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l.t('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              final toUserId = userIdController.text.trim();
              if (toUserId.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l.t('fill_required_fields')),
                    backgroundColor: ColorTokens.error50,
                  ),
                );
                return;
              }

              final success = await bikeProvider.requestTransfer(
                bikeId: bike.id,
                fromUserId: bike.ownerId,
                toUserId: toUserId,
                message: messageController.text.trim().isNotEmpty
                    ? messageController.text.trim()
                    : null,
              );

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? '✅ ${l.t('transfer_requested_success')}'
                          : '❌ ${l.t('error_generic')}: ${bikeProvider.errorMessage}',
                    ),
                    backgroundColor: success
                        ? ColorTokens.success40
                        : ColorTokens.error50,
                  ),
                );
              }
            },
            child: Text(l.t('transfer')),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BikeEntity bike) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.t('delete_bike')),
        content: Text(
          '${l.t('delete_bike_confirm')} ${l.t('delete_action_irreversible')}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.t('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              // Mostrar indicador de carga
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l.t('deleting_bike')),
                  duration: const Duration(seconds: 2),
                ),
              );

              // Ejecutar eliminación
              final bikeProvider = context.read<BikeProvider>();
              final success = await bikeProvider.deleteBike(bike.id);

              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✅ ${l.t('bike_deleted_success')}'),
                    backgroundColor: ColorTokens.success40,
                    duration: Duration(seconds: 2),
                  ),
                );
                // Navegar de regreso a la lista de bicicletas después de 1 segundo
                Future.delayed(const Duration(seconds: 1), () {
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                });
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '❌ ${l.t('error_generic')}: ${bikeProvider.errorMessage}',
                    ),
                    backgroundColor: ColorTokens.error50,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorTokens.error50,
            ),
            child: Text(l.t('delete')),
          ),
        ],
      ),
    );
  }

  void _downloadQR(BikeEntity bike) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l.t('qr_downloaded')),
        backgroundColor: ColorTokens.success40,
      ),
    );
  }

  void _requestSticker(BikeEntity bike) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l.t('sticker_request_sent')),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
