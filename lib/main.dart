import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/core/app_router.dart';
import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/features/profile/providers/profile_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // if (Platform.isAndroid) {
  //   WebViewPlatform.instance = SurfaceAndroidWebView() as WebViewPlatform?;
  // }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: const TubaliApp(),
    ),
  );
}

class SurfaceAndroidWebView {}

class TubaliApp extends StatelessWidget {
  const TubaliApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Tubali',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent),
        useMaterial3: true,
      ),
      routerConfig: router,
      // home: const SplashScreen(),
      // onGenerateRoute: (settings) {
      //   if (settings.name == '/wallet/history/details') {
      //     final args = settings.arguments as Map<String, dynamic>;
      //     return MaterialPageRoute(
      //       builder:
      //           (context) => TransactionDetailsPage(
      //             transactionId: args['transactionId'],
      //           ),
      //     );
      //   }
      //   return null;
      // },

      // routes: {
      //   '/login': (_) => const LoginPage(),
      //   '/register': (_) => const SignUpPage(),
      //   '/forget-password': (_) => const ForgetPasswordPage(),
      //   '/forget-password-link-sent': (_) => const ForgetPasswordSentPage(),
      //   '/verification-email-sent':
      //       (_) => const SignupVerificationEmailSentPage(),
      //   '/dashboard': (_) => const DashboardPage(),

      //   '/investements/details': (context) {
      //     final args =
      //         ModalRoute.of(context)?.settings.arguments
      //             as Map<String, dynamic>;
      //     return InvestementDetailsPage(investementId: args['investementId']);
      //   },
      // },
    );
  }
}
