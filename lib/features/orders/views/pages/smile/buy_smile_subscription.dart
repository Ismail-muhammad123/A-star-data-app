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
      appBar: AppBar(
        title: Text("Buy Smile", style: TextStyle(color: Colors.white)),
        elevation: 4,
        backgroundColor: Colors.lightBlue,
        surfaceTintColor: Colors.lightBlue,
      ),
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset("assets/images/hq720.jpg"),
                ),
              ),
              SizedBox(height: 20),
              Text("Select Package Type"),
              SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'data', label: Text('Smile Data')),
                    ButtonSegment(
                      value: 'smilevoice',
                      label: Text('Smile Voice'),
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
                ),
              ),
              SizedBox(height: 20),
              Text("Select Smile Plan"),
              GestureDetector(
                onTap:
                    _isLoading
                        ? null
                        : () async {
                          SmilePackage? bundle = await showDialog(
                            context: context,
                            builder:
                                (context) => Dialog(
                                  backgroundColor: Colors.white,
                                  insetPadding: EdgeInsets.all(14.0),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 6.0,
                                          ),
                                          child: Row(
                                            children: [
                                              IconButton(
                                                onPressed:
                                                    () =>
                                                        Navigator.of(
                                                          context,
                                                        ).pop(),
                                                icon: Icon(Icons.close),
                                              ),
                                              Text(
                                                'Pick Smile Plan',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Divider(),
                                        Expanded(
                                          child: FutureBuilder<
                                            List<SmilePackage>
                                          >(
                                            future: OrderServices()
                                                .fetchSmilePackages(
                                                  context
                                                          .read<AuthProvider>()
                                                          .authToken ??
                                                      "",
                                                ),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                );
                                              }
                                              if (snapshot.hasError) {
                                                return Center(
                                                  child: Text(
                                                    'Error loading bundles',
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
                                                          .contains("voice"),
                                                );
                                              }
                                              bundles.sort(
                                                (a, b) => a.sellingPrice
                                                    .compareTo(b.sellingPrice),
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
                                                        color: Colors.grey[600],
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }
                                              return ListView.builder(
                                                itemCount: bundles.length,
                                                itemBuilder: (context, index) {
                                                  final bundle = bundles[index];
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 2.0,
                                                        ),
                                                    child: Card(
                                                      color: Colors.white,
                                                      child: ListTile(
                                                        title: Text(
                                                          bundle.name,
                                                        ),
                                                        trailing: Text(
                                                          "₦${bundle.sellingPrice}",
                                                        ),
                                                        onTap: () {
                                                          setState(() {
                                                            _selectedSmileVoicePlan =
                                                                bundle;
                                                            _isVerified = false;
                                                            _customerName =
                                                                null;
                                                          });
                                                          Navigator.pop(
                                                            context,
                                                            bundle,
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
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
                child: AbsorbPointer(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.white,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedSmileVoicePlan != null
                                ? _selectedSmileVoicePlan!.name
                                : ("Tap to select Smile Plan"),
                            style: TextStyle(
                              color:
                                  _selectedSmileVoicePlan != null
                                      ? Colors.black
                                      : Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Icon(Icons.arrow_drop_down, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text("Amount"),
              SizedBox(height: 18),
              TextFormField(
                enabled: false,
                controller: TextEditingController(
                  text:
                      _selectedSmileVoicePlan != null
                          ? "₦${NumberFormat('###,###,###').format(_selectedSmileVoicePlan!.sellingPrice)}"
                          : "",
                ),
                decoration: InputDecoration(border: OutlineInputBorder()),
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              SizedBox(height: 20),
              Text("Phone Number"),
              SizedBox(height: 18),
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
                  if (value.length >= 10 && _selectedSmileVoicePlan != null) {
                    _verifyNumber();
                  }
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter phone number",
                  suffixIcon:
                      _isLoading
                          ? Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                          : IconButton(
                            onPressed: _verifyNumber,
                            icon: Icon(Icons.verified, color: Colors.blue),
                          ),
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              if (_isVerified && _customerName != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    "Customer Name: $_customerName",
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              SizedBox(height: 50),
              Center(
                child: MaterialButton(
                  height: 40,
                  minWidth: 200,
                  onPressed: _isLoading ? null : _purchasePlan,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  color: Colors.blue,
                  child:
                      _isLoading
                          ? CircularProgressIndicator()
                          : Text(
                            "Purchase",
                            style: TextStyle(fontSize: 19, color: Colors.white),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
