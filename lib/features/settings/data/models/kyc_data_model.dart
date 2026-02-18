class KYCData {
  final int? user;
  final String? bvn;
  final String? nin;
  final String? idImage;
  final bool? isVerified;
  final bool? isApproved;
  final String? submittedAt;
  final String? verifiedAt;
  final String? approvedAt;
  final String? kycStatus;
  final String? feedback;

  KYCData({
    this.user,
    this.bvn,
    this.nin,
    this.idImage,
    this.isVerified,
    this.isApproved,
    this.submittedAt,
    this.verifiedAt,
    this.approvedAt,
    this.kycStatus,
    this.feedback,
  });

  factory KYCData.fromJson(Map<String, dynamic> json) {
    return KYCData(
      user: json['user'],
      bvn: json['bvn'],
      nin: json['nin'],
      idImage: json['is_image'],
      isVerified: json['id_verified'],
      isApproved: json['is_approved'],
      submittedAt: json['submitted_at'],
      verifiedAt: json['verified_at'] ?? '',
      approvedAt: json['approved_at'] ?? '',
      kycStatus: json['kyc_status'],
      feedback: json['feedback'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user,
      'bvn': bvn,
      'nin': nin,
      'id_image': idImage,
      'id_verified': isVerified,
      'is_approved': isApproved,
      'submitted_at': submittedAt,
      'verified_at': verifiedAt,
      'approved_at': approvedAt,
      'kyc_status': kycStatus,
      'feedback': feedback,
    };
  }
}
