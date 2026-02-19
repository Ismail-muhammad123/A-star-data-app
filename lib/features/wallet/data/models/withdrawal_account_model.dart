class WithdrawalAccount {
  final String bankName;
  final String bankCode;
  final String accountNumber;
  final String accountName;

  WithdrawalAccount({
    required this.bankName,
    required this.bankCode,
    required this.accountNumber,
    required this.accountName,
  });

  factory WithdrawalAccount.fromJson(Map<String, dynamic> json) {
    return WithdrawalAccount(
      bankName: json['bank_name'] ?? '',
      bankCode: json['bank_code'] ?? '',
      accountNumber: json['account_number'] ?? '',
      accountName: json['account_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bank_name': bankName,
      'bank_code': bankCode,
      'account_number': accountNumber,
      'account_name': accountName,
    };
  }
}
