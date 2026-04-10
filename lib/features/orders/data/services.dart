import 'package:app/core/constants/api_endpoints.dart';
import 'package:app/features/orders/data/models.dart';
import 'package:dio/dio.dart';

class OrderServices {
  final OrderEndpoints _endpoints = OrderEndpoints();
  final Dio _dio = Dio();

  //======================== AIRTIME ======================================
  Future<List<AirtimeNetwork>> fetchAirtimeNetworks(String authToken) async {
    var response = await _dio.get(
      _endpoints.getAirtimeNetworks,
      options: Options(
        validateStatus: (status) => true,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ),
    );
    print(response.data);

    if (response.statusCode == 200) {
      List<dynamic> data = response.data["results"];
      return data
          .map((item) => AirtimeNetwork.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load airtime networks');
    }
  }

  Future<List<DataNetwork>> fetchDataNetworks(String authToken) async {
    var response = await _dio.get(
      _endpoints.getDataNetworks,
      options: Options(
        validateStatus: (status) => true,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ),
    );
    print(response.data);

    if (response.statusCode == 200) {
      List<dynamic> data = response.data['results'] as List<dynamic>;
      return data
          .map((item) => DataNetwork.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load data networks');
    }
  }

  Future<List<DataBundle>> fetchDataBundles(String authToken) async {
    var response = await _dio.get(
      _endpoints.getDataBundles,
      options: Options(
        validateStatus: (status) => true,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = response.data['results'] as List<dynamic>;
      return data
          .map((item) => DataBundle.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load data bundles');
    }
  }

  Future<List<DataBundle>> fetchDataBundlesByNetwork(
    String authToken,
    int networkId,
  ) async {
    var response = await _dio.get(
      _endpoints.getDataBundles,
      queryParameters: {'network_id': networkId},
      options: Options(
        validateStatus: (status) => true,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ),
    );

    if (response.statusCode == 200) {
      dynamic data = response.data;
      List<dynamic> results =
          (data is Map && data.containsKey('results')) ? data['results'] : data;
      return results
          .map((item) => DataBundle.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load data bundles');
    }
  }

  Future<void> purchaseAirtime({
    required String authToken,
    required String transactionPin,
    required String serviceId,
    required String phoneNumber,
    required double amount,
  }) async {
    var response = await _dio.post(
      _endpoints.purchaseAirtime,
      data: {
        'transaction_pin': transactionPin,
        'service_id': serviceId,
        'phone_number': phoneNumber,
        'amount': amount,
      },
      options: Options(
        validateStatus: (status) => true,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ),
    );
    print(response.data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Purchase successful
      return;
    } else {
      throw Exception(response.data['error'] ?? 'Failed to purchase airtime');
    }
  }

  Future<void> purchaseDataBundle({
    required String authToken,
    required String transactionPin,
    required int bundleId,
    required String phoneNumber,
  }) async {
    var response = await _dio.post(
      _endpoints.purchaseDataBundle,
      data: {
        'transaction_pin': transactionPin,
        'plan_id': bundleId,
        'phone_number': phoneNumber
      },
      options: Options(
        validateStatus: (status) => true,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Purchase successful
      return;
    } else {
      throw Exception(
        response.data['error'] ?? 'Failed to purchase data bundle',
      );
    }
  }

  // Future<List<SmilePackage>> fetchSmilePackages(String authToken) async {
  //   var response = await _dio.get(
  //     _endpoints.getSmilePackages,
  //     options: Options(
  //       validateStatus: (status) => true,
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $authToken',
  //       },
  //     ),
  //   );

  //   if (response.statusCode == 200) {
  //     List<dynamic> data = response.data;
  //     return data
  //         .map((item) => SmilePackage.fromJson(item as Map<String, dynamic>))
  //         .toList();
  //   } else {
  //     throw Exception('Failed to load smile packages');
  //   }
  // }

  Future<void> purchaseSmileSubscription({
    required String authToken,
    required String transactionPin,
    required int bundleId,
    required String phoneNumber,
  }) async {
    var response = await _dio.post(
      _endpoints.purchaseSmileSubscription,
      data: {
        'transaction_pin': transactionPin,
        'plan_id': bundleId,
        'phone_number': phoneNumber
      },
      options: Options(
        validateStatus: (status) => true,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
    } else {
      throw Exception(
        response.data['error'] ?? 'Failed to purchase smile subscription',
      );
    }
  }

  Future<Map<String, dynamic>> verifyCustomer({
    required String authToken,
    required String serviceId,
    required String customerId,
    required String purchaseType,
  }) async {
    var response = await _dio.post(
      _endpoints.verifyCustomer,
      data: {
        'service_id': serviceId,
        'customer_id': customerId,
        'purchase_type': purchaseType,
      },
      options: Options(
        validateStatus: (status) => true,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ),
    );

    print(response.data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Purchase successful
      return response.data as Map<String, dynamic>;
    } else {
      throw Exception(response.data['error'] ?? 'Failed to verify customer');
    }
  }

  Future<List<ElectricityService>> fetchElectricityServices(
    String authToken,
  ) async {
    var response = await _dio.get(
      _endpoints.getElectricityServices,
      options: Options(
        validateStatus: (status) => true,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      dynamic data = response.data;
      List<dynamic> results =
          (data is Map && data.containsKey('results')) ? data['results'] : data;
      return results
          .map(
            (item) => ElectricityService.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } else {
      throw Exception(
        response.data['error'] ?? 'Failed to load electricity services',
      );
    }
  }

  Future<List<CableTVService>> fetchTVServices(String authToken) async {
    var response = await _dio.get(
      _endpoints.getTVServices,
      options: Options(
        validateStatus: (status) => true,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      dynamic data = response.data;
      List<dynamic> results =
          (data is Map && data.containsKey('results')) ? data['results'] : data;
      return results
          .map((item) => CableTVService.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(response.data['error'] ?? 'Failed to load TV services');
    }
  }

  Future<List<CableTVPackage>> fetchTVPackages(
    String authToken,
    int networkId,
  ) async {
    var response = await _dio.get(
      "${_endpoints.getTVServices}$networkId/packages/",
      options: Options(
        validateStatus: (status) => true,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ),
    );
    print("tv packagses");
    print(response.data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      List<dynamic> data = response.data['results'];
      return data
          .map((item) => CableTVPackage.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(response.data['error'] ?? 'Failed to load TV packages');
    }
  }

  Future<OrderHistory> purchaseElectricity({
    required String authToken,
    required String transactionPin,
    required int amount,
    required String serviceId,
    required String variationId,
    required String customerId,
  }) async {
    var response = await _dio.post(
      _endpoints.purchaseElectricity,
      data: {
        'transaction_pin': transactionPin,
        'amount': amount,
        'service_id': serviceId,
        'variation_id': variationId,
        'customer_id': customerId,
      },
      options: Options(
        validateStatus: (status) => true,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return OrderHistory.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw Exception(
        response.data['error'] ?? 'Failed to purchase electricity',
      );
    }
  }

  Future<OrderHistory> purchaseTVSubscription({
    required String authToken,
    required String transactionPin,
    required int amount,
    required String serviceId,
    required String variationId,
    required String customerId,
    required String subscriptionType,
  }) async {
    var response = await _dio.post(
      _endpoints.purchaseTVSubscription,
      data: {
        'transaction_pin': transactionPin,
        "amount": amount,
        "service_id": serviceId,
        "variation_id": variationId,
        "customer_id": customerId,
        "subscription_type": subscriptionType,
      },
      options: Options(
        validateStatus: (status) => true,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return OrderHistory.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw Exception(
        response.data['error'] ?? 'Failed to purchase TV subscription',
      );
    }
  }

  Future<List<OrderHistory>> getTransactions(String authToken) async {
    var response = await _dio.get(
      _endpoints.orderHistory,
      options: Options(
        validateStatus: (status) => true,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ),
    );
    if (response.statusCode == 200) {
      List<dynamic> data = response.data['results'];
      return data
          .map((item) => OrderHistory.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load transactions');
    }
  }

  Future<OrderHistory> fetchOrderById(
    String authToken,
    int transactionId,
  ) async {
    var response = await _dio.get(
      '${_endpoints.orderHistory}$transactionId',
      options: Options(
        validateStatus: (status) => true,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ),
    );

    if (response.statusCode == 200) {
      return OrderHistory.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw Exception('Failed to load order details');
    }
  }

  //======================== INTERNET SERVICES ======================================
  Future<List<InternetService>> fetchInternetServices(String authToken) async {
    var response = await _dio.get(
      _endpoints.getInternetServices,
      options: Options(
        validateStatus: (status) => true,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = response.data['results'];
      return data
          .map((item) => InternetService.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load internet services');
    }
  }

  Future<List<InternetPackage>> fetchInternetPackages(
    String authToken,
    int? networkId,
  ) async {
    String url =
        networkId != null
            ? _endpoints.getInternetPackagesByService(networkId)
            : _endpoints.getInternetPackages;

    var response = await _dio.get(
      url,
      options: Options(
        validateStatus: (status) => true,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = response.data['results'];
      return data
          .map((item) => InternetPackage.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load internet packages');
    }
  }

  Future<OrderHistory> purchaseInternetSubscription({
    required String authToken,
    required String transactionPin,
    required int planId,
    required String phoneNumber,
    String? promoCode,
  }) async {
    var response = await _dio.post(
      _endpoints.purchaseInternetSubscription,
      data: {
        'transaction_pin': transactionPin,
        'plan_id': planId,
        'phone_number': phoneNumber,
        if (promoCode != null) 'promo_code': promoCode,
      },
      options: Options(
        validateStatus: (status) => true,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return OrderHistory.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw Exception(
        response.data['error'] ?? 'Failed to purchase internet subscription',
      );
    }
  }

  //======================== EDUCATION SERVICES ======================================
  Future<List<EducationService>> fetchEducationServices(
    String authToken,
  ) async {
    var response = await _dio.get(
      _endpoints.getEducationServices,
      options: Options(
        validateStatus: (status) => true,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      dynamic data = response.data;
      List<dynamic> results =
          (data is Map && data.containsKey('results')) ? data['results'] : data;
      return results
          .map(
            (item) => EducationService.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } else {
      throw Exception(
        response.data['error'] ?? 'Failed to load education services',
      );
    }
  }

  Future<List<EducationPackage>> fetchEducationPackages(
    String authToken,
    int? networkId,
  ) async {
    var response = await _dio.get(
      "${_endpoints.getEducationServices}$networkId/plans/",
      options: Options(
        validateStatus: (status) => true,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ),
    );
    print(response.data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      dynamic data = response.data;
      List<dynamic> results =
          (data is Map && data.containsKey('results')) ? data['results'] : data;
      return results
          .map(
            (item) => EducationPackage.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } else {
      throw Exception(
        response.data['error'] ?? 'Failed to load education packages',
      );
    }
  }

  Future<OrderHistory> purchaseEducation({
    required String authToken,
    required String transactionPin,
    required String serviceId,
    required String variationId,
    required String phoneNumber,
    String? promoCode,
  }) async {
    var response = await _dio.post(
      _endpoints.purchaseEducation,
      data: {
        'transaction_pin': transactionPin,
        'service_id': serviceId,
        'variation_id': variationId,
        'phone_number': phoneNumber,
        if (promoCode != null) 'promo_code': promoCode,
      },
      options: Options(
        validateStatus: (status) => true,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return OrderHistory.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw Exception(
        response.data['error'] ?? 'Failed to purchase education service',
      );
    }
  }
}
