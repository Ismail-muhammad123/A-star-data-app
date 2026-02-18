import 'package:app/core/constants/api_endpoints.dart';
import 'package:app/features/orders/data/models.dart';
import 'package:dio/dio.dart';

class OrderServices {
  final OrderEndpoints _endpoints = OrderEndpoints();
  final Dio _dio = Dio();

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

    if (response.statusCode == 200) {
      List<dynamic> data = response.data;
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

    if (response.statusCode == 200) {
      List<dynamic> data = response.data;
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
      List<dynamic> data = response.data;
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
      List<dynamic> data = response.data;
      return data
          .map((item) => DataBundle.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load data bundles');
    }
  }

  Future<void> purchaseAirtime({
    required String authToken,
    required String serviceId,
    required String phoneNumber,
    required double amount,
  }) async {
    var response = await _dio.post(
      _endpoints.purchaseAirtime,
      data: {
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

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Purchase successful
      return;
    } else {
      throw Exception(response.data['error'] ?? 'Failed to purchase airtime');
    }
  }

  Future<void> purchaseDataBundle({
    required String authToken,
    required int bundleId,
    required String phoneNumber,
  }) async {
    var response = await _dio.post(
      _endpoints.purchaseDataBundle,
      data: {'plan_id': bundleId, 'phone_number': phoneNumber},
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

  Future<List<SmilePackage>> fetchSmilePackages(String authToken) async {
    var response = await _dio.get(
      _endpoints.getSmilePackages,
      options: Options(
        validateStatus: (status) => true,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = response.data;
      return data
          .map((item) => SmilePackage.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load smile packages');
    }
  }

  Future<void> purchaseSmileSubscription({
    required String authToken,
    required int bundleId,
    required String phoneNumber,
  }) async {
    var response = await _dio.post(
      _endpoints.purchaseSmileSubscription,
      data: {'plan_id': bundleId, 'phone_number': phoneNumber},
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
    required String variationId,
    required String customerId,
  }) async {
    var response = await _dio.post(
      _endpoints.verifyCustomer,
      data: {
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
      // Purchase successful
      return (response.data as List)
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
      // Purchase successful
      return (response.data as List)
          .map((item) => CableTVService.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(response.data['error'] ?? 'Failed to load TV services');
    }
  }

  Future<List<CableTVPackage>> fetchTVPackages(
    String authToken,
    String? serviceId,
  ) async {
    var response = await _dio.get(
      _endpoints.getTVPackages,
      queryParameters: serviceId != null ? {'service_id': serviceId} : null,
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
      return (response.data as List)
          .map((item) => CableTVPackage.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(response.data['error'] ?? 'Failed to load TV packages');
    }
  }

  Future<OrderHistory> purchaseElectricity({
    required String authToken,
    required int amount,
    required String serviceId,
    required String variationId,
    required String customerId,
  }) async {
    var response = await _dio.post(
      _endpoints.purchaseElectricity,
      data: {
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
    required int amount,
    required String serviceId,
    required String variationId,
    required String customerId,
    required String subscriptionType,
  }) async {
    var response = await _dio.post(
      _endpoints.purchaseTVSubscription,
      data: {
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
      List<dynamic> data = response.data;
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
}
