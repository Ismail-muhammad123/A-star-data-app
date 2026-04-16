import 'package:app/core/utils/contact_helper.dart';
import 'package:app/core/utils/error_handler.dart';
import 'package:app/core/utils/network_detector.dart';
import 'package:app/core/widgets/beneficiary_section.dart';
import 'package:app/core/widgets/pin_entry_bottom_sheet.dart';
import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/features/orders/data/models.dart';
import 'package:app/features/orders/data/models/purchase_beneficiary_model.dart';
import 'package:app/features/orders/data/services.dart';
import 'package:app/core/widgets/balance_summary.dart';
import 'package:app/features/orders/views/widgets/network_card.dart';
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
  int? _selectedNetworkId;

  bool _isLoading = false;
  bool _saveBeneficiary = false;
  List<AirtimeNetwork> _networks = [];
  List<PurchaseBeneficiary> _beneficiaries = [];

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

    final transactionPin = await showPinEntrySheet(
      context,
      title: "Enter Transaction PIN",
      subtitle:
          "Enter your 4-digit transaction PIN to complete this purchase of ₦${NumberFormat("#,##0.00").format(enteredAmount)} airtime",
    );

    if (transactionPin == null || transactionPin.length < 4) return;

    setState(() {
      _isLoading = true;
    });
    try {
      if (_saveBeneficiary && _phoneController.text.isNotEmpty) {
        try {
          await OrderServices().savePurchaseBeneficiary(
            context.read<AuthProvider>().authToken ?? "",
            PurchaseBeneficiary(
              id: 0,
              serviceType: 'airtime',
              identifier: _phoneController.text,
              nickname: _phoneController.text,
            ),
          );
        } catch (e) {
          print("Failed to save beneficiary: $e");
        }
      }

      await OrderServices().purchaseAirtime(
        authToken: context.read<AuthProvider>().authToken ?? "",
        transactionPin: transactionPin,
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
      ).showSnackBar(SnackBar(content: Text(ErrorHandler.getFriendlyMessage(e))));
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
      print(e);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(ErrorHandler.getFriendlyMessage(e))));
    }

    try {
      final token = context.read<AuthProvider>().authToken;
      if (token != null) {
        final fetched = await OrderServices().getPurchaseBeneficiaries(token);
        if (mounted) {
          setState(() {
            _beneficiaries =
                fetched.where((b) => b.serviceType == 'airtime').toList();
          });
        }
      }
    } catch (e) {
      // Ignored
    }
  }

  /// Called whenever the phone field changes. Detects the network from the
  /// prefix and auto-selects the matching network card.
  void _onPhoneChanged() {
    final phone = _phoneController.text;
    if (phone.length < 4) return;
    final detected = detectNigerianNetwork(phone);
    if (detected == null) return;

    var matches = _networks.where(
      (n) => n.serviceName.toLowerCase().contains(detected),
    );
    if (matches.isEmpty) return;

    var matchedNetwork = matches.first;
    if (matchedNetwork.id != _selectedNetworkId) {
      setState(() {
        _selectedNetworkId = matchedNetwork.id;
      });
    }
  }

  @override
  void dispose() {
    _phoneController.removeListener(_onPhoneChanged);
    _amountController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _phoneController.addListener(_onPhoneChanged);
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
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children:
                          _networks.map((network) {
                            bool isSelected = _selectedNetworkId == network.id;
                            return Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: GestureDetector(
                                onTap: () {
                                  if (_isLoading) return;
                                  setState(() {
                                    _selectedNetworkId = network.id;
                                  });
                                },
                                child: NetworkContainerCard(
                                  isSelected: isSelected,
                                  serviceName: network.serviceName,
                                  imageUrl: network.imageUrl,
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                  const SizedBox(height: 28),

                  if (_beneficiaries.isNotEmpty) ...[
                    BeneficiarySection(
                      initialBeneficiaries:
                          _beneficiaries
                              .map(
                                (b) => BeneficiaryDisplayModel(
                                  id: b.id,
                                  identifier: b.identifier,
                                  name: b.nickname,
                                ),
                              )
                              .toList(),
                      selectedIdentifier: _phoneController.text,
                      type: BeneficiaryType.purchase,
                      onSelect: (ben) {
                        setState(() {
                          _phoneController.text = ben.identifier;
                          _saveBeneficiary = false;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                  ],

                  Text(
                    "Phone Number",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.8),
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
                      suffixIcon:
                          ContactHelper.isMobile
                              ? IconButton(
                                icon: const Icon(
                                  Icons.contacts,
                                  color: Colors.blueAccent,
                                ),
                                onPressed: () async {
                                  final phone =
                                      await ContactHelper.pickPhoneNumber();
                                  if (phone != null) {
                                    setState(() {
                                      _phoneController.text = phone;
                                    });
                                  }
                                },
                              )
                              : null,
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
                    onChanged: (val) => setState(() {}),
                  ),

                  BeneficiarySuggestions(
                    beneficiaries:
                        _beneficiaries
                            .map(
                              (b) => BeneficiaryDisplayModel(
                                id: b.id,
                                identifier: b.identifier,
                                name: b.nickname,
                              ),
                            )
                            .toList(),
                    query: _phoneController.text,
                    onSelect: (ben) {
                      setState(() {
                        _phoneController.text = ben.identifier;
                      });
                    },
                  ),

                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: Text(
                      "Save this number as a beneficiary",
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                      ),
                    ),
                    value: _saveBeneficiary,
                    onChanged: (val) {
                      setState(() {
                        _saveBeneficiary = val ?? false;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),

                  const SizedBox(height: 28),

                  Text(
                    "Amount (min ₦50)",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    enabled: !_isLoading,
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
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
