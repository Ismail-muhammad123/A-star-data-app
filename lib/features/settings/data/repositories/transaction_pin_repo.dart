import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:app/core/constants/api_endpoints.dart';

class TransactionPinService {
  final Dio _dio = Dio();
  final TransactionPinEndpoints endpoints = TransactionPinEndpoints();

  Future<void> setTransactionPin(String authToken, String pin) async {
    final response = await _dio.post(
      endpoints.setPin,
      options: Options(
        validateStatus: (status) => true,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ),
      data: jsonEncode({'pin': pin}),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(response.data['detail'] ?? 'Failed to set PIN');
    }
  }

  Future<void> changeTransactionPin(String authToken, String oldPin, String newPin) async {
    final response = await _dio.post(
      endpoints.changePin,
      options: Options(
        validateStatus: (status) => true,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ),
      data: jsonEncode({'old_pin': oldPin, 'new_pin': newPin}),
    );
    if (response.statusCode != 200) {
      throw Exception(response.data['detail'] ?? 'Failed to change PIN');
    }
  }

  Future<bool> verifyTransactionPin(String authToken, String pin) async {
    final response = await _dio.post(
      endpoints.verifyPin,
      options: Options(
        validateStatus: (status) => true,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ),
      data: jsonEncode({'pin': pin}),
    );
    if (response.statusCode == 200) {
      return response.data['valid'] ?? true;
    } else {
      throw Exception(response.data['detail'] ?? 'Failed to verify PIN');
    }
  }

  Future<void> requestResetOtp(String authToken) async {
    final response = await _dio.post(
      endpoints.requestResetOtp,
      options: Options(
        validateStatus: (status) => true,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ),
    );
    if (response.statusCode != 200) {
      throw Exception(response.data['detail'] ?? 'Failed to request OTP');
    }
  }

  Future<void> resetTransactionPin(String authToken, String otp, String newPin) async {
    final response = await _dio.post(
      endpoints.resetPin,
      options: Options(
        validateStatus: (status) => true,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ),
      data: jsonEncode({'otp': otp, 'new_pin': newPin}),
    );
    if (response.statusCode != 200) {
      throw Exception(response.data['detail'] ?? 'Failed to reset PIN');
    }
  }
}
