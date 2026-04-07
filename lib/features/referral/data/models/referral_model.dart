class ReferralInfo {
  final String referralCode;
  final String referralLink;
  final int referralCount;
  final double referralEarnings;
  final List<ReferredUser> referredUsers;

  ReferralInfo({
    required this.referralCode,
    required this.referralLink,
    required this.referralCount,
    required this.referralEarnings,
    required this.referredUsers,
  });

  factory ReferralInfo.fromJson(Map<String, dynamic> json) {
    return ReferralInfo(
      referralCode: json['referral_code'] ?? '',
      referralLink: json['referral_link'] ?? '',
      referralCount: json['referral_count'] ?? 0,
      referralEarnings: double.tryParse(json['referral_earnings']?.toString() ?? '0.0') ?? 0.0,
      referredUsers: (json['referred_users'] as List? ?? [])
          .map((u) => ReferredUser.fromJson(u))
          .toList(),
    );
  }
}

class ReferredUser {
  final String fullName;
  final DateTime dateJoined;
  final String status; // 'active', 'pending'

  ReferredUser({
    required this.fullName,
    required this.dateJoined,
    required this.status,
  });

  factory ReferredUser.fromJson(Map<String, dynamic> json) {
    return ReferredUser(
      fullName: json['full_name'] ?? 'User',
      dateJoined: DateTime.parse(json['date_joined']),
      status: json['status'] ?? 'pending',
    );
  }
}
