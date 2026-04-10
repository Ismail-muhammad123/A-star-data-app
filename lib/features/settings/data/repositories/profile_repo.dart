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
      print(response.data);

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
    Map<String, dynamic> updatedData, {
    String? profileImagePath,
  }) async {
    try {
      dynamic data;
      Map<String, dynamic> headers = {'Authorization': "Bearer $authToken"};

      if (profileImagePath != null) {
        data = FormData.fromMap({
          ...updatedData,
          'profile_image': await MultipartFile.fromFile(
            profileImagePath,
            filename: profileImagePath.split('/').last,
          ),
        });
        // Dio handles content-type for FormData automatically
      } else {
        data = jsonEncode(updatedData);
        headers['Content-Type'] = 'application/json';
      }

      final response = await _dio.put(
        profileEndpoints.updateProfile,
        data: data,
        options: Options(validateStatus: (status) => true, headers: headers),
      );
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> setTwoFactorStatus(String authToken, bool enabled) async {
    final payloadCandidates = <Map<String, dynamic>>[
      {'requires_2fa': enabled},
      {'two_factor_enabled': enabled},
      {'two_fa_enabled': enabled},
      {'is_2fa_enabled': enabled},
    ];

    String? lastError;

    for (final payload in payloadCandidates) {
      try {
        final response = await _dio.put(
          profileEndpoints.updateProfile,
          data: jsonEncode(payload),
          options: Options(
            validateStatus: (status) => true,
            headers: {
              'Authorization': "Bearer $authToken",
              'Content-Type': 'application/json',
            },
          ),
        );

        if (response.statusCode != null &&
            response.statusCode! >= 200 &&
            response.statusCode! < 300) {
          return;
        }
        lastError = _extractErrorMessage(response.data);
      } catch (e) {
        lastError = e.toString();
      }
    }

    throw Exception(lastError ?? 'Unable to update 2FA setting right now.');
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
        WalletEndpoints().banks,
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

  String? _extractErrorMessage(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      for (final key in ['detail', 'error', 'message']) {
        final value = responseData[key];
        if (value is String && value.trim().isNotEmpty) {
          return value.trim();
        }
      }
    }
    return null;
  }
}
