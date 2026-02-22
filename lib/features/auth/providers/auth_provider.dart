import 'package:app/core/services/biometric_service.dart';
import 'package:app/features/settings/data/repositories/profile_repo.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/features/auth/data/repository/auth_repo.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;
  String? authToken;

  final AuthService _authService = AuthService();
  final BiometricService _biometricService = BiometricService();

  bool _isBiometricEnabled = false;
  bool get isBiometricEnabled => _isBiometricEnabled;

  Future<String?> get token async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return token;
  }

  Future<String?> get lastPhoneNumber async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('last_phone_number');
  }

  Future<String?> get lastUserName async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('last_user_name');
  }

  Future<bool> get isFirstTime async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_first_time') ?? true;
  }

  Future<void> markFirstTimeSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_first_time', false);
  }

  Future<bool> get hasSeenOnboarding async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('has_seen_onboarding') ?? false;
  }

  Future<void> markOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
  }

  Future<bool> get hasLoggedInBefore async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('has_logged_in_before') ?? false;
  }

  Future<void> _markLoggedInBefore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_logged_in_before', true);
  }

  Future<bool> get isNewUser async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_new_user') ?? false;
  }

  Future<void> markNewUser(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_new_user', value);
  }

  Future<void> checkAuth() async {
    // refresh token first
    await refreshToken();
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    authToken = token;
    _isAuthenticated = token != null;

    _isBiometricEnabled = await _biometricService.isBiometricLoginEnabled();

    notifyListeners();
  }

  // stream isAuthenticated state
  Stream<bool> authStateStream() async* {
    yield isAuthenticated;
  }

  // refresh token
  Future<void> refreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    var refr = prefs.getString('refresh_token');

    if (refr == null) {
      _isAuthenticated = false;
      authToken = null;
      notifyListeners();
      return;
    }

    try {
      var res = await _authService.refreshToken(refr);

      var token = res['access'];
      if (token != null) {
        await prefs.setString('auth_token', token);
        authToken = token;
        _isAuthenticated = true;
        notifyListeners();
      } else {
        _isAuthenticated = false;
        authToken = null;
        await prefs.remove('auth_token');
        await prefs.remove('refresh_token');
        notifyListeners();
      }
    } catch (e) {
      _isAuthenticated = false;
      authToken = null;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> login(String phoneNumber, String pin) async {
    if (phoneNumber.startsWith("0")) {
      phoneNumber = phoneNumber.substring(1);
    }
    try {
      var res = await _authService.login(phoneNumber, pin);
      print(res);

      var token = res['access'];
      var refresh = res['refresh'];
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await prefs.setString('refresh_token', refresh);
        await prefs.setString('last_phone_number', phoneNumber);

        // Fetch profile to save name
        try {
          final profile = await ProfileService().fetchUserProfile(token);
          if (profile != null) {
            final firstName = profile.firstName ?? "";
            final lastName = profile.lastName ?? "";
            final fullName = "$firstName $lastName".trim();
            if (fullName.isNotEmpty) {
              await prefs.setString('last_user_name', fullName);
            }
          }
        } catch (e) {
          debugPrint(
            "AuthProvider: Error fetching profile for name retention: $e",
          );
        }

        authToken = token;
        _isAuthenticated = true;
        await _markLoggedInBefore();
        notifyListeners();
        return {"success": true, "message": ""};
      } else {
        return {"success": false, "message": "Invalid Phone Number or Pin"};
      }
    } catch (e) {
      print(e);
      return {"success": false, "message": e.toString()};
    }
  }

  Future<Map<String, dynamic>?> register(
    String phone,
    String pin, {
    String countryCode = "+234",
    String email = "",
    dynamic channel,
  }) async {
    if (phone.startsWith("0")) {
      phone = phone.substring(1);
    }

    try {
      var res = await _authService.register(
        phone,
        pin,
        countryCode: countryCode,
        email: email,
        channel: channel,
      );
      if (res != null) {
        return {"success": true, "message": ""};
      } else {
        return {"success": false, "message": "Registration failed"};
      }
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  Future<Map<String, dynamic>> resendConfirmationOTP(
    String identifier, {
    dynamic channel,
  }) async {
    try {
      await _authService.requestConfirmationOTP(identifier, channel: channel);
      return {"success": true, "message": "OTP sent successfully"};
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('refresh_token');
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<void> closeAccount() async {
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('auth_token');
    if (token != null) {
      await _authService.closeAccount(token);
    }
    await prefs.remove('auth_token');
    await prefs.remove('refresh_token');
    await _biometricService.disableBiometricLogin();
    _isAuthenticated = false;
    notifyListeners();
  }

  // Biometric methods
  Future<bool> enableBiometrics() async {
    final bool canBiometric = await _biometricService.isBiometricAvailable();
    if (!canBiometric) return false;

    final bool authenticated = await _biometricService.authenticate(
      reason: 'Confirm biometrics to enable login',
    );

    if (authenticated) {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');
      if (refreshToken != null) {
        await _biometricService.saveRefreshTokenSecurely(refreshToken);
        await _biometricService.enableBiometricLogin();
        _isBiometricEnabled = true;
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  Future<void> disableBiometrics() async {
    await _biometricService.disableBiometricLogin();
    _isBiometricEnabled = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>?> loginWithBiometrics() async {
    final bool hasSetup = await _biometricService.hasBiometricSetup();
    if (!hasSetup) {
      return {"success": false, "message": "Biometric login not set up"};
    }

    final bool authenticated = await _biometricService.authenticate(
      reason: 'Login with biometrics',
    );

    if (!authenticated) {
      return {"success": false, "message": "Biometric authentication failed"};
    }

    final String? refreshToken =
        await _biometricService.getSecureRefreshToken();
    if (refreshToken == null) {
      return {"success": false, "message": "No secure token found"};
    }

    try {
      var res = await _authService.refreshToken(refreshToken);
      print(res);
      var token = res['access'];
      // var newRefresh = res['refresh'];

      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        // await prefs.setString('refresh_token', newRefresh);

        // Update securely saved refresh token
        // await _biometricService.saveRefreshTokenSecurely(newRefresh);

        authToken = token;
        _isAuthenticated = true;
        notifyListeners();
        return {"success": true, "message": ""};
      } else {
        return {"success": false, "message": "Failed to refresh token"};
      }
    } catch (e) {
      print(e);
      return {"success": false, "message": "Failed to authenticate"};
    }
  }
}
