import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/core/app_router.dart';
import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/features/settings/providers/profile_provider.dart';
import 'package:app/core/themes/theme_provider.dart';
import 'package:app/core/themes/app_theme.dart';
import 'package:app/core/providers/balance_visibility_provider.dart';
import 'package:app/features/wallet/providers/wallet_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => BalanceVisibilityProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
      ],
      child: const AStarDataApp(),
    ),
  );
}

class AStarDataApp extends StatelessWidget {
  const AStarDataApp({super.key});
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp.router(
      title: 'A-Star Data App',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
