import 'package:app/core/widgets/pin_entry_bottom_sheet.dart';
import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/features/orders/data/models.dart';
import 'package:app/features/orders/data/services.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PurchaseEducationFormPage extends StatefulWidget {
  final EducationService service;
  final EducationPackage package;

  const PurchaseEducationFormPage({
    super.key,
    required this.service,
    required this.package,
  });

  @override
  State<PurchaseEducationFormPage> createState() =>
      _PurchaseEducationFormPageState();
}

class _PurchaseEducationFormPageState extends State<PurchaseEducationFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  bool _isVerified = false;
  Map<String, dynamic> _beneficiaryDetails = {};

  Future<void> _verifyBeneficiary() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      final response = await OrderServices().verifyCustomer(
        authToken: context.read<AuthProvider>().authToken ?? "",
        serviceId: widget.service.serviceId,
        customerId: _phoneController.text.trim(),
        purchaseType: 'education',
      );
      
      setState(() {
        _isVerified = true;
        _beneficiaryDetails = {'Account Name': response['account_name'] ?? 'Verified'};
        if (response['raw_response'] != null && response['raw_response'] is Map) {
          _beneficiaryDetails.addAll(response['raw_response'] as Map<String, dynamic>);
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().split(":").last.trim()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Purchase Education PIN",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryHeader(),
              const SizedBox(height: 30),
              Text(
                "Phone Number",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                onChanged: (v) => setState(() => _isVerified = false),
                decoration: InputDecoration(
                  hintText: "Enter ID/Phone",
                  prefixIcon: const Icon(Icons.phone_android),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a phone number";
                  }
                  return null;
                },
              ),
              if (_isVerified) ...[
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blueAccent.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Beneficiary Details", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                      const SizedBox(height: 8),
                      ..._beneficiaryDetails.entries.map((e) => Text("${e.key}: ${e.value}")),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : (_isVerified ? _handlePurchase : _verifyBeneficiary),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isVerified ? Colors.blueAccent : Colors.grey[200],
                    foregroundColor: _isVerified ? Colors.white : Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: _isVerified ? BorderSide.none : const BorderSide(color: Colors.blueAccent),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _isVerified 
                            ? "Pay ${NumberFormat.currency(symbol: '₦', decimalDigits: 0).format(widget.package.sellingPrice)}"
                            : "Verify Beneficiary",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05), blurRadius: 5),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: (widget.service.imageUrl ?? "").isNotEmpty
                ? Image.network(
                    widget.service.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.primaries[widget.service.serviceName.length %
                          Colors.primaries.length],
                      alignment: Alignment.center,
                      child: Text(
                        widget.service.serviceName.length >= 2
                            ? widget.service.serviceName
                                .substring(0, 2)
                                .toUpperCase()
                            : widget.service.serviceName.toUpperCase(),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  )
                : Container(
                    color: Colors.primaries[widget.service.serviceName.length %
                        Colors.primaries.length],
                    alignment: Alignment.center,
                    child: Text(
                      widget.service.serviceName.length >= 2
                          ? widget.service.serviceName
                              .substring(0, 2)
                              .toUpperCase()
                          : widget.service.serviceName.toUpperCase(),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.package.name,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.service.serviceName,
                  style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handlePurchase() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isVerified) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please verify beneficiary first")));
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
      final authProvider = context.read<AuthProvider>();
      final result = await OrderServices().purchaseEducation(
        authToken: authProvider.authToken ?? "",
        transactionPin: transactionPin,
        serviceId: widget.service.serviceId,
        variationId: widget.package.variationId,
        phoneNumber: _phoneController.text,
      );

      if (mounted) {
        _showSuccessDialog(result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString().split(":").last.trim()),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog(OrderHistory order) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Column(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 60),
            SizedBox(height: 10),
            Text("Purchase Successful"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                "Successfully purchased ${widget.package.name} for ${widget.service.serviceName}"),
            if (order.token != null) ...[
              const SizedBox(height: 20),
              const Text("Your PIN:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SelectableText(
                  order.token!,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go("/home");
            },
            child: const Text("Done"),
          ),
        ],
      ),
    );
  }
}
