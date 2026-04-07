import 'package:flutter/foundation.dart';
import 'package:app/features/notifications/data/models/notification_model.dart';
import 'package:app/features/notifications/data/repositories/notification_repo.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<AppNotification> _notifications = [];
  List<AppNotification> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> fetchNotifications(String authToken) async {
    _isLoading = true;
    notifyListeners();
    try {
      _notifications = await _notificationService.fetchNotifications(authToken);
    } catch (e) {
      debugPrint("Notifications: Error fetching: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String authToken, int id) async {
    try {
      await _notificationService.markRead(authToken, id);
      var index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        var old = _notifications[index];
        _notifications[index] = AppNotification(
          id: old.id,
          title: old.title,
          message: old.message,
          isRead: true,
          createdAt: old.createdAt,
        );
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Notifications: Error marking read: $e");
    }
  }

  Future<void> markAllAsRead(String authToken) async {
    try {
      await _notificationService.markAllRead(authToken);
      _notifications = _notifications.map((n) => AppNotification(
        id: n.id,
        title: n.title,
        message: n.message,
        isRead: true,
        createdAt: n.createdAt,
      )).toList();
      notifyListeners();
    } catch (e) {
      debugPrint("Notifications: Error marking all read: $e");
    }
  }
}
