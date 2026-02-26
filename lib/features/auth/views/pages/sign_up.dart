import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();

  String _countryCode = "+234";
  bool _isLoading = false;
  bool _obscurePin = true;

  bool _sendSms = true;
  bool _sendEmail = true;

  void _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    String phone = _phoneController.text.trim();
    if (phone.startsWith('0')) {
      phone = phone.substring(1);
    }

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      dynamic selectedChannel;
      if (_sendSms && _sendEmail && _emailController.text.isNotEmpty) {
        selectedChannel = null; // Backend handles both when null
      } else if (_sendSms) {
        selectedChannel = 'sms';
      } else if (_sendEmail && _emailController.text.isNotEmpty) {
        selectedChannel = 'email';
      } else {
        selectedChannel = 'sms'; // Fallback
      }

      var res = await authProvider.register(
        phone,
        _pinController.text.trim(),
        countryCode: _countryCode,
        email: _emailController.text.trim(),
        channel: selectedChannel,
      );

      if (res?['success'] == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              "Account created successfully! Please verify your phone number.",
            ),
          ),
        );
        context.go('/activate-account', extra: _phoneController.text);
      } else {
        if (!mounted) return;
        _showError(res?['message'] ?? "Registration failed. Please try again.");
      }
    } catch (e) {
      _showError("An unexpected error occurred. Please check your connection.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Error", style: TextStyle(color: Colors.red)),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors:
                    isDark
                        ? [
                          theme.colorScheme.surface,
                          theme.colorScheme.surface.withOpacity(0.8),
                        ]
                        : [Colors.blue.shade800, Colors.blue.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Hero(
                      tag: "logo",
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? theme.cardColor : Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          "assets/images/logo/a-star_app_logo.png",
                          height: 60,
                          width: 60,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Create Account",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: theme.textTheme.headlineSmall?.color,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Fill in your details to get started",
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.textTheme.bodySmall?.color
                                  ?.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Phone Number (with Country Picker)
                          _buildLabel("Phone Number", theme),
                          const SizedBox(height: 8),
                          IntlPhoneField(
                            controller: _phoneController,
                            initialCountryCode: 'NG',
                            keyboardType: TextInputType.phone,
                            style: TextStyle(
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                            decoration: _inputDecoration(
                              theme: theme,
                              hint: "801 234 5678",
                            ),
                            languageCode: "en",
                            onChanged: (phone) {
                              setState(() {
                                _countryCode = phone.countryCode;
                              });
                            },
                            onCountryChanged: (country) {
                              setState(() {
                                _countryCode = "+${country.dialCode}";
                              });
                            },
                            validator: (v) {
                              if (v == null || v.number.isEmpty) {
                                return "Required";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Email (Optional)
                          _buildLabel("Email Address (Optional)", theme),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                            decoration: _inputDecoration(
                              theme: theme,
                              hint: "you@example.com",
                              icon: Icons.email_outlined,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // PIN
                          _buildLabel("6-Digit PIN", theme),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _pinController,
                            obscureText: _obscurePin,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              letterSpacing: 8,
                              fontWeight: FontWeight.bold,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                            decoration: _inputDecoration(
                              theme: theme,
                              hint: "******",
                              icon: Icons.lock_outline,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePin
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: theme.textTheme.bodySmall?.color,
                                ),
                                onPressed:
                                    () => setState(
                                      () => _obscurePin = !_obscurePin,
                                    ),
                              ),
                              counterText: "",
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return "Required";
                              if (v.length != 6) return "Must be 6 digits";
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Verification Channel
                          _buildLabel("Receive Verification Code Via:", theme),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap:
                                      () =>
                                          setState(() => _sendSms = !_sendSms),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          _sendSms
                                              ? theme.colorScheme.primary
                                                  .withOpacity(0.1)
                                              : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color:
                                            _sendSms
                                                ? theme.colorScheme.primary
                                                : theme.dividerColor,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.sms_outlined,
                                          size: 18,
                                          color:
                                              _sendSms
                                                  ? theme.colorScheme.primary
                                                  : theme
                                                      .textTheme
                                                      .bodySmall
                                                      ?.color,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "SMS",
                                          style: TextStyle(
                                            fontWeight:
                                                _sendSms
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                            color:
                                                _sendSms
                                                    ? theme.colorScheme.primary
                                                    : theme
                                                        .textTheme
                                                        .bodySmall
                                                        ?.color,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    if (_emailController.text.isEmpty) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Please enter an email address first",
                                          ),
                                        ),
                                      );
                                      return;
                                    }
                                    setState(() => _sendEmail = !_sendEmail);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          _sendEmail
                                              ? theme.colorScheme.primary
                                                  .withOpacity(0.1)
                                              : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color:
                                            _sendEmail
                                                ? theme.colorScheme.primary
                                                : theme.dividerColor,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.email_outlined,
                                          size: 18,
                                          color:
                                              _sendEmail
                                                  ? theme.colorScheme.primary
                                                  : theme
                                                      .textTheme
                                                      .bodySmall
                                                      ?.color,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Email",
                                          style: TextStyle(
                                            fontWeight:
                                                _sendEmail
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                            color:
                                                _sendEmail
                                                    ? theme.colorScheme.primary
                                                    : theme
                                                        .textTheme
                                                        .bodySmall
                                                        ?.color,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),

                          // Signup Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleSignUp,
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
                                        "Create Account",
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
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account? ",
                          style: TextStyle(
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go('/login'),
                          child: Text(
                            "Login",
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, ThemeData theme) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: theme.textTheme.bodySmall?.color?.withOpacity(0.8),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required ThemeData theme,
    required String hint,
    IconData? icon,
    Widget? suffixIcon,
    String? counterText,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon:
          icon != null
              ? Icon(icon, color: theme.colorScheme.primary, size: 20)
              : null,
      suffixIcon: suffixIcon,
      counterText: counterText,
      filled: true,
      fillColor:
          theme.brightness == Brightness.dark
              ? theme.colorScheme.surface
              : Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: theme.dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
      ),
    );
  }
}
