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
      id: json['id'],
      serviceName: json['service_name'],
      serviceId: json['service_id'],
      imageUrl: json['image_url'],
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

// AIRTIME NETWORKS
class AirtimeNetwork {
  final int? id;
  final String serviceName;
  final String serviceId;
  // final double minimumAmount;
  // final double maximumAmount;
  final String imageUrl;

  AirtimeNetwork({
    required this.id,
    required this.serviceName,
    required this.serviceId,
    // required this.minimumAmount,
    // required this.maximumAmount,
    required this.imageUrl,
  });

  factory AirtimeNetwork.fromJson(Map<String, dynamic> json) {
    return AirtimeNetwork(
      id: json['id'],
      serviceName: json['service_name'],
      serviceId: json['service_id'],
      // minimumAmount: (json['minimum_amount'] as num).toDouble(),
      // maximumAmount: (json['maximum_amount'] as num).toDouble(),
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_name': serviceName,
      'service_id': serviceId,
      // 'minimum_amount': minimumAmount,
      // 'maximum_amount': maximumAmount,
      'image_url': imageUrl,
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
      id: json['id'],
      serviceName: json['service_name'],
      serviceId: json['service_id'],
      imageUrl: json['image_url'],
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
      id: json['id'],
      serviceName: json['service_name'],
      serviceId: json['service_id'],
      imageUrl: json['image_url'],
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
      name: json['name'],
      service: CableTVService.fromJson(json['service']),
      variationId: json['variation_id'],
      description: json['description'],
      sellingPrice: double.tryParse(json['selling_price']) ?? 0.0,
      isActive: json['is_active'],
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
  final bool isActive;

  DataBundle({
    this.id,
    this.description,
    required this.name,
    required this.service,
    required this.variationId,
    required this.sellingPrice,
    required this.durationDays,
    required this.isActive,
  });

  factory DataBundle.fromJson(Map<String, dynamic> json) {
    return DataBundle(
      id: json['id'],
      name: json['name'],
      service: DataNetwork.fromJson(json['service']),
      variationId: json['variation_id'],
      description: json['description'],
      sellingPrice: double.tryParse(json['selling_price']) ?? 0.0,
      durationDays: json['duration_days'],
      isActive: json['is_active'],
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
      'duration_days': durationDays,
      'is_active': isActive,
    };
  }
}

// ORDER HISTORY
class OrderHistory {
  int id;
  final String purchaseType;
  final int? airtimeService;
  final int? dataVariation;
  final String reference;
  final double amount;
  final String beneficiary;
  final String status;
  final DateTime time;

  OrderHistory({
    required this.id,
    required this.purchaseType,
    required this.airtimeService,
    required this.dataVariation,
    required this.reference,
    required this.amount,
    required this.beneficiary,
    required this.status,
    required this.time,
  });

  factory OrderHistory.fromJson(Map<String, dynamic> json) {
    return OrderHistory(
      id: json['id'],
      purchaseType: json['purchase_type'],
      airtimeService: json['airtime_service'],
      dataVariation: json['data_variation'],
      reference: json['reference'],
      amount: double.parse(json['amount']),
      beneficiary: json['beneficiary'],
      status: json['status'],
      time: DateTime.parse(json['time']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'purchase_type': purchaseType,
      'airtime_service': airtimeService,
      'data_variation': dataVariation,
      'reference': reference,
      'amount': amount,
      'beneficiary': beneficiary,
      'status': status,
      'time': time.toIso8601String(),
    };
  }
}
