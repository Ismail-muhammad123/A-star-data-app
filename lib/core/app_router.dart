import 'package:app/features/auth/views/pages/confirm_pin_reset.dart';
import 'package:app/features/orders/data/models.dart';
import 'package:app/features/orders/views/pages/airtime/buy_airtime.dart';
import 'package:app/features/orders/views/pages/data/buy_data.dart';
import 'package:app/features/orders/views/pages/electricity/buy_electricity_page.dart';
import 'package:app/features/orders/views/pages/electricity/list_electricity_providers.dart';
import 'package:app/features/orders/views/pages/history/order_details.dart';
import 'package:app/features/orders/views/pages/history/order_history.dart';
import 'package:app/features/orders/views/pages/internet/buy_internet_subscription.dart';
import 'package:app/features/orders/views/pages/tv/buy_tv_page.dart';
import 'package:app/features/orders/views/pages/tv/select_tv_pachage.dart';
import 'package:app/features/orders/views/pages/tv/select_tv_service.dart';

import 'package:app/features/settings/views/pages/personal/change_pin_form_page.dart';
import 'package:app/features/settings/views/pages/transaction_pin/change_transaction_pin_page.dart';
import 'package:app/features/settings/views/pages/transaction_pin/reset_transaction_pin_page.dart';
import 'package:app/features/settings/views/pages/transaction_pin/set_transaction_pin_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/authorization_page.dart';
import 'package:app/features/auth/views/pages/account_activation_page.dart';
import 'package:app/features/auth/views/pages/forget_pin.dart';
import 'package:app/features/auth/views/pages/login.dart';
import 'package:app/features/auth/views/pages/sign_up.dart';
import 'package:app/features/auth/views/pages/two_fa_otp_page.dart';
import 'package:app/features/settings/views/pages/personal/profile_form_page.dart';

import 'package:app/features/wallet/views/pages/transaction_details_page.dart';
import 'package:app/features/wallet/views/pages/wallet_history_page.dart';
import 'package:app/features/wallet/views/pages/withdrawal_page.dart';
import 'package:app/features/wallet/views/pages/p2p/p2p_transfer_page.dart';
import 'package:app/home.dart';

import 'package:app/features/notifications/views/pages/notifications_page.dart';
import 'package:app/features/auth/views/pages/onboarding_page.dart';
import 'package:app/features/auth/views/pages/splash_screen.dart';
import 'package:app/features/support/views/pages/support_page.dart';
import 'package:app/features/support/views/pages/create_support_ticket_page.dart';
import 'package:app/features/support/views/pages/support_ticket_details_page.dart';
import 'package:app/features/support/data/models/support_model.dart';
import 'package:app/features/referral/views/pages/referral_page.dart';
import 'package:app/features/settings/views/pages/kyc/kyc_page.dart';

final GoRouter router = GoRouter(
  redirect: (context, state) {
    // List of public routes
    final publicRoutes = [
      '/',
      '/splash',
      '/onboarding',
      '/login',
      '/register',
      '/forgot-pin',
      '/activate-account',
      '/account-not-activated',
      '/confirm-pin-reset',
      '/verify-2fa',
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
      return '/login?next=${state.uri.toString()}';
    }

    // Otherwise, allow access
    return null;
  },
  initialLocation: '/splash',
  errorBuilder: (context, state) {
    return Scaffold(body: Center(child: Text('Error: ${state.error}')));
  },
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
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
        var channel = state.uri.queryParameters['channel'] ?? 'sms';
        if (phoneNumber != null) {
          return ConfirmPinReset(phoneNumber: phoneNumber, channel: channel);
        }
        return const ConfirmPinReset(phoneNumber: '', channel: 'sms');
      },
    ),

    GoRoute(
      path: '/activate-account',
      builder: (context, state) {
        var phone = state.extra == null ? "" : state.extra.toString();
        return AccountActivationPage(phoneNumber: phone);
      },
    ),
    GoRoute(
      path: '/verify-2fa',
      builder: (context, state) {
        var phone = state.extra == null ? "" : state.extra.toString();
        return TwoFaOtpPage(phoneNumber: phone);
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
    GoRoute(
      path: "/orders/buy-internet",
      builder: (context, state) {
        final preferredNetworkName = state.extra as String?;
        return InternetPurchasePage(
          preferredNetworkName: preferredNetworkName,
        );
      },
    ),

    // ==================== Electricity Routes =====================
    GoRoute(
      path: "/orders/select-electricity-provider",
      builder: (context, state) => ElectricityProvidersListPage(),
    ),

    GoRoute(
      path: "/orders/buy-electricity",
      builder: (context, state) {
        final service = state.extra as ElectricityService;
        return PurchaseElectricityFormPage(service: service);
      },
    ),

    // ==================== Cable/TV Routes =====================
    GoRoute(
      path: "/orders/select-tv-service",
      builder: (context, state) => TvServiceProvidersListPage(),
    ),

    GoRoute(
      path: "/orders/select-tv-plan",
      builder: (context, state) {
        final service = state.extra as CableTVService;
        return SelectTvPackagePage(provider: service);
      },
    ),

    GoRoute(
      path: "/orders/buy-tv-subscription",
      builder: (context, state) {
        final package = state.extra as CableTVPackage;
        return PurchaseTVSubscriptionFormPage(
          service: package.service,
          package: package,
        );
      },
    ),

    // ===================== Wallet Routes =====================
    // GoRoute(
    //   path: "/orders/buy-smile",
    //   builder: (context, state) => SmileVoicePurchasePage(),
    // ),
    GoRoute(
      path: '/wallet',
      builder: (context, state) => const HomePage(index: 1),
    ),
    GoRoute(
      path: '/wallet/history',
      builder: (context, state) => const WalletHistoryPage(),
    ),
    GoRoute(
      path: '/wallet/p2p',
      builder: (context, state) => const P2PTransferPage(),
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
      path: '/wallet/withdraw',
      builder: (context, state) => const WithdrawalPage(),
    ),

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
    GoRoute(
      path: '/profile/transaction-pin/set',
      builder: (context, state) => const SetTransactionPinPage(),
    ),
    GoRoute(
      path: '/profile/transaction-pin/change',
      builder: (context, state) => const ChangeTransactionPinPage(),
    ),
    GoRoute(
      path: '/profile/transaction-pin/reset',
      builder: (context, state) => const ResetTransactionPinPage(),
    ),
    GoRoute(path: '/support', builder: (context, state) => const SupportPage()),
    GoRoute(
      path: '/support/create',
      builder: (context, state) => const CreateSupportTicketPage(),
    ),
    GoRoute(
      path: '/support/ticket/:id',
      builder: (context, state) {
        final ticket = state.extra as SupportTicket;
        return SupportTicketDetailsPage(ticket: ticket);
      },
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsPage(),
    ),
    GoRoute(path: '/profile/kyc', builder: (context, state) => const KycPage()),
    GoRoute(
      path: '/referral',
      builder: (context, state) => const ReferralPage(),
    ),
  ],
);
