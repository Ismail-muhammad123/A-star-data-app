import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/features/wallet/data/models/wallet.dart';
import 'package:app/features/wallet/data/repository/wallet_repo.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TransactionDetailsPage extends StatefulWidget {
  final int? transactionId;
  const TransactionDetailsPage({super.key, this.transactionId});

  @override
  State<TransactionDetailsPage> createState() => _TransactionDetailsPageState();
}

class _TransactionDetailsPageState extends State<TransactionDetailsPage> {
  WalletTransaction? transaction;
  bool _isLoading = false;

  _getTransaction() async {
    setState(() {
      _isLoading = true;
    });
    try {
      var res = await WalletService().getTransactionById(
        context.read<AuthProvider>().authToken ?? "",
        widget.transactionId ?? 0,
      );
      if (res != null) {
        setState(() {
          transaction = res;
        });
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load transaction! ${e.toString()}")),
      );
      if (mounted) {
        context.canPop() ? context.pop() : context.go("/wallet");
      }
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
    _getTransaction();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: Colors.white,
          onPressed:
              () => context.canPop() ? context.pop() : context.go("/home"),
        ),
        title: const Text(
          'Transaction Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.lightBlue,
        surfaceTintColor: Colors.lightBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child:
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withAlpha(100),
                          blurRadius: 12,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // cahnge to get the values from Transaction Obj
                        _buildDetailRow(
                          'Transaction ID',
                          "#${transaction?.id != null ? transaction!.id.toString().padLeft(7, '0') : ''}",
                        ),
                        Divider(),
                        _buildDetailRow(
                          'Amount',
                          transaction != null
                              ? '₦${transaction?.amount.toStringAsFixed(2)}'
                              : '',
                        ),
                        Divider(),
                        _buildDetailRow(
                          'Type',
                          (transaction?.transactionType ?? '').toUpperCase(),
                        ),
                        Divider(),
                        _buildDetailRow(
                          'Date',
                          DateFormat.yMMMEd().format(transaction!.timestamp),
                        ),
                        // _buildDetailRow(
                        //   'Description',
                        //   transaction?.description ?? '',
                        // ),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }

  _buildDetailRow(String name, value) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Row(
        children: [
          Text(
            name,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          SizedBox(width: 14.0),
          Spacer(),
          SizedBox(
            width: 150,
            child: Text(
              value.toString(),
              softWrap: true,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
