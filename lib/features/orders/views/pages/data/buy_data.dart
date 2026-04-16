import 'package:app/core/utils/contact_helper.dart';
import 'package:app/core/utils/error_handler.dart';
import 'package:app/core/utils/network_detector.dart';
import 'package:app/core/widgets/beneficiary_section.dart';
import 'package:app/core/widgets/pin_entry_bottom_sheet.dart';
import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/features/orders/data/models.dart';
import 'package:app/features/orders/data/models/purchase_beneficiary_model.dart';
import 'package:app/features/orders/data/services.dart';
import 'package:app/features/orders/views/pages/data/select_bundle_page.dart';
import 'package:app/core/widgets/balance_summary.dart';
import 'package:app/features/orders/views/widgets/network_card.dart';
import 'package:app/features/wallet/providers/wallet_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DataPurchaseFormPage extends StatefulWidget {
  const DataPurchaseFormPage({super.key});

  @override
  State<DataPurchaseFormPage> createState() => _DataPurchaseFormPageState();
}

class _DataPurchaseFormPageState extends State<DataPurchaseFormPage> {
  final _phoneController = TextEditingController();
  int? _selectedNetworkId;
  DataBundle? selectedBundle;

  bool _isLoading = false;
  bool _saveBeneficiary = false;
  List<DataNetwork> _networks = [];
  List<PurchaseBeneficiary> _beneficiaries = [];
  List<DataBundle> dataPlans = [];

  _purchaseData() async {
    final balance = context.read<WalletProvider>().balance;
    final bundleAmount = selectedBundle?.sellingPrice ?? 0.0;

    if (_selectedNetworkId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please select a network')));
      return;
    }
    if (selectedBundle == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please select a Data Plan')));
      return;
    }

    if (bundleAmount > balance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Insufficient balance. This plan costs ₦${NumberFormat("#,##0.00").format(bundleAmount)}, but your balance is ₦${NumberFormat("#,##0.00").format(balance)}',
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
          "Enter your 4-digit transaction PIN to complete this purchase of ${selectedBundle?.name ?? 'data bundle'}",
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
              serviceType: 'data',
              identifier: _phoneController.text,
              nickname: _phoneController.text,
            ),
          );
        } catch (e) {
          print("Failed to save beneficiary: $e");
        }
      }

      await OrderServices().purchaseDataBundle(
        authToken: context.read<AuthProvider>().authToken ?? "",
        transactionPin: transactionPin,
        bundleId: selectedBundle?.id ?? 0,
        phoneNumber: _phoneController.text,
      );

      // Update balance locally after success
      if (mounted) {
        context.read<WalletProvider>().updateBalance(balance - bundleAmount);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data purchase successful'),
          backgroundColor: Colors.green,
        ),
      );
      if (mounted) context.pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ErrorHandler.getFriendlyMessage(e))),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  _fetchNetworks() async {
    try {
      var networks = await OrderServices().fetchDataNetworks(
        context.read<AuthProvider>().authToken ?? "",
      );
      setState(() {
        _networks = networks;
      });
    } catch (e) {
      print(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ErrorHandler.getFriendlyMessage(e))),
        );
      }
    }

    try {
      final token = context.read<AuthProvider>().authToken;
      if (token != null) {
        final fetched = await OrderServices().getPurchaseBeneficiaries(token);
        if (mounted) {
          setState(() {
            _beneficiaries =
                fetched.where((b) => b.serviceType == 'data').toList();
          });
        }
      }
    } catch (e) {
      // Ignored
    }
  }

  /// Called whenever the phone field changes. Detects the network from the
  /// prefix and auto-selects the matching network card. Also resets the
  /// selected bundle when the network changes via auto-detection.
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
          "Buy Data Plan",
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
                      color: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.color?.withOpacity(0.8),
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
                                    selectedBundle =
                                        null; // reset bundle when network changes
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

                  Text(
                    "Select Data bundle",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap:
                        _isLoading
                            ? null
                            : () async {
                              if (_selectedNetworkId == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please select a network first',
                                    ),
                                  ),
                                );
                                return;
                              }
                              final bundle = await Navigator.push<DataBundle>(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => SelectBundlePage(
                                        networkId: _selectedNetworkId!,
                                      ),
                                ),
                              );
                              if (bundle != null) {
                                setState(() {
                                  selectedBundle = bundle;
                                });
                              }
                            },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color:
                              selectedBundle != null
                                  ? Colors.blueAccent
                                  : Colors.grey.shade300,
                          width: selectedBundle != null ? 2 : 1,
                        ),
                        boxShadow: [
                          if (Theme.of(context).brightness == Brightness.light)
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.language,
                            color:
                                selectedBundle != null
                                    ? Colors.blueAccent
                                    : Colors.grey,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  selectedBundle != null
                                      ? selectedBundle!.name
                                      : "Tap to select Data Bundle",
                                  style: TextStyle(
                                    color:
                                        selectedBundle != null
                                            ? Theme.of(
                                              context,
                                            ).textTheme.bodyLarge?.color
                                            : Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.color
                                                ?.withOpacity(0.6),
                                    fontSize: 14,
                                    fontWeight:
                                        selectedBundle != null
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                  ),
                                ),
                                if (selectedBundle != null)
                                  Text(
                                    "Price: ₦${selectedBundle!.sellingPrice}",
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

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

                  Text(
                    "Phone Number",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.color?.withOpacity(0.8),
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
                        color: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.color?.withOpacity(0.8),
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

                  const SizedBox(height: 48),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _purchaseData,
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
                                "Purchase Data",
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
