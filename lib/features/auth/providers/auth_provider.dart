import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/features/auth/data/repository/auth_repo.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;
  String? authToken;

  final AuthService _authService = AuthService();

  Future<String?> get token async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return token;
  }

  Future<void> checkAuth() async {
    // refresh token first
    await refreshToken();
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    authToken = token;
    _isAuthenticated = token != null;
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
      var token = res['access'];
      var refresh = res['refresh'];
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await prefs.setString('refresh_token', refresh);

        authToken = token;
        _isAuthenticated = true;
        notifyListeners();
        return {"success": true, "message": ""};
      } else {
        return {"success": false, "message": "Invalid Phone Number or Pin"};
      }
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  Future<Map<String, dynamic>?> register(
    String phone,
    String pin, {
    String countryCode = "+234",
    String email = "",
  }) async {
    if (phone.startsWith("0")) {
      phone = phone.substring(1);
    }

    var res = await _authService.register(
      phone,
      pin,
      countryCode: countryCode,
      email: email,
    );
    // var token = res['token'];
    if (res != null) {
      // final prefs = await SharedPreferences.getInstance();
      // await prefs.setString('auth_token', token);
      // _isAuthenticated = true;
      // notifyListeners();
      return {"success": true, "message": ""};
    } else {
      return {"success": false, "message": "Registration failed"};
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('refresh_token');
    _isAuthenticated = false;
    notifyListeners();
  }
}
