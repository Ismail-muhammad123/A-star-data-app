import 'package:app/core/widgets/otp_input.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/features/settings/providers/transaction_pin_provider.dart';

class SetTransactionPinPage extends StatefulWidget {
  const SetTransactionPinPage({super.key});

  @override
  State<SetTransactionPinPage> createState() => _SetTransactionPinPageState();
}

class _SetTransactionPinPageState extends State<SetTransactionPinPage> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  bool _isConfirming = false;

  void _onPinEntered(String pin) {
    if (!_isConfirming) {
      setState(() {
        _isConfirming = true;
      });
      _pinController.text = pin;
    } else {
      if (pin == _pinController.text) {
        _handleSetPin(pin);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("PINs do not match. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isConfirming = false;
          _pinController.clear();
          _confirmPinController.clear();
        });
      }
    }
  }

  Future<void> _handleSetPin(String pin) async {
    final authProvider = context.read<AuthProvider>();
    final pinProvider = context.read<TransactionPinProvider>();
    
    final res = await pinProvider.setPin(authProvider.authToken ?? "", pin);
    
    if (!mounted) return;

    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Transaction PIN set successfully!"),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? "Failed to set PIN"),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isConfirming = false;
        _pinController.clear();
        _confirmPinController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Set Transaction PIN"),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isConfirming ? "Confirm Your PIN" : "Create a PIN",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.headlineSmall?.color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _isConfirming
                  ? "Enter the 6-digit PIN again to confirm."
                  : "This PIN will be used to authorize your transactions.",
              style: TextStyle(
                fontSize: 14,
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 48),
            Center(
              child: _isConfirming
                  ? OtpInput(
                      key: const ValueKey("confirm"),
                      controller: _confirmPinController,
                      onCompleted: _onPinEntered,
                    )
                  : OtpInput(
                      key: const ValueKey("create"),
                      controller: _pinController,
                      onCompleted: _onPinEntered,
                    ),
            ),
            const Spacer(),
            if (_isConfirming)
              Center(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _isConfirming = false;
                      _pinController.clear();
                      _confirmPinController.clear();
                    });
                  },
                  child: const Text("Back to create PIN"),
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
