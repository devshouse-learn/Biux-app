import '../models/auth_response.dart';
import 'package:dio/dio.dart';

class AuthRepository {
  final Dio _dio;
  final String _baseUrl; // URL base de tu API

  AuthRepository({Dio? dio, String? baseUrl})
      : _dio = dio ?? Dio(),
        _baseUrl = baseUrl ?? 'TU_URL_BASE' {
    // Configurar timeout
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.sendTimeout = const Duration(seconds: 30);
  }

  // Validar formato de número telefónico (E.164)
  bool _isValidPhoneNumber(String phoneNumber) {
    // Aceptar números con formato +XXXXXXXXXXX (mínimo 10 dígitos)
    // o números locales de 10 cifras
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    return cleanNumber.length >= 10 && cleanNumber.length <= 15;
  }

  Future<bool> sendOTP(String phoneNumber) async {
    try {
      print('📱 [AuthRepo] Iniciando envío de OTP para: $phoneNumber');

      // Validar formato del número
      if (!_isValidPhoneNumber(phoneNumber)) {
        print('❌ [AuthRepo] Formato de número inválido: $phoneNumber');
        throw Exception(
          'Formato de teléfono inválido. Usa +código área (ej: +573001234567) o 10-15 dígitos',
        );
      }

      print('✓ [AuthRepo] Número validado correctamente');
      print('📤 [AuthRepo] Enviando request a: $_baseUrl/send-otp');

      final response = await _dio.post(
        '$_baseUrl/send-otp',
        data: {
          'phone': phoneNumber,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      print('📨 [AuthRepo] Respuesta recibida - Status: ${response.statusCode}');
      print('📝 [AuthRepo] Body: ${response.data}');

      if (response.statusCode == 200) {
        print('✅ [AuthRepo] OTP enviado exitosamente');
        return true;
      } else {
        print('⚠️ [AuthRepo] Status inesperado: ${response.statusCode}');
        throw Exception(
          'Servidor respondió con código ${response.statusCode}. Intenta nuevamente.',
        );
      }
    } on DioException catch (e) {
      print('❌ [AuthRepo] Error de conexión:');
      print('   Tipo: ${e.type}');
      print('   Mensaje: ${e.message}');
      print('   Response: ${e.response?.data}');

      String errorMessage = 'Error al enviar el código OTP';

      if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Tiempo de espera agotado. Verifica tu conexión a internet.';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Servidor tardó demasiado. Intenta nuevamente.';
      } else if (e.type == DioExceptionType.unknown) {
        if (e.error.toString().contains('SocketException')) {
          errorMessage = 'Sin conexión a internet. Verifica tu WiFi o datos móviles.';
        }
      } else if (e.response?.statusCode == 400) {
        errorMessage = 'Número de teléfono inválido.';
      } else if (e.response?.statusCode == 429) {
        errorMessage = 'Demasiados intentos. Intenta en unos minutos.';
      } else if (e.response?.statusCode == 500) {
        errorMessage = 'Error del servidor. Por favor intenta más tarde.';
      }

      throw Exception(errorMessage);
    } catch (e) {
      print('❌ [AuthRepo] Error inesperado: $e');
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

      print('✅ [AuthRepo] Respuesta de validación recibida - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(response.data);
        print('🎫 [AuthRepo] Token obtenido exitosamente');
        return authResponse;
      } else {
        print('⚠️ [AuthRepo] Validación fallida - Status: ${response.statusCode}');
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
