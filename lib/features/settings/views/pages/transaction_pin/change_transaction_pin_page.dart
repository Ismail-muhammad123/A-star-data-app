import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/features/settings/providers/transaction_pin_provider.dart';

class ChangeTransactionPinPage extends StatefulWidget {
  const ChangeTransactionPinPage({super.key});

  @override
  State<ChangeTransactionPinPage> createState() => _ChangeTransactionPinPageState();
}

class _ChangeTransactionPinPageState extends State<ChangeTransactionPinPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _oldPinController = TextEditingController();
  final TextEditingController _newPinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();

  bool _isLoading = false;
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  Future<void> _handleChangePin() async {
    if (!_formKey.currentState!.validate()) return;
    
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
      appBar: AppBar(
        title: const Text("Change Transaction PIN"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
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
                "Keep your transaction PIN confidential. Change it regularly for better security.",
                style: TextStyle(
                  fontSize: 14,
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),

              // Current PIN
              _buildLabel("Current PIN"),
              const SizedBox(height: 8),
              TextFormField(
                controller: _oldPinController,
                obscureText: _obscureOld,
                keyboardType: TextInputType.number,
                maxLength: 6,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) => (v?.length ?? 0) < 6 ? "Enter 6-digit current PIN" : null,
                decoration: _inputDecoration(
                  hint: "••••••",
                  icon: Icons.lock_outline,
                  obscure: _obscureOld,
                  onToggle: () => setState(() => _obscureOld = !_obscureOld),
                ),
              ),

              const SizedBox(height: 24),

              // New PIN
              _buildLabel("New 6-Digit PIN"),
              const SizedBox(height: 8),
              TextFormField(
                controller: _newPinController,
                obscureText: _obscureNew,
                keyboardType: TextInputType.number,
                maxLength: 6,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) => (v?.length ?? 0) < 6 ? "Enter 6-digit new PIN" : null,
                decoration: _inputDecoration(
                  hint: "••••••",
                  icon: Icons.password_rounded,
                  obscure: _obscureNew,
                  onToggle: () => setState(() => _obscureNew = !_obscureNew),
                ),
              ),

              const SizedBox(height: 24),

              // Confirm New PIN
              _buildLabel("Confirm New PIN"),
              const SizedBox(height: 8),
              TextFormField(
                controller: _confirmPinController,
                obscureText: _obscureConfirm,
                keyboardType: TextInputType.number,
                maxLength: 6,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) => (v?.length ?? 0) < 6 ? "Confirm your new PIN" : null,
                decoration: _inputDecoration(
                  hint: "••••••",
                  icon: Icons.check_circle_outline,
                  obscure: _obscureConfirm,
                  onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),
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
                  child: _isLoading
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

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    final theme = Theme.of(context);
    return InputDecoration(
      hintText: hint,
      counterText: "",
      prefixIcon: Icon(icon, color: theme.colorScheme.primary, size: 20),
      suffixIcon: IconButton(
        icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
        onPressed: onToggle,
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      filled: true,
      fillColor: theme.cardColor,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: theme.dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
      ),
    );
  }
}
