import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/features/orders/data/models.dart';
import 'package:app/features/orders/data/services.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PurchaseDetailsPage extends StatefulWidget {
  const PurchaseDetailsPage({super.key, required this.transactionId});
  final int transactionId;

  @override
  State<PurchaseDetailsPage> createState() => PurchaseDetailsPageState();
}

class PurchaseDetailsPageState extends State<PurchaseDetailsPage> {
  OrderHistory? transactionDetails;
  bool isLoading = true;
  _getTransactionDetails() async {
    setState(() {
      isLoading = true;
    });
    try {
      var res = await OrderServices().fetchOrderById(
        context.read<AuthProvider>().authToken ?? "",
        widget.transactionId,
      );
      setState(() {
        transactionDetails = res;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching transaction details: $e')),
      );
      context.canPop() ? context.pop() : context.go("/home");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    _getTransactionDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Purchase Details"),
        elevation: 4,
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: Container(
              width: double.maxFinite,
              height: 100,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.lightBlueAccent,
                    child: Icon(
                      transactionDetails?.purchaseType == "airtime"
                          ? Icons.phone_android
                          : Icons.wifi,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${transactionDetails?.purchaseType ?? ""} Purchase"
                            .toUpperCase(),
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "To: ${transactionDetails?.beneficiary ?? '-'}",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  Spacer(),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        NumberFormat.currency(
                          symbol: "₦",
                        ).format(transactionDetails?.amount ?? 0),
                        style: TextStyle(fontSize: 18),
                      ),
                      Text((transactionDetails?.status ?? '').toUpperCase()),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 14),
          Container(
            width: double.maxFinite,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                isLoading
                    ? Center(child: CircularProgressIndicator())
                    : transactionDetails == null
                    ? Center(child: Text("No details available"))
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // DetailRow(
                        //   label: "Transaction ID",
                        //   value: transactionDetails!..toString(),
                        // ),
                        DetailRow(
                          label: "Amount",
                          value: NumberFormat.currency(
                            symbol: "₦",
                          ).format(transactionDetails!.amount),
                        ),
                        // DetailRow(
                        //   label: "Network",
                        //   value: transactionDetails!.network,
                        // ),
                        DetailRow(
                          label: "Phone Number",
                          value: transactionDetails!.beneficiary,
                        ),
                        DetailRow(
                          label: "Date",
                          value: DateFormat.yMMMd().add_jm().format(
                            transactionDetails!.time,
                          ),
                        ),
                        DetailRow(
                          label: "Status",
                          value: transactionDetails!.status.toUpperCase(),
                        ),
                        DetailRow(
                          label: "Reference",
                          value: transactionDetails!.reference,
                        ),
                      ],
                    ),
          ),
        ],
      ),
    );
  }
}

class DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const DetailRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(
            width: 200,
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
