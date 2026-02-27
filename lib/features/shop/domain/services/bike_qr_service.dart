import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Servicio para generar códigos QR para bicicletas verificadas
class BikeQRService {
  /// Genera un código QR con la información de una bicicleta verificada
  ///
  /// El QR contiene:
  /// - ID del producto
  /// - Número de serie
  /// - Fecha de verificación
  /// - UID del verificador (admin)
  static String generateQRData({
    required String productId,
    required String frameSerial,
    required DateTime verificationDate,
    required String verifierUid,
  }) {
    // Formato: biux://verified-bike?id=xxx&serial=xxx&date=xxx&verifier=xxx
    final timestamp = verificationDate.millisecondsSinceEpoch;
    return 'biux://verified-bike'
        '?id=$productId'
        '&serial=$frameSerial'
        '&date=$timestamp'
        '&verifier=$verifierUid';
  }

  /// Genera la imagen del QR como bytes PNG
  static Future<Uint8List?> generateQRImage({
    required String qrData,
    double size = 300,
  }) async {
    try {
      final qrValidationResult = QrValidator.validate(
        data: qrData,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.H,
      );

      if (qrValidationResult.status == QrValidationStatus.valid) {
        final qrCode = qrValidationResult.qrCode!;
        final painter = QrPainter.withQr(
          qr: qrCode,
          eyeStyle: const QrEyeStyle(
            eyeShape: QrEyeShape.square,
            color: Color(0xFF000000),
          ),
          dataModuleStyle: const QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.square,
            color: Color(0xFF000000),
          ),
          gapless: true,
          embeddedImageStyle: null,
          embeddedImage: null,
        );

        final pictureRecorder = ui.PictureRecorder();
        final canvas = Canvas(pictureRecorder);
        painter.paint(canvas, Size(size, size));
        final picture = pictureRecorder.endRecording();
        final image = await picture.toImage(size.toInt(), size.toInt());
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        return byteData?.buffer.asUint8List();
      }

      return null;
    } catch (e) {
      print('❌ Error generando imagen QR: $e');
      return null;
    }
  }

  /// Decodifica los datos del QR escaneado
  static Map<String, String>? decodeQRData(String qrData) {
    try {
      if (!qrData.startsWith('biux://verified-bike')) {
        return null;
      }

      final uri = Uri.parse(qrData);
      final params = uri.queryParameters;

      if (!params.containsKey('id') ||
          !params.containsKey('serial') ||
          !params.containsKey('date') ||
          !params.containsKey('verifier')) {
        return null;
      }

      return {
        'productId': params['id']!,
        'frameSerial': params['serial']!,
        'verificationDate': params['date']!,
        'verifierUid': params['verifier']!,
      };
    } catch (e) {
      print('❌ Error decodificando QR: $e');
      return null;
    }
  }

  /// Verifica la autenticidad de un código QR escaneado
  static Future<QRVerificationResult> verifyQRCode(String qrData) async {
    try {
      final decodedData = decodeQRData(qrData);
      if (decodedData == null) {
        return QRVerificationResult(
          isValid: false,
          message: 'Código QR inválido',
        );
      }

      final productId = decodedData['productId']!;
      final frameSerial = decodedData['frameSerial']!;
      final timestamp = int.parse(decodedData['verificationDate']!);
      final verificationDate = DateTime.fromMillisecondsSinceEpoch(timestamp);

      // Verificar que el producto exista en Firestore
      final productDoc = await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .get();

      if (!productDoc.exists) {
        return QRVerificationResult(
          isValid: false,
          message: 'Producto no encontrado en el sistema',
        );
      }

      final productData = productDoc.data()!;

      // Verificar que el número de serie coincida
      if (productData['bikeFrameSerial'] != frameSerial) {
        return QRVerificationResult(
          isValid: false,
          message: 'El número de serie no coincide',
          details:
              'El QR podría haber sido alterado. No compres esta bicicleta.',
        );
      }

      // Verificar que esté marcada como verificada
      if (productData['isVerifiedNotStolen'] != true) {
        return QRVerificationResult(
          isValid: false,
          message: 'Esta bicicleta no está verificada como segura',
          details: 'La verificación puede haber expirado o sido revocada.',
        );
      }

      // Todo correcto
      return QRVerificationResult(
        isValid: true,
        message: '✅ Bicicleta verificada como NO robada',
        details:
            'Marca: ${productData['bikeBrand'] ?? 'N/A'}\n'
            'Modelo: ${productData['bikeModel'] ?? 'N/A'}\n'
            'Color: ${productData['bikeColor'] ?? 'N/A'}\n'
            'Verificada el: ${_formatDate(verificationDate)}',
        productData: productData,
        verificationDate: verificationDate,
      );
    } catch (e) {
      print('❌ Error verificando QR: $e');
      return QRVerificationResult(
        isValid: false,
        message: 'Error al verificar el código QR',
        details: e.toString(),
      );
    }
  }

  /// Guarda el QR en Firestore para el producto
  static Future<void> saveQRToProduct({
    required String productId,
    required String qrData,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .update({
            'qrCode': qrData,
            'qrGeneratedAt': FieldValue.serverTimestamp(),
          });
      print('✅ QR guardado en producto $productId');
    } catch (e) {
      print('❌ Error guardando QR: $e');
    }
  }

  /// Genera el widget del QR para mostrar en la UI
  static Widget buildQRWidget({
    required String qrData,
    double size = 250,
    Color? color,
  }) {
    return QrImageView(
      data: qrData,
      version: QrVersions.auto,
      size: size,
      backgroundColor: Colors.white,
      eyeStyle: QrEyeStyle(
        eyeShape: QrEyeShape.square,
        color: color ?? Colors.black,
      ),
      dataModuleStyle: QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: color ?? Colors.black,
      ),
      embeddedImage: null,
      embeddedImageStyle: null,
      errorCorrectionLevel: QrErrorCorrectLevel.H,
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

/// Resultado de la verificación de un código QR
class QRVerificationResult {
  final bool isValid;
  final String message;
  final String? details;
  final Map<String, dynamic>? productData;
  final DateTime? verificationDate;

  QRVerificationResult({
    required this.isValid,
    required this.message,
    this.details,
    this.productData,
    this.verificationDate,
  });
}
