import 'package:dio/dio.dart';
import 'package:app/core/constants/api_endpoints.dart';

class KycService {
  final Dio _dio = Dio();
  final KycEndpoints endpoints = KycEndpoints();

  Future<Map<String, dynamic>> fetchKycStatus(String authToken) async {
    final response = await _dio.get(
      endpoints.status,
      options: Options(
        validateStatus: (status) => true,
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      ),
    );
    if (response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    } else {
      throw Exception(response.data['detail'] ?? 'Failed to fetch KYC status');
    }
  }

  Future<void> submitKyc(String authToken, Map<String, dynamic> data) async {
    final response = await _dio.post(
      endpoints.submit,
      data: data, // Form data is usually multipart or json. Schema says json/multipart depending on if files are sent.
      options: Options(
        validateStatus: (status) => true,
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      ),
    );
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(response.data['detail'] ?? 'Failed to submit KYC');
    }
  }
}
