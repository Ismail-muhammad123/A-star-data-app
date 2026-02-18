import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/features/wallet/data/models/wallet.dart';
import 'package:app/features/wallet/data/repository/wallet_repo.dart';
import 'package:app/features/wallet/views/widgets/transaction_history_list.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class WalletHistoryPage extends StatefulWidget {
  const WalletHistoryPage({super.key});

  @override
  State<WalletHistoryPage> createState() => _WalletHistoryPageState();
}

class _WalletHistoryPageState extends State<WalletHistoryPage> {
  bool _isLoading = false;
  List<WalletTransaction> _transactions = [];

  _fetctWalletTransactions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      var transactions = await WalletService().getTransactions(
        context.read<AuthProvider>().authToken ?? "",
      );

      setState(() {
        _transactions = transactions;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load transactions! ${e.toString()}")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    _fetctWalletTransactions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Transaction History",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        leading: BackButton(
          color: Colors.white,
          onPressed:
              () => context.canPop() ? context.pop() : context.go("/wallet"),
        ),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () => _fetctWalletTransactions(),
        color: Colors.blueAccent,
        child:
            _isLoading && _transactions.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _transactions.isEmpty
                ? ListView(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.history_rounded,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No transactions yet",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Your transaction history will appear here.",
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
                : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    children: [
                      TransactionHistoryList(transactions: _transactions),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
      ),
    );
  }
}
