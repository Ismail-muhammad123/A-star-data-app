import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/features/wallet/providers/wallet_provider.dart';
import 'package:app/core/providers/balance_visibility_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class BalanceSummary extends StatefulWidget {
  const BalanceSummary({super.key});

  @override
  State<BalanceSummary> createState() => _BalanceSummaryState();
}

class _BalanceSummaryState extends State<BalanceSummary> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.authToken != null) {
        context.read<WalletProvider>().fetchBalance(authProvider.authToken!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final walletProvider = context.watch<WalletProvider>();
    final balanceVisibility = context.watch<BalanceVisibilityProvider>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet,
                color: Colors.blueAccent,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                "Wallet Balance",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
          if (walletProvider.isLoading)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Text(
              balanceVisibility.isBalanceHidden
                  ? "****"
                  : NumberFormat.currency(
                    locale: 'en_NG',
                    symbol: '₦',
                  ).format(walletProvider.balance),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
        ],
      ),
    );
  }
}
