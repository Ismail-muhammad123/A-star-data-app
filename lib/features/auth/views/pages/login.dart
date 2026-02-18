import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:app/features/auth/providers/auth_provider.dart';
// import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final List<String> _pinDigits = [];
  String? _lastUserName;
  String? _lastPhoneNumber;
  bool _isLoading = false;
  bool _showKeypad = false;
  final FocusNode _phoneFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadLastUser();
    Provider.of<AuthProvider>(context, listen: false).checkAuth().then((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      debugPrint(
        "Login: checkAuth completed. isAuthenticated=${auth.isAuthenticated}",
      );
      if (auth.isAuthenticated) {
        _navigateToHome();
      }
    });
  }

  Future<void> _loadLastUser() async {
    try {
      debugPrint("Login: Loading last user info...");
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final phone = await auth.lastPhoneNumber;
      final name = await auth.lastUserName;
      debugPrint("Login: lastPhone=$phone, lastName=$name");
      if (mounted) {
        setState(() {
          _lastPhoneNumber = phone;
          _lastUserName = name;
          if (phone != null) {
            _phoneNumberController.text = phone;
            _showKeypad = true;
          }
        });
      }
    } catch (e) {
      debugPrint("Login: Error loading last user: $e");
    }
  }

  void _navigateToHome() {
    final nextUri = GoRouterState.of(context).uri.queryParameters['next'];
    if (nextUri != null && nextUri.isNotEmpty) {
      context.go("/?next=$nextUri");
    } else {
      context.go('/');
    }
  }

  void handleLogin() async {
    if (_phoneNumberController.text.isEmpty || _pinDigits.length < 6) {
      _showError("Please enter both phone number and a 6-digit pin.");
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    setState(() {
      _isLoading = true;
    });

    try {
      final pin = _pinDigits.join();
      var res = await authProvider.login(
        _phoneNumberController.text.trim(),
        pin,
      );
      setState(() {
        _isLoading = false;
      });

      if (res!['success'] == true) {
        if (mounted) _navigateToHome();
      } else {
        _showError(res['message'] ?? "Invalid Phone Number or Pin!");
        setState(() {
          _pinDigits.clear();
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _pinDigits.clear();
      });
      _showError(e.toString().split(":").last);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
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

  void _onKeyTap(String key) {
    if (_isLoading) return;
    if (_pinDigits.length < 6) {
      setState(() {
        _pinDigits.add(key);
      });
      if (_pinDigits.length == 6) {
        handleLogin();
      }
    }
  }

  void _onPinAreaTap() {
    setState(() {
      _showKeypad = true;
    });
    // Dismiss system keyboard if open
    FocusScope.of(context).unfocus();
  }

  void _onBackspace() {
    if (_isLoading) return;
    if (_pinDigits.isNotEmpty) {
      setState(() {
        _pinDigits.removeLast();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          // Header Background
          Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade800, Colors.blue.shade600],
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
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  // Logo Card
                  Hero(
                    tag: "logo",
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        "assets/images/logo/a-star_app_logo.png",
                        height: 60,
                        width: 60,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Main Content Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
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
                      children: [
                        if (_lastUserName != null &&
                            _lastUserName!.isNotEmpty) ...[
                          Text(
                            "Welcome Back,",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _lastUserName!.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.blue,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _lastUserName = null;
                                _lastPhoneNumber = null;
                                _phoneNumberController.clear();
                                _showKeypad = false;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                "Switch Account",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ] else ...[
                          const Text(
                            "Login to Account",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            "Please enter your details to continue",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                        const SizedBox(height: 32),

                        // Input Section
                        if (_lastUserName == null || _lastUserName!.isEmpty)
                          TextFormField(
                            enabled: !_isLoading,
                            controller: _phoneNumberController,
                            focusNode: _phoneFocusNode,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                            onTap: () => setState(() => _showKeypad = false),
                            decoration: InputDecoration(
                              labelText: "Phone Number",
                              hintText: "e.g. 08012345678",
                              prefixIcon: const Icon(
                                Icons.phone_android,
                                color: Colors.blue,
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Colors.blue,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          )
                        else
                          // Read-only Phone Display
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 20,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.phone_android,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _lastPhoneNumber ?? "",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 32),

                        // PIN Section
                        GestureDetector(
                          onTap: _onPinAreaTap,
                          child: Column(
                            children: [
                              Text(
                                "ENTER 6-DIGIT PIN",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(6, (index) {
                                  bool isActive = index < _pinDigits.length;
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                          isActive ? Colors.blue : Colors.white,
                                      border: Border.all(
                                        color:
                                            isActive
                                                ? Colors.blue
                                                : Colors.grey[300]!,
                                        width: 2.5,
                                      ),
                                      boxShadow:
                                          isActive
                                              ? [
                                                BoxShadow(
                                                  color: Colors.blue
                                                      .withOpacity(0.3),
                                                  blurRadius: 10,
                                                  spreadRadius: 2,
                                                ),
                                              ]
                                              : [],
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Keypad or Loading Section
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child:
                        _isLoading
                            ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 80),
                              child: CircularProgressIndicator(),
                            )
                            : _showKeypad
                            ? _buildKeypad()
                            : SizedBox(
                              height: 350,
                              child: Center(
                                child: Text(
                                  "Tap PIN dots to show keypad",
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ),
                  ),

                  const SizedBox(height: 16),

                  // Bottom Links
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () => context.push('/forgot-pin'),
                        child: Text(
                          "FORGOT PIN?",
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      Container(height: 15, width: 1, color: Colors.grey[300]),
                      TextButton(
                        onPressed: () => context.go('/register'),
                        child: Text(
                          "CREATE ACCOUNT",
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () => context.push('/activate-account'),
                    child: Text(
                      "ACTIVATE MY ACCOUNT",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeypad() {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        return Column(
          children: [
            for (var row in [
              ['1', '2', '3'],
              ['4', '5', '6'],
              ['7', '8', '9'],
            ])
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: row.map((key) => _buildKey(key)).toList(),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (auth.isBiometricEnabled)
                  _buildBiometricKey(auth)
                else
                  const SizedBox(width: 80),
                _buildKey('0'),
                _buildBackspaceKey(),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildBiometricKey(AuthProvider auth) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.blue.withOpacity(0.1)),
      ),
      child: IconButton(
        onPressed: () async {
          setState(() => _isLoading = true);
          final res = await auth.loginWithBiometrics();
          setState(() => _isLoading = false);
          if (res != null && res['success'] == true) {
            if (mounted) _navigateToHome();
          } else if (res != null && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(res['message'] ?? "Biometric login failed"),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        icon: const Icon(Icons.fingerprint, color: Colors.blue, size: 36),
      ),
    );
  }

  Widget _buildKey(String label) {
    return SizedBox(
      width: 72,
      height: 72,
      child: ElevatedButton(
        onPressed: () => _onKeyTap(label),
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
          foregroundColor: Colors.blue.shade900,
          backgroundColor: Colors.white,
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.2),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }

  Widget _buildBackspaceKey() {
    return SizedBox(
      width: 72,
      height: 72,
      child: IconButton(
        onPressed: _onBackspace,
        icon: Icon(
          Icons.backspace_outlined,
          color: Colors.red.shade400,
          size: 24,
        ),
        style: IconButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor: Colors.white,
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.2),
        ),
      ),
    );
  }
}
