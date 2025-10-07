// DATA NETWORKS
class DataNetwork {
  final int id;
  final String name;
  final String serviceId;
  final String imageUrl;

  DataNetwork({
    required this.id,
    required this.name,
    required this.serviceId,
    required this.imageUrl,
  });

  factory DataNetwork.fromJson(Map<String, dynamic> json) {
    return DataNetwork(
      id: json['id'],
      name: json['name'],
      serviceId: json['service_id'],
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'service_id': serviceId,
      'image_url': imageUrl,
    };
  }
}

// AITIME NETWORKS
class AirtimeNetwork {
  final int id;
  final String name;
  final String serviceId;
  final double minimumAmount;
  final double maximumAmount;
  final String imageUrl;

  AirtimeNetwork({
    required this.id,
    required this.name,
    required this.serviceId,
    required this.minimumAmount,
    required this.maximumAmount,
    required this.imageUrl,
  });

  factory AirtimeNetwork.fromJson(Map<String, dynamic> json) {
    return AirtimeNetwork(
      id: json['id'],
      name: json['name'],
      serviceId: json['service_id'],
      minimumAmount: (json['minimum_amount'] as num).toDouble(),
      maximumAmount: (json['maximum_amount'] as num).toDouble(),
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'service_id': serviceId,
      'minimum_amount': minimumAmount,
      'maximum_amount': maximumAmount,
      'image_url': imageUrl,
    };
  }
}

// DATA BUNDLES
class DataBundle {
  final int id;
  final String name;
  final int serviceType;
  final String variationCode;
  final String description;
  final double costPrice;
  final double sellingPrice;
  final int? durationDays;
  final bool isActive;

  DataBundle({
    required this.id,
    required this.name,
    required this.serviceType,
    required this.variationCode,
    required this.description,
    required this.costPrice,
    required this.sellingPrice,
    required this.durationDays,
    required this.isActive,
  });

  factory DataBundle.fromJson(Map<String, dynamic> json) {
    return DataBundle(
      id: json['id'],
      name: json['name'],
      serviceType: json['service_type'],
      variationCode: json['variation_code'],
      description: json['description'],
      costPrice: double.tryParse(json['cost_price']) ?? 0.0,
      sellingPrice: double.tryParse(json['selling_price']) ?? 0.0,
      durationDays: json['duration_days'],
      isActive: json['is_active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'service_type': serviceType,
      'variation_code': variationCode,
      'description': description,
      'cost_price': costPrice,
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
  final int? airtimeType;
  final int? dataPlan;
  final String reference;
  final double amount;
  final String beneficiary;
  final String status;
  final DateTime time;

  OrderHistory({
    required this.id,
    required this.purchaseType,
    required this.airtimeType,
    required this.dataPlan,
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
      airtimeType: json['airtime_type'],
      dataPlan: json['data_plan'],
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
      'airtime_type': airtimeType,
      'data_plan': dataPlan,
      'reference': reference,
      'amount': amount,
      'beneficiary': beneficiary,
      'status': status,
      'time': time.toIso8601String(),
    };
  }
}
