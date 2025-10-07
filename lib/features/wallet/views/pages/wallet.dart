import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/features/wallet/data/models/wallet.dart';
import 'package:app/features/wallet/data/repository/wallet_repo.dart';
import 'package:app/features/wallet/views/widgets/transaction_history_list.dart';
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
  bool showBalance = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,

        elevation: 8.0,
        title: Text(
          "My Wallet",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.lightBlue[200],
        surfaceTintColor: Colors.lightBlue[200],
        actions: [
          IconButton(
            onPressed:
                () => setState(() {
                  // Refresh the wallet page
                }),
            icon: Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              height: 170,
              width: double.maxFinite,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.lightBlueAccent.withAlpha(100),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              padding: EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Available Balance",
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                  FutureBuilder<String>(
                    future: WalletService().getBalance(
                      Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      ).authToken!,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator(color: Colors.white);
                      }
                      if (snapshot.hasError) {
                        print(snapshot.error);
                        return Text(
                          "Error loading balance",
                          style: TextStyle(color: Colors.white),
                        );
                      }
                      return Text(
                        NumberFormat.currency(
                          locale: 'en_NG',
                          symbol: '₦',
                          decimalDigits: 2,
                        ).format(double.parse(snapshot.data!)),
                        style: TextStyle(fontSize: 28),
                      );
                    },
                  ),
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: MaterialButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          height: 40,
                          color: Colors.blue,
                          onPressed:
                              () => context
                                  .push("/wallet/fund")
                                  .then((_) => setState(() {})),
                          child: Text(
                            "Fund Wallet",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.lightBlue.shade50,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
                  border: Border(
                    top: BorderSide(color: Colors.grey.withOpacity(0.2)),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Recent Transactions",
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                      GestureDetector(
                        onTap: () => context.push("/wallet/history"),
                        child: Text(
                          "view all",
                          style: TextStyle(
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: FutureBuilder<List<WalletTransaction>>(
                  future: WalletService().getTransactions(
                    Provider.of<AuthProvider>(
                      context,
                      listen: false,
                    ).authToken!,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      print(snapshot.error);
                      return Center(child: Text("Error loading transactions"));
                    }

                    var transactions = snapshot.data!;
                    if (transactions.isEmpty) {
                      return Center(child: Text("No transactions found"));
                    }
                    transactions.sort(
                      (a, b) => b.timestamp.compareTo(a.timestamp),
                    );
                    transactions =
                        transactions.length > 10
                            ? transactions.sublist(0, 10)
                            : transactions;
                    return TransactionHistoryList(transactions: transactions);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
