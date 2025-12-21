class UserProfile {
  final String? firstName;
  final String? lastName;
  final String? middleName;
  final String? email;
  final String phoneCountryCode;
  final String? bvn;
  final int tier;
  final String phoneNumber;
  final DateTime createdAt;
  final bool isActive;

  UserProfile({
    required this.firstName,
    required this.lastName,
    required this.middleName,
    required this.createdAt,
    required this.phoneNumber,
    this.email,
    this.bvn,
    this.tier = 1,
    this.isActive = false,
    this.phoneCountryCode = '+234',
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      firstName: json['first_name'],
      lastName: json['last_name'],
      middleName: json['middle_name'],
      email: json['email'],
      bvn: json['bvn'],
      tier: json['tier'] ?? 1,
      phoneNumber: json['phone_number'],
      phoneCountryCode: json['phone_country_code'] ?? '+234',
      isActive: json['is_active'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'middle_name': middleName,
      'email': email,
      'phone_number': phoneNumber,
      'bvn': bvn,
      'tier': tier,
      'phone_country_code': phoneCountryCode,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
