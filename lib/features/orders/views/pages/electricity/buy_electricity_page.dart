import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/features/orders/data/models.dart';
import 'package:app/features/orders/data/services.dart';
import 'package:app/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class PurchaseElectricityFormPage extends StatefulWidget {
  final ElectricityService service;
  const PurchaseElectricityFormPage({super.key, required this.service});

  @override
  State<PurchaseElectricityFormPage> createState() =>
      _PurchaseElectricityFormPageState();
}

class _PurchaseElectricityFormPageState
    extends State<PurchaseElectricityFormPage> {
  TextEditingController _meterNumberController = TextEditingController();
  TextEditingController _amountController = TextEditingController();

  String? _meterType;
  bool _isLoading = false;

  bool _isVerified = false;
  int minimumAmount = 0;
  int maximumAmount = 100000;

  Map<String, dynamic> meterDetails = {};

  _verifyMeter() async {
    if (_meterNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid meter number')),
      );
      return;
    }

    if (_meterType == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please select a meter type')));
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });
      var meterInfo = await OrderServices().verifyCustomer(
        authToken: context.read<AuthProvider>().authToken ?? "",
        serviceId: widget.service.serviceId,
        customerId: _meterNumberController.text,
        variationId: _meterType!,
      );
      setState(() {
        minimumAmount = meterInfo['minimum_amount'] ?? 500;
        maximumAmount = meterInfo['maximum_amount'] ?? 100000;

        meterDetails = meterInfo;
        _isVerified = true;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString().split(":").last)));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  _purchase() async {
    if (!_isVerified) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please verify the meter first')));
      return;
    }

    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please enter a valid amount')));
      return;
    }

    int amount = int.parse(_amountController.text);
    if (amount < minimumAmount || amount > maximumAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Amount must be between $minimumAmount and $maximumAmount',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await OrderServices().purchaseElectricity(
        authToken: context.read<AuthProvider>().authToken ?? "",
        serviceId: widget.service.serviceId,
        variationId: _meterType!,
        customerId: _meterNumberController.text,
        amount: amount,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Electricity purchase successful'),
          backgroundColor: Colors.green,
        ),
      );
      if (mounted) context.pop();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString().split(":").last)));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _meterNumberController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buy Electricity'),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.blueAccent,
        surfaceTintColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Purchase Electricity from:"),
                      Divider(),
                      Row(
                        children: [
                          ((widget.service.imageUrl ?? "").isNotEmpty)
                              ? Image.network(
                                widget.service.imageUrl!,
                                width: 50,
                                height: 50,
                                errorBuilder:
                                    (context, error, stackTrace) => Icon(
                                      Icons.electrical_services,
                                      size: 50,
                                    ),
                              )
                              : Icon(Icons.electrical_services, size: 50),
                          SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              widget.service.serviceName,
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text("Meter type"),
              DropdownButtonFormField(
                items: [
                  DropdownMenuItem(value: "prepaid", child: Text("Prepaid")),
                  DropdownMenuItem(value: "postpaid", child: Text("Postpaid")),
                ],
                onChanged: (value) {
                  setState(() {
                    _meterType = value;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Select Meter Type',
                ),
              ),
              SizedBox(height: 20),
              Text("Enter Meter Number"),
              SizedBox(height: 8),
              TextFormField(
                controller: _meterNumberController,
                enabled: !_isLoading,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _isVerified = false;
                  });
                },
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Meter Number',
                ),
              ),
              SizedBox(height: 20),
              if (_isVerified) Text("Enter Amount"),
              if (_isVerified)
                TextFormField(
                  controller: _amountController,
                  enabled: !_isLoading && _isVerified,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Amount',
                  ),
                  keyboardType: TextInputType.number,
                ),

              SizedBox(height: 8),
              _isVerified
                  ? Card(
                    color: Colors.white,
                    child: SizedBox(
                      width: double.maxFinite,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Meter Details:",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Divider(),
                            // SizedBox(height: 8),
                            ...meterDetails.entries.map(
                              (entry) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 155,
                                      child: Text(
                                        "${entry.key.split("_").map((s) => s.capitalize()).join(" ")}: ",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Flexible(child: Text("${entry.value}")),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _isLoading ? null : _verifyMeter,
                        child: Text("Verify Meter"),
                      ),
                    ],
                  ),
              SizedBox(height: 30),
              if (_isVerified)
                Center(
                  child: MaterialButton(
                    onPressed: _isLoading ? null : _purchase,
                    color: Colors.blueAccent,
                    textColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                        _isLoading
                            ? CircularProgressIndicator()
                            : Text("Purchase Electricity"),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
