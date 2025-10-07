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
      appBar: AppBar(
        leading: BackButton(
          color: Colors.white,
          onPressed:
              () => context.canPop() ? context.pop() : context.go("/wallet"),
        ),
        title: Text("Wallet History", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.lightBlue,
        surfaceTintColor: Colors.lightBlue,
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _transactions.isEmpty
              ? Center(child: Text("No Transactions Found"))
              : TransactionHistoryList(transactions: _transactions),
    );
  }
}
