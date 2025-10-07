import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/features/orders/data/models.dart';
import 'package:app/features/orders/data/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

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
  List<AirtimeNetwork> _networks = [];

  _purchaseAirtime() async {
    if (_selectedNetworkId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please select a network')));
      return;
    }
    if (_amountController.text.isEmpty ||
        int.tryParse(_amountController.text) == null ||
        int.parse(_amountController.text) < 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid amount (min ₦100)')),
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
        networkId: _selectedNetworkId!,
        amount: double.parse(_amountController.text),
        phoneNumber: _phoneController.text,
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Airtime purchase successful')));
      if (mounted) context.pop();
    } catch (e) {
      print(e);
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
      print(e);
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
      appBar: AppBar(
        title: Text("Buy Airtime"),
        elevation: 4,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      backgroundColor: Colors.grey[50],
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      floatingActionButton: MaterialButton(
        height: 40,
        minWidth: 200,

        onPressed: _isLoading ? null : _purchaseAirtime,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        color: Colors.blue,
        child:
            _isLoading
                ? CircularProgressIndicator()
                : Text(
                  "Continue",
                  style: TextStyle(fontSize: 19, color: Colors.white),
                ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
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
                        child: ChoiceChip(
                          label: Image.network(
                            network.imageUrl,
                            height: 40,
                            width: 40,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Text(network.name);
                            },
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (_isLoading) return;
                            setState(() {
                              _selectedNetworkId = selected ? network.id : null;
                            });
                          },
                          selectedColor: Colors.blue,
                          backgroundColor: Colors.lightBlue[50],
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
            SizedBox(height: 20),
            Text("Amount (min ₦100)"),
            SizedBox(height: 18),
            TextFormField(
              enabled: !_isLoading,
              controller: _amountController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                prefixText: "₦ ",
                hintText: "100.00",
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            SizedBox(height: 20),
            Text("Quick Select"),
            SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children:
                  [50, 100, 200, 500, 1000].map((amount) {
                    return ActionChip(
                      backgroundColor: Colors.lightBlue,
                      label: Text("₦$amount"),
                      labelPadding: EdgeInsets.symmetric(horizontal: 4.0),
                      labelStyle: TextStyle(color: Colors.white),
                      onPressed: () {
                        if (_isLoading) return;
                        setState(() {
                          _amountController.text = amount.toString();
                        });
                      },
                    );
                  }).toList(),
            ),
            SizedBox(height: 20),
            Text("Phone Number"),
            SizedBox(height: 18),
            TextFormField(
              enabled: !_isLoading,
              controller: _phoneController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "08012345678",
              ),
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ],
        ),
      ),
    );
  }
}
