import 'package:app/core/widgets/otp_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/features/settings/providers/transaction_pin_provider.dart';

class ResetTransactionPinPage extends StatefulWidget {
  const ResetTransactionPinPage({super.key});

  @override
  State<ResetTransactionPinPage> createState() => _ResetTransactionPinPageState();
}

class _ResetTransactionPinPageState extends State<ResetTransactionPinPage> {
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  
  bool _isLoading = false;
  bool _otpSent = false;

  Future<void> _requestOtp() async {
    setState(() => _isLoading = true);
    try {
      final authProvider = context.read<AuthProvider>();
      final pinProvider = context.read<TransactionPinProvider>();
      
      final res = await pinProvider.requestResetOtp(authProvider.authToken ?? "");
      
      if (!mounted) return;

      if (res['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Reset OTP has been sent to your phone/email."),
            backgroundColor: Colors.green,
          ),
        );
        setState(() => _otpSent = true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message'] ?? "Failed to request OTP"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleReset() async {
    if (_otpController.text.length < 6) return;
    if (_newPinController.text.length < 4) return;
    if (_newPinController.text != _confirmPinController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("PINs do not match"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authProvider = context.read<AuthProvider>();
      final pinProvider = context.read<TransactionPinProvider>();
      
      final res = await pinProvider.resetPin(
        authProvider.authToken ?? "",
        _otpController.text.trim(),
        _newPinController.text.trim(),
      );

      if (!mounted) return;

      if (res['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Transaction PIN reset successfully!"), backgroundColor: Colors.green),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? "Reset failed"), backgroundColor: Colors.red),
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
      appBar: AppBar(title: const Text("Reset Transaction PIN"), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _otpSent ? "Reset PIN" : "Reset Identity Verification",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.headlineSmall?.color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _otpSent
                  ? "Enter the 6-digit OTP and your new 4-digit PIN."
                  : "We will send an OTP verify your identity before resetting your transaction PIN.",
              style: TextStyle(
                fontSize: 14,
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),

            if (!_otpSent) ...[
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _requestOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Request Reset OTP", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ] else ...[
              // OTP Section
              _buildLabel("Verification OTP"),
              const SizedBox(height: 12),
              OtpInput(
                controller: _otpController,
                onCompleted: (v) {},
              ),

              const SizedBox(height: 32),

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
                  onPressed: _isLoading ? null : _handleReset,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Reset Transaction PIN", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
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

