import 'package:app/core/widgets/otp_input.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:app/features/auth/providers/auth_provider.dart';

class TwoFaOtpPage extends StatefulWidget {
  const TwoFaOtpPage({super.key, this.phoneNumber});
  final String? phoneNumber;

  @override
  State<TwoFaOtpPage> createState() => _TwoFaOtpPageState();
}

class _TwoFaOtpPageState extends State<TwoFaOtpPage> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  int _resendTimer = 60;
  bool _canResend = false;

  @override
  void initState() {
    _startResendTimer();
    super.initState();
  }

  void _startResendTimer() {
    setState(() {
      _resendTimer = 60;
      _canResend = false;
    });
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        _resendTimer--;
      });
      if (_resendTimer <= 0) {
        setState(() {
          _canResend = true;
        });
        return false;
      }
      return true;
    });
  }

  Future<void> _verifyOtp() async {
    if (_codeController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter the 6-digit OTP code")),
      );
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });
      
      final authProvider = context.read<AuthProvider>();
      final res = await authProvider.verify2FA(_codeController.text.trim());
      
      if (!mounted) return;

      if (res['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text("Log in successful!"),
          ),
        );
        context.go('/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(res['message'] ?? "Verification failed"),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("An error occurred: ${e.toString()}"),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resendOtp() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      final authProvider = context.read<AuthProvider>();
      final res = await authProvider.resend2FAOtp();
      
      if (!mounted) return;

      if (res['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text("OTP resent successfully!"),
          ),
        );
        _startResendTimer();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(res['message'] ?? "Failed to resend OTP"),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("An error occurred: ${e.toString()}"),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Two-Factor Authentication",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.appBarTheme.backgroundColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Hero(
                    tag: "logo",
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.brightness == Brightness.dark
                            ? theme.cardColor
                            : Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        "assets/images/logo/a-star_app_logo.png",
                        height: 60,
                        width: 60,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Security Verification",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.headlineSmall?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Enter the 6-digit code sent to your registered phone number ${widget.phoneNumber ?? ''} to complete your sign in.",
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // OTP Input
                  Text(
                    "Verification Code",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OtpInput(
                    controller: _codeController,
                    onCompleted: (otp) {
                      _verifyOtp();
                    },
                  ),
                  const SizedBox(height: 40),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _verifyOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              "Confirm Login",
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
                            color: theme.textTheme.bodySmall?.color
                                ?.withOpacity(0.6),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_canResend)
                          TextButton(
                            onPressed: _isLoading ? null : _resendOtp,
                            child: Text(
                              "Resend Code",
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              "Resend in ${_resendTimer}s",
                              style: TextStyle(
                                color: theme.textTheme.bodySmall?.color
                                    ?.withOpacity(0.4),
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
          ],
        ),
      ),
    );
  }
}
