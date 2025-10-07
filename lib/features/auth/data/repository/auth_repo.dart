import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:app/core/constants/api_endpoints.dart';

class AuthService {
  final Dio _dio = Dio();
  final AuthEndpoints endpoints = AuthEndpoints();
  // Login
  Future<Map<String, dynamic>> login(String phoneNumber, String pin) async {
    final response = await _dio.post(
      endpoints.login,
      options: Options(
        validateStatus: (status) => true,
        headers: {'Content-Type': 'application/json'},
      ),
      data: jsonEncode({'phone_number': phoneNumber, 'pin': pin}),
    );
    print(response.data);
    if (response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    } else {
      throw Exception(response.data['detail'] ?? 'Failed to login');
    }
  }

  // Register
  Future<Map<String, dynamic>?> register(
    String phone,
    String pin, {
    String countryCode = "+234",
    String email = "",
  }) async {
    final response = await _dio.post(
      endpoints.register,
      options: Options(
        validateStatus: (status) => true,
        headers: {'Content-Type': 'application/json'},
      ),
      data: jsonEncode({
        "phone_country_code": countryCode,
        "phone_number": phone,
        "pin": pin,
        "email": email,
      }),
    );
    print(response.statusCode);
    if (response.statusCode == 201 || response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    } else {
      print(response);
      throw Exception(response.data['error'] ?? 'Failed to register');
    }
  }

  //REFRESH TOKEN
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final response = await _dio.post(
      endpoints.refresh,
      options: Options(
        validateStatus: (status) => true,
        headers: {'Content-Type': 'application/json'},
      ),
      data: jsonEncode({'refresh': refreshToken}),
    );
    print("TOKEN REFRESHED");
    print(response);
    if (response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    } else {
      throw Exception('Failed to refresh token');
    }
  }

  // // Logout
  Future<void> logout(String token) async {
    final response = await _dio.post(
      endpoints.logout,
      options: Options(
        validateStatus: (status) => true,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to logout');
    }
  }

  // // Reset password
  Future<void> resetPin(String phoneNumber) async {
    var response = await _dio.post(
      endpoints.resetPin,
      options: Options(
        validateStatus: (status) => true,
        headers: {'Content-Type': 'application/json'},
      ),
      data: jsonEncode({"identifier": phoneNumber}),
    );
    print(response.data);
    if (response.statusCode != 200) {
      throw Exception('Failed to request confirmation email');
    }
  }

  Future<void> confirmPinReset(
    String otp,
    String newPassword,
    String phoneNumber,
  ) async {
    final response = await _dio.post(
      endpoints.confirmPinReset,
      options: Options(
        validateStatus: (status) => true,
        headers: {'Content-Type': 'application/json'},
      ),
      data: jsonEncode({
        "identifier": phoneNumber,
        "otp_code": otp,
        "new_pin": newPassword,
      }),
    );
    print(response.statusCode);
    if (!(response.statusCode == 201 || response.statusCode == 200)) {
      print(response);
      throw Exception('Failed to register');
    }
  }

  // // Request confirmation email
  Future<void> requestConfirmationOTP(String phoneNumber) async {
    var response = await _dio.post(
      endpoints.resendConfirmationOTP,
      options: Options(
        validateStatus: (status) => true,
        headers: {'Content-Type': 'application/json'},
      ),
      data: jsonEncode({"identifier": phoneNumber}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to request confirmation email');
    }
  }

  Future<void> activateAccount(String phoneNumber, String otp) async {
    final response = await _dio.post(
      endpoints.activateAccount,
      options: Options(
        validateStatus: (status) => true,
        headers: {'Content-Type': 'application/json'},
      ),
      data: jsonEncode({"identifier": phoneNumber, "otp": otp}),
    );
    print(response.statusCode);
    if (!(response.statusCode == 201 || response.statusCode == 200)) {
      print(response);
      throw Exception(response.data['error'] ?? 'Failed to register');
    }
  }
}
