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
  const InternetPurchasePage({super.key, this.preferredNetworkName});

  final String? preferredNetworkName;

  @override
  State<InternetPurchasePage> createState() => _InternetPurchasePageState();
}

class _InternetPurchasePageState extends State<InternetPurchasePage> {
  final _phoneController = TextEditingController();
  final _promoController = TextEditingController();

  final OrderServices _orderServices = OrderServices();

  bool _isLoading = false;
  bool _isLoadingNetworks = false;
  bool _isLoadingPackages = false;
  bool _shortcutNetworkMissing = false;
  String? _networkError;
  String? _packageError;

  List<InternetService> _services = [];
  List<InternetPackage> _packages = [];
  InternetService? _selectedService;
  InternetPackage? _selectedPackage;

  @override
  void initState() {
    super.initState();
    _fetchInternetServices();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _promoController.dispose();
    super.dispose();
  }

  Future<void> _fetchInternetServices() async {
    setState(() {
      _isLoadingNetworks = true;
      _networkError = null;
      _shortcutNetworkMissing = false;
    });

    try {
      final authToken = context.read<AuthProvider>().authToken ?? "";
      final allServices = await _orderServices.fetchInternetServices(authToken);
      final activeServices = allServices.where((service) => service.isActive).toList();

      if (!mounted) return;

      InternetService? selected;
      final preferred = widget.preferredNetworkName?.trim();
      if (preferred != null && preferred.isNotEmpty) {
        for (final service in activeServices) {
          if (_matchesPreferredNetwork(service, preferred)) {
            selected = service;
            break;
          }
        }
      }

      setState(() {
        _services = activeServices;
        _selectedService = selected;
        _shortcutNetworkMissing =
            preferred != null && preferred.isNotEmpty && selected == null;
      });

      if (_selectedService != null) {
        await _fetchPackagesForService(_selectedService!.id);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _networkError = e.toString().split(":").last.trim();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingNetworks = false;
        });
      }
    }
  }

  bool _matchesPreferredNetwork(InternetService service, String preferred) {
    final needle = preferred.toLowerCase().trim();
    final serviceName = service.serviceName.toLowerCase();
    final serviceId = service.serviceId.toLowerCase();
    return serviceName.contains(needle) || serviceId.contains(needle);
  }

  Future<void> _fetchPackagesForService(int serviceId) async {
    setState(() {
      _isLoadingPackages = true;
      _packageError = null;
      _packages = [];
      _selectedPackage = null;
    });

    try {
      final authToken = context.read<AuthProvider>().authToken ?? "";
      final packages = await _orderServices.fetchInternetPackages(
        authToken,
        serviceId,
      );
      if (!mounted) return;
      setState(() {
        _packages = packages.where((package) => package.isActive).toList();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _packageError = e.toString().split(":").last.trim();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingPackages = false;
        });
      }
    }
  }

  Future<void> _purchaseInternetSubscription() async {
    final selectedPackage = _selectedPackage;
    if (selectedPackage == null) {
      _showMessage('Please select an internet package');
      return;
    }

    final phone = _phoneController.text.trim();
    if (phone.length < 10) {
      _showMessage('Please enter a valid phone number');
      return;
    }

    final balance = context.read<WalletProvider>().balance;
    final packageAmount = selectedPackage.sellingPrice;
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
        planId: selectedPackage.id,
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
        context.pop();
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
    final preferredName = widget.preferredNetworkName;
    final selectedLabel = _selectedService?.serviceName ?? "Tap to select network";
    final packageLabel = _selectedPackage?.name ?? "Tap to select internet package";

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Buy Internet Subscription",
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BalanceSummary(),
                  const SizedBox(height: 24),

                  if (_isLoadingNetworks)
                    const Center(child: CircularProgressIndicator())
                  else if (_networkError != null)
                    _buildErrorState(
                      message: _networkError!,
                      onRetry: _fetchInternetServices,
                    )
                  else if (_services.isEmpty || _shortcutNetworkMissing)
                    _buildNoNetworkState(preferredName)
                  else ...[
                    Text(
                      "Select Network",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSelectorTile(
                      icon: Icons.router_outlined,
                      text: selectedLabel,
                      onTap: _isLoading ? null : _pickNetwork,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Select Package",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSelectorTile(
                      icon: Icons.wifi,
                      text:
                          _isLoadingPackages
                              ? "Loading packages..."
                              : packageLabel,
                      onTap:
                          _isLoading || _isLoadingPackages || _selectedService == null
                              ? null
                              : _pickPackage,
                    ),
                    if (_packageError != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        _packageError!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                    if (!_isLoadingPackages &&
                        _selectedService != null &&
                        _packages.isEmpty &&
                        _packageError == null) ...[
                      const SizedBox(height: 10),
                      const Text(
                        "No available packages found for this network.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                    const SizedBox(height: 20),
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
                      textCapitalization: TextCapitalization.characters,
                      decoration: _inputDecoration(
                        hintText: "Enter promo code",
                        prefixIcon: Icons.local_offer_outlined,
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            _isLoading ||
                                    _selectedService == null ||
                                    _selectedPackage == null
                                ? null
                                : _purchaseInternetSubscription,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                        ),
                        child:
                            _isLoading
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : Text(
                                  _selectedPackage == null
                                      ? "Select Package to Continue"
                                      : "Buy for ${NumberFormat.currency(locale: 'en_NG', symbol: '₦').format(_selectedPackage!.sellingPrice)}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickNetwork() async {
    final selected = await showModalBottomSheet<InternetService>(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Select Internet Network",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _services.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final service = _services[index];
                      return ListTile(
                        title: Text(service.serviceName),
                        subtitle:
                            service.providerName == null
                                ? null
                                : Text(service.providerName!),
                        onTap: () => Navigator.pop(context, service),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected == null || !mounted) return;
    setState(() {
      _selectedService = selected;
      _selectedPackage = null;
    });
    await _fetchPackagesForService(selected.id);
  }

  Future<void> _pickPackage() async {
    if (_packages.isEmpty) return;

    final selected = await showModalBottomSheet<InternetPackage>(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Select Internet Package",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _packages.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final package = _packages[index];
                      return ListTile(
                        title: Text(package.name),
                        subtitle:
                            package.planType == null
                                ? null
                                : Text(package.planType!.toUpperCase()),
                        trailing: Text(
                          NumberFormat.currency(
                            locale: 'en_NG',
                            symbol: '₦',
                          ).format(package.sellingPrice),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onTap: () => Navigator.pop(context, package),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected == null || !mounted) return;
    setState(() => _selectedPackage = selected);
  }

  Widget _buildErrorState({
    required String message,
    required VoidCallback onRetry,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Unable to load internet services",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(color: Colors.red.shade700),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  Widget _buildNoNetworkState(String? preferredName) {
    final missingName = preferredName?.trim();
    final message =
        (missingName != null && missingName.isNotEmpty)
            ? "No available networks found for $missingName right now."
            : "No available networks found.";
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "No available networks found",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
          ),
          const SizedBox(height: 8),
          Text(message),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _fetchInternetServices,
            child: const Text("Refresh"),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectorTile({
    required IconData icon,
    required String text,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blueAccent),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.grey),
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
