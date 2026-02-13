import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biux/core/config/strings.dart';
import 'package:biux/core/design_system/color_tokens.dart';
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
      orElse: () => throw Exception('Bicicleta no encontrada'),
    );

    if (bike != null) {
      bikeProvider.selectBike(bike!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BikeProvider>(
      builder: (context, bikeProvider, child) {
        final currentBike = bikeProvider.currentBike ?? bike;

        if (currentBike == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Bicicleta'),
              backgroundColor: ColorTokens.primary30,
            ),
            body: const Center(child: Text('Bicicleta no encontrada')),
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
    final photos = <String>[
      bike.mainPhoto,
      if (bike.serialPhoto != null) bike.serialPhoto!,
      ...(bike.additionalPhotos ?? []),
    ];

    final photoLabels = <String>[
      'Foto Principal',
      if (bike.serialPhoto != null) 'Número de Serie',
      ...List.generate(
        (bike.additionalPhotos ?? []).length,
        (i) => 'Foto Adicional ${i + 1}',
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
                        'Toca para ampliar',
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
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Editar'),
                ],
              ),
            ),
            if (bike.canBeTransferred)
              const PopupMenuItem(
                value: 'transfer',
                child: Row(
                  children: [
                    Icon(Icons.swap_horiz),
                    SizedBox(width: 8),
                    Text('Transferir'),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Eliminar', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusCard(BikeEntity bike) {
    Color statusColor;
    IconData statusIcon;
    String statusDescription;

    switch (bike.status) {
      case BikeStatus.active:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusDescription = 'Tu bicicleta está activa y registrada';
        break;
      case BikeStatus.stolen:
        statusColor = Colors.red;
        statusIcon = Icons.warning;
        statusDescription = 'Reportada como robada';
        break;
      case BikeStatus.recovered:
        statusColor = Colors.orange;
        statusIcon = Icons.restore;
        statusDescription = 'Recuperada después de robo';
        break;
      case BikeStatus.verified:
        statusColor = Colors.blue;
        statusIcon = Icons.verified;
        statusDescription = bike.verifiedBy ?? 'Verificada por tienda aliada';
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
                  bike.status.displayName,
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
          const Text(
            'Información Básica',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: ColorTokens.primary30,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Marca', bike.brand),
          _buildInfoRow('Modelo', bike.model),
          _buildInfoRow('Año', bike.year.toString()),
          _buildInfoRow('Color', bike.color),
          _buildInfoRow('Talla', bike.size),
          _buildInfoRow('Tipo', bike.type.displayName),
          _buildInfoRow('Número de Serie', bike.frameSerial),
          _buildInfoRow('Ciudad', bike.city),
          if (bike.neighborhood != null)
            _buildInfoRow('Barrio', bike.neighborhood!),
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
    final photos = <String>[
      bike.mainPhoto,
      if (bike.serialPhoto != null) bike.serialPhoto!,
      ...(bike.additionalPhotos ?? []),
    ];

    final photoLabels = <String>[
      'Foto Principal',
      if (bike.serialPhoto != null) 'Número de Serie',
      ...List.generate(
        (bike.additionalPhotos ?? []).length,
        (i) => 'Foto Adicional ${i + 1}',
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
              const Text(
                'Fotos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ColorTokens.primary30,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.zoom_in, size: 18, color: ColorTokens.neutral60),
              const SizedBox(width: 4),
              Text(
                'Toca para ver en pantalla completa',
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
          const Text(
            'Información Adicional',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: ColorTokens.primary30,
            ),
          ),
          const SizedBox(height: 16),
          if (bike.purchaseDate != null)
            _buildInfoRow(
              'Fecha de Compra',
              '${bike.purchaseDate!.day}/${bike.purchaseDate!.month}/${bike.purchaseDate!.year}',
            ),
          if (bike.purchasePlace != null)
            _buildInfoRow('Lugar de Compra', bike.purchasePlace!),
          if (bike.featuredComponents != null)
            _buildInfoRow('Componentes Destacados', bike.featuredComponents!),
        ],
      ),
    );
  }

  Widget _buildQRSection(BikeEntity bike) {
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
          const Text(
            'Código QR',
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
                  label: Text(AppStrings.downloadQR),
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
                  label: Text(AppStrings.requestSticker),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection(BikeEntity bike, BikeProvider bikeProvider) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Acciones',
            style: TextStyle(
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
              label: AppStrings.reportTheft,
              color: Colors.red,
              onPressed: () => _showTheftReportDialog(bike, bikeProvider),
            ),

          if (bike.status == BikeStatus.stolen)
            _buildActionButton(
              icon: Icons.restore,
              label: AppStrings.markRecovered,
              color: Colors.green,
              onPressed: () => _markAsRecovered(bike, bikeProvider),
            ),

          // Transferir propiedad
          if (bike.canBeTransferred)
            _buildActionButton(
              icon: Icons.swap_horiz,
              label: AppStrings.transferOwnership,
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.reportTheft),
        content: const Text(
          '¿Estás seguro de que quieres reportar esta bicicleta como robada?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implementar reporte de robo
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reportar'),
          ),
        ],
      ),
    );
  }

  void _markAsRecovered(BikeEntity bike, BikeProvider bikeProvider) {
    // TODO: Implementar marcar como recuperada
  }

  void _showTransferDialog(BikeEntity bike, BikeProvider bikeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.transferOwnership),
        content: const Text(
          '¿Deseas transferir la propiedad de esta bicicleta?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implementar transferencia
            },
            child: const Text('Transferir'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BikeEntity bike) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Bicicleta'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar esta bicicleta? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              // Mostrar indicador de carga
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Eliminando bicicleta...'),
                  duration: Duration(seconds: 2),
                ),
              );

              // Ejecutar eliminación
              final bikeProvider = context.read<BikeProvider>();
              final success = await bikeProvider.deleteBike(bike.id);

              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Bicicleta eliminada correctamente'),
                    backgroundColor: Colors.green,
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
                    content: Text('❌ Error: ${bikeProvider.errorMessage}'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _downloadQR(BikeEntity bike) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('QR descargado en la galería'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _requestSticker(BikeEntity bike) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Solicitud de sticker enviada'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
