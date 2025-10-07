import 'package:app/features/auth/views/pages/confirm_pin_reset.dart';
import 'package:app/features/orders/views/pages/buy_airtime.dart';
import 'package:app/features/orders/views/pages/buy_data.dart';
import 'package:app/features/orders/views/pages/order_details.dart';
import 'package:app/features/orders/views/pages/order_history.dart';
import 'package:app/features/profile/views/pages/personal/change_password_form_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/authorization_page.dart';
import 'package:app/features/auth/views/pages/account_activation_page.dart';
import 'package:app/features/auth/views/pages/forget_pin.dart';
import 'package:app/features/auth/views/pages/login.dart';
import 'package:app/features/auth/views/pages/sign_up.dart';
import 'package:app/features/profile/views/pages/personal/profile_form_page.dart';
import 'package:app/features/wallet/views/pages/fund_wallet_page.dart';
import 'package:app/features/wallet/views/pages/transaction_details_page.dart';
import 'package:app/features/wallet/views/pages/wallet_history_page.dart';
// import 'package:app/features/wallet/views/pages/withdrawal_form_page.dart';
import 'package:app/home.dart';

final GoRouter router = GoRouter(
  redirect: (context, state) {
    // List of public routes
    final publicRoutes = [
      '/',
      '/login',
      '/register',
      '/forgot-password',
      '/activate-account',
      '/account-not-activated',
      // '/account-activation-success',
      // '/account-activation-failure',
    ];
    // Allow product details as public
    // final isProductDetails =
    //     state.matchedLocation.startsWith('/products/') &&
    //     state.matchedLocation.split('/').length == 3;

    // Simulate authentication check (replace with your real logic)
    final isLoggedIn = context.read<AuthProvider>().isAuthenticated;

    // If route is public, allow access
    if (publicRoutes.contains(state.matchedLocation)) {
      return null;
    }

    // If not logged in, redirect to login
    if (!isLoggedIn) {
      print(state.uri.toString());
      return '/login?next=${state.uri.toString()}';
    }

    // Otherwise, allow access
    return null;
  },
  initialLocation: '/',
  errorBuilder: (context, state) {
    return Scaffold(body: Center(child: Text('Error: ${state.error}')));
  },
  routes: [
    GoRoute(path: '/', builder: (context, state) => const AuthorizationPage()),
    // ===================== Auth Routes =====================
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(path: '/register', builder: (context, state) => const SignUpPage()),
    GoRoute(
      path: '/forgot-pin',
      builder: (context, state) => const ForgetPinPage(),
    ),
    GoRoute(
      path: '/confirm-pin-reset',

      builder: (context, state) {
        var phoneNumber = state.uri.queryParameters['phone'];
        if (phoneNumber != null) {
          return ConfirmPinReset(phoneNumber: phoneNumber);
        }
        return const ConfirmPinReset(phoneNumber: '');
      },
    ),

    GoRoute(
      path: '/activate-account',
      builder: (context, state) {
        var phone = state.extra == null ? "" : state.extra.toString();
        return AccountActivationPage(phoneNumber: phone);
      },
    ),

    // ===================== Data & Airtime Routes  =====================
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomePage(index: 0),
    ),

    GoRoute(
      path: '/orders',
      builder: (context, state) => const HomePage(index: 0),
    ),

    GoRoute(
      path: "/orders/history",
      builder: (context, state) => PurchaseHistory(),
    ),

    GoRoute(
      path: "/orders/history/:transactionId",

      builder: (context, state) {
        var id = int.tryParse(state.pathParameters['transactionId']!) ?? 0;
        return PurchaseDetailsPage(transactionId: id);
      },
    ),

    GoRoute(
      path: "/orders/buy-airtime",
      builder: (context, state) => AirtimePurchaseFormPage(),
    ),
    GoRoute(
      path: "/orders/buy-data",
      builder: (context, state) => DataPurchaseFormPage(),
    ),

    // ===================== Wallet Routes =====================
    GoRoute(
      path: '/wallet',
      builder: (context, state) => const HomePage(index: 1),
    ),
    GoRoute(
      path: '/wallet/history',
      builder: (context, state) => const WalletHistoryPage(),
    ),
    GoRoute(
      path: '/wallet/history/:transactionId',
      builder: (context, state) {
        final transactionId =
            int.tryParse(state.pathParameters['transactionId']!) ?? 0;
        return TransactionDetailsPage(transactionId: transactionId);
      },
    ),
    GoRoute(
      path: '/wallet/fund',
      builder: (context, state) => FundWalletFormPage(),
    ),

    // GoRoute(
    //   path: '/wallet/withdraw',
    //   builder: (context, state) => WithdrawalFormPage(),
    // ),

    // ===================== Profile Routes =====================
    GoRoute(
      path: '/profile',
      builder: (context, state) => const HomePage(index: 2),
    ),
    GoRoute(
      path: '/profile/update',
      builder: (context, state) => ProfileFormPage(),
    ),
    GoRoute(
      path: '/profile/change-pin',
      builder: (context, state) => const ChangePasswordPage(),
    ),
    // GoRoute(path: '/profile/kyc', builder: (context, state) => KycFormPage()),
    // GoRoute(
    //   path: '/profile/personal-info',
    //   builder: (context, state) => PersonalInfoFormPage(),
    // ),

    // GoRoute(
    //   path: '/account-not-activated',
    //   builder: (context, state) => const AccountNotActivatedPage(),
    // ),
    // GoRoute(
    //   path: '/account-activation-success',
    //   builder: (context, state) => const AccountActivationSuccessPage(),
    // ),
    // GoRoute(
    //   path: '/account-activation-failure',
    //   builder: (context, state) => const AccountActivationFailed(),
    // ),
  ],
);
