// DATA NETWORKS
class DataNetwork {
  final int id;
  final String serviceName;
  final String serviceId;
  final String imageUrl;

  DataNetwork({
    required this.id,
    required this.serviceName,
    required this.serviceId,
    required this.imageUrl,
  });
  factory DataNetwork.fromJson(Map<String, dynamic> json) {
    return DataNetwork(
      id:
          json['id'] is int
              ? json['id']
              : (int.tryParse(json['id'].toString()) ?? 0),
      serviceName: json['service_name'] ?? "",
      serviceId: json['service_id'] ?? "",
      imageUrl: json['image'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_name': serviceName,
      'service_id': serviceId,
      'image': imageUrl,
    };
  }
}

// AIRTIME NETWORKS
class AirtimeNetwork {
  final int? id;
  final String serviceName;
  final String serviceId;
  final double minimumAmount;
  final double maximumAmount;
  final String imageUrl;
  final bool isActive;
  final String discount;
  final String agentDiscount;

  AirtimeNetwork({
    required this.id,
    required this.serviceName,
    required this.serviceId,
    required this.minimumAmount,
    required this.maximumAmount,
    required this.imageUrl,
    required this.isActive,
    required this.discount,
    required this.agentDiscount,
  });

  factory AirtimeNetwork.fromJson(Map<String, dynamic> json) {
    return AirtimeNetwork(
      id:
          json['id'] is int
              ? json['id']
              : (int.tryParse(json['id'].toString())),
      serviceName: json['service_name'] ?? "",
      serviceId: json['service_id'] ?? "",
      minimumAmount: double.tryParse(json['min_amount'].toString()) ?? 0.0,
      maximumAmount: double.tryParse(json['max_amount'].toString()) ?? 0.0,
      imageUrl: json['image'] ?? "",
      isActive: json['is_active'] ?? true,
      discount: json['discount']?.toString() ?? '0',
      agentDiscount: json['agent_discount']?.toString() ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_name': serviceName,
      'service_id': serviceId,
      'min_amount': minimumAmount,
      'max_amount': maximumAmount,
      'image': imageUrl,
      'is_active': isActive,
      'discount': discount,
      'agent_discount': agentDiscount,
    };
  }
}

// Electricity Service
class ElectricityService {
  final int? id;
  final String serviceName;
  final String serviceId;
  final String? imageUrl;

  ElectricityService({
    required this.id,
    required this.serviceName,
    required this.serviceId,
    required this.imageUrl,
  });

  factory ElectricityService.fromJson(Map<String, dynamic> json) {
    return ElectricityService(
      id:
          json['id'] is int
              ? json['id']
              : (int.tryParse(json['id'].toString())),
      serviceName: json['service_name'] ?? "",
      serviceId: json['service_id'] ?? "",
      imageUrl: json['image_url'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_name': serviceName,
      'service_id': serviceId,
      'image_url': imageUrl,
    };
  }
}

// Cable TV Service
class CableTVService {
  final int? id;
  final String serviceName;
  final String serviceId;
  final String? imageUrl;
  CableTVService({
    required this.id,
    required this.serviceName,
    required this.serviceId,
    required this.imageUrl,
  });
  factory CableTVService.fromJson(Map<String, dynamic> json) {
    return CableTVService(
      id:
          json['id'] is int
              ? json['id']
              : (int.tryParse(json['id'].toString())),
      serviceName: json['service_name'] ?? "",
      serviceId: json['service_id'] ?? "",
      imageUrl: json['image_url'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_name': serviceName,
      'service_id': serviceId,
      'image_url': imageUrl,
    };
  }
}

// Cable TV Packages
class CableTVPackage {
  final int? id;
  final String name;
  final CableTVService service;
  final String variationId;
  final String? description;
  final double sellingPrice;
  final bool isActive;
  CableTVPackage({
    this.id,
    this.description,
    required this.name,
    required this.service,
    required this.variationId,
    required this.sellingPrice,
    required this.isActive,
  });

