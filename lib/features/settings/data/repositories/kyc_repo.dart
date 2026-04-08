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
        headers: {'Authorization': 'Bearer $authToken'},
      ),
    );
    print(response.data);

    if (response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    } else {
      throw Exception(response.data['detail'] ?? 'Failed to fetch KYC status');
    }
  }

  Future<void> submitKyc(String authToken, Map<String, dynamic> data) async {
    final formData = FormData.fromMap({
      'id_type': data['id_type'],
      'id_number': data['id_number'],
      if (data['id_image'] != null)
        'id_image': await MultipartFile.fromFile(data['id_image']),
      if (data['face_image'] != null)
        'face_image': await MultipartFile.fromFile(data['face_image']),
    });

    final response = await _dio.post(
      endpoints.submit,
      data: formData,
      options: Options(
        validateStatus: (status) => true,
        headers: {'Authorization': 'Bearer $authToken'},
      ),
    );
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(response.data['detail'] ?? 'Failed to submit KYC');
    }
  }
}
