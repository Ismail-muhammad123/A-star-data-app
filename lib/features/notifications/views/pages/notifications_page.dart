import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/features/notifications/providers/notification_provider.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      context.read<NotificationProvider>().fetchNotifications(auth.authToken ?? "");
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notificationProvider = context.watch<NotificationProvider>();
    final notifications = notificationProvider.notifications;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Notifications", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          if (notifications.any((n) => !n.isRead))
            TextButton(
              onPressed: () {
                final auth = context.read<AuthProvider>();
                notificationProvider.markAllAsRead(auth.authToken ?? "");
              },
              child: const Text("Mark all read", style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final auth = context.read<AuthProvider>();
          await notificationProvider.fetchNotifications(auth.authToken ?? "");
        },
        child: notificationProvider.isLoading && notifications.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : notifications.isEmpty
                ? _buildEmptyState(context)
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: notifications.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final n = notifications[index];
                      return _buildNotificationItem(n, theme);
                    },
                  ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        Center(
          child: Column(
            children: [
              Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey[300]),
              const SizedBox(height: 16),
              const Text("No Notifications Yet", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("Stay tuned! We'll notify you here.", style: TextStyle(color: Colors.grey[400])),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationItem(dynamic n, ThemeData theme) {
    final auth = context.read<AuthProvider>();
    return InkWell(
      onTap: () {
        if (!n.isRead) {
          context.read<NotificationProvider>().markAsRead(auth.authToken ?? "", n.id);
        }
        _showNotificationDialog(n);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        color: n.isRead ? Colors.transparent : theme.colorScheme.primary.withOpacity(0.05),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: n.isRead ? Colors.grey[100] : theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                n.isRead ? Icons.notifications_none : Icons.notifications_active,
                size: 20,
                color: n.isRead ? Colors.grey : theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          n.title,
                          style: TextStyle(
                            fontWeight: n.isRead ? FontWeight.w500 : FontWeight.bold,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        DateFormat('MMM dd').format(n.createdAt),
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    n.message,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (!n.isRead)
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 4),
                child: CircleAvatar(radius: 4, backgroundColor: theme.colorScheme.primary),
              ),
          ],
        ),
      ),
    );
  }

  void _showNotificationDialog(dynamic n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(n.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: SingleChildScrollView(child: Text(n.message, style: const TextStyle(fontSize: 14, height: 1.5))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Close")),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
