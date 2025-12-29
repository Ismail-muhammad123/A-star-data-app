import 'package:app/features/auth/providers/auth_provider.dart';
// import 'package:app/features/profile/providers/profile_provider.dart';
import 'package:app/features/wallet/data/models/wallet.dart';
import 'package:app/features/wallet/data/repository/wallet_repo.dart';
import 'package:app/features/wallet/views/widgets/transaction_history_list.dart';
import 'package:app/features/wallet/views/widgets/transfer_deposit_account_info_card.dart';
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.maxFinite,
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(88, 158, 158, 158),
                      blurRadius: 10,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Available balance",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    FutureBuilder<String>(
                      future: WalletService().getBalance(
                        context.read<AuthProvider>().authToken ?? "",
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }
                        if (!snapshot.hasData || snapshot.hasError) {
                          return Text(
                            "Error",
                            style: TextStyle(
                              fontSize: 30,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }
                        // if (snapshot.data != null) {
                        var balance = double.tryParse(snapshot.data!);

                        return Text(
                          NumberFormat.currency(
                            locale: 'en_NG',
                            symbol: '₦',
                          ).format(balance ?? 0).toString(),
                          style: TextStyle(fontSize: 28, color: Colors.black),
                        );
                      },
                    ),
                    SizedBox(height: 10),

                    FutureBuilder<VirtualAccount>(
                      future: WalletService().getVirtualAccount(
                        context.read<AuthProvider>().authToken ?? "",
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return SizedBox();
                        }
                        if (!snapshot.hasData || snapshot.hasError) {
                          return SizedBox();
                        }
                        var account = snapshot.data!;
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "Fund via transfer",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            SizedBox(height: 6.0),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TransferDepositAccountInfoCard(
                                accountName: account.accountName,
                                accountNumber: account.accountNumber,
                                bankName: account.bankName,
                                color: Colors.lightBlue[50],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.payment, color: Colors.white),
                                SizedBox(width: 10),
                                Text(
                                  "Fund with Card",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
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
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(6),
                    ),
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
                          style: TextStyle(fontSize: 14, color: Colors.black),
                        ),
                        GestureDetector(
                          onTap: () => context.push("/wallet/history"),
                          child: Text(
                            "view all",
                            style: TextStyle(
                              fontSize: 14,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
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
            ],
          ),
        ),
      ),
    );
  }
}
