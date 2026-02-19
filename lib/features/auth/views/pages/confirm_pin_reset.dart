import 'package:app/features/auth/data/repository/auth_repo.dart';
import 'package:app/core/widgets/otp_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class ConfirmPinReset extends StatefulWidget {
  const ConfirmPinReset({super.key, required this.phoneNumber});
  final String phoneNumber;

  @override
  State<ConfirmPinReset> createState() => _ConfirmPinResetState();
}

class _ConfirmPinResetState extends State<ConfirmPinReset> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _newPinController = TextEditingController();

  DateTime? _lastResend;
  bool _isLoading = false;
  bool _obscurePin = true;

  @override
  void initState() {
    _phoneNumberController.text = widget.phoneNumber;
    super.initState();
  }

  void _handleChangePin() async {
    if (_codeController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter the 6-digit OTP code")),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => _isLoading = true);

      var phone = _phoneNumberController.text.trim();
      if (phone.startsWith("0")) {
        phone = phone.substring(1);
      }

      await AuthService().confirmPinReset(
        _codeController.text.trim(),
        _newPinController.text.trim(),
        phone,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            "PIN reset successfully! Please login with your new PIN.",
          ),
        ),
      );
      context.go('/login');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Failed to reset PIN! ${e.toString().split(":").last}"),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Set New PIN",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        leading: BackButton(
          color: Colors.white,
          onPressed: () => context.go("/forgot-pin"),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 120,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: const Icon(
                Icons.lock_reset_rounded,
                size: 60,
                color: Colors.white,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Reset your PIN",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Enter the 6-digit code sent to your device and your new preferred 6-digit PIN.",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Phone (Read Only)
                    _buildLabel("Phone Number"),
                    const SizedBox(height: 8),
                    TextFormField(
                      enabled: false,
                      controller: _phoneNumberController,
                      decoration: _inputDecoration(
                        hint: "",
                        icon: Icons.phone_android,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // OTP Code
                    _buildLabel("Verification Code"),
                    const SizedBox(height: 12),
                    OtpInput(
                      controller: _codeController,
                      onCompleted: (otp) {},
                    ),
                    const SizedBox(height: 32),

                    // New PIN
                    _buildLabel("New 6-Digit PIN"),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _newPinController,
                      obscureText: _obscurePin,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        letterSpacing: 8,
                        fontWeight: FontWeight.bold,
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: _inputDecoration(
                        hint: "******",
                        icon: Icons.vpn_key_outlined,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePin
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed:
                              () => setState(() => _obscurePin = !_obscurePin),
                        ),
                        counterText: "",
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return "Required";
                        if (v.length != 6) return "Must be 6 digits";
                        return null;
                      },
                    ),
                    const SizedBox(height: 48),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleChangePin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child:
                            _isLoading
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : const Text(
                                  "Reset PIN & Login",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Resend Section
                    Center(
                      child: Column(
                        children: [
                          Text(
                            "Didn't receive the code?",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (_lastResend == null ||
                              _lastResend!
                                  .add(const Duration(seconds: 60))
                                  .isBefore(DateTime.now()))
                            TextButton(
                              onPressed: _isLoading ? null : _resendOtp,
                              child: const Text(
                                "Resend Code",
                                style: TextStyle(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          else
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                "Resend in ${_lastResend!.add(const Duration(seconds: 60)).difference(DateTime.now()).inSeconds}s",
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
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
        color: Colors.grey[700],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
    String? counterText,
    Color? fillColor,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.blueAccent, size: 20),
      suffixIcon: suffixIcon,
      counterText: counterText,
      filled: true,
      fillColor: fillColor ?? Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
      ),
    );
  }

  Future<void> _resendOtp() async {
    try {
      setState(() => _isLoading = true);
      await AuthService().resetPin(widget.phoneNumber);
      setState(() {
        _lastResend = DateTime.now();
        _isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text("OTP resent successfully!"),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Failed to resend OTP! ${e.toString().split(":").last}",
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