  factory CableTVPackage.fromJson(Map<String, dynamic> json) {
    return CableTVPackage(
      id: json['id'],
      name: json['name'] ?? "",
      service: CableTVService.fromJson(json['service']),
      variationId: json['variation_id']?.toString() ?? "",
      description: json['description'],
      sellingPrice: double.tryParse(json['selling_price'].toString()) ?? 0.0,
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'service': service.toJson(),
      'variation_id': variationId,
      'description': description,
      'selling_price': sellingPrice,
      'is_active': isActive,
    };
  }
}

// DATA BUNDLES
class DataBundle {
  final int? id;
  final String name;
  final DataNetwork service;
  final String variationId;
  final String? description;
  final double sellingPrice;
  final int? durationDays;
  final double? agentPrice;
  final bool isActive;
  final String? planType;

  DataBundle({
    this.id,
    this.description,
    required this.name,
    required this.service,
    required this.variationId,
    required this.sellingPrice,
    this.agentPrice,
    required this.durationDays,
    required this.isActive,
    this.planType,
  });

  factory DataBundle.fromJson(Map<String, dynamic> json) {
    return DataBundle(
      id: json['id'],
      name: json['name'],
      service: DataNetwork.fromJson(json['service']),
      variationId: json['variation_id'],
      description: json['description'],
      sellingPrice: double.tryParse(json['selling_price'].toString()) ?? 0.0,
      agentPrice:
          json['agent_price'] != null
              ? double.tryParse(json['agent_price'].toString())
              : null,
      durationDays: json['duration_days'],
      isActive: json['is_active'],
      planType: json['plan_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'service': service.toJson(),
      'variation_id': variationId,
      'description': description,
      'selling_price': sellingPrice,
      'agent_price': agentPrice,
      'duration_days': durationDays,
      'is_active': isActive,
      'plan_type': planType,
    };
  }
}

// EDUCATION SERVICES
class EducationService {
  final int? id;
  final String serviceName;
  final String serviceId;
  final String? imageUrl;
  EducationService({
    required this.id,
    required this.serviceName,
    required this.serviceId,
    required this.imageUrl,
  });
  factory EducationService.fromJson(Map<String, dynamic> json) {
    return EducationService(
      id:
          json['id'] is int
              ? json['id']
              : int.tryParse(json['id']?.toString() ?? ""),
      serviceName: json['service_name'] ?? "",
      serviceId: json['service_id'] ?? "",
      imageUrl: json['image_url'] ?? "",
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_name': serviceName,
      'service_id': serviceId,
      'image_url': imageUrl,
    };
  }
}

class EducationPackage {
  final int? id;
  final String name;
  final EducationService service;
  final String variationId;
  final double sellingPrice;
  final bool isActive;
  EducationPackage({
    this.id,
    required this.name,
    required this.service,
    required this.variationId,
    required this.sellingPrice,
    required this.isActive,
  });
  factory EducationPackage.fromJson(Map<String, dynamic> json) {
    return EducationPackage(
      id:
          json['id'] is int
              ? json['id']
              : int.tryParse(json['id']?.toString() ?? ""),
      name: json['name'] ?? "",
      service: EducationService.fromJson(json['service']),
      variationId: json['variation_id']?.toString() ?? "",
      sellingPrice: double.tryParse(json['selling_price'].toString()) ?? 0.0,
      isActive: json['is_active'] ?? true,
    );
  }
}

// INTERNET SERVICES
class InternetService {
  final int id;
  final String serviceName;
  final String serviceId;
  final int? provider;
  final String? providerName;
  final String? image;
  final bool isActive;

  InternetService({
    required this.id,
    required this.serviceName,
    required this.serviceId,
    this.provider,
    this.providerName,
    this.image,
    required this.isActive,
  });

