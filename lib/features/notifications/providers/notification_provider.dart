import 'package:flutter/foundation.dart';
import 'package:app/features/notifications/data/models/notification_model.dart';
import 'package:app/features/notifications/data/repositories/notification_repo.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingAnnouncements = false;
  bool get isLoadingAnnouncements => _isLoadingAnnouncements;

  List<AppNotification> _notifications = [];
  List<AppNotification> get notifications => _notifications;

  List<Announcement> _announcements = [];
  List<Announcement> get announcements => _announcements;

  List<Announcement> get announcementsWithImages =>
      _announcements.where((a) => a.hasImage).toList();

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> fetchNotifications(String authToken) async {
    _isLoading = true;
    notifyListeners();
    try {
      _notifications = await _notificationService.fetchNotifications(authToken);
    } catch (e) {
      debugPrint("Notifications: Error fetching notifications: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAnnouncements(String authToken) async {
    _isLoadingAnnouncements = true;
    notifyListeners();
    try {
      _announcements = await _notificationService.fetchAnnouncements(authToken);
    } catch (e) {
      debugPrint("Notifications: Error fetching announcements: $e");
    } finally {
      _isLoadingAnnouncements = false;
      notifyListeners();
    }
  }

  Future<void> refreshAll(String authToken) async {
    await Future.wait([
      fetchNotifications(authToken),
      fetchAnnouncements(authToken),
    ]);
  }

  Future<void> markAsRead(String authToken, int id) async {
    try {
      await _notificationService.markRead(authToken, id);
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(
          isRead: true,
          readAt: DateTime.now(),
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
      _notifications = _notifications
          .map((n) => n.copyWith(isRead: true, readAt: DateTime.now()))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint("Notifications: Error marking all read: $e");
    }
  }
}
