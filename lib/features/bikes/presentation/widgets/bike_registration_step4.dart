import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biux/core/config/strings.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/features/bikes/presentation/providers/bike_provider.dart';
import 'package:biux/features/bikes/domain/entities/bike_enums.dart';

/// Cuarto paso del registro: Generar QR y finalizar
class BikeRegistrationStep4 extends StatelessWidget {
  const BikeRegistrationStep4({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BikeProvider>(
      builder: (context, bikeProvider, child) {
        final registrationData = bikeProvider.registrationData;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              const SizedBox(height: 8),

              // Mensaje de éxito
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 64,
                      color: Colors.green[600],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppStrings.step4Title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.bikeRegistrationSuccess,
                      style: TextStyle(fontSize: 14, color: Colors.green[700]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Resumen de la bicicleta
              _buildBikeSummary(registrationData),

              const SizedBox(height: 24),

              // QR Code
              _buildQRSection(),

              const SizedBox(height: 24),

              // Acciones
              _buildActionButtons(context),

              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBikeSummary(Map<String, dynamic> data) {
    final bikeType = data['type'] as BikeType?;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorTokens.neutral90),
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
          Row(
            children: [
              Icon(
                Icons.directions_bike,
                color: ColorTokens.primary30,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Resumen de tu bicicleta',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ColorTokens.primary30,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Foto principal si existe
          if (data['mainPhoto'] != null)
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  data['mainPhoto'],
                  height: 120,
                  width: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 120,
                      width: 120,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image),
                    );
                  },
                ),
              ),
            ),

          if (data['mainPhoto'] != null) const SizedBox(height: 16),

          // Información básica
          _buildInfoRow('Marca:', data['brand'] ?? ''),
          _buildInfoRow('Modelo:', data['model'] ?? ''),
          _buildInfoRow('Año:', data['year']?.toString() ?? ''),
          _buildInfoRow('Color:', data['color'] ?? ''),
          _buildInfoRow('Talla:', data['size'] ?? ''),
          _buildInfoRow('Tipo:', bikeType?.displayName ?? ''),
          _buildInfoRow('Ciudad:', data['city'] ?? ''),

          if (data['neighborhood'] != null &&
              data['neighborhood'].toString().isNotEmpty)
            _buildInfoRow('Barrio:', data['neighborhood']),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
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
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRSection() {
    // Generar un QR temporal para la demostración
    const tempQR = 'BIUX-BIKE-TEMP-QR-12345';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorTokens.neutral90),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Tu código QR único',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ColorTokens.primary30,
            ),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: ColorTokens.neutral90),
            ),
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code, size: 80, color: ColorTokens.primary30),
                  const SizedBox(height: 8),
                  Text(
                    'QR Code',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: ColorTokens.primary30,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),
          Text(
            'Código: $tempQR',
            style: TextStyle(
              fontSize: 12,
              color: ColorTokens.neutral70,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Botón principal: Descargar QR
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _downloadQR(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorTokens.primary30,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.download),
            label: Text(
              AppStrings.downloadQR,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Botón secundario: Solicitar sticker
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _requestSticker(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: ColorTokens.primary30,
              side: const BorderSide(color: ColorTokens.primary30),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.local_shipping),
            label: Text(
              AppStrings.requestSticker,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  void _downloadQR(BuildContext context) {
    // Implementar descarga del QR
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('QR descargado en la galería'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _requestSticker(BuildContext context) {
    // Implementar solicitud de sticker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Solicitud de sticker enviada'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
