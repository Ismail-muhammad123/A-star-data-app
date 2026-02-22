import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BalanceVisibilityProvider with ChangeNotifier {
  static const String _hideBalanceKey = 'hide_wallet_balance';
  bool _isBalanceHidden = false;

  bool get isBalanceHidden => _isBalanceHidden;

  BalanceVisibilityProvider() {
    _loadBalanceVisibility();
  }

  Future<void> _loadBalanceVisibility() async {
    final prefs = await SharedPreferences.getInstance();
    _isBalanceHidden = prefs.getBool(_hideBalanceKey) ?? false;
    notifyListeners();
  }

  Future<void> toggleBalanceVisibility() async {
    _isBalanceHidden = !_isBalanceHidden;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hideBalanceKey, _isBalanceHidden);
  }
}
