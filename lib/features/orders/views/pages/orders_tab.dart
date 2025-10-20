import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/features/orders/data/models.dart';
import 'package:app/features/orders/data/services.dart';
import 'package:app/features/wallet/data/repository/wallet_repo.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class OrdersTab extends StatefulWidget {
  const OrdersTab({super.key});

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> {
  Future<void> _refresh() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome"),
        elevation: 0,
        backgroundColor: Colors.lightBlue,
        actions: [
          IconButton(
            onPressed: () => setState(() {}),
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      backgroundColor: Colors.lightBlue[50],
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: RefreshIndicator(
          onRefresh: _refresh,
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
                          "Available Wallet Balance",
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
                                      .push("/wallet")
                                      .then((_) => setState(() {})),
                              child: Text(
                                "Go to Wallet",
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
                SizedBox(height: 10),
                Row(
                  children: [
                    Flexible(
                      child: GestureDetector(
                        onTap:
                            () => context
                                .push("/orders/buy-airtime")
                                .then((_) => setState(() {})),
                        child: Container(
                          width: double.maxFinite,
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
                          padding: EdgeInsets.all(14.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.lightBlueAccent[100],
                                child: Icon(
                                  Icons.phone_android,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Buy Airtime",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.0),
                    Flexible(
                      child: GestureDetector(
                        onTap:
                            () => context
                                .push("/orders/buy-data")
                                .then((_) => setState(() {})),
                        child: Container(
                          width: double.maxFinite,

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
                          padding: EdgeInsets.all(14.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.lightBlueAccent[100],
                                child: Icon(
                                  Icons.wifi,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Buy Data",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      "Recent Transactions",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    TextButton(
                      onPressed: () => context.push("/orders/history"),
                      child: Text(
                        "view all",
                        style: TextStyle(decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.7,
                    minHeight: 200,
                  ),
                  child: FutureBuilder<List<OrderHistory>>(
                    future: OrderServices().getTransactions(
                      context.read<AuthProvider>().authToken ?? "",
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.hasError) {
                        return Center(
                          child: Text("Error loading transactions"),
                        );
                      }
                      var transactions = snapshot.data!;
                      if (transactions.isEmpty) {
                        return Center(child: Text("No transactions found"));
                      }
                      transactions.sort((a, b) => b.time.compareTo(a.time));
                      transactions = transactions.take(10).toList();

                      return ListView.builder(
                        itemCount: transactions.length,
                        itemBuilder:
                            (context, index) => OrderTransactionTile(
                              transaction: transactions[index],
                            ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OrderTransactionTile extends StatelessWidget {
  final OrderHistory transaction;
  const OrderTransactionTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: ListTile(
        onTap: () => context.push("/orders/history/${transaction.id}"),
        leading: Icon(
          transaction.purchaseType == "data" ? Icons.wifi : Icons.phone_android,
        ),
        title: Text(
          "${transaction.purchaseType} Purchase".toUpperCase(),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        subtitle: Text(
          "To: ${transaction.beneficiary}",
          style: TextStyle(fontSize: 11),
        ),
        // subtitle: Text(DateFormat.yMMMd().format(date)),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              NumberFormat.currency(
                locale: 'en_NG',
                symbol: '₦',
              ).format(transaction.amount).toString(),
              style: TextStyle(
                color: transaction.amount >= 0 ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              DateFormat.yMMMd().format(transaction.time),
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
