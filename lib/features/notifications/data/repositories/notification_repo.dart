import 'package:dio/dio.dart';
import 'package:app/core/constants/api_endpoints.dart';
import 'package:app/features/notifications/data/models/notification_model.dart';

class NotificationService {
  final Dio _dio = Dio();
  final NotificationEndpoints endpoints = NotificationEndpoints();

  List<T> _parsePaginatedResults<T>(
    dynamic payload,
    T Function(Map<String, dynamic>) parser,
  ) {
    final results = payload is Map<String, dynamic>
        ? payload['results']
        : payload;

    if (results is! List) return [];

    return results
        .whereType<Map<String, dynamic>>()
        .map(parser)
        .toList();
  }

  Future<List<AppNotification>> fetchNotifications(String authToken) async {
    final response = await _dio.get(
      endpoints.list,
      options: Options(
        validateStatus: (status) => true,
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      ),
    );

    if (response.statusCode == 200) {
      return _parsePaginatedResults<AppNotification>(
        response.data,
        AppNotification.fromJson,
      );
    }

    throw Exception(response.data?['detail'] ?? 'Failed to fetch notifications');
  }

  Future<List<Announcement>> fetchAnnouncements(String authToken) async {
    final response = await _dio.get(
      endpoints.announcements,
      options: Options(
        validateStatus: (status) => true,
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      ),
    );

    if (response.statusCode == 200) {
      return _parsePaginatedResults<Announcement>(
        response.data,
        Announcement.fromJson,
      );
    }

    throw Exception(response.data?['detail'] ?? 'Failed to fetch announcements');
  }

  Future<void> markRead(String authToken, int id) async {
    final response = await _dio.post(
      endpoints.markRead(id),
      options: Options(
        validateStatus: (status) => true,
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(response.data?['detail'] ?? 'Failed to mark notification as read');
    }
  }

  Future<void> markAllRead(String authToken) async {
    final response = await _dio.post(
      endpoints.markAllRead,
      options: Options(
        validateStatus: (status) => true,
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(response.data?['detail'] ?? 'Failed to mark all notifications as read');
    }
  }
}
