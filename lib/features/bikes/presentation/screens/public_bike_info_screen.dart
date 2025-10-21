import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biux/core/config/strings.dart';
import 'package:biux/core/design_system/color_tokens.dart';
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
          _error = 'No se pudo cargar la información de la bicicleta';
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorTokens.primary30,
              ),
              child: const Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: ColorTokens.neutral70),
            const SizedBox(height: 16),
            const Text(
              'Bicicleta no encontrada',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'El código QR no corresponde a ninguna bicicleta registrada',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: ColorTokens.neutral70),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorTokens.primary30,
              ),
              child: const Text('Volver'),
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
                  colors: [Colors.transparent, Colors.black.withOpacity(0.5)],
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
    Color statusColor;
    IconData statusIcon;
    String statusDescription;

    switch (bike.status) {
      case BikeStatus.active:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusDescription = 'Esta bicicleta está registrada en Biux';
        break;
      case BikeStatus.stolen:
        statusColor = Colors.red;
        statusIcon = Icons.warning;
        statusDescription = '¡Esta bicicleta fue reportada como robada!';
        break;
      case BikeStatus.recovered:
        statusColor = Colors.orange;
        statusIcon = Icons.restore;
        statusDescription = 'Esta bicicleta fue recuperada después de un robo';
        break;
      case BikeStatus.verified:
        statusColor = Colors.blue;
        statusIcon = Icons.verified;
        statusDescription = 'Bicicleta verificada por tienda aliada';
        break;
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
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
                  bike.status.displayName,
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información de la Bicicleta',
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
          _buildInfoRow('Ciudad', bike.city),
          const Divider(height: 24),
          Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: ColorTokens.neutral70),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Esta información es pública para verificar la identidad de la bicicleta.',
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
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
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
                        '¿Has visto esta bicicleta?',
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
                  'Si has visto esta bicicleta, por favor reporta el avistamiento para ayudar a su dueño a recuperarla.',
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
                    label: const Text(
                      'Reportar Avistamiento',
                      style: TextStyle(
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reportar Avistamiento'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¿Dónde viste esta bicicleta?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Ubicación',
                hintText: 'Ej: Parque El Virrey, Calle 85 con 15',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
                hintText: 'Detalles adicionales sobre el avistamiento',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _submitSighting();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[600]),
            child: const Text('Reportar'),
          ),
        ],
      ),
    );
  }

  void _submitSighting() {
    // TODO: Implementar envío de avistamiento
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          '¡Avistamiento reportado! Gracias por ayudar a la comunidad.',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }
}
