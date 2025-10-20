class WalletTransaction {
  final int id;
  final double amount;
  final String transactionType; // 'credit' or 'debit'
  final DateTime timestamp;
  final String description;

  WalletTransaction({
    required this.id,
    required this.amount,
    required this.transactionType,
    required this.timestamp,
    required this.description,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'],
      amount: (num.tryParse(json['amount']) ?? 0).toDouble(),
      transactionType: json['transaction_type'],
      timestamp: DateTime.parse(json['timestamp']),
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'transaction_type': transactionType,
      'timestamp': timestamp.toIso8601String(),
      'description': description,
    };
  }
}

class VirtualAccount {
  final String accountNumber;
  final String bankName;
  final String accountName;
  final String status;

  VirtualAccount({
    required this.accountName,
    required this.bankName,
    required this.accountNumber,
    required this.status,
  });

  factory VirtualAccount.fromJson(Map<String, dynamic> data) {
    return VirtualAccount(
      accountName: data['account_name'],
      bankName: data['bank_name'],
      accountNumber: data['account_number'],
      status: data['status'],
    );
  }
}
