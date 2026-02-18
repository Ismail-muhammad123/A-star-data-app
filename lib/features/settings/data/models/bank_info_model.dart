class BankInformationModel {
  final int? user;
  final String accountNumber;
  final String accountName;
  final String bankName;
  final String latUpdatedAt;

  BankInformationModel({
    this.user,
    required this.accountNumber,
    required this.accountName,
    required this.bankName,
    required this.latUpdatedAt,
  });
  factory BankInformationModel.fromJson(Map<String, dynamic> json) {
    return BankInformationModel(
      user: json['user'],
      accountNumber: json['account_number'],
      accountName: json['account_name'],
      bankName: json['bank_name'],
      latUpdatedAt: json['last_updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user,
      'account_number': accountNumber,
      'account_name': accountName,
      'bank_name': bankName,
      'last_updated_at': latUpdatedAt,
    };
  }
}
