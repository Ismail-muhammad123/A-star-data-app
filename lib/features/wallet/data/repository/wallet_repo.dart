import 'dart:convert';

import 'package:app/core/constants/api_endpoints.dart';
import 'package:app/features/wallet/data/models/wallet.dart';
import 'package:dio/dio.dart';

class WalletService {
  final WalletEndpoints _endpoints = WalletEndpoints();
  final Dio _dio = Dio();

  Future<String> getBalance(String authToken) async {
    var response = await _dio.get(
      _endpoints.getWallet,
      options: Options(
        validateStatus: (status) => true,
        headers: {
          "Authorization": "Bearer $authToken",
          'Content-Type': 'application/json',
        },
      ),
    );

    print(response);

    if (response.statusCode == 200) {
      return response.data['balance'];
    } else {
      throw Exception('Failed to load wallet balance');
    }
  }

  Future<List<WalletTransaction>> getTransactions(String authToken) async {
    var response = await _dio.get(
      _endpoints.walletTransactions,
      options: Options(
        validateStatus: (status) => true,
        headers: {
          "Authorization": "Bearer $authToken",
          'Content-Type': 'application/json',
        },
      ),
    );

    if (response.statusCode == 200) {
      return (response.data as List)
          .map((e) => WalletTransaction.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      print(response);
      throw Exception('Failed to load wallet transactions');
    }
  }

  Future<WalletTransaction?> getTransactionById(
    String authToken,
    int transactionId,
  ) async {
    var response = await _dio.get(
      "${_endpoints.walletTransactions}$transactionId",
      options: Options(
        validateStatus: (status) => true,
        headers: {
          "Authorization": "Bearer $authToken",
          'Content-Type': 'application/json',
        },
      ),
    );
    print("transaction by id");
    print(response);

    if (response.statusCode == 200) {
      return WalletTransaction.fromJson(response.data);
    } else {
      print(response);
      throw Exception('Failed to load wallet transaction details');
    }
  }

  Future<Map<String, dynamic>?> addFunds(
    String authToken,
    double amount,
  ) async {
    var response = await _dio.post(
      _endpoints.fundWalletViaTransafer,
      data: jsonEncode({"amount": amount}),
      options: Options(
        validateStatus: (status) => true,
        headers: {
          "Authorization": "Bearer $authToken",
          'Content-Type': 'application/json',
        },
      ),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return (response.data as Map<String, dynamic>)['monnify_response'];
    } else {
      throw Exception('Failed to initiate deposit into wallet');
    }
  }

  // Future<Map<String, dynamic>?> withdrawFunds(
  //   String authToken,
  //   double amount,
  // ) async {
  //   var response = await _dio.post(
  //     _endpoints.withdraw,
  //     data: jsonEncode({"amount": amount}),
  //     options: Options(
  //       validateStatus: (status) => true,
  //       headers: {
  //         "Authorization": "Bearer $authToken",
  //         'Content-Type': 'application/json',
  //       },
  //     ),
  //   );

  //   if (response.statusCode == 201) {
  //     return response.data as Map<String, dynamic>;
  //   } else {
  //     throw Exception('Failed to initiate withdrawal request from wallet');
  //   }
  // }
}
