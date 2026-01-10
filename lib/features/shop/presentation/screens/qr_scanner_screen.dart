import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import 'package:biux/core/design_system/color_tokens.dart';

/// Pantalla para escanear códigos QR de productos
class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({Key? key}) : super(key: key);

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _isProcessing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;

    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    final String? code = barcode.rawValue;

    if (code != null && code.isNotEmpty) {
      setState(() {
        _isProcessing = true;
      });

      // Vibrar si está disponible
      _controller.stop();

      // Buscar producto por código QR
      _searchProductByQR(code);
    }
  }

  void _searchProductByQR(String code) {
    // Cerrar escáner y buscar producto
    Navigator.of(context).pop();

    // Navegar a búsqueda con el código
    context.go('/shop?search=$code');
  }

  void _toggleTorch() {
    _controller.toggleTorch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Escanear Código QR'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: _toggleTorch,
            tooltip: 'Flash',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Visor de cámara
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.white,
                      size: 80,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error al iniciar cámara',
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.errorDetails?.message ?? 'Error desconocido',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Volver'),
                    ),
                  ],
                ),
              );
            },
          ),

          // Overlay con marco de escaneo
          CustomPaint(painter: ScannerOverlayPainter(), child: Container()),

          // Indicador de procesamiento
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: ColorTokens.secondary50),
                    const SizedBox(height: 16),
                    const Text(
                      'Buscando producto...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

          // Instrucciones
          Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.qr_code_scanner, color: Colors.white, size: 32),
                  SizedBox(height: 8),
                  Text(
                    'Apunta la cámara al código QR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'El escaneo se realizará automáticamente',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Painter para el overlay del escáner
class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    final double scanAreaSize = size.width * 0.7;
    final double left = (size.width - scanAreaSize) / 2;
    final double top = (size.height - scanAreaSize) / 2;

    // Dibujar overlay oscuro
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, top, scanAreaSize, scanAreaSize),
          const Radius.circular(16),
        ),
      )
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    // Dibujar marco del área de escaneo
    final borderPaint = Paint()
      ..color = ColorTokens.secondary50
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final borderPath = Path();
    const double cornerLength = 30;

    // Esquina superior izquierda
    borderPath.moveTo(left, top + cornerLength);
    borderPath.lineTo(left, top);
    borderPath.lineTo(left + cornerLength, top);

    // Esquina superior derecha
    borderPath.moveTo(left + scanAreaSize - cornerLength, top);
    borderPath.lineTo(left + scanAreaSize, top);
    borderPath.lineTo(left + scanAreaSize, top + cornerLength);

    // Esquina inferior derecha
    borderPath.moveTo(left + scanAreaSize, top + scanAreaSize - cornerLength);
    borderPath.lineTo(left + scanAreaSize, top + scanAreaSize);
    borderPath.lineTo(left + scanAreaSize - cornerLength, top + scanAreaSize);

    // Esquina inferior izquierda
    borderPath.moveTo(left + cornerLength, top + scanAreaSize);
    borderPath.lineTo(left, top + scanAreaSize);
    borderPath.lineTo(left, top + scanAreaSize - cornerLength);

    canvas.drawPath(borderPath, borderPaint);

    // Línea de escaneo animada (opcional)
    final scanLinePaint = Paint()
      ..color = ColorTokens.secondary50.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(left, top + scanAreaSize / 2 - 1, scanAreaSize, 2),
      scanLinePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
