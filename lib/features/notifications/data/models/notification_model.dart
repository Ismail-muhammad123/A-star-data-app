class AppNotification {
  final int id;
  final String title;
  final String body;
  final String channel;
  final String data;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.channel,
    required this.data,
    required this.isRead,
    required this.readAt,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final readAtRaw = json['read_at']?.toString();
    return AppNotification(
      id: json['id'] ?? 0,
      title: (json['title'] ?? '').toString(),
      body: (json['body'] ?? json['message'] ?? '').toString(),
      channel: (json['channel'] ?? '').toString(),
      data: (json['data'] ?? '').toString(),
      isRead: json['is_read'] == true,
      readAt: readAtRaw == null || readAtRaw.isEmpty
          ? null
          : DateTime.tryParse(readAtRaw),
      createdAt:
          DateTime.tryParse((json['created_at'] ?? '').toString()) ??
          DateTime.now(),
    );
  }

  AppNotification copyWith({
    int? id,
    String? title,
    String? body,
    String? channel,
    String? data,
    bool? isRead,
    DateTime? readAt,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      channel: channel ?? this.channel,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class Announcement {
  final int id;
  final String title;
  final String body;
  final String image;
  final String audience;
  final DateTime? startsAt;
  final DateTime? expiresAt;
  final DateTime createdAt;

  Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.image,
    required this.audience,
    required this.startsAt,
    required this.expiresAt,
    required this.createdAt,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    DateTime? parseNullable(dynamic value) {
      if (value == null) return null;
      final str = value.toString();
      if (str.isEmpty) return null;
      return DateTime.tryParse(str);
    }

    return Announcement(
      id: json['id'] ?? 0,
      title: (json['title'] ?? '').toString(),
      body: (json['body'] ?? '').toString(),
      image: (json['image'] ?? '').toString(),
      audience: (json['audience'] ?? '').toString(),
      startsAt: parseNullable(json['starts_at']),
      expiresAt: parseNullable(json['expires_at']),
      createdAt:
          DateTime.tryParse((json['created_at'] ?? '').toString()) ??
          DateTime.now(),
    );
  }

  bool get hasImage => image.trim().isNotEmpty;
}
