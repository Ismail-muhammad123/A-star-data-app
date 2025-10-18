import 'dart:convert';
import 'dart:typed_data';
import 'package:app/core/constants/api_endpoints.dart';
import 'package:app/features/profile/data/models/kyc_data_model.dart';
import 'package:app/features/profile/data/models/profile_model.dart';
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

  // Future<BankInformationModel?> retriveBankInformation(String authToken) async {
  //   try {
  //     final response = await _dio.get(
  //       profileEndpoints.bankInfoRetrive,
  //       options: Options(
  //         validateStatus: (status) => true,
  //         headers: {
  //           'Authorization': "Bearer $authToken",
  //           'content-Type': 'application/json',
  //         },
  //       ),
  //     );
  //     // print(response);
  //     if (response.statusCode == 200) {
  //       return BankInformationModel.fromJson(
  //         response.data as Map<String, dynamic>,
  //       );
  //     } else {
  //       print('Failed to load bank info: ${response.statusCode}');
  //       return null;
  //     }
  //   } catch (e) {
  //     print(e);
  //     print('Error fetching bank info: $e');
  //     return null;
  //   }
  // }

  // Future<BankInformationModel?> updateBankInformation(
  //   String authToken,
  //   BankInformationModel bankData,
  // ) async {
  //   try {
  //     final response = await _dio.put(
  //       profileEndpoints.bankInfoUpdate,
  //       data: jsonEncode(bankData.toJson()),
  //       options: Options(
  //         validateStatus: (status) => true,
  //         headers: {
  //           'Authorization': "Bearer $authToken",
  //           'content-Type': 'application/json',
  //         },
  //       ),
  //     );
  //     // print(response);
  //     if (response.statusCode == 200) {
  //       return BankInformationModel.fromJson(
  //         response.data as Map<String, dynamic>,
  //       );
  //     } else {
  //       print('Failed to update bank info: ${response.statusCode}');
  //       return null;
  //     }
  //   } catch (e) {
  //     print(e);
  //     print('Error updating bank info: $e');
  //     return null;
  //   }
  // }

  // Future<BankInformationModel?> addBankInformation(
  //   String authToken,
  //   BankInformationModel bankData,
  // ) async {
  //   try {
  //     final response = await _dio.post(
  //       profileEndpoints.bankInfoSubmit,
  //       data: jsonEncode(bankData.toJson()),
  //       options: Options(
  //         validateStatus: (status) => true,
  //         headers: {
  //           'Authorization': "Bearer $authToken",
  //           'content-Type': 'application/json',
  //         },
  //       ),
  //     );
  //     print(response);
  //     if (response.statusCode == 201) {
  //       return BankInformationModel.fromJson(
  //         response.data as Map<String, dynamic>,
  //       );
  //     } else {
  //       print('Failed to add bank info: ${response.statusCode}');
  //       return null;
  //     }
  //   } catch (e) {
  //     print(e);
  //     print('Error adding bank info: $e');
  //     return null;
  //   }
  // }

  // Future<List<Map<String, dynamic>>> fetchNigerianBanks(
  //   String authToken,
  // ) async {
  //   try {
  //     final response = await _dio.get(
  //       profileEndpoints.getNigerianBanks,
  //       options: Options(
  //         validateStatus: (status) => true,
  //         headers: {
  //           'Authorization': "Bearer $authToken",
  //           'content-Type': 'application/json',
  //         },
  //       ),
  //     );
  //     if (response.statusCode == 200) {
  //       return List<Map<String, dynamic>>.from(response.data as List);
  //     } else {
  //       print('Failed to load Nigerian banks: ${response.statusCode}');
  //       return [];
  //     }
  //   } catch (e) {
  //     print(e);
  //     print('Error fetching Nigerian banks: $e');
  //     return [];
  //   }
  // }

  Future<KYCData?> retriveKYCStatus(String authToken) async {
    try {
      final response = await _dio.get(
        profileEndpoints.kycStatus,
        options: Options(
          validateStatus: (status) => true,
          headers: {
            'content-Type': 'application/json',
            'Authorization': "Bearer $authToken",
          },
        ),
      );
      print(response);
      if (response.statusCode == 200) {
        return KYCData.fromJson(response.data as Map<String, dynamic>);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        print('Failed to load KYC status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print(e);
      print('Error fetching KYC status: $e');
      return null;
    }
  }

  updateKYCData(String authToken, KYCData kycData, ByteData imageData) async {
    try {
      final response = await _dio.put(
        profileEndpoints.kycUpdate,
        data: jsonEncode(kycData.toJson()),
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
        return KYCData.fromJson(response.data as Map<String, dynamic>);
      } else {
        print('Failed to update KYC data: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print(e);
      print('Error updating KYC data: $e');
      return null;
    }
  }

  Future<KYCData?> submitKYCData(
    String authToken,
    KYCData kycData,
    ByteData imageData, {
    bool isUpdate = false,
  }) async {
    try {
      // Convert ByteData to List<int>
      final bytes = imageData.buffer.asUint8List();

      // Build FormData
      final formData = FormData.fromMap({
        // Add your JSON fields
        ...kycData.toJson(),

        // Attach image
        'id_image': MultipartFile.fromBytes(
          bytes,
          filename: 'kyc_image.jpg', // you can change the filename
        ),
      });

      Response? response;

      if (isUpdate) {
        response = await _dio.put(
          profileEndpoints.kycUpdate,
          data: formData,
          options: Options(
            validateStatus: (status) => true,
            headers: {
              'Authorization': "Bearer $authToken",
              'Content-Type': 'multipart/form-data',
            },
          ),
        );
      } else {
        response = await _dio.post(
          profileEndpoints.kycSubmit,
          data: formData,
          options: Options(
            validateStatus: (status) => true,
            headers: {
              'Authorization': "Bearer $authToken",
              'Content-Type': 'multipart/form-data',
            },
          ),
        );
      }

      print(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return KYCData.fromJson(response.data as Map<String, dynamic>);
      } else {
        print('Failed to add KYC data: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error adding KYC data: $e');
      return null;
    }
  }
}
