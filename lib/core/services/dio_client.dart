import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DioClient {
  /// Returns a Dio client with the Authorization header if a token exists in SharedPreferences.
  static Future<Dio> getAuthorizedClient() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    final dio = Dio(
      BaseOptions(
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        validateStatus: (status) => true,
      ),
    );
    
    // Add logging in debug mode if needed
    // dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
    
    return dio;
  }

  /// Returns a plain Dio client for public endpoints.
  static Dio getPublicClient() {
    return Dio(
      BaseOptions(
        headers: {
          'Content-Type': 'application/json',
        },
        validateStatus: (status) => true,
      ),
    );
  }
}
