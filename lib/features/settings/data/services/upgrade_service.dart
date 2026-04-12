import 'package:app/core/constants/api_endpoints.dart';
import 'package:dio/dio.dart';

class UpgradeRoleInfo {
  final String toRole;
  final String fee;
  final bool kycRequired;

  UpgradeRoleInfo({
    required this.toRole,
    required this.fee,
    required this.kycRequired,
  });

  factory UpgradeRoleInfo.fromJson(Map<String, dynamic> json) {
    return UpgradeRoleInfo(
      toRole: json['to_role'],
      fee: json['fee'].toString(),
      kycRequired: json['kyc_required'] ?? false,
    );
  }
}

class UpgradeFeesResponse {
  final bool isActive;
  final String currentRole;
  final List<UpgradeRoleInfo> availableUpgrades;

  UpgradeFeesResponse({
    required this.isActive,
    required this.currentRole,
    required this.availableUpgrades,
  });

  factory UpgradeFeesResponse.fromJson(Map<String, dynamic> json) {
    return UpgradeFeesResponse(
      isActive: json['is_active'] ?? false,
      currentRole: json['current_role'] ?? '',
      availableUpgrades:
          (json['available_upgrades'] as List)
              .map((item) => UpgradeRoleInfo.fromJson(item))
              .toList(),
    );
  }
}

class UpgradeService {
  final AccountUpgradeEndpoints _endpoints = AccountUpgradeEndpoints();
  final Dio _dio = Dio();

  Future<UpgradeFeesResponse> fetchUpgradeFees(String authToken) async {
    var response = await _dio.get(
      _endpoints.fees,
      options: Options(
        validateStatus: (status) => true,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ),
    );

    if (response.statusCode == 200) {
      return UpgradeFeesResponse.fromJson(response.data);
    } else {
      throw Exception(response.data['error'] ?? 'Failed to load upgrade fees');
    }
  }

  Future<Map<String, dynamic>> upgradeRole({
    required String authToken,
    required String toRole,
  }) async {
    var response = await _dio.post(
      _endpoints.upgrade,
      data: {'to_role': toRole},
      options: Options(
        validateStatus: (status) => true,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.data;
    } else {
      throw Exception(
        (response.data['error'] ?? 'Upgrade failed').toString().split(":").last,
      );
    }
  }

  Future<Map<String, dynamic>> upgradeToAgentDirect(String authToken) async {
    var response = await _dio.post(
      _endpoints.upgradeAgent,
      options: Options(
        validateStatus: (status) => true,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ),
    );

    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception(response.data['error'] ?? 'Upgrade to agent failed');
    }
  }
}
