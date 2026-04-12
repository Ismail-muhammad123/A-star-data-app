import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/features/wallet/data/models/wallet.dart';
import 'package:app/features/wallet/data/repositories/wallet_repo.dart';
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

class TransactionDetailsPage extends StatefulWidget {
  final int? transactionId;
  const TransactionDetailsPage({super.key, this.transactionId});

  @override
  State<TransactionDetailsPage> createState() => _TransactionDetailsPageState();
}

class _TransactionDetailsPageState extends State<TransactionDetailsPage> {
  WalletTransaction? transaction;
  bool _isLoading = false;
  final ScreenshotController _screenshotController = ScreenshotController();

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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to load transaction! ${e.toString()}"),
          ),
        );
      }
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

  Future<void> _shareReceipt() async {
    try {
      final Uint8List? image = await _screenshotController.capture();
      if (image == null) return;

      final directory = await getTemporaryDirectory();
      final imagePath =
          await File(
            '${directory.path}/receipt_${transaction!.id}.png',
          ).create();
      await imagePath.writeAsBytes(image);

      await Share.shareXFiles([
        XFile(imagePath.path),
      ], text: 'Transaction Receipt - Starboy Global');
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
    _getTransaction();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Transaction Details",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        leading: BackButton(
          color: Colors.white,
          onPressed:
              () => context.canPop() ? context.pop() : context.go("/wallet"),
        ),
        elevation: 0,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : transaction == null
              ? const Center(child: Text("Transaction not found"))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Screenshot(
                      controller: _screenshotController,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            if (Theme.of(context).brightness ==
                                Brightness.light)
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Watermark
                            Positioned.fill(
                              child: Center(
                                child: Transform.rotate(
                                  angle: -0.5,
                                  child: Text(
                                    "Starboy Global",
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
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check_circle_rounded,
                                    color: Colors.green,
                                    size: 48,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  "Transaction Successful",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  NumberFormat.currency(
                                    locale: 'en_NG',
                                    symbol: '₦',
                                    decimalDigits: 2,
                                  ).format(transaction!.amount),
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(
                                          context,
                                        ).textTheme.bodyLarge?.color,
                                  ),
                                ),
                                const SizedBox(height: 32),
                                const Divider(),
                                const SizedBox(height: 24),
                                _buildInfoRow(
                                  "Transaction ID",
                                  "#${transaction!.id.toString().padLeft(7, '0')}",
                                ),
                                _buildInfoRow(
                                  "Type",
                                  transaction!.transactionType
                                      .replaceAll("_", " ")
                                      .toUpperCase(),
                                ),
                                _buildInfoRow(
                                  "Date & Time",
                                  DateFormat.yMMMEd().add_jm().format(
                                    transaction!.timestamp,
                                  ),
                                ),
                                _buildInfoRow("Status", "SUCCESSFUL"),
                                _buildInfoRow(
                                  "Description",
                                  transaction?.description ?? "",
                                ),
                                const SizedBox(height: 24),
                                const Divider(),
                                const SizedBox(height: 16),
                                Center(
                                  child: Text(
                                    "Starboy Global",
                                    style: TextStyle(
                                      color: Colors.blueAccent.withOpacity(0.5),
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
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _saveReceipt,
                            icon: const Icon(Icons.download_outlined, size: 18),
                            label: const Text("Save"),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
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
                            onPressed: _shareReceipt,
                            icon: const Icon(Icons.share_outlined, size: 18),
                            label: const Text("Share"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      "If you have any issues with this transaction, please contact our support team.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 14)),
          SizedBox(width: 8.0),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
