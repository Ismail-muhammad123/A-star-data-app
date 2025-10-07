import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/features/orders/data/models.dart';
import 'package:app/features/orders/data/services.dart';
import 'package:app/features/orders/views/pages/orders_tab.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class PurchaseHistory extends StatefulWidget {
  const PurchaseHistory({super.key});

  @override
  State<PurchaseHistory> createState() => _PurchaseHistoryState();
}

class _PurchaseHistoryState extends State<PurchaseHistory> {
  DateTime? _selectedDate;
  String? _selectedType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: Colors.white,
          onPressed:
              () => context.canPop() ? context.pop() : context.go("/home"),
        ),
        title: Text("Purchase History", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.lightBlue,
        surfaceTintColor: Colors.lightBlue,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            tooltip: "Clear Filters & refresh",
            onPressed: () {
              setState(() {
                _selectedDate = null;
                _selectedType = null;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Date filter
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        firstDate: DateTime(2024),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDate = picked;
                        });
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _selectedDate == null
                            ? "Select Date"
                            : _selectedDate!.toLocal().toString().split(' ')[0],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                // Transaction type filter
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                    ),
                    items: [
                      DropdownMenuItem(value: null, child: Text("All Types")),
                      DropdownMenuItem(
                        value: "airtime",
                        child: Text("Airtime"),
                      ),
                      DropdownMenuItem(value: "data", child: Text("Data")),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<OrderHistory>>(
              future: OrderServices().getTransactions(
                context.read<AuthProvider>().authToken ?? "",
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.hasError) {
                  return Center(child: Text("Error loading transactions"));
                }
                var transactions = snapshot.data!;
                if (transactions.isEmpty) {
                  return Center(child: Text("No transactions found"));
                }
                transactions.sort((a, b) => b.time.compareTo(a.time));
                // Apply filters
                if (_selectedDate != null) {
                  transactions =
                      transactions.where((tx) {
                        return tx.time.year == _selectedDate!.year &&
                            tx.time.month == _selectedDate!.month &&
                            tx.time.day == _selectedDate!.day;
                      }).toList();
                }
                if (_selectedType != null) {
                  transactions =
                      transactions.where((tx) {
                        return tx.purchaseType == _selectedType;
                      }).toList();
                }
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
    );
  }
}
