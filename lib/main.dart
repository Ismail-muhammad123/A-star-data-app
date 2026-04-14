import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/core/app_router.dart';
import 'package:app/core/services/push_notification_service.dart';
import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/features/settings/providers/profile_provider.dart';
import 'package:app/core/themes/theme_provider.dart';
import 'package:app/core/themes/app_theme.dart';
import 'package:app/core/providers/balance_visibility_provider.dart';
import 'package:app/features/wallet/providers/wallet_provider.dart';
import 'package:app/features/settings/providers/transaction_pin_provider.dart';
import 'package:app/features/support/providers/support_provider.dart';
import 'package:app/features/notifications/providers/notification_provider.dart';
import 'package:app/core/permission_services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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
        ChangeNotifierProvider(create: (_) => TransactionPinProvider()),
        ChangeNotifierProvider(create: (_) => SupportProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: const AStarDataApp(),
    ),
  );
}

class AStarDataApp extends StatefulWidget {
  const AStarDataApp({super.key});

  @override
  State<AStarDataApp> createState() => _AStarDataAppState();
}

class _AStarDataAppState extends State<AStarDataApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupPushNotifications();
    });
  }

  Future<void> _setupPushNotifications() async {
    final authProvider = context.read<AuthProvider>();
    final notificationProvider = context.read<NotificationProvider>();

    // Request notification permission
    await PermissionService.requestNotificationPermission();

    await PushNotificationService.instance.initialize(
      onForegroundMessage: (RemoteMessage message) async {
        final token = authProvider.authToken;
        if (token != null && token.isNotEmpty) {
          await notificationProvider.fetchNotifications(token);
        }
      },
      onMessageOpenedApp: (RemoteMessage message) async {
        final token = authProvider.authToken;
        if (token != null && token.isNotEmpty) {
          await notificationProvider.fetchNotifications(token);
        }
      },
      onTokenRefresh: (String token) async {
        await authProvider.registerSpecificFcmToken(token);
      },
    );

    await authProvider.registerCurrentFcmToken();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp.router(
      title: 'Starboy Global - Data & Airtime App',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: router,
      builder: (context, child) {
        final theme = Theme.of(context);
        return Container(
          color: theme.brightness == Brightness.dark
              ? Colors.black
              : Colors.grey[200],
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
