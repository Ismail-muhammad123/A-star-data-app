enum SupportCategories { transaction, wallet, account, other }

class SupportTicket {
  final int? id;
  final String subject;
  final String? description;
  final SupportCategories category;
  final String status; // 'open', 'closed'
  final DateTime createdAt;
  final DateTime updatedAt;

  SupportTicket({
    required this.id,
    required this.subject,
    this.description,
    required this.category,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      id: json['id'],
      subject: json['subject'],
      status: json['status'],
      description: json['description'],
      category: SupportCategories.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => SupportCategories.other,
      ),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "subject": subject,
    "status": status,
    "description": description,
    "category": category.name,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}

class SupportMessage {
  final int id;
  final String sender; // 'user', 'admin'
  final String text;
  final bool isAdmin;
  final DateTime createdAt;

  SupportMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.createdAt,
    required this.isAdmin,
  });
  factory SupportMessage.fromJson(Map<String, dynamic> json) {
    return SupportMessage(
      id: json['id'],
      sender: json['sender_name'],
      isAdmin: json['is_admin'],
      text: json['message'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
