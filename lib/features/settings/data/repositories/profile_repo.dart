import 'dart:convert';
import 'package:app/core/constants/api_endpoints.dart';
import 'package:app/features/settings/data/models/bank_info_model.dart';
import 'package:app/features/settings/data/models/profile_model.dart';
import 'package:dio/dio.dart';

class ProfileService {
  final Dio _dio = Dio();
  final ProfileEndpoints profileEndpoints = ProfileEndpoints();

  Future<UserProfile?> fetchUserProfile(String authToken) async {
    try {
      final response = await _dio.get(
        profileEndpoints.getProfile,
        options: Options(
          validateStatus: (status) => true,
          headers: {
            'Authorization': "Bearer $authToken",
            'content-Type': 'application/json',
          },
        ),
      );
      if (response.statusCode == 200) {
        return UserProfile.fromJson(response.data as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateUserProfile(
    String authToken,
    Map<String, dynamic> updatedData,
  ) async {
    try {
      final response = await _dio.put(
        profileEndpoints.updateProfile,
        data: jsonEncode(updatedData),
        options: Options(
          validateStatus: (status) => true,
          headers: {
            'Authorization': "Bearer $authToken",
            'content-Type': 'application/json',
          },
        ),
      );
      // print(response);
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        print(response);
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<bool> changePin(String authToken, String oldPin, String newPin) async {
    try {
      final response = await _dio.post(
        profileEndpoints.changePin,
        data: jsonEncode({"old_pin": oldPin, "new_pin": newPin}),
        options: Options(
          validateStatus: (status) => true,
          headers: {
            'Authorization': "Bearer $authToken",
            'content-Type': 'application/json',
          },
        ),
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<void> upgradeAccount(String authToken) async {
    try {
      final response = await _dio.post(
        profileEndpoints.upgradeAccountTier,
        options: Options(
          validateStatus: (status) => true,
          headers: {
            'Authorization': "Bearer $authToken",
            'content-Type': 'application/json',
          },
        ),
      );
      if (response.statusCode != 200) {
        print(response);
        throw Exception(response.data['error'] ?? "Failed to upgrade account");
      }
    } catch (e) {
      print(e);
      throw Exception("Failed to upgrade account");
    }
  }

  Future<BankInformationModel?> retriveBankInformation(String authToken) async {
    try {
      final response = await _dio.get(
        profileEndpoints.bankInfoRetrive,
        options: Options(
          validateStatus: (status) => true,
          headers: {
            'Authorization': "Bearer $authToken",
            'content-Type': 'application/json',
          },
        ),
      );
      // print(response);
      if (response.statusCode == 200) {
        return BankInformationModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        print('Failed to load bank info: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print(e);
      print('Error fetching bank info: $e');
      return null;
    }
  }

  Future<BankInformationModel?> updateBankInformation(
    String authToken,
    BankInformationModel bankData,
  ) async {
    try {
      final response = await _dio.put(
        profileEndpoints.bankInfoUpdate,
        data: jsonEncode(bankData.toJson()),
        options: Options(
          validateStatus: (status) => true,
          headers: {
            'Authorization': "Bearer $authToken",
            'content-Type': 'application/json',
          },
        ),
      );
      // print(response);
      if (response.statusCode == 200) {
        return BankInformationModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        print('Failed to update bank info: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print(e);
      print('Error updating bank info: $e');
      return null;
    }
  }

  Future<BankInformationModel?> addBankInformation(
    String authToken,
    BankInformationModel bankData,
  ) async {
    try {
      final response = await _dio.post(
        profileEndpoints.bankInfoSubmit,
        data: jsonEncode(bankData.toJson()),
        options: Options(
          validateStatus: (status) => true,
          headers: {
            'Authorization': "Bearer $authToken",
            'content-Type': 'application/json',
          },
        ),
      );
      print(response);
      if (response.statusCode == 201) {
        return BankInformationModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        print('Failed to add bank info: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print(e);
      print('Error adding bank info: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> fetchNigerianBanks(
    String authToken,
  ) async {
    try {
      final response = await _dio.get(
        profileEndpoints.getNigerianBanks,
        options: Options(
          validateStatus: (status) => true,
          headers: {
            'Authorization': "Bearer $authToken",
            'content-Type': 'application/json',
          },
        ),
      );
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data as List);
      } else {
        print('Failed to load Nigerian banks: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print(e);
      print('Error fetching Nigerian banks: $e');
      return [];
    }
  }
}
