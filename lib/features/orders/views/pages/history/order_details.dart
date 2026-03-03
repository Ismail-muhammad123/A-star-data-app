import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/features/orders/data/models.dart';
import 'package:app/features/orders/data/services.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gal/gal.dart';

class PurchaseDetailsPage extends StatefulWidget {
  const PurchaseDetailsPage({super.key, required this.transactionId});
  final int transactionId;

  @override
  State<PurchaseDetailsPage> createState() => PurchaseDetailsPageState();
}

class PurchaseDetailsPageState extends State<PurchaseDetailsPage> {
  OrderHistory? transactionDetails;
  bool isLoading = true;
  final ScreenshotController _screenshotController = ScreenshotController();
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

  Future<void> _shareReceipt() async {
    try {
      final Uint8List? image = await _screenshotController.capture();
      if (image == null) return;

      final directory = await getTemporaryDirectory();
      final imagePath =
          await File(
            '${directory.path}/purchase_${widget.transactionId}.png',
          ).create();
      await imagePath.writeAsBytes(image);

      await Share.shareXFiles([
        XFile(imagePath.path),
      ], text: 'Purchase Receipt - A-Star Connect');
    } catch (e) {
      debugPrint("Error sharing receipt: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to share receipt: ${e.toString()}")),
        );
      }
    }
  }

  Future<void> _saveReceipt() async {
    try {
      final Uint8List? image = await _screenshotController.capture();
      if (image == null) return;

      await Gal.putImageBytes(image);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Receipt saved to gallery!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error saving receipt: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save receipt: ${e.toString()}")),
        );
      }
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: BackButton(
          onPressed:
              () => context.canPop() ? context.pop() : context.go("/wallet"),
          color: Colors.white,
        ),
        title: const Text(
          "Purchase Details",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              color: Theme.of(context).appBarTheme.backgroundColor,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 24.0,
                  ),
                  child: Column(
                    children: [
                      Screenshot(
                        controller: _screenshotController,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                          ),
                          child: Stack(
                            children: [
                              // Watermark
                              Positioned.fill(
                                child: Center(
                                  child: Transform.rotate(
                                    angle: -0.5,
                                    child: Text(
                                      "A-Star Connect",
                                      style: TextStyle(
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.withOpacity(0.05),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Column(
                                children: [
                                  // Header Card
                                  Container(
                                    width: double.maxFinite,
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.04),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.blueAccent
                                                .withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            _getIconForType(
                                              transactionDetails?.purchaseType,
                                            ),
                                            color: Colors.blueAccent,
                                            size: 28,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${transactionDetails?.purchaseType ?? ""} Purchase"
                                                    .toUpperCase(),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color:
                                                      Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge
                                                          ?.color,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                "To: ${transactionDetails?.beneficiary ?? '-'}",
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              NumberFormat.currency(
                                                symbol: "₦",
                                                decimalDigits: 0,
                                              ).format(
                                                transactionDetails?.amount ?? 0,
                                              ),
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blueAccent,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color:
                                                    (transactionDetails?.status
                                                                .toLowerCase() ==
                                                            "success")
                                                        ? Colors.green
                                                            .withOpacity(0.1)
                                                        : Colors.orange
                                                            .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                              child: Text(
                                                (transactionDetails?.status ??
                                                        '')
                                                    .toUpperCase(),
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      (transactionDetails
                                                                  ?.status
                                                                  .toLowerCase() ==
                                                              "success")
                                                          ? Colors.green
                                                          : Colors.orange,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // Details Card
                                  Container(
                                    width: double.maxFinite,
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.04),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child:
                                        isLoading
                                            ? const Padding(
                                              padding: EdgeInsets.all(40.0),
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Colors.blueAccent,
                                                    ),
                                              ),
                                            )
                                            : transactionDetails == null
                                            ? const Padding(
                                              padding: EdgeInsets.all(40.0),
                                              child: Center(
                                                child: Text(
                                                  "No details available",
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                            )
                                            : Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Transaction Info",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color:
                                                        Theme.of(context)
                                                            .textTheme
                                                            .bodyLarge
                                                            ?.color,
                                                  ),
                                                ),
                                                const SizedBox(height: 16),
                                                _buildDetailRow(
                                                  "Amount",
                                                  NumberFormat.currency(
                                                    symbol: "₦",
                                                    decimalDigits: 0,
                                                  ).format(
                                                    transactionDetails!.amount,
                                                  ),
                                                ),
                                                _buildDivider(),
                                                _buildDetailRow(
                                                  "Phone Number",
                                                  transactionDetails!
                                                      .beneficiary,
                                                ),
                                                _buildDivider(),
                                                _buildDetailRow(
                                                  "Date",
                                                  DateFormat(
                                                    'MMM dd, yyyy \u2022 hh:mm a',
                                                  ).format(
                                                    transactionDetails!.time,
                                                  ),
                                                ),
                                                _buildDivider(),
                                                _buildDetailRow(
                                                  "Status",
                                                  transactionDetails!.status
                                                      .toUpperCase(),
                                                  isStatus: true,
                                                ),
                                                _buildDivider(),
                                                _buildDetailRow(
                                                  "Reference",
                                                  transactionDetails!.reference,
                                                ),
                                              ],
                                            ),
                                  ),
                                  const SizedBox(height: 20),
                                  Center(
                                    child: Text(
                                      "A-Star Connect",
                                      style: TextStyle(
                                        color: Colors.blueAccent.withOpacity(
                                          0.5,
                                        ),
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: isLoading ? null : _saveReceipt,
                              icon: const Icon(
                                Icons.download_outlined,
                                size: 18,
                              ),
                              label: const Text("Save"),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                side: BorderSide(
                                  color: Theme.of(context).dividerColor,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: isLoading ? null : _shareReceipt,
                              icon: const Icon(Icons.share_outlined, size: 18),
                              label: const Text("Share"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(String? type) {
    if (type == null) return Icons.receipt;
    final lower = type.toLowerCase();
    if (lower.contains('airtime')) return Icons.phone_android;
    if (lower.contains('data')) return Icons.wifi;
    if (lower.contains('electricity')) return Icons.electric_bolt;
    if (lower.contains('tv')) return Icons.tv;
    return Icons.receipt;
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Divider(thickness: 0.5, color: Theme.of(context).dividerColor),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          isStatus
              ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color:
                      value == "SUCCESS"
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: value == "SUCCESS" ? Colors.green : Colors.orange,
                  ),
                ),
              )
              : Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
        ],
      ),
    );
  }
}
