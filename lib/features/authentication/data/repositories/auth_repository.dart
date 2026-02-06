import '../models/auth_response.dart';
import 'package:dio/dio.dart';

class AuthRepository {
  final Dio _dio;
  final String _baseUrl; // URL base de tu API

  AuthRepository({Dio? dio, String? baseUrl})
    : _dio = dio ?? Dio(),
      _baseUrl = baseUrl ?? 'https://n8n.oktavia.me/webhook' {
    // Configurar timeout y headers
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.sendTimeout = const Duration(seconds: 30);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    print('🔧 [AuthRepo] Inicializado con URL: $_baseUrl');
  }

  // Validar formato de número telefónico - PERMISIVO
  bool _isValidPhoneNumber(String phoneNumber) {
    // Aceptar CUALQUIER número con al menos 8 dígitos
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    return cleanNumber.length >= 8; // Muy permisivo
  }

  Future<bool> sendOTP(String phoneNumber) async {
    try {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📱 [AuthRepo] ENVIANDO CÓDIGO SMS');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📞 NÚMERO DESTINO: $phoneNumber');
      print('📞 EL CÓDIGO SE ENVIARÁ A: $phoneNumber');
      print('🌐 URL Backend: $_baseUrl');
      print('⏰ Timestamp: ${DateTime.now().toIso8601String()}');
      print('');
      print('⚠️  IMPORTANTE: El SMS se envía al número ingresado');
      print('⚠️  NO se envía al número del administrador');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      // Validación muy permisiva
      if (!_isValidPhoneNumber(phoneNumber)) {
        print('❌ [AuthRepo] Número inválido: $phoneNumber');
        throw Exception(
          'Número inválido. Debe tener al menos 8 dígitos',
        );
      }

      print('✅ [AuthRepo] Número válido: $phoneNumber');

      final url = '$_baseUrl/send-otp';
      final requestData = {
        'phone': phoneNumber,
        'timestamp': DateTime.now().toIso8601String(),
      };

      print('📤 [AuthRepo] Enviando POST a: $url');
      print('� [AuthRepo] Datos: $requestData');
      print('🔧 [AuthRepo] Headers: ${_dio.options.headers}');

      final response = await _dio.post(url, data: requestData);

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📨 [AuthRepo] RESPUESTA RECIBIDA');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📊 Status Code: ${response.statusCode}');
      print('📝 Response Data: ${response.data}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ [AuthRepo] ¡OTP ENVIADO EXITOSAMENTE!');
        return true;
      } else {
        print('⚠️ [AuthRepo] Status inesperado: ${response.statusCode}');
        throw Exception(
          'Servidor respondió con código ${response.statusCode}. Intenta nuevamente.',
        );
      }
    } on DioException catch (e) {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('❌ [AuthRepo] ERROR DE CONEXIÓN');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🔴 Tipo de error: ${e.type}');
      print('💬 Mensaje: ${e.message}');
      print('📍 URL intentada: ${e.requestOptions.uri}');
      print('📦 Datos enviados: ${e.requestOptions.data}');
      print('📨 Response Status: ${e.response?.statusCode}');
      print('📝 Response Data: ${e.response?.data}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      String errorMessage = 'Error al enviar el código OTP';

      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          errorMessage =
              'Tiempo de espera agotado. Verifica tu conexión a internet.';
          break;
        case DioExceptionType.sendTimeout:
          errorMessage = 'Tiempo de envío agotado. Verifica tu conexión.';
          break;
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Servidor tardó demasiado. Intenta nuevamente.';
          break;
        case DioExceptionType.badResponse:
          if (e.response?.statusCode == 400) {
            errorMessage = 'Número de teléfono inválido.';
          } else if (e.response?.statusCode == 429) {
            errorMessage = 'Demasiados intentos. Intenta en unos minutos.';
          } else if (e.response?.statusCode == 500) {
            errorMessage = 'Error del servidor. Por favor intenta más tarde.';
          } else {
            errorMessage = 'Error del servidor (${e.response?.statusCode}).';
          }
          break;
        case DioExceptionType.unknown:
          if (e.error.toString().contains('SocketException') ||
              e.error.toString().contains('Network is unreachable')) {
            errorMessage =
                'Sin conexión a internet. Verifica tu WiFi o datos móviles.';
          } else if (e.error.toString().contains('HandshakeException')) {
            errorMessage =
                'Error de seguridad SSL. Verifica la fecha/hora del dispositivo.';
          } else {
            errorMessage = 'Error de red: ${e.error}';
          }
          break;
        default:
          errorMessage = 'Error inesperado: ${e.type}';
      }

      print('🔴 Mensaje de error final: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('❌ [AuthRepo] ERROR INESPERADO');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🔴 Tipo: ${e.runtimeType}');
      print('🔴 Detalles: $e');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      throw Exception('Error inesperado: ${e.toString()}');
    }
  }

  Future<AuthResponse> validateOTP(String phoneNumber, String code) async {
    try {
      print('🔑 [AuthRepo] Validando código para: $phoneNumber');
      print('📝 [AuthRepo] Código: ${code.replaceAll(RegExp(r'.'), '*')}');

      if (code.length != 6) {
        throw Exception('El código debe tener exactamente 6 dígitos');
      }

      print('📤 [AuthRepo] Enviando validación a: $_baseUrl/validate-otp');

      final response = await _dio.post(
        '$_baseUrl/validate-otp',
        data: {
          'phone': phoneNumber,
          'code': code,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      print(
        '✅ [AuthRepo] Respuesta de validación recibida - Status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(response.data);
        print('🎫 [AuthRepo] Token obtenido exitosamente');
        return authResponse;
      } else {
        print(
          '⚠️ [AuthRepo] Validación fallida - Status: ${response.statusCode}',
        );
        throw Exception('Código inválido o expirado');
      }
    } on DioException catch (e) {
      print('❌ [AuthRepo] Error en validación:');
      print('   Tipo: ${e.type}');
      print('   Status: ${e.response?.statusCode}');

      String errorMessage = 'Error al validar el código';

      if (e.response?.statusCode == 401) {
        errorMessage = 'Código incorrecto. Intenta nuevamente.';
      } else if (e.response?.statusCode == 410) {
        errorMessage = 'Código expirado. Solicita uno nuevo.';
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Tiempo de espera agotado. Verifica tu conexión.';
      }

      throw Exception(errorMessage);
    } catch (e) {
      print('❌ [AuthRepo] Error inesperado en validación: $e');
      throw Exception('Error al validar: ${e.toString()}');
    }
  }
}
