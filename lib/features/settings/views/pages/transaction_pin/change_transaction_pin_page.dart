import 'package:app/core/widgets/otp_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/features/settings/providers/transaction_pin_provider.dart';

class ChangeTransactionPinPage extends StatefulWidget {
  const ChangeTransactionPinPage({super.key});

  @override
  State<ChangeTransactionPinPage> createState() =>
      _ChangeTransactionPinPageState();
}

class _ChangeTransactionPinPageState extends State<ChangeTransactionPinPage> {
  final TextEditingController _oldPinController = TextEditingController();
  final TextEditingController _newPinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();

  bool _isLoading = false;

  Future<void> _handleChangePin() async {
    if (_oldPinController.text.length < 4) return;
    if (_newPinController.text.length < 4) return;

    if (_newPinController.text != _confirmPinController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("New PINs do not match."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final pinProvider = context.read<TransactionPinProvider>();

      final res = await pinProvider.changePin(
        authProvider.authToken ?? "",
        _oldPinController.text.trim(),
        _newPinController.text.trim(),
      );

      if (!mounted) return;

      if (res['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction PIN changed successfully'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message'] ?? 'Failed to change PIN'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text("Change Transaction PIN"), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Update Secure PIN",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.headlineSmall?.color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Keep your 4-digit transaction PIN confidential. Change it regularly for better security.",
              style: TextStyle(
                fontSize: 14,
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),

            // Current PIN
            _buildLabel("Current PIN"),
            const SizedBox(height: 12),
            OtpInput(
              length: 4,
              controller: _oldPinController,
              onCompleted: (v) {},
              autofocus: true,
            ),

            const SizedBox(height: 24),

            // New PIN
            _buildLabel("New 4-Digit PIN"),
            const SizedBox(height: 12),
            OtpInput(
              length: 4,
              controller: _newPinController,
              onCompleted: (v) {},
              autofocus: false,
            ),

            const SizedBox(height: 24),

            // Confirm New PIN
            _buildLabel("Confirm New PIN"),
            const SizedBox(height: 12),
            OtpInput(
              length: 4,
              controller: _confirmPinController,
              onCompleted: (v) {},
              autofocus: false,
            ),

            const SizedBox(height: 48),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleChangePin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child:
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                          "Update Transaction PIN",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ),

            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => context.push('/profile/transaction-pin/reset'),
                child: Text(
                  "Forgot Transaction PIN?",
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.8),
      ),
    );
  }
}
