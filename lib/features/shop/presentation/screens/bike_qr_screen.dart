import 'package:flutter/material.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/features/shop/domain/services/bike_qr_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

/// Pantalla que muestra el código QR de una bicicleta verificada
class BikeQRScreen extends StatefulWidget {
  final String productId;
  final String frameSerial;
  final DateTime verificationDate;
  final String verifierUid;
  final String? bikeBrand;
  final String? bikeModel;
  final String? bikeColor;

  const BikeQRScreen({
    super.key,
    required this.productId,
    required this.frameSerial,
    required this.verificationDate,
    required this.verifierUid,
    this.bikeBrand,
    this.bikeModel,
    this.bikeColor,
  });

  @override
  State<BikeQRScreen> createState() => _BikeQRScreenState();
}

class _BikeQRScreenState extends State<BikeQRScreen> {
  late String _qrData;

  @override
  void initState() {
    super.initState();
    _generateQRData();
  }

  void _generateQRData() {
    _qrData = BikeQRService.generateQRData(
      productId: widget.productId,
      frameSerial: widget.frameSerial,
      verificationDate: widget.verificationDate,
      verifierUid: widget.verifierUid,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorTokens.success40,
        foregroundColor: ColorTokens.neutral100,
        title: const Text('Código QR de Verificación'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Compartir QR',
            onPressed: _shareQR,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Badge de verificación
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: ColorTokens.success99,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: ColorTokens.success40, width: 2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified, color: ColorTokens.success40, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'BICICLETA VERIFICADA',
                    style: TextStyle(
                      color: ColorTokens.success30,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Información de la bicicleta
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información de la Bicicleta',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: ColorTokens.neutral30,
                      ),
                    ),
                    const Divider(height: 16),
                    _buildInfoRow(
                      Icons.badge,
                      'Número de Serie',
                      widget.frameSerial,
                    ),
                    if (widget.bikeBrand != null)
                      _buildInfoRow(
                        Icons.branding_watermark,
                        'Marca',
                        widget.bikeBrand!,
                      ),
                    if (widget.bikeModel != null)
                      _buildInfoRow(
                        Icons.directions_bike,
                        'Modelo',
                        widget.bikeModel!,
                      ),
                    if (widget.bikeColor != null)
                      _buildInfoRow(
                        Icons.color_lens,
                        'Color',
                        widget.bikeColor!,
                      ),
                    const Divider(height: 16),
                    _buildInfoRow(
                      Icons.calendar_today,
                      'Fecha de Verificación',
                      DateFormat(
                        'dd/MM/yyyy HH:mm',
                      ).format(widget.verificationDate),
                    ),
                    _buildInfoRow(
                      Icons.shield_outlined,
                      'ID de Verificación',
                      widget.verifierUid.substring(0, 12) + '...',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Código QR
            Text(
              'Escanea este código QR para verificar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: ColorTokens.neutral40,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: BikeQRService.buildQRWidget(qrData: _qrData, size: 250),
            ),
            const SizedBox(height: 24),

            // Instrucciones
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ColorTokens.primary99,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ColorTokens.primary80),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: ColorTokens.primary40),
                      const SizedBox(width: 8),
                      Text(
                        '¿Cómo usar este QR?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: ColorTokens.primary30,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInstructionItem(
                    '1',
                    'Pega este código QR en tu bicicleta (en el cuadro o el manubrio)',
                  ),
                  _buildInstructionItem(
                    '2',
                    'Cualquiera puede escanear el QR con la app Biux',
                  ),
                  _buildInstructionItem(
                    '3',
                    'El comprador puede verificar que NO es una bici robada',
                  ),
                  _buildInstructionItem(
                    '4',
                    'Aumenta la confianza y reduce el riesgo de fraude',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.download),
                    label: const Text('Descargar QR'),
                    onPressed: _downloadQR,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.share),
                    label: const Text('Compartir'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorTokens.primary40,
                      foregroundColor: ColorTokens.neutral100,
                    ),
                    onPressed: _shareQR,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: ColorTokens.neutral60),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: ColorTokens.neutral60),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: ColorTokens.primary40,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  Future<void> _downloadQR() async {
    try {
      final qrImage = await BikeQRService.generateQRImage(qrData: _qrData);

      if (qrImage != null && mounted) {
        // TODO: Implementar guardado en galería usando image_gallery_saver
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Descarga de QR disponible próximamente'),
            backgroundColor: ColorTokens.primary40,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al descargar: $e'),
            backgroundColor: ColorTokens.error50,
          ),
        );
      }
    }
  }

  Future<void> _shareQR() async {
    try {
      final shareText =
          '''
🚴 Bicicleta Verificada en Biux 

✅ Esta bicicleta ha sido verificada como NO ROBADA

📋 Información:
• Número de Serie: ${widget.frameSerial}
${widget.bikeBrand != null ? '• Marca: ${widget.bikeBrand}\n' : ''}${widget.bikeModel != null ? '• Modelo: ${widget.bikeModel}\n' : ''}
🔍 Escaneá el código QR en la app Biux para confirmar

Verificada el: ${DateFormat('dd/MM/yyyy').format(widget.verificationDate)}
''';

      await SharePlus.instance.share(ShareParams(text: shareText));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al compartir: $e'),
            backgroundColor: ColorTokens.error50,
          ),
        );
      }
    }
  }
}
