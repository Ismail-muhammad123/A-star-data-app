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
    dynamic channel,
  }) async {
    final Map<String, dynamic> data = {
      "phone_country_code": countryCode,
      "phone_number": phone,
      "pin": pin,
      "email": email,
    };
    if (channel != null) {
      data["channel"] = channel;
    }

    final response = await _dio.post(
      endpoints.register,
      options: Options(
        validateStatus: (status) => true,
        headers: {'Content-Type': 'application/json'},
      ),
      data: jsonEncode(data),
    );
    print(response.data);
    if (response.statusCode == 201 || response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    } else {
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
  Future<void> resetPin(String phoneNumber, {String? channel}) async {
    print(phoneNumber);
    if (phoneNumber.startsWith("0")) {
      phoneNumber = phoneNumber.substring(1, phoneNumber.length);
    }
    print(phoneNumber);
    var data = {"identifier": phoneNumber};
    if (channel != null) {
      data["channel"] = channel;
    }
    var response = await _dio.post(
      endpoints.resetPin,
      options: Options(
        validateStatus: (status) => true,
        headers: {'Content-Type': 'application/json'},
      ),
      data: jsonEncode(data),
    );
    print(response.data);
    if (response.statusCode != 200) {
      throw Exception('Failed to request reset otp');
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
    if (!(response.statusCode == 201 || response.statusCode == 200)) {
      throw Exception('Failed to register');
    }
  }

  // // Request confirmation email
  Future<void> requestConfirmationOTP(
    String identifier, {
    dynamic channel,
  }) async {
    final Map<String, dynamic> data = {"identifier": identifier};
    if (channel != null) {
      data["channel"] = channel;
    }

    var response = await _dio.post(
      endpoints.resendConfirmationOTP,
      options: Options(
        validateStatus: (status) => true,
        headers: {'Content-Type': 'application/json'},
      ),
      data: jsonEncode(data),
    );

    print(response.data);
    if (response.statusCode != 200) {
      throw Exception(
        response.data['error'] ?? 'Failed to request confirmation OTP',
      );
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
    if (!(response.statusCode == 201 || response.statusCode == 200)) {
      throw Exception(response.data['error'] ?? 'Failed to register');
    }
  }

  Future<void> closeAccount(String authToken) async {
    final response = await _dio.post(
      endpoints.closeAccount,
      options: Options(
        validateStatus: (status) => true,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to close account');
    }
  }
}
