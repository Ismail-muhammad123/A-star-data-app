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
  bool _isLoading = true;
  void checkLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.checkAuth();
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    if (authProvider.isAuthenticated) {
      final nextUri = GoRouterState.of(context).uri.queryParameters['next'];
      context.go(nextUri ?? '/home');
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    checkLogin();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color.fromARGB(255, 255, 202, 198),
      backgroundColor: Colors.white,
      body: SizedBox(
        height: double.maxFinite,
        width: double.maxFinite,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Hero(
            //   tag: "logo",
            //   child: Image.asset(
            //     "assets/images/logo.png",
            //     height: 200,
            //     width: 200,
            //     fit: BoxFit.contain,
            //   ),
            // ),
            Text(
              "Welcome to",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 20),
            Text(
              "A-Star Data App",
              style: TextStyle(
                fontSize: 30,
                color: Colors.black,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 40),

            _isLoading
                ? CircularProgressIndicator(color: Colors.white)
                : SizedBox(),

            _isLoading
                ? SizedBox()
                : MaterialButton(
                  onPressed: () {
                    context.go('/login');
                  },
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  height: 40,
                  minWidth: 200,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'Log in',
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward, color: Colors.red),
                    ],
                  ),
                ),
            SizedBox(height: 20),
            _isLoading
                ? SizedBox()
                : MaterialButton(
                  onPressed: () {
                    context.go('/register');
                  },
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  height: 40,
                  minWidth: 200,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'Sign up',
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.add, color: Colors.red),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
