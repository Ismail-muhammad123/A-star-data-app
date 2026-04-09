import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:app/core/constants/api_endpoints.dart';

class P2PException implements Exception {
  final String message;

  const P2PException(this.message);

  @override
  String toString() => message;
}

class P2PService {
  final Dio _dio = Dio();
  final P2PEndpoints endpoints = P2PEndpoints();

  Future<Map<String, dynamic>> lookupUser(
    String authToken,
    String identifier,
  ) async {
    try {
      final response = await _dio.get(
        endpoints.lookup,
        queryParameters: {'phone_number': identifier},
        options: Options(
          validateStatus: (status) => true,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $authToken',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      throw P2PException(_extractErrorMessage(response.data) ?? 'User not found');
    } on DioException {
      throw const P2PException(
        'Unable to verify recipient right now. Please check your connection and try again.',
      );
    }
  }

  Future<void> executeTransfer({
    required String authToken,
    required String recipientIdentifier,
    required double amount,
    required String pin,
    String? note,
  }) async {
    try {
      final response = await _dio.post(
        endpoints.transfer,
        data: jsonEncode({
          'recipient': recipientIdentifier,
          'amount': amount,
          'pin': pin,
          'note': note,
        }),
        options: Options(
          validateStatus: (status) => true,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $authToken',
          },
        ),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw P2PException(_extractErrorMessage(response.data) ?? 'Transfer failed');
      }
    } on DioException {
      throw const P2PException(
        'Transfer failed. Please check your internet connection and try again.',
      );
    }
  }

  String? _extractErrorMessage(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      for (final key in ['detail', 'error', 'message']) {
        final value = responseData[key];
        if (value is String && value.trim().isNotEmpty) {
          return value.trim();
        }
      }
    }
    return null;
  }
}