  factory InternetService.fromJson(Map<String, dynamic> json) {
    return InternetService(
      id:
          json['id'] is int
              ? json['id']
              : (int.tryParse(json['id'].toString()) ?? 0),
      serviceName: json['service_name'] ?? "",
      serviceId: json['service_id'] ?? "",
      provider:
          json['provider'] is int
              ? json['provider']
              : (int.tryParse(json['provider'].toString())),
      providerName: json['provider_name'],
      image: json['image'] ?? "",
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_name': serviceName,
      'service_id': serviceId,
      'provider': provider,
      'provider_name': providerName,
      'image': image,
      'is_active': isActive,
    };
  }
}

// INTERNET PACKAGES
class InternetPackage {
  final int id;
  final String name;
  final InternetService service;
  final String? providerName;
  final String variationId;
  final double sellingPrice;
  final double? agentPrice;
  final String? planType;
  final bool isActive;

  InternetPackage({
    required this.id,
    required this.name,
    required this.service,
    this.providerName,
    required this.variationId,
    required this.sellingPrice,
    this.agentPrice,
    this.planType,
    required this.isActive,
  });

  factory InternetPackage.fromJson(Map<String, dynamic> json) {
    return InternetPackage(
      id:
          json['id'] is int
              ? json['id']
              : (int.tryParse(json['id'].toString()) ?? 0),
      name: json['name'] ?? "",
      service: InternetService.fromJson(json['service']),
      providerName: json['provider_name'],
      variationId: json['variation_id']?.toString() ?? "",
      sellingPrice: double.tryParse(json['selling_price'].toString()) ?? 0.0,
      agentPrice:
          json['agent_price'] != null
              ? double.tryParse(json['agent_price'].toString())
              : null,
      planType: json['plan_type'],
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'service': service.toJson(),
      'provider_name': providerName,
      'variation_id': variationId,
      'selling_price': sellingPrice,
      'agent_price': agentPrice,
      'plan_type': planType,
      'is_active': isActive,
    };
  }
}

// ORDER HISTORY
class OrderHistory {
  int id;
  final String purchaseType;
  final String reference;
  final double amount;
  final String beneficiary;
  final String status;
  final DateTime time;
  final String? remarks;
  final String? initiator;
  final int? airtimeService;
  final int? dataVariation;
  final int? electricityService;
  final int? electricityVariation;
  final int? tvVariation;
  final int? internetVariation;
  final int? educationVariation;
  final String? token;

  OrderHistory({
    required this.id,
    required this.purchaseType,
    required this.reference,
    required this.amount,
    required this.beneficiary,
    required this.status,
    required this.time,
    this.remarks,
    this.initiator,
    this.airtimeService,
    this.dataVariation,
    this.electricityService,
    this.electricityVariation,
    this.tvVariation,
    this.internetVariation,
    this.educationVariation,
    this.token,
  });

  factory OrderHistory.fromJson(Map<String, dynamic> json) {
    return OrderHistory(
      id: json['id'],
      purchaseType: json['purchase_type'],
      reference: json['reference'],
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      beneficiary: json['beneficiary'] ?? "",
      status: json['status'],
      time: DateTime.parse(json['time']),
      remarks: json['remarks'],
      initiator: json['initiator'],
      airtimeService: json['airtime_service'],
      dataVariation: json['data_variation'],
      electricityService: json['electricity_service'],
      electricityVariation: json['electricity_variation'],
      tvVariation: json['tv_variation'],
      internetVariation: json['internet_variation'],
      educationVariation: json['education_variation'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'purchase_type': purchaseType,
      'reference': reference,
      'amount': amount,
      'beneficiary': beneficiary,
      'status': status,
      'time': time.toIso8601String(),
      'remarks': remarks,
      'initiator': initiator,
      'airtime_service': airtimeService,
      'data_variation': dataVariation,
      'electricity_service': electricityService,
      'electricity_variation': electricityVariation,
      'tv_variation': tvVariation,
      'internet_variation': internetVariation,
      'education_variation': educationVariation,
      'token': token,
    };
  }
}
