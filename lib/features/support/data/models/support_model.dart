class SupportTicket {
  final int id;
  final String subject;
  final String status; // 'open', 'closed'
  final DateTime createdAt;
  final DateTime updatedAt;

  SupportTicket({
    required this.id,
    required this.subject,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      id: json['id'],
      subject: json['subject'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

class SupportMessage {
  final int id;
  final int ticketId;
  final String sender; // 'user', 'admin'
  final String text;
  final DateTime createdAt;

  SupportMessage({
    required this.id,
    required this.ticketId,
    required this.sender,
    required this.text,
    required this.createdAt,
  });

  factory SupportMessage.fromJson(Map<String, dynamic> json) {
    return SupportMessage(
      id: json['id'],
      ticketId: json['ticket'],
      sender: json['sender'],
      text: json['text'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
