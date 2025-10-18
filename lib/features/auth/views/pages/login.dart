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
  final TextEditingController _pinController = TextEditingController();
  String? countryCode;
  // bool _rememberMe = false;
  bool _isLoading = false;

  void handleLogin(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    setState(() {
      _isLoading = true;
    });

    try {
      var res = await authProvider.login(
        _phoneNumberController.text.trim(),
        _pinController.text.trim(),
      );
      setState(() {
        _isLoading = false;
      });
      if (res!['success'] == true) {
        if (mounted) {
          final nextUri = GoRouterState.of(context).uri.queryParameters['next'];
          if (nextUri != null && nextUri.isNotEmpty) {
            context.go("/?next=$nextUri");
          } else {
            context.go('/');
          }
        }
      } else {
        if (mounted) {
          await showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: Text("Error"),
                  content: Text("Invalid Phone Number or Pin!"),
                ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print(e);
    }
  }

  bool _hidePassword = true;

  @override
  void initState() {
    Provider.of<AuthProvider>(context, listen: false).checkAuth().then((_) {
      if (Provider.of<AuthProvider>(context, listen: false).isAuthenticated) {
        final nextUri = GoRouterState.of(context).uri.queryParameters['next'];
        if (nextUri != null && nextUri.isNotEmpty) {
          context.go("/?next=$nextUri");
        } else {
          context.go('/');
        }
        // context.go('/');
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: double.maxFinite,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Card(
                    elevation: 8.0,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Hero(
                            tag: "logo",
                            child: Image.asset(
                              "assets/images/logo/a-star_app_logo.png",
                              height: 120,
                              width: 120,
                              fit: BoxFit.contain,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Login to your account".toUpperCase(),
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              enabled: !_isLoading,
                              controller: _phoneNumberController,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.zero,
                                prefixText: countryCode ?? "",
                                label: Text("Your Phone Number"),
                                prefixIcon: Icon(Icons.phone),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              enabled: !_isLoading,
                              controller: _pinController,
                              obscureText: _hidePassword,
                              textAlign: TextAlign.center,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.zero,
                                hintText: "* * * * * *",
                                suffix: GestureDetector(
                                  onTap:
                                      () => setState(
                                        () => _hidePassword = !_hidePassword,
                                      ),
                                  child: Icon(
                                    _hidePassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                ),
                                label: Text("Pin"),
                                prefixIcon: Icon(Icons.lock),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          MaterialButton(
                            onPressed:
                                _isLoading
                                    ? null
                                    : () {
                                      handleLogin(context);
                                    },
                            color: Colors.blue,
                            height: 50,
                            minWidth: 300,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child:
                                _isLoading
                                    ? CircularProgressIndicator()
                                    : Text(
                                      "Login",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                          ),
                          SizedBox(height: 20),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () => context.push('/forgot-pin'),
                                child: Text(
                                  "Forgot pin?",
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                              SizedBox(height: 16),
                              GestureDetector(
                                onTap: () => context.go('/register'),
                                child: Text(
                                  "Don't have an account?",
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                              SizedBox(height: 16),
                              GestureDetector(
                                onTap: () => context.push('/activate-account'),
                                child: Text(
                                  "Activate my account",
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
