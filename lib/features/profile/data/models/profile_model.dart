class UserProfile {
  final String? fullName;
  final String? email;
  final String phoneCountryCode;
  final String phoneNumber;
  final DateTime createdAt;
  final bool isActive;

  UserProfile({
    required this.fullName,
    required this.createdAt,
    required this.phoneNumber,
    this.email,
    this.isActive = false,
    this.phoneCountryCode = '+234',
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      fullName: json['full_name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      phoneCountryCode: json['phone_country_code'] ?? '+234',
      isActive: json['is_active'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'phone_country_code': phoneCountryCode,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
