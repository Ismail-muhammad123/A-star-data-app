class TransferBeneficiary {
  final int id;
  final String bankName;
  final String bankCode;
  final String accountNumber;
  final String accountName;
  final String nickname;

  TransferBeneficiary({
    required this.id,
    required this.bankName,
    required this.bankCode,
    required this.accountNumber,
    required this.accountName,
    this.nickname = '',
  });

  factory TransferBeneficiary.fromJson(Map<String, dynamic> json) {
    return TransferBeneficiary(
      id: json['id'] ?? 0,
      bankName: json['bank_name'] ?? '',
      bankCode: json['bank_code'] ?? '',
      accountNumber: json['account_number'] ?? '',
      accountName: json['account_name'] ?? '',
      nickname: json['nickname'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bank_name': bankName,
      'bank_code': bankCode,
      'account_number': accountNumber,
      'account_name': accountName,
      'nickname': nickname,
    };
  }
}
