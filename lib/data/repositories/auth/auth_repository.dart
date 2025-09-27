import 'package:biux/data/models/auth_response.dart';
import 'package:dio/dio.dart';

class AuthRepository {
  final Dio _dio;
  final String _baseUrl; // URL base de tu API

  AuthRepository({Dio? dio, String? baseUrl})
      : _dio = dio ?? Dio(),
        _baseUrl = baseUrl ?? 'TU_URL_BASE';

  Future<bool> sendOTP(String phoneNumber) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/send-otp',
        data: {'phone': phoneNumber},
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error al enviar el código OTP');
    }
  }

  Future<AuthResponse> validateOTP(String phoneNumber, String code) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/validate-otp',
        data: {
          'phone': phoneNumber,
          'code': code,
        },
      );

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(response.data);
      }

      throw Exception('Error de autenticación');
    } catch (e) {
      throw Exception('Error al validar el código OTP');
    }
  }
}
