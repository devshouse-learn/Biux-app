import '../models/auth_response.dart';
import 'package:biux/core/services/app_logger.dart';
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

    AppLogger.debug('🔧 [AuthRepo] Inicializado con URL: $_baseUrl');
  }

  // Validar formato de número telefónico - PERMISIVO
  bool _isValidPhoneNumber(String phoneNumber) {
    // Aceptar CUALQUIER número con al menos 8 dígitos
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    return cleanNumber.length >= 8; // Muy permisivo
  }

  Future<bool> sendOTP(String phoneNumber) async {
    try {
      AppLogger.debug('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      AppLogger.debug('📱 [AuthRepo] ENVIANDO CÓDIGO SMS');
      AppLogger.debug('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      AppLogger.debug('📞 NÚMERO DESTINO: $phoneNumber');
      AppLogger.debug('📞 EL CÓDIGO SE ENVIARÁ A: $phoneNumber');
      AppLogger.debug('🌐 URL Backend: $_baseUrl');
      AppLogger.debug('⏰ Timestamp: ${DateTime.now().toIso8601String()}');
      AppLogger.debug('');
      AppLogger.warning('⚠️  IMPORTANTE: El SMS se envía al número ingresado');
      AppLogger.warning('⚠️  NO se envía al número del administrador');
      AppLogger.debug('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      // Validación muy permisiva
      if (!_isValidPhoneNumber(phoneNumber)) {
        AppLogger.error('❌ [AuthRepo] Número inválido: $phoneNumber');
        throw Exception('Número inválido. Debe tener al menos 8 dígitos');
      }

      AppLogger.info('✅ [AuthRepo] Número válido: $phoneNumber');

      final url = '$_baseUrl/send-otp';
      final requestData = {
        'phone': phoneNumber,
        'timestamp': DateTime.now().toIso8601String(),
      };

      AppLogger.debug('📤 [AuthRepo] Enviando POST a: $url');
      AppLogger.debug('� [AuthRepo] Datos: $requestData');
      AppLogger.debug('🔧 [AuthRepo] Headers: ${_dio.options.headers}');

      final response = await _dio.post(url, data: requestData);

      AppLogger.debug('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      AppLogger.debug('📨 [AuthRepo] RESPUESTA RECIBIDA');
      AppLogger.debug('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      AppLogger.debug('📊 Status Code: ${response.statusCode}');
      AppLogger.debug('📝 Response Data: ${response.data}');
      AppLogger.debug('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.info('✅ [AuthRepo] ¡OTP ENVIADO EXITOSAMENTE!');
        return true;
      } else {
        AppLogger.warning('⚠️ [AuthRepo] Status inesperado: ${response.statusCode}');
        throw Exception('err_server_status');
      }
    } on DioException catch (e) {
      AppLogger.debug('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      AppLogger.error('❌ [AuthRepo] ERROR DE CONEXIÓN');
      AppLogger.debug('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      AppLogger.error('🔴 Tipo de error: ${e.type}');
      AppLogger.debug('💬 Mensaje: ${e.message}');
      AppLogger.debug('📍 URL intentada: ${e.requestOptions.uri}');
      AppLogger.debug('📦 Datos enviados: ${e.requestOptions.data}');
      AppLogger.debug('📨 Response Status: ${e.response?.statusCode}');
      AppLogger.debug('📝 Response Data: ${e.response?.data}');
      AppLogger.debug('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

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

      AppLogger.error('🔴 Mensaje de error final: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      AppLogger.debug('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      AppLogger.error('❌ [AuthRepo] ERROR INESPERADO');
      AppLogger.debug('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      AppLogger.error('🔴 Tipo: ${e.runtimeType}');
      AppLogger.error('🔴 Detalles: $e');
      AppLogger.debug('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      throw Exception('err_unexpected');
    }
  }

  Future<AuthResponse> validateOTP(String phoneNumber, String code) async {
    try {
      AppLogger.debug('🔑 [AuthRepo] Validando código para: $phoneNumber');
      AppLogger.debug('📝 [AuthRepo] Código: ${code.replaceAll(RegExp(r'.'), '*')}');

      if (code.length != 6) {
        throw Exception('err_code_6_digits');
      }

      AppLogger.debug('📤 [AuthRepo] Enviando validación a: $_baseUrl/validate-otp');

      final response = await _dio.post(
        '$_baseUrl/validate-otp',
        data: {
          'phone': phoneNumber,
          'code': code,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      AppLogger.debug(
        '✅ [AuthRepo] Respuesta de validación recibida - Status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(response.data);
        AppLogger.debug('🎫 [AuthRepo] Token obtenido exitosamente');
        return authResponse;
      } else {
        AppLogger.debug(
          '⚠️ [AuthRepo] Validación fallida - Status: ${response.statusCode}',
        );
        throw Exception('err_code_invalid_or_expired');
      }
    } on DioException catch (e) {
      AppLogger.error('❌ [AuthRepo] Error en validación:');
      AppLogger.debug('   Tipo: ${e.type}');
      AppLogger.debug('   Status: ${e.response?.statusCode}');

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
      AppLogger.error('❌ [AuthRepo] Error inesperado en validación: $e');
      throw Exception('err_validate_code');
    }
  }
}
