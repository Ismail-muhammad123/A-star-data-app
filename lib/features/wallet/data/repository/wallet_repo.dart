import 'dart:convert';
import 'package:app/core/constants/api_endpoints.dart';
import 'package:app/features/wallet/data/models/wallet.dart';
import 'package:app/features/wallet/data/models/withdrawal_account_model.dart';
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

    if (response.statusCode == 200) {
      return response.data['balance'].toString();
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

    if (response.statusCode == 200) {
      return WalletTransaction.fromJson(response.data);
    } else {
      throw Exception('Failed to load wallet transaction details');
    }
  }

  Future<Map<String, dynamic>?> fundWithTransfer(
    String authToken,
    double amount,
  ) async {
    var response = await _dio.post(
      _endpoints.fundWallet,
      data: jsonEncode({"amount": amount, "method": "transfer"}),
      options: Options(
        validateStatus: (status) => true,
        headers: {
          "Authorization": "Bearer $authToken",
          'Content-Type': 'application/json',
        },
      ),
    );
    print(response);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return (response.data as Map<String, dynamic>)['monnify_response'];
    } else {
      throw Exception('Failed to initiate deposit into wallet');
    }
  }

  Future<Map<String, dynamic>?> fundWithCard(
    String authToken,
    double amount,
  ) async {
    var response = await _dio.post(
      _endpoints.fundWallet,
      data: jsonEncode({"amount": amount, "method": "card"}),
      options: Options(
        validateStatus: (status) => true,
        headers: {
          "Authorization": "Bearer $authToken",
          'Content-Type': 'application/json',
        },
      ),
    );
    // print(response);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return (response.data as Map<String, dynamic>)['response'];
    } else {
      throw Exception('Failed to initiate deposit into wallet');
    }
  }

  Future<VirtualAccount> getVirtualAccount(String authToken) async {
    var response = await _dio.get(
      _endpoints.getVirtualAccount,
      options: Options(
        validateStatus: (status) => true,
        headers: {
          "Authorization": "Bearer $authToken",
          'Content-Type': 'application/json',
        },
      ),
    );

    if (response.statusCode == 200) {
      return VirtualAccount.fromJson(response.data);
    } else {
      throw Exception('Failed to load virtual wallet');
    }
  }

  Future<Map<String, dynamic>> requestWithdrawal(
    String authToken,
    double amount,
    String bankName,
    String accountNumber,
    String accountName, {
    String? reason = "",
    String? bankCode = "",
  }) async {
    var response = await _dio.post(
      _endpoints.withdraw,
      data: {
        "amount": amount.toString(),
        "bank_name": bankName,
        "account_number": accountNumber,
        "account_name": accountName,
        "reason": reason,
        "bank_code": bankCode,
      },
      options: Options(
        validateStatus: (status) => true,
        headers: {
          "Authorization": "Bearer $authToken",
          'Content-Type': 'application/json',
        },
      ),
    );
    print(response.data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.data;
    } else {
      throw Exception(
        response.data['message'] ?? 'Failed to request withdrawal',
      );
    }
  }

  Future<List<Map<String, dynamic>>> fetchBanks(String authToken) async {
    try {
      final response = await _dio.get(
        _endpoints.banks,
        options: Options(
          validateStatus: (status) => true,
          headers: {
            'Authorization': "Bearer $authToken",
            'Content-Type': 'application/json',
          },
        ),
      );
      print(response.data);
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data as List);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load banks');
      }
    } catch (e) {
      throw Exception('Error fetching banks: $e');
    }
  }

  Future<String> resolveAccount(
    String authToken,
    String bankCode,
    String accountNumber,
  ) async {
    try {
      final response = await _dio.post(
        _endpoints.resolveAccount,
        data: {'bank_code': bankCode, 'account_number': accountNumber},
        options: Options(
          validateStatus: (status) => true,
          headers: {
            'Authorization': "Bearer $authToken",
            'Content-Type': 'application/json',
          },
        ),
      );
      print(response.data);
      if (response.statusCode == 200) {
        return response.data['account_name'] ?? '';
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to resolve account',
        );
      }
    } catch (e) {
      throw Exception('Error resolving account: $e');
    }
  }

  Future<WithdrawalAccount?> getWithdrawalAccount(String authToken) async {
    try {
      final response = await _dio.get(
        _endpoints.withdrawalAccount,
        options: Options(
          validateStatus: (status) => true,
          headers: {
            'Authorization': "Bearer $authToken",
            'Content-Type': 'application/json',
          },
        ),
      );
      if (response.statusCode == 200) {
        if (response.data == null || (response.data as Map).isEmpty)
          return null;
        return WithdrawalAccount.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<WithdrawalAccount> saveWithdrawalAccount(
    String authToken,
    WithdrawalAccount accountData,
  ) async {
    try {
      final response = await _dio.put(
        _endpoints.withdrawalAccount,
        data: jsonEncode(accountData.toJson()),
        options: Options(
          validateStatus: (status) => true,
          headers: {
            'Authorization': "Bearer $authToken",
            'Content-Type': 'application/json',
          },
        ),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return WithdrawalAccount.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to save withdrawal account',
        );
      }
    } catch (e) {
      throw Exception('Error saving withdrawal account: $e');
    }
  }

  Future<Map<String, dynamic>> getChargesConfig(String authToken) async {
    try {
      final response = await _dio.get(
        _endpoints.chargesConfig,
        options: Options(
          validateStatus: (status) => true,
          headers: {
            'Authorization': "Bearer $authToken",
            'Content-Type': 'application/json',
          },
        ),
      );
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        return {};
      }
    } catch (e) {
      return {};
    }
  }
}
