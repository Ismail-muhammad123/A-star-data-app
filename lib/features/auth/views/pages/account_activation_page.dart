import 'package:app/features/auth/data/repository/auth_repo.dart';
import 'package:app/core/widgets/otp_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/features/settings/providers/profile_provider.dart';

class AccountActivationPage extends StatefulWidget {
  const AccountActivationPage({super.key, this.phoneNumber});
  final String? phoneNumber;

  @override
  State<AccountActivationPage> createState() => _AccountActivationPageState();
}

class _AccountActivationPageState extends State<AccountActivationPage> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  DateTime? _lastResend;
  bool _isLoading = false;

  @override
  void initState() {
    _phoneNumberController.text = widget.phoneNumber ?? "";
    super.initState();
  }

  _activateAccount() async {
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
      await AuthService().activateAccount(
        _phoneNumberController.text.trim(),
        _codeController.text.trim(),
      );
      if (!mounted) return;

      final authProvider = context.read<AuthProvider>();
      if (authProvider.isAuthenticated && authProvider.authToken != null) {
        await authProvider.markNewUser(true);
        await context.read<ProfileProvider>().loadProfile(
          authProvider.authToken!,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text("Account Verified Successfully!"),
          ),
        );
        context.go('/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text("Account Activated Successfully! Please Login"),
          ),
        );
        context.go('/login');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Failed to activate account! ${e.toString().split(":").last}",
          ),
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
        title: Text(
          "Account Activation",
          style: TextStyle(
            color: theme.appBarTheme.foregroundColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: theme.appBarTheme.backgroundColor,
        leading: BackButton(
          color: theme.appBarTheme.foregroundColor,
          onPressed:
              () => context.canPop() ? context.pop() : context.go("/login"),
        ),
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
                        color:
                            theme.brightness == Brightness.dark
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
                    "Verify your account",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.headlineSmall?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "A 6-digit one-time password has been sent to your SMS and Email. Please enter it below to verify your account.",
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Phone Number Field
                  _buildLabel("Phone Number"),
                  const SizedBox(height: 8),
                  TextFormField(
                    enabled: false,
                    controller: _phoneNumberController,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    keyboardType: TextInputType.phone,
                    style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                    decoration: InputDecoration(
                      hintText: "Enter phone number",
                      prefixIcon: Icon(
                        Icons.phone_android,
                        color: theme.colorScheme.primary,
                      ),
                      filled: true,
                      fillColor:
                          theme.brightness == Brightness.dark
                              ? theme.colorScheme.surface
                              : Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: theme.dividerColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: theme.dividerColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // OTP Input
                  _buildLabel("Verification Code"),
                  const SizedBox(height: 12),
                  OtpInput(
                    controller: _codeController,
                    onCompleted: (otp) {
                      _activateAccount();
                    },
                  ),
                  const SizedBox(height: 40),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _activateAccount,
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
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Text(
                                "Verify & Activate",
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
                        if (_lastResend == null ||
                            _lastResend!
                                .add(const Duration(seconds: 60))
                                .isBefore(DateTime.now()))
                          TextButton(
                            onPressed:
                                _isLoading
                                    ? null
                                    : () => _showResendOptions(context),
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
                              "Resend in ${_lastResend!.add(const Duration(seconds: 60)).difference(DateTime.now()).inSeconds}s",
                              style: TextStyle(
                                color: theme.textTheme.bodySmall?.color
                                    ?.withOpacity(0.4),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ), // Closing Center
                  const SizedBox(height: 24),

                  // Skip Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () => context.go('/login'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: BorderSide(color: theme.colorScheme.primary),
                      ),
                      child: const Text(
                        "Skip for now",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  void _showResendOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Resend Code Via",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.headlineSmall?.color,
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.sms_outlined),
                title: const Text("SMS Only"),
                onTap: () {
                  Navigator.pop(context);
                  _resendOtp("sms");
                },
              ),
              ListTile(
                leading: const Icon(Icons.email_outlined),
                title: const Text("Email Only"),
                onTap: () {
                  Navigator.pop(context);
                  _resendOtp("email");
                },
              ),
              ListTile(
                leading: const Icon(Icons.all_inclusive),
                title: const Text("SMS & Email"),
                onTap: () {
                  Navigator.pop(context);
                  _resendOtp(null);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<void> _resendOtp(String? channel) async {
    if (_phoneNumberController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your phone number first")),
      );
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });
      await AuthService().requestConfirmationOTP(
        _phoneNumberController.text.trim(),
        channel: channel,
      );
      setState(() {
        _lastResend = DateTime.now();
        _isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            channel == null
                ? "OTP resent successfully via all channels!"
                : "OTP resent successfully via ${channel.toUpperCase()}!",
          ),
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
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildLabel(String text) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: theme.textTheme.bodySmall?.color?.withOpacity(0.8),
      ),
    );
  }
}
