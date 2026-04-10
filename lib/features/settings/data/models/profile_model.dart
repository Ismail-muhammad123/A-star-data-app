class UserProfile {
  final String? firstName;
  final String? lastName;
  final String? middleName;
  final String? email;
  final String phoneCountryCode;

  final int tier;
  final String phoneNumber;
  final DateTime createdAt;
  final bool isActive;
  final bool isVerified;
  final bool emailVerified;
  final bool phoneVerified;
  final bool hasTransactionPin;
  final bool twoFactorEnabled;
  final String? profileImage;
  final String? userType;

  String get fullName {
    return '$firstName $lastName';
  }

  UserProfile({
    required this.firstName,
    required this.lastName,
    required this.middleName,
    required this.createdAt,
    required this.phoneNumber,
    this.email,

    this.tier = 1,
    this.isActive = false,
    this.phoneCountryCode = '+234',
    this.isVerified = false,
    this.emailVerified = false,
    this.phoneVerified = false,
    this.hasTransactionPin = false,
    this.twoFactorEnabled = false,
    this.profileImage,
    this.userType = 'customer',
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      firstName: json['first_name'],
      lastName: json['last_name'],
      middleName: json['middle_name'],
      email: json['email'],

      tier: json['tier'] ?? 1,
      phoneNumber: json['phone_number'],
      phoneCountryCode: json['phone_country_code'] ?? '+234',
      isActive: _toBool(json['is_active']),
      isVerified: _toBool(json['is_verified']),
      emailVerified: _toBool(json['email_verified']),
      phoneVerified: _toBool(json['phone_verified']),
      hasTransactionPin: _toBool(json['transaction_pin_set']),
      twoFactorEnabled:
          _toBool(json['requires_2fa']) ||
          _toBool(json['two_factor_enabled']) ||
          _toBool(json['two_fa_enabled']) ||
          _toBool(json['is_2fa_enabled']),
      profileImage: json['profile_image'],
      userType: json['role'],
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

      'tier': tier,
      'phone_country_code': phoneCountryCode,
      'is_active': isActive,
      'is_verified': isVerified,
      'email_verified': emailVerified,
      'phone_verified': phoneVerified,
      'transaction_pin_set': hasTransactionPin,
      'requires_2fa': twoFactorEnabled,
      'profile_image': profileImage,
      'user_type': userType,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get userTypeLabel {
    switch (userType) {
      case 'agent':
        return 'Agent';
      case 'api_developer':
        return 'API/Developer';
      default:
        return 'Customer';
    }
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      final v = value.trim().toLowerCase();
      return v == 'true' || v == '1' || v == 'yes' || v == 'enabled';
    }
    return false;
  }
}
