import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/features/wallet/data/models/wallet.dart';
import 'package:app/features/wallet/data/repository/wallet_repo.dart';
import 'package:app/features/wallet/views/widgets/transaction_history_list.dart';
import 'package:app/features/wallet/views/widgets/transfer_deposit_account_info_card.dart';
import 'package:app/core/providers/balance_visibility_provider.dart';
import 'package:app/features/wallet/providers/wallet_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
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
    final balanceVisibility = context.watch<BalanceVisibilityProvider>();
    final walletProvider = context.watch<WalletProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "My Wallet",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final authProvider = context.read<AuthProvider>();
          if (authProvider.authToken != null) {
            await context.read<WalletProvider>().fetchBalance(
              authProvider.authToken!,
            );
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors:
                        Theme.of(context).brightness == Brightness.dark
                            ? const [
                              Color(0xFF0F2027),
                              Color(0xFF203A43),
                              Color(0xFF2C5364),
                            ]
                            : const [Colors.blueAccent, Colors.lightBlue],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Available Balance",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap:
                              () => balanceVisibility.toggleBalanceVisibility(),
                          child: Icon(
                            balanceVisibility.isBalanceHidden
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.white.withOpacity(0.7),
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (walletProvider.isLoading && walletProvider.balance == 0)
                      const SizedBox(
                        height: 40,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
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
                          fontSize: 36,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            label: "Fund",
                            icon: Icons.add_circle_outline,
                            color: Colors.white,
                            textColor: Colors.blueAccent,
                            onTap:
                                () => context
                                    .push("/wallet/fund")
                                    .then((_) => setState(() {})),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionButton(
                            label: "Withdraw",
                            icon: Icons.account_balance_wallet_outlined,
                            color: Colors.white.withOpacity(0.2),
                            textColor: Colors.white,
                            onTap:
                                () => context
                                    .push("/wallet/withdraw")
                                    .then((_) => setState(() {})),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Virtual Account Section
              FutureBuilder<VirtualAccount>(
                future: WalletService().getVirtualAccount(
                  context.read<AuthProvider>().authToken ?? "",
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox();
                  }

                  if (!snapshot.hasData || snapshot.hasError) {
                    return _buildIncompleteProfileNotice(context);
                  }

                  final account = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Bank Transfer Deposit",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TransferDepositAccountInfoCard(
                        accountName: account.accountName,
                        accountNumber: account.accountNumber,
                        bankName: account.bankName,
                        color: Theme.of(context).cardColor,
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 32),

              // Transaction History Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Recent Transactions",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push("/wallet/history"),
                    child: const Text(
                      "See All",
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              FutureBuilder<List<WalletTransaction>>(
                future: WalletService().getTransactions(
                  context.read<AuthProvider>().authToken ?? "",
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text("Error loading transactions"),
                    );
                  }

                  final transactions = snapshot.data ?? [];
                  if (transactions.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.history,
                              size: 48,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No transactions yet",
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final displayList = [...transactions];
                  displayList.sort(
                    (a, b) => b.timestamp.compareTo(a.timestamp),
                  );

                  return Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TransactionHistoryList(
                      transactions: displayList.take(10).toList(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: textColor, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIncompleteProfileNotice(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push("/profile/update"),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.orange.shade100),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.orange[400], size: 28),
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                "Complete your profile to unlock a permanent virtual account for instant funding.",
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.orange),
          ],
        ),
      ),
    );
  }
}
