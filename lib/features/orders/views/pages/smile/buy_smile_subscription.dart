import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/features/orders/data/models.dart';
import 'package:app/features/orders/data/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SmileVoicePurchasePage extends StatefulWidget {
  const SmileVoicePurchasePage({super.key});

  @override
  State<SmileVoicePurchasePage> createState() => _SmileVoicePurchasePageState();
}

class _SmileVoicePurchasePageState extends State<SmileVoicePurchasePage> {
  final _phoneController = TextEditingController();

  bool _isLoading = false;
  SmilePackage? _selectedSmileVoicePlan;
  String _packageType = 'data'; // 'data' or 'smilevoice'
  bool _isVerified = false;
  String? _customerName;

  _verifyNumber() async {
    if (_phoneController.text.trim().isEmpty ||
        _phoneController.text.trim().length < 10) {
      return;
    }
    if (_selectedSmileVoicePlan == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await OrderServices().verifyCustomer(
        authToken: context.read<AuthProvider>().authToken ?? "",
        serviceId: "smile-direct",
        variationId: _selectedSmileVoicePlan!.variationId,
        customerId: _phoneController.text.trim(),
      );
      setState(() {
        _isVerified = true;
        _customerName = result['Customer_Name'] ?? result['name'] ?? "Unknown";
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification failed: ${e.toString().split(":").last}'),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  _purchasePlan() async {
    if (_selectedSmileVoicePlan == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please select a Smile Plan')));
      return;
    }

    if (_phoneController.text.trim().isEmpty ||
        _phoneController.text.trim().length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid phone number')),
      );
      return;
    }

    if (!_isVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please verify the phone number first')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });
    try {
      await OrderServices().purchaseSmileSubscription(
        authToken: context.read<AuthProvider>().authToken ?? "",
        bundleId: _selectedSmileVoicePlan?.id ?? 0,
        phoneNumber: _phoneController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Smile Plan purchase was successful'),
          backgroundColor: Colors.green,
        ),
      );
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

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Buy Smile Subscription",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
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
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Smile Banner
                  Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      image: const DecorationImage(
                        image: AssetImage("assets/images/hq720.jpg"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    "Select Package Type",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'data',
                          label: Text(
                            'Smile Data',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        ButtonSegment(
                          value: 'smilevoice',
                          label: Text(
                            'Smile Voice',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                      selected: {_packageType},
                      onSelectionChanged: (Set<String> newSelection) {
                        setState(() {
                          _packageType = newSelection.first;
                          _selectedSmileVoicePlan = null;
                          _isVerified = false;
                          _customerName = null;
                        });
                      },
                      style: SegmentedButton.styleFrom(
                        backgroundColor: Theme.of(context).cardColor,
                        selectedBackgroundColor: Colors.blueAccent.withOpacity(
                          0.1,
                        ),
                        selectedForegroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    "Select Smile Plan",
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
                              SmilePackage? bundle = await showDialog(
                                context: context,
                                builder:
                                    (context) => Dialog(
                                      backgroundColor:
                                          Theme.of(context).cardColor,
                                      insetPadding: const EdgeInsets.all(14.0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text(
                                                  'Pick Smile Plan',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                IconButton(
                                                  onPressed:
                                                      () =>
                                                          Navigator.of(
                                                            context,
                                                          ).pop(),
                                                  icon: const Icon(
                                                    Icons.close,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const Divider(),
                                            Flexible(
                                              child: ConstrainedBox(
                                                constraints: BoxConstraints(
                                                  maxHeight:
                                                      MediaQuery.of(
                                                        context,
                                                      ).size.height *
                                                      0.6,
                                                ),
                                                child: FutureBuilder<
                                                  List<SmilePackage>
                                                >(
                                                  future: OrderServices()
                                                      .fetchSmilePackages(
                                                        context
                                                                .read<
                                                                  AuthProvider
                                                                >()
                                                                .authToken ??
                                                            "",
                                                      ),
                                                  builder: (context, snapshot) {
                                                    if (snapshot
                                                            .connectionState ==
                                                        ConnectionState
                                                            .waiting) {
                                                      return const Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                              color:
                                                                  Colors
                                                                      .blueAccent,
                                                            ),
                                                      );
                                                    }
                                                    if (snapshot.hasError) {
                                                      return const Center(
                                                        child: Text(
                                                          'Error loading bundles',
                                                          style: TextStyle(
                                                            color:
                                                                Colors
                                                                    .redAccent,
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                    final bundles =
                                                        snapshot.data ?? [];
                                                    if (_packageType ==
                                                        'smilevoice') {
                                                      bundles.retainWhere(
                                                        (b) => b.name
                                                            .toLowerCase()
                                                            .contains("voice"),
                                                      );
                                                    } else {
                                                      bundles.retainWhere(
                                                        (b) =>
                                                            !b.name
                                                                .toLowerCase()
                                                                .contains(
                                                                  "voice",
                                                                ),
                                                      );
                                                    }
                                                    bundles.sort(
                                                      (a, b) => a.sellingPrice
                                                          .compareTo(
                                                            b.sellingPrice,
                                                          ),
                                                    );
                                                    if (bundles.isEmpty) {
                                                      return Center(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets.all(
                                                                20.0,
                                                              ),
                                                          child: Text(
                                                            'No packages found for this type',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors
                                                                      .grey[600],
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                    return ListView.builder(
                                                      shrinkWrap: true,
                                                      itemCount: bundles.length,
                                                      itemBuilder: (
                                                        context,
                                                        index,
                                                      ) {
                                                        final bundle =
                                                            bundles[index];
                                                        return Card(
                                                          color:
                                                              Theme.of(
                                                                context,
                                                              ).cardColor,
                                                          elevation: 0,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  12,
                                                                ),
                                                            side: BorderSide(
                                                              color:
                                                                  Colors
                                                                      .grey
                                                                      .shade200,
                                                            ),
                                                          ),
                                                          margin:
                                                              const EdgeInsets.symmetric(
                                                                vertical: 4,
                                                              ),
                                                          child: ListTile(
                                                            title: Text(
                                                              bundle.name,
                                                              style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                            trailing: Text(
                                                              "₦${bundle.sellingPrice}",
                                                              style: const TextStyle(
                                                                color:
                                                                    Colors
                                                                        .blueAccent,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            onTap: () {
                                                              Navigator.pop(
                                                                context,
                                                                bundle,
                                                              );
                                                            },
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                              );
                              if (bundle != null) {
                                setState(() {
                                  _selectedSmileVoicePlan = bundle;
                                  _isVerified = false;
                                  _customerName = null;
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
                              _selectedSmileVoicePlan != null
                                  ? Colors.blueAccent
                                  : Colors.grey.shade300,
                          width: _selectedSmileVoicePlan != null ? 2 : 1,
                        ),
                        boxShadow: [
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
                            Icons.wifi,
                            color:
                                _selectedSmileVoicePlan != null
                                    ? Colors.blueAccent
                                    : Colors.grey,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _selectedSmileVoicePlan != null
                                  ? _selectedSmileVoicePlan!.name
                                  : "Tap to select Smile Plan",
                              style: TextStyle(
                                color:
                                    _selectedSmileVoicePlan != null
                                        ? Theme.of(
                                          context,
                                        ).textTheme.bodyLarge?.color
                                        : Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color
                                            ?.withOpacity(0.6),
                                fontSize: 16,
                                fontWeight:
                                    _selectedSmileVoicePlan != null
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    "Amount",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    enabled: false,
                    controller: TextEditingController(
                      text:
                          _selectedSmileVoicePlan != null
                              ? " ${NumberFormat('###,###,###').format(_selectedSmileVoicePlan!.sellingPrice)}"
                              : "",
                    ),
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
                      hintText: "Amount e.g 1000",
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
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
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
                    enabled: !_isLoading,
                    controller: _phoneController,
                    onChanged: (value) {
                      if (_isVerified) {
                        setState(() {
                          _isVerified = false;
                          _customerName = null;
                        });
                      }
                      if (value.length >= 10 &&
                          _selectedSmileVoicePlan != null) {
                        _verifyNumber();
                      }
                    },
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
                      suffixIcon:
                          _isLoading
                              ? const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              )
                              : _isVerified
                              ? const Icon(Icons.verified, color: Colors.green)
                              : IconButton(
                                onPressed: _verifyNumber,
                                icon: const Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.grey,
                                ),
                              ),
                    ),
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),

                  if (_isVerified && _customerName != null)
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.person, color: Colors.green),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Customer: $_customerName",
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 48),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _purchasePlan,
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
                                "Purchase",
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
