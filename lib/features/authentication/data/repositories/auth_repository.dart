import '../models/auth_response.dart';
import 'package:dio/dio.dart';
import "package:flutter/foundation.dart";

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

    debugPrint('🔧 [AuthRepo] Inicializado con URL: $_baseUrl');
  }

  // Validar formato de número telefónico - PERMISIVO
  bool _isValidPhoneNumber(String phoneNumber) {
    // Aceptar CUALQUIER número con al menos 8 dígitos
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    return cleanNumber.length >= 8; // Muy permisivo
  }

  Future<bool> sendOTP(String phoneNumber) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📱 [AuthRepo] ENVIANDO CÓDIGO SMS');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📞 NÚMERO DESTINO: $phoneNumber');
      debugPrint('📞 EL CÓDIGO SE ENVIARÁ A: $phoneNumber');
      debugPrint('🌐 URL Backend: $_baseUrl');
      debugPrint('⏰ Timestamp: ${DateTime.now().toIso8601String()}');
      debugPrint('');
      debugPrint('⚠️  IMPORTANTE: El SMS se envía al número ingresado');
      debugPrint('⚠️  NO se envía al número del administrador');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      // Validación muy permisiva
      if (!_isValidPhoneNumber(phoneNumber)) {
        debugPrint('❌ [AuthRepo] Número inválido: $phoneNumber');
        throw Exception('Número inválido. Debe tener al menos 8 dígitos');
      }

      debugPrint('✅ [AuthRepo] Número válido: $phoneNumber');

      final url = '$_baseUrl/send-otp';
      final requestData = {
        'phone': phoneNumber,
        'timestamp': DateTime.now().toIso8601String(),
      };

      debugPrint('📤 [AuthRepo] Enviando POST a: $url');
      debugPrint('� [AuthRepo] Datos: $requestData');
      debugPrint('🔧 [AuthRepo] Headers: ${_dio.options.headers}');

      final response = await _dio.post(url, data: requestData);

      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📨 [AuthRepo] RESPUESTA RECIBIDA');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📊 Status Code: ${response.statusCode}');
      debugPrint('📝 Response Data: ${response.data}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ [AuthRepo] ¡OTP ENVIADO EXITOSAMENTE!');
        return true;
      } else {
        debugPrint('⚠️ [AuthRepo] Status inesperado: ${response.statusCode}');
        throw Exception('err_server_status');
      }
    } on DioException catch (e) {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('❌ [AuthRepo] ERROR DE CONEXIÓN');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔴 Tipo de error: ${e.type}');
      debugPrint('💬 Mensaje: ${e.message}');
      debugPrint('📍 URL intentada: ${e.requestOptions.uri}');
      debugPrint('📦 Datos enviados: ${e.requestOptions.data}');
      debugPrint('📨 Response Status: ${e.response?.statusCode}');
      debugPrint('📝 Response Data: ${e.response?.data}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      String errorMessage = 'err_send_otp';

      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          errorMessage = 'err_connection_timeout';
          break;
        case DioExceptionType.sendTimeout:
          errorMessage = 'err_send_timeout';
          break;
        case DioExceptionType.receiveTimeout:
          errorMessage = 'err_receive_timeout';
          break;
        case DioExceptionType.badResponse:
          if (e.response?.statusCode == 400) {
            errorMessage = 'err_invalid_phone_number';
          } else if (e.response?.statusCode == 429) {
            errorMessage = 'err_too_many_attempts';
          } else if (e.response?.statusCode == 500) {
            errorMessage = 'err_server_error';
          } else {
            errorMessage = 'err_server_error';
          }
          break;
        case DioExceptionType.unknown:
          if (e.error.toString().contains('SocketException') ||
              e.error.toString().contains('Network is unreachable')) {
            errorMessage = 'err_no_wifi';
          } else if (e.error.toString().contains('HandshakeException')) {
            errorMessage = 'err_ssl';
          } else {
            errorMessage = 'err_network';
          }
          break;
        default:
          errorMessage = 'err_unexpected';
      }

      debugPrint('🔴 Mensaje de error final: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('❌ [AuthRepo] ERROR INESPERADO');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔴 Tipo: ${e.runtimeType}');
      debugPrint('🔴 Detalles: $e');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      throw Exception('err_unexpected');
    }
  }

  Future<AuthResponse> validateOTP(String phoneNumber, String code) async {
    try {
      debugPrint('🔑 [AuthRepo] Validando código para: $phoneNumber');
      debugPrint('📝 [AuthRepo] Código: ${code.replaceAll(RegExp(r'.'), '*')}');

      if (code.length != 6) {
        throw Exception('err_code_6_digits');
      }

      debugPrint('📤 [AuthRepo] Enviando validación a: $_baseUrl/validate-otp');

      final response = await _dio.post(
        '$_baseUrl/validate-otp',
        data: {
          'phone': phoneNumber,
          'code': code,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      debugPrint(
        '✅ [AuthRepo] Respuesta de validación recibida - Status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(response.data);
        debugPrint('🎫 [AuthRepo] Token obtenido exitosamente');
        return authResponse;
      } else {
        debugPrint(
          '⚠️ [AuthRepo] Validación fallida - Status: ${response.statusCode}',
        );
        throw Exception('err_code_invalid_or_expired');
      }
    } on DioException catch (e) {
      debugPrint('❌ [AuthRepo] Error en validación:');
      debugPrint('   Tipo: ${e.type}');
      debugPrint('   Status: ${e.response?.statusCode}');

      String errorMessage = 'err_validate_code';

      if (e.response?.statusCode == 401) {
        errorMessage = 'err_wrong_code';
      } else if (e.response?.statusCode == 410) {
        errorMessage = 'err_code_expired';
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'err_code_timeout';
      }

      throw Exception(errorMessage);
    } catch (e) {
      debugPrint('❌ [AuthRepo] Error inesperado en validación: $e');
      throw Exception('err_validate_code');
    }
  }
}
