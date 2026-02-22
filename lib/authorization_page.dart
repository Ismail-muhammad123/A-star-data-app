import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'features/auth/providers/auth_provider.dart';

class AuthorizationPage extends StatefulWidget {
  const AuthorizationPage({super.key});

  @override
  State<AuthorizationPage> createState() => _AuthorizationPageState();
}

class _AuthorizationPageState extends State<AuthorizationPage> {
  @override
  void initState() {
    super.initState();
    _handleRouting();
  }

  Future<void> _handleRouting() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    // Check auth and refresh token
    await auth.checkAuth();

    // Minimum loading time for a smooth experience
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    if (auth.isAuthenticated) {
      context.go('/home');
      return;
    }

    final isFirstTime = await auth.isFirstTime;
    if (isFirstTime) {
      context.go('/onboarding');
      return;
    }

    final hasLoggedIn = await auth.hasLoggedInBefore;
    if (hasLoggedIn) {
      context.go('/login');
    } else {
      context.go('/register');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade900,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: "logo",
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  "assets/images/logo/a-star_app_logo.png",
                  height: 100,
                  width: 100,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              "A-STAR CONNECT",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
            const SizedBox(height: 16),
            const Text(
              "Authenticating...",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
