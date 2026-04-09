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
  String _resetChannel = 'sms';

  String get _identifier {
    final direct = (widget.phoneNumber ?? '').trim();
    if (direct.isNotEmpty) return _normalizeIdentifier(direct);
    final pending = context.read<AuthProvider>().pending2FAIdentifier ?? '';
    return _normalizeIdentifier(pending);
  }

  String _normalizeIdentifier(String value) {
    var normalized = value.trim();
    if (normalized.startsWith('0') && normalized.length > 10) {
      normalized = normalized.substring(1);
    }
    return normalized;
  }

  String _friendlyError(dynamic e, String fallback) {
    final msg = e.toString().replaceAll('Exception: ', '').trim();
    return msg.isEmpty ? fallback : msg;
  }

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

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
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
      final res = await authProvider.verify2FA(
        _codeController.text.trim(),
        identifier: _identifier,
      );
      
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
            content: Text(
              _friendlyError(res['message'] ?? "", "Verification failed"),
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(_friendlyError(e, "An error occurred during verification.")),
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
      final res = await authProvider.resend2FAOtp(
        identifier: _identifier,
        channel: 'sms',
      );
      
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
            content: Text(
              _friendlyError(res['message'] ?? "", "Failed to resend OTP"),
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(_friendlyError(e, "An error occurred while resending OTP.")),
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

  Future<void> _requestReset2FA() async {
    if (_identifier.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text("No account identifier found. Please login again."),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authProvider = context.read<AuthProvider>();
      final res = await authProvider.request2FAReset(
        identifier: _identifier,
        channel: _resetChannel,
      );
      if (!mounted) return;
      if (res['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              "Reset code sent via ${_resetChannel.toUpperCase()}. Enter it to disable 2FA.",
            ),
          ),
        );
        await _showConfirmResetDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              _friendlyError(res['message'] ?? "", "Failed to request 2FA reset."),
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(_friendlyError(e, "Failed to request 2FA reset.")),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showConfirmResetDialog() async {
    final otpController = TextEditingController();
    var isSubmitting = false;
    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Confirm 2FA Reset"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Enter the 6-digit reset code to disable 2FA.",
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: const InputDecoration(
                      hintText: "Enter reset code",
                      counterText: "",
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(ctx),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (otpController.text.trim().length < 6) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please enter a valid 6-digit code."),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          setDialogState(() => isSubmitting = true);
                          final res = await this.context.read<AuthProvider>().confirm2FAReset(
                                identifier: _identifier,
                                otpCode: otpController.text.trim(),
                              );
                          if (!mounted) return;
                          setDialogState(() => isSubmitting = false);
                          if (res['success'] == true) {
                            if (this.context.mounted) Navigator.pop(ctx);
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.green,
                                content: Text("2FA has been reset successfully. Please login again."),
                              ),
                            );
                            this.context.go('/login');
                          } else {
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.red,
                                content: Text(
                                  _friendlyError(
                                    res['message'] ?? "",
                                    "Unable to confirm 2FA reset.",
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                  child: const Text("Confirm Reset"),
                ),
              ],
            );
          },
        );
      },
    );
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
                        "assets/images/logo/starboy.png",
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
                    "Enter the 6-digit code sent to $_identifier to complete your sign in.",
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
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  await showModalBottomSheet(
                                    context: context,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20),
                                      ),
                                    ),
                                    builder: (ctx) {
                                      return StatefulBuilder(
                                        builder: (context, setModalState) {
                                          return Padding(
                                            padding: const EdgeInsets.all(20),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  "Reset 2FA",
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                const Text(
                                                  "Choose where to receive your 2FA reset code.",
                                                ),
                                                const SizedBox(height: 16),
                                                DropdownButtonFormField<String>(
                                                  value: _resetChannel,
                                                  decoration: const InputDecoration(
                                                    labelText: "Channel",
                                                  ),
                                                  items: const [
                                                    DropdownMenuItem(
                                                      value: 'sms',
                                                      child: Text('SMS'),
                                                    ),
                                                    DropdownMenuItem(
                                                      value: 'whatsapp',
                                                      child: Text('WhatsApp'),
                                                    ),
                                                    DropdownMenuItem(
                                                      value: 'email',
                                                      child: Text('Email'),
                                                    ),
                                                  ],
                                                  onChanged: (value) {
                                                    if (value == null) return;
                                                    setModalState(() {
                                                      _resetChannel = value;
                                                    });
                                                  },
                                                ),
                                                const SizedBox(height: 20),
                                                SizedBox(
                                                  width: double.infinity,
                                                  child: ElevatedButton(
                                                    onPressed: () async {
                                                      Navigator.pop(ctx);
                                                      await _requestReset2FA();
                                                    },
                                                    child: const Text("Send Reset Code"),
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                          child: Text(
                            "Can't access your code? Reset 2FA",
                            style: TextStyle(
                              color: theme.colorScheme.primary,
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
