class PurchaseBeneficiary {
  final int id;
  final String serviceType; // airtime, data, electricity, tv, education, internet
  final String identifier;
  final String nickname;

  PurchaseBeneficiary({
    required this.id,
    required this.serviceType,
    required this.identifier,
    this.nickname = '',
  });

  factory PurchaseBeneficiary.fromJson(Map<String, dynamic> json) {
    return PurchaseBeneficiary(
      id: json['id'] ?? 0,
      serviceType: json['service_type'] ?? '',
      identifier: json['identifier'] ?? '',
      nickname: json['nickname'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'service_type': serviceType,
      'identifier': identifier,
      'nickname': nickname,
    };
  }
}
