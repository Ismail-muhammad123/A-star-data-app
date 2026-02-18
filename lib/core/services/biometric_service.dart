import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Check if biometric is available on the device
  Future<bool> isBiometricAvailable() async {
    try {
      final bool canAuthenticateWithBiometrics =
          await _localAuth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();
      return canAuthenticate;
    } on PlatformException catch (e) {
      print('Error checking biometric availability: $e');
      return false;
    }
  }

  // Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print('Error getting available biometrics: $e');
      return [];
    }
  }

  // Authenticate with biometrics
  Future<bool> authenticate({
    String reason = 'Please authenticate to login',
  }) async {
    try {
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
      );
      return didAuthenticate;
    } on PlatformException catch (e) {
      print('Error during biometric authentication: $e');
      return false;
    }
  }

  // Check if biometric login is enabled
  Future<bool> isBiometricLoginEnabled() async {
    final String? enabled = await _secureStorage.read(key: 'biometric_enabled');
    return enabled == 'true';
  }

  // Enable biometric login
  Future<void> enableBiometricLogin() async {
    await _secureStorage.write(key: 'biometric_enabled', value: 'true');
  }

  // Disable biometric login
  Future<void> disableBiometricLogin() async {
    await _secureStorage.delete(key: 'biometric_enabled');
    await _secureStorage.delete(key: 'biometric_refresh_token');
  }

  // Save refresh token securely for biometric login
  Future<void> saveRefreshTokenSecurely(String refreshToken) async {
    await _secureStorage.write(
      key: 'biometric_refresh_token',
      value: refreshToken,
    );
  }

  // Get securely saved refresh token
  Future<String?> getSecureRefreshToken() async {
    return await _secureStorage.read(key: 'biometric_refresh_token');
  }

  // Check if user has set up biometric login (has saved refresh token)
  Future<bool> hasBiometricSetup() async {
    final String? token = await _secureStorage.read(
      key: 'biometric_refresh_token',
    );
    final bool enabled = await isBiometricLoginEnabled();
    return token != null && enabled;
  }
}
