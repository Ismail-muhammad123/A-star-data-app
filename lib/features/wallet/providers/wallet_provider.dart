import 'package:app/features/wallet/data/repository/wallet_repo.dart';
import 'package:flutter/material.dart';

class WalletProvider with ChangeNotifier {
  double _balance = 0.0;
  bool _isLoading = false;
  String? _error;

  double get balance => _balance;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final WalletService _walletService = WalletService();

  Future<void> fetchBalance(String authToken) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final balanceStr = await _walletService.getBalance(authToken);
      _balance = double.tryParse(balanceStr) ?? 0.0;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateBalance(double newBalance) {
    _balance = newBalance;
    notifyListeners();
  }
}
