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
        leading: BackButton(
          onPressed:
              () => context.canPop() ? context.pop() : context.go("/wallet"),
          color: Colors.white,
        ),
        title: Text(
          "Purchase Details",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        elevation: 4,
        backgroundColor: Colors.lightBlue,
      ),
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Container(
              width: double.maxFinite,
              // height: 100,
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.lightBlueAccent,
                    child: Icon(
                      transactionDetails?.purchaseType == "airtime"
                          ? Icons.phone_android
                          : Icons.wifi,
                      color: Colors.white,
                      size: 20,
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
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "To: ${transactionDetails?.beneficiary ?? '-'}",
                        style: TextStyle(fontSize: 11),
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
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        padding: EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          color:
                              transactionDetails?.status.toLowerCase() ==
                                      "success"
                                  ? Colors.green
                                  : Colors.orange,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          (transactionDetails?.status ?? '').toUpperCase(),
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
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
                          Divider(),
                          // DetailRow(
                          //   label: "Network",
                          //   value: transactionDetails!.network,
                          // ),
                          DetailRow(
                            label: "Phone Number",
                            value: transactionDetails!.beneficiary,
                          ),
                          Divider(),
                          DetailRow(
                            label: "Date",
                            value: DateFormat.yMMMd().add_jm().format(
                              transactionDetails!.time,
                            ),
                          ),
                          Divider(),
                          DetailRow(
                            label: "Status",
                            value: transactionDetails!.status.toUpperCase(),
                          ),
                          Divider(),
                          DetailRow(
                            label: "Reference",
                            value: transactionDetails!.reference,
                          ),
                        ],
                      ),
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

          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
