import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:app/core/constants/api_endpoints.dart';

class P2PService {
  final Dio _dio = Dio();
  final P2PEndpoints endpoints = P2PEndpoints();

  Future<Map<String, dynamic>> lookupUser(
    String authToken,
    String identifier,
  ) async {
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
    print('Lookup response: ${response.statusCode} - ${response.data}');
    if (response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    } else {
      throw Exception(response.data['detail'] ?? 'User not found');
    }
  }

  Future<void> executeTransfer({
    required String authToken,
    required String recipientIdentifier,
    required double amount,
    required String pin,
    String? note,
  }) async {
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
      throw Exception(response.data['detail'] ?? 'Transfer failed');
    }
  }
}
