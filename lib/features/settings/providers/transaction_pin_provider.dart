import 'package:flutter/foundation.dart';
import 'package:app/features/settings/data/repositories/transaction_pin_repo.dart';

class TransactionPinProvider extends ChangeNotifier {
  final TransactionPinService _pinService = TransactionPinService();
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<Map<String, dynamic>> setPin(String authToken, String pin) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _pinService.setTransactionPin(authToken, pin);
      return {'success': true};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> changePin(String authToken, String oldPin, String newPin) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _pinService.changeTransactionPin(authToken, oldPin, newPin);
      return {'success': true};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyPin(String authToken, String pin) async {
    _isLoading = true;
    notifyListeners();
    try {
      return await _pinService.verifyTransactionPin(authToken, pin);
    } catch (e) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> requestResetOtp(String authToken) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _pinService.requestResetOtp(authToken);
      return {'success': true};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> resetPin(String authToken, String otp, String newPin) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _pinService.resetTransactionPin(authToken, otp, newPin);
      return {'success': true};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
