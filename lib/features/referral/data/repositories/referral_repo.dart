import 'package:dio/dio.dart';
import 'package:app/core/constants/api_endpoints.dart';
import 'package:app/features/referral/data/models/referral_model.dart';

class ReferralService {
  final Dio _dio = Dio();
  final ReferralEndpoints endpoints = ReferralEndpoints();

  Future<ReferralInfo?> fetchReferralInfo(String authToken) async {
    try {
      final response = await _dio.get(
        endpoints.info,
        options: Options(
          validateStatus: (status) => true,
          headers: {
            'Authorization': 'Bearer $authToken',
            'Content-Type': 'application/json',
          },
        ),
      );
      if (response.statusCode == 200) {
        return ReferralInfo.fromJson(response.data as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
