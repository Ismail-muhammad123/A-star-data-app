import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/features/orders/data/models.dart';
import 'package:app/features/orders/data/services.dart';
import 'package:app/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class PurchaseTVSubscriptionFormPage extends StatefulWidget {
  final CableTVService service;
  final CableTVPackage package;
  const PurchaseTVSubscriptionFormPage({
    super.key,
    required this.service,
    required this.package,
  });

  @override
  State<PurchaseTVSubscriptionFormPage> createState() =>
      _PurchaseTVSubscriptionFormPageState();
}

class _PurchaseTVSubscriptionFormPageState
    extends State<PurchaseTVSubscriptionFormPage> {
  TextEditingController _smartCardNumberController = TextEditingController();
  TextEditingController _amountController = TextEditingController();

  bool _isLoading = false;

  bool _isVerified = false;
  int minimumAmount = 0;
  int maximumAmount = 100000;

  String? _subscriptionType;

  Map<String, dynamic> smartCardDetails = {};

  _verifySmartCard() async {
    if (_smartCardNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid smart card number')),
      );
      return;
    }

    if (_subscriptionType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a subscription type')),
      );
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });
      var meterInfo = await OrderServices().verifyCustomer(
        authToken: context.read<AuthProvider>().authToken ?? "",
        serviceId: widget.service.serviceId,
        customerId: _smartCardNumberController.text,
        variationId: _subscriptionType!,
      );

      print(meterInfo);
      setState(() {
        minimumAmount = meterInfo['minimum_amount'] ?? 500;
        maximumAmount = meterInfo['maximum_amount'] ?? 100000;

        smartCardDetails = meterInfo;
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please verify the smart card first')),
      );
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
      await OrderServices().purchaseTVSubscription(
        authToken: context.read<AuthProvider>().authToken ?? "",
        serviceId: widget.service.serviceId,
        variationId: _subscriptionType!,
        customerId: _smartCardNumberController.text,
        subscriptionType: _subscriptionType!,
        amount: amount,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cable TV subscription purchase successful'),
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
  void initState() {
    _amountController.text = widget.package.sellingPrice.toString();
    super.initState();
  }

  @override
  void dispose() {
    _smartCardNumberController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buy Cable TV Subscription'),
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
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Purchase Cable TV Subscription from:"),
                      ),
                      Divider(),
                      ListTile(
                        leading:
                            ((widget.service.imageUrl ?? "").isNotEmpty)
                                ? Image.network(
                                  widget.service.imageUrl!,
                                  width: 30,
                                  height: 30,
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                          Icon(Icons.tv, size: 30),
                                )
                                : Icon(Icons.tv, size: 30),
                        title: Text(widget.service.serviceName),
                        subtitle: Text("Package: ${widget.package.name}"),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text("Subscription type"),
              DropdownButtonFormField(
                items: [
                  DropdownMenuItem(
                    value: "renew",
                    child: Text("Renew Subscription"),
                  ),
                  DropdownMenuItem(
                    value: "change",
                    child: Text("Change Subscription"),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _subscriptionType = value;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Select Subscription Type',
                ),
              ),
              SizedBox(height: 20),
              Text("Enter Smart Card Number"),
              SizedBox(height: 8),
              TextFormField(
                controller: _smartCardNumberController,
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
                  hintText: 'Smart Card Number',
                ),
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
                              "Smart Card Details (verified):",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Divider(),
                            SizedBox(height: 4),
                            ...smartCardDetails.entries.map(
                              (entry) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4.0,
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
                        onPressed: _isLoading ? null : _verifySmartCard,
                        child:
                            _isLoading
                                ? CircularProgressIndicator()
                                : Text("Verify Smart Card"),
                      ),
                    ],
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
                            : Text("Purchase Subscription"),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
