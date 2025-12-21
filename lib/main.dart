import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/core/app_router.dart';
import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/features/profile/providers/profile_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      title: 'A-Star Data App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
