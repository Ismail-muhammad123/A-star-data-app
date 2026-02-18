import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/features/settings/data/models/bank_info_model.dart';
import 'package:app/features/settings/data/repositories/profile_repo.dart';
import 'package:app/features/settings/views/pages/bank_information/bank_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class BankInfoFormPage extends StatefulWidget {
  const BankInfoFormPage({super.key});

  @override
  State<BankInfoFormPage> createState() => _BankInfoFormPageState();
}

class _BankInfoFormPageState extends State<BankInfoFormPage> {
  bool _editing = false;
  bool _loading = false;
  BankInformationModel? currentBankInfo;

  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _accountNameController = TextEditingController();
  final TextEditingController _accountNumberController =
      TextEditingController();

  _createBankInfo(BankInformationModel data) async {
    setState(() {
      _editing = false;
      _loading = true;
    });

    try {
      await ProfileService().addBankInformation(
        context.read<AuthProvider>().authToken ?? "",
        data,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Bank information saved successfully")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error saving bank info: $e")));
      }
    }

    setState(() {
      _loading = false;
    });
    _loadCurrentBankInfo();
  }

  _updateBankInfo(BankInformationModel data) async {
    setState(() {
      _editing = false;
      _loading = true;
    });

    try {
      await ProfileService().updateBankInformation(
        context.read<AuthProvider>().authToken ?? "",
        data,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Bank information updated successfully"),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error updating bank info: $e")));
      }
    }

    setState(() {
      _loading = false;
    });
    _loadCurrentBankInfo();
  }

  _loadCurrentBankInfo() async {
    setState(() {
      _loading = true;
    });

    try {
      var info = await ProfileService().retriveBankInformation(
        context.read<AuthProvider>().authToken ?? "",
      );
      setState(() {
        if (info != null) {
          currentBankInfo = info;
          _bankNameController.text = info.bankName;
          _accountNameController.text = info.accountName;
          _accountNumberController.text = info.accountNumber;
        }
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentBankInfo();
    });
    super.initState();
  }

  @override
  void dispose() {
    _bankNameController.dispose();
    _accountNameController.dispose();
    _accountNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: BackButton(
          color: Colors.white,
          onPressed:
              () => context.canPop() ? context.pop() : context.go('/profile'),
        ),
        title: const Text(
          'Bank Information',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        backgroundColor: Colors.blueAccent,
        surfaceTintColor: Colors.blueAccent,
        actions: [
          if (currentBankInfo != null)
            TextButton(
              onPressed: () => setState(() => _editing = !_editing),
              child: Text(
                _editing ? "Cancel" : "Edit",
                style: TextStyle(
                  color: _editing ? Colors.white70 : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),

      body:
          _loading && currentBankInfo == null
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Payout Details",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Provide your bank details for withdrawals and refunds.",
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _bankNameController,
                      enabled: _editing || currentBankInfo == null,
                      onTap:
                          (_editing || currentBankInfo == null)
                              ? () async {
                                final selectedBank = await Navigator.of(
                                  context,
                                ).push<String>(
                                  MaterialPageRoute(
                                    builder: (context) => const BankPicker(),
                                  ),
                                );
                                if (selectedBank != null &&
                                    selectedBank.isNotEmpty) {
                                  setState(() {
                                    _bankNameController.text = selectedBank;
                                  });
                                }
                              }
                              : null,
                      decoration: InputDecoration(
                        labelText: 'Bank Name',
                        hintText: 'Select your bank',
                        prefixIcon: const Icon(Icons.account_balance),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      readOnly: true,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      enabled: _editing || currentBankInfo == null,
                      controller: _accountNumberController,
                      decoration: InputDecoration(
                        labelText: 'Account Number',
                        hintText: 'Enter 10-digit account number',
                        prefixIcon: const Icon(Icons.numbers),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      enabled: _editing || currentBankInfo == null,
                      controller: _accountNameController,
                      decoration: InputDecoration(
                        labelText: 'Account Name',
                        hintText: 'Enter account holder name',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 40),
                    if (_editing || currentBankInfo == null)
                      SizedBox(
                        width: double.maxFinite,
                        height: 55,
                        child: MaterialButton(
                          onPressed:
                              _loading
                                  ? null
                                  : () {
                                    final data = BankInformationModel(
                                      accountName: _accountNameController.text,
                                      accountNumber:
                                          _accountNumberController.text,
                                      bankName: _bankNameController.text,
                                      latUpdatedAt: DateTime.now().toString(),
                                      user: currentBankInfo?.user,
                                    );
                                    if (currentBankInfo == null) {
                                      _createBankInfo(data);
                                    } else {
                                      _updateBankInfo(data);
                                    }
                                  },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          color: Colors.blueAccent,
                          disabledColor: Colors.grey[300],
                          child:
                              _loading
                                  ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                  : const Text(
                                    "Save Bank Details",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                        ),
                      ),
                  ],
                ),
              ),
    );
  }
}
