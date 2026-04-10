import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:app/core/constants/api_endpoints.dart';

class AuthService {
  final Dio _dio = Dio();
  final AuthEndpoints endpoints = AuthEndpoints();

  String _extractError(dynamic responseData, String fallback) {
    if (responseData is Map<String, dynamic>) {
      for (final key in ['detail', 'error', 'message']) {
        final value = responseData[key];
        if (value is String && value.trim().isNotEmpty) {
          return value.trim();
        }
      }
    }
    return fallback;
  }

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
    if (response.statusCode == 200 || response.statusCode == 202) {
      return response.data as Map<String, dynamic>;
    } else {
      throw Exception(_extractError(response.data, 'Failed to login'));
    }
  }

  // Verify 2FA
  Future<Map<String, dynamic>> verify2FA(
    String identifier,
    String otpCode,
  ) async {
    final response = await _dio.post(
      endpoints.verify2FA,
      options: Options(
        validateStatus: (status) => true,
        headers: {'Content-Type': 'application/json'},
      ),
      data: jsonEncode({'identifier': identifier, 'otp_code': otpCode}),
    );
    if (response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    } else {
      throw Exception(_extractError(response.data, 'Failed to verify OTP'));
    }
  }

  // Resend 2FA OTP
  Future<void> resend2FAOtp(String identifier, {String channel = 'sms'}) async {
    final response = await _dio.post(
      endpoints.twoFaResend,
      options: Options(
        validateStatus: (status) => true,
        headers: {'Content-Type': 'application/json'},
      ),
      data: jsonEncode({'identifier': identifier, 'channel': channel}),
    );
    if (response.statusCode != 200) {
      throw Exception(
        _extractError(response.data, 'Failed to resend 2FA code'),
      );
    }
  }

  Future<void> request2FAReset(
    String identifier, {
    String channel = 'sms',
  }) async {
    final response = await _dio.post(
      endpoints.twoFaReset,
      options: Options(
        validateStatus: (status) => true,
        headers: {'Content-Type': 'application/json'},
      ),
      data: jsonEncode({'identifier': identifier, 'channel': channel}),
    );
    if (response.statusCode != 200) {
      throw Exception(
        _extractError(response.data, 'Failed to request 2FA reset code'),
      );
    }
  }

  Future<void> confirm2FAReset(String identifier, String otpCode) async {
    final response = await _dio.put(
      endpoints.twoFaReset,
      options: Options(
        validateStatus: (status) => true,
        headers: {'Content-Type': 'application/json'},
      ),
      data: jsonEncode({'identifier': identifier, 'otp_code': otpCode}),
    );
    if (response.statusCode != 200) {
      throw Exception(_extractError(response.data, 'Failed to reset 2FA'));
    }
  }

  Future<void> update2FASettings({
    required String authToken,
    required bool isEnabled,
    required String twoFactorMethod,
  }) async {
    final response = await _dio.post(
      endpoints.twoFaSettings,
      options: Options(
        validateStatus: (status) => true,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ),
      data: jsonEncode({
        'is_2fa_enabled': isEnabled,
        'two_factor_method': twoFactorMethod,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception(
        _extractError(response.data, 'Failed to update 2FA settings'),
      );
    }
  }

  // Register
  Future<Map<String, dynamic>?> register(
    String phone,
    String pin, {
    String countryCode = "+234",
    String email = "",
    String firstName = "",
    String lastName = "",
    String middleName = "",
    String referralCode = "",
    dynamic channel,
  }) async {
    final Map<String, dynamic> data = {
      "phone_country_code": countryCode,
      "phone_number": phone,
      "pin": pin,
      "email": email,
      "first_name": firstName,
      "last_name": lastName,
      "middle_name": middleName,
    };
    if (referralCode.isNotEmpty) {
      data["referral_code"] = referralCode;
    }
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
    if (phoneNumber.startsWith("0")) {
      phoneNumber = phoneNumber.substring(1, phoneNumber.length);
    }
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
    if (response.statusCode != 200) {
      throw Exception('Failed to request reset otp');
    }
  }

  Future<void> confirmPinReset(
    String otp,
    String newPassword,
    String phoneNumber,
  ) async {
    if (phoneNumber.startsWith("0") && phoneNumber.length > 10) {
      phoneNumber = phoneNumber.substring(1, phoneNumber.length);
    }
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

    if (response.statusCode != 200) {
      throw Exception(
        response.data['error'] ?? 'Failed to request confirmation OTP',
      );
    }
  }

  Future<void> activateAccount(String phoneNumber, String otp) async {
    if (phoneNumber.startsWith("0") && phoneNumber.length > 10) {
      phoneNumber = phoneNumber.substring(1, phoneNumber.length);
    }
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

  Future<void> registerFcmToken({
    required String authToken,
    required String fcmToken,
  }) async {
    final response = await _dio.post(
      endpoints.registerFCM,
      options: Options(
        validateStatus: (status) => true,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ),
      data: jsonEncode({'token': fcmToken, 'fcm_token': fcmToken}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        response.data?['error'] ??
            response.data?['detail'] ??
            'Failed to register FCM token',
      );
    }
  }
}
