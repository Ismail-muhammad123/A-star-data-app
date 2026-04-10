import 'package:app/core/widgets/balance_summary.dart';
import 'package:app/core/widgets/pin_entry_bottom_sheet.dart';
import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/features/orders/data/models.dart';
import 'package:app/features/orders/data/services.dart';
import 'package:app/features/wallet/providers/wallet_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class InternetPurchasePage extends StatefulWidget {
  final InternetPackage package;
  const InternetPurchasePage({super.key, required this.package});

  @override
  State<InternetPurchasePage> createState() => _InternetPurchasePageState();
}

class _InternetPurchasePageState extends State<InternetPurchasePage> {
  final _phoneController = TextEditingController();
  final _promoController = TextEditingController();

  final OrderServices _orderServices = OrderServices();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _promoController.dispose();
    super.dispose();
  }

  Future<void> _purchaseInternetSubscription() async {
    final phone = _phoneController.text.trim();
    if (phone.length < 10) {
      _showMessage('Please enter a valid phone number');
      return;
    }

    final balance = context.read<WalletProvider>().balance;
    final packageAmount = widget.package.sellingPrice;
    if (packageAmount > balance) {
      _showMessage(
        'Insufficient balance. This package costs ₦${NumberFormat("#,##0.00").format(packageAmount)}',
        isError: true,
      );
      return;
    }

    final transactionPin = await showPinEntrySheet(
      context,
      title: "Enter Transaction PIN",
      subtitle: "Enter your 4-digit transaction PIN to complete this purchase",
    );
    if (transactionPin == null || transactionPin.length < 4) return;

    setState(() => _isLoading = true);
    try {
      await _orderServices.purchaseInternetSubscription(
        authToken: context.read<AuthProvider>().authToken ?? "",
        transactionPin: transactionPin,
        planId: widget.package.id,
        phoneNumber: phone,
        promoCode:
            _promoController.text.trim().isEmpty
                ? null
                : _promoController.text.trim(),
      );

      if (mounted) {
        context.read<WalletProvider>().updateBalance(balance - packageAmount);
      }

      _showMessage('Internet subscription purchased successfully');
      if (mounted) {
        context.go('/orders/history');
      }
    } catch (e) {
      _showMessage(e.toString().split(":").last.trim(), isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Complete Purchase",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).appBarTheme.backgroundColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BalanceSummary(),
                  const SizedBox(height: 24),
                  
                  // Package Info Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        if (Theme.of(context).brightness == Brightness.light)
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Selected Package",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blueAccent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: (widget.package.service.image ?? "").isNotEmpty
                                  ? Image.network(
                                      widget.package.service.image!,
                                      width: 40,
                                      height: 40,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Icon(Icons.router_outlined, size: 40, color: Colors.blueAccent),
                                    )
                                  : const Icon(Icons.router_outlined, size: 40, color: Colors.blueAccent),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.package.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    widget.package.service.serviceName,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              NumberFormat.currency(
                                locale: 'en_NG',
                                symbol: '₦',
                                decimalDigits: 0,
                              ).format(widget.package.sellingPrice),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  Text(
                    "Phone Number",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneController,
                    enabled: !_isLoading,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: _inputDecoration(
                      hintText: "Enter beneficiary phone number",
                      prefixIcon: Icons.phone_android,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  Text(
                    "Promo Code (Optional)",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _promoController,
                    enabled: !_isLoading,
                    decoration: _inputDecoration(
                      hintText: "Enter promo code if any",
                      prefixIcon: Icons.discount_outlined,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _purchaseInternetSubscription,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              "Pay ${NumberFormat.currency(locale: 'en_NG', symbol: '₦').format(widget.package.sellingPrice)}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(prefixIcon, color: Colors.blueAccent),
      filled: true,
      fillColor: Theme.of(context).cardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
      ),
    );
  }
}
