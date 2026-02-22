import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/features/orders/data/models.dart';
import 'package:app/features/orders/data/services.dart';
import 'package:app/core/widgets/balance_summary.dart';
import 'package:app/features/wallet/providers/wallet_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class AirtimePurchaseFormPage extends StatefulWidget {
  const AirtimePurchaseFormPage({super.key});

  @override
  State<AirtimePurchaseFormPage> createState() =>
      _AirtimePurchaseFormPageState();
}

class _AirtimePurchaseFormPageState extends State<AirtimePurchaseFormPage> {
  final _amountController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedNetworkId;

  bool _isLoading = false;
  List<AirtimeNetwork> _networks = [];

  _purchaseAirtime() async {
    final balance = context.read<WalletProvider>().balance;
    final enteredAmount = double.tryParse(_amountController.text) ?? 0.0;

    if (_selectedNetworkId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please select a network')));
      return;
    }
    if (_amountController.text.isEmpty ||
        int.tryParse(_amountController.text) == null ||
        int.parse(_amountController.text) < 50) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid amount (min ₦50)')),
      );
      return;
    }

    if (enteredAmount > balance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Insufficient balance. Your balance is ₦${NumberFormat("#,##0.00").format(balance)}',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_phoneController.text.isEmpty || _phoneController.text.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid phone number')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });
    try {
      await OrderServices().purchaseAirtime(
        authToken: context.read<AuthProvider>().authToken ?? "",
        serviceId: _selectedNetworkId!,
        amount: enteredAmount,
        phoneNumber: _phoneController.text,
      );

      // Update balance locally after success
      if (mounted) {
        context.read<WalletProvider>().updateBalance(balance - enteredAmount);
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Airtime purchase successful')));
      if (mounted) context.pop();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString().split(":").last)));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  _fetchNetworks() async {
    try {
      var networks = await OrderServices().fetchAirtimeNetworks(
        context.read<AuthProvider>().authToken ?? "",
      );
      setState(() {
        _networks = networks;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching networks')));
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _fetchNetworks();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Buy Airtime",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header curve
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
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BalanceSummary(),
                  const SizedBox(height: 24),
                  Text(
                    "Select Network",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children:
                          _networks.map((network) {
                            bool isSelected =
                                _selectedNetworkId == network.serviceId;
                            return Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: GestureDetector(
                                onTap: () {
                                  if (_isLoading) return;
                                  setState(() {
                                    _selectedNetworkId = network.serviceId;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color:
                                          isSelected
                                              ? Colors.blueAccent
                                              : Colors.grey.shade300,
                                      width: isSelected ? 3 : 1,
                                    ),
                                    boxShadow: [
                                      if (isSelected)
                                        BoxShadow(
                                          color: Colors.blueAccent.withOpacity(
                                            0.3,
                                          ),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      if (!isSelected &&
                                          Theme.of(context).brightness ==
                                              Brightness.light)
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.04),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      network.imageUrl,
                                      webHtmlElementStrategy:
                                          WebHtmlElementStrategy.prefer,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                                width: 60,
                                                height: 60,
                                                color: Colors.grey[200],
                                                alignment: Alignment.center,
                                                child: Text(
                                                  network.serviceName.substring(
                                                    0,
                                                    3,
                                                  ),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                  const SizedBox(height: 28),

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
                    enabled: !_isLoading,
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      hintText: "Enter phone number",
                      prefixIcon: const Icon(
                        Icons.phone_android,
                        color: Colors.blueAccent,
                      ),
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
                        borderSide: const BorderSide(
                          color: Colors.blueAccent,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  Text(
                    "Amount (min ₦50)",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    enabled: !_isLoading,
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          "₦",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 0,
                        minHeight: 0,
                      ),
                      hintText: "100",
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
                        borderSide: const BorderSide(
                          color: Colors.blueAccent,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children:
                        [50, 100, 200, 500, 1000].map((amount) {
                          return InkWell(
                            onTap: () {
                              if (_isLoading) return;
                              setState(() {
                                _amountController.text = amount.toString();
                              });
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blueAccent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.blueAccent.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                "₦$amount",
                                style: const TextStyle(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 48),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _purchaseAirtime,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child:
                          _isLoading
                              ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text(
                                "Purchase Airtime",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
