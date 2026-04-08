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

    await PushNotificationService.instance.initialize(
      onForegroundMessage: (RemoteMessage message) async {
        final token = authProvider.authToken;
        if (token != null && token.isNotEmpty) {
          await notificationProvider.fetchNotifications(token);
        }

        if (!mounted) return;
        final title = message.notification?.title ?? "New notification";
        final body = message.notification?.body;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(body == null || body.isEmpty ? title : "$title: $body"),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      onMessageOpenedApp: (RemoteMessage message) async {
        final token = authProvider.authToken;
        if (token != null && token.isNotEmpty) {
          await notificationProvider.fetchNotifications(token);
        }
        router.push('/notifications');
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
      title: 'A-Star Data App',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
