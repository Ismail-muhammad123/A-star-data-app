import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/features/orders/data/models.dart';
import 'package:app/features/orders/data/services.dart';
import 'package:app/features/orders/views/pages/data/select_bundle_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
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
  List<DataNetwork> _networks = [];
  List<DataBundle> dataPlans = [];

  _purchaseData() async {
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
      await OrderServices().purchaseDataBundle(
        authToken: context.read<AuthProvider>().authToken ?? "",
        bundleId: selectedBundle?.id ?? 0,
        phoneNumber: _phoneController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data purchase successful'),
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

  _fetchNetworks() async {
    try {
      var networks = await OrderServices().fetchDataNetworks(
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
      appBar: AppBar(
        title: Text(
          "Buy Data Plan",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
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
              SizedBox(height: 20),
              Text("Select Network"),
              SizedBox(height: 18),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children:
                      _networks.map((network) {
                        bool isSelected = _selectedNetworkId == network.id;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: GestureDetector(
                            onTap: () {
                              if (_isLoading) return;
                              setState(() {
                                _selectedNetworkId =
                                    _selectedNetworkId = network.id;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.all(6.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  width: isSelected ? 2 : 1,
                                  color:
                                      isSelected
                                          ? Colors.blue
                                          : Colors.lightBlue[100]!,
                                ),
                              ),
                              child: Image.network(
                                network.imageUrl,
                                webHtmlElementStrategy:
                                    WebHtmlElementStrategy.prefer,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) =>
                                        Text(network.serviceName),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
              SizedBox(height: 20),
              Text("Select Data bundle"),
              GestureDetector(
                onTap:
                    _isLoading
                        ? null
                        : () async {
                          // Navigate to bundle selector page and await result
                          if (_selectedNetworkId == null) return;
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
                            selectedBundle != null
                                ? selectedBundle!.name
                                : (_selectedNetworkId == null
                                    ? "Select a network first"
                                    : "Tap to select Data Bundle"),
                            style: TextStyle(
                              color:
                                  selectedBundle != null
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
              Text("Phone Number"),
              SizedBox(height: 18),
              TextFormField(
                enabled: !_isLoading,
                controller: _phoneController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter phone number",
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              SizedBox(height: 50),
              Center(
                child: MaterialButton(
                  height: 40,
                  minWidth: 200,
                  onPressed: _isLoading ? null : _purchaseData,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  color: Colors.blue,
                  child:
                      _isLoading
                          ? CircularProgressIndicator()
                          : Text(
                            "Continue",
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
