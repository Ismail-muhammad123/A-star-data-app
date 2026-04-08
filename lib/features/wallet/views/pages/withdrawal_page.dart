import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/features/wallet/data/models/withdrawal_account_model.dart';
import 'package:app/features/wallet/data/repository/wallet_repo.dart';
import 'package:app/features/settings/views/pages/bank_information/wallet_bank_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class WithdrawalPage extends StatefulWidget {
  const WithdrawalPage({super.key});

  @override
  State<WithdrawalPage> createState() => _WithdrawalPageState();
}

class _WithdrawalPageState extends State<WithdrawalPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _otherAccountNumberController = TextEditingController();
  final _otherBankNameController = TextEditingController();
  final _otherAccountNameController = TextEditingController();

  bool _isLoading = false;
  double _balance = 0.0;
  bool _isLoadingData = true;
  WithdrawalAccount? _withdrawalAccount;
  bool _useOtherAccount = false;
  String? _otherBankCode;
  bool _isResolving = false;
  bool _isSaving = false;

  double _withdrawalCharge = 0.0;
  bool _isChargePercentage = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoadingData = true);
    try {
      final token = context.read<AuthProvider>().authToken;
      if (token != null) {
        final balString = await WalletService().getBalance(token);
        final account = await WalletService().getWithdrawalAccount(token);
        final config = await WalletService().getChargesConfig(token);
        setState(() {
          _balance = double.tryParse(balString) ?? 0.0;
          _withdrawalAccount = account;
          _isChargePercentage =
              config['withdrawal_charge_type'] == 'percentage';
          _withdrawalCharge =
              double.tryParse(
                config['withdrawal_charge']?.toString() ?? '0.0',
              ) ??
              0.0;
        });
      }
    } catch (e) {
      // Handle error cleanly
    } finally {
      if (mounted) setState(() => _isLoadingData = false);
    }
  }

  Future<void> _resolveAccount() async {
    if (_isResolving) return;
    setState(() => _isResolving = true);
    try {
      final token = context.read<AuthProvider>().authToken;
      if (token != null && _otherBankCode != null) {
        final name = await WalletService().resolveAccount(
          token,
          _otherBankCode!,
          _otherAccountNumberController.text,
        );
        setState(() {
          _otherAccountNameController.text = name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll("Exception: ", ""))),
        );
      }
    } finally {
      if (mounted) setState(() => _isResolving = false);
    }
  }

  Future<void> _saveAsWithdrawalAccount() async {
    if (_isSaving) return;

    final bankName = _otherBankNameController.text;
    final accountNumber = _otherAccountNumberController.text;
    final accountName = _otherAccountNameController.text;
    final bankCode = _otherBankCode;

    if (bankCode == null || accountName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please select a bank and resolve the account name first",
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final token = context.read<AuthProvider>().authToken;
      if (token != null) {
        final account = WithdrawalAccount(
          bankName: bankName,
          bankCode: bankCode,
          accountNumber: accountNumber,
          accountName: accountName,
        );
        await WalletService().saveWithdrawalAccount(token, account);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Withdrawal account saved successfully"),
              backgroundColor: Colors.green,
            ),
          );
          await _loadData(); // Reload to get the new withdrawal account
          setState(() {
            _useOtherAccount = false; // Switch to saved account tab
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll("Exception: ", "")),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _submitWithdrawal() async {
    if (!_formKey.currentState!.validate()) return;

    String bankName;
    String accountNumber;
    String accountName;
    String? bankCode;

    if (_useOtherAccount) {
      if (_otherBankCode == null || _otherAccountNameController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please select a bank and resolve the account name"),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      bankName = _otherBankNameController.text;
      accountNumber = _otherAccountNumberController.text;
      accountName = _otherAccountNameController.text;
      bankCode = _otherBankCode;
    } else {
      if (_withdrawalAccount == null ||
          _withdrawalAccount!.accountNumber.isEmpty ||
          _withdrawalAccount!.bankName.isEmpty ||
          _withdrawalAccount!.accountName.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please link a valid withdrawal account first"),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      bankName = _withdrawalAccount!.bankName;
      accountNumber = _withdrawalAccount!.accountNumber;
      accountName = _withdrawalAccount!.accountName;
      bankCode = _withdrawalAccount!.bankCode;
    }

    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount > _balance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Insufficient balance"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final token = context.read<AuthProvider>().authToken;
      if (token != null) {
        await WalletService().requestWithdrawal(
          token,
          amount,
          bankName,
          accountNumber,
          accountName,
          reason: "Withdrawal request",
          bankCode: bankCode,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Withdrawal request submitted successfully"),
              backgroundColor: Colors.green,
            ),
          );
          context.pop(); // Go back to wallet
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll("Exception: ", "")),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Withdraw Funds",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        leading: BackButton(
          color: Colors.white,
          onPressed: () => context.pop(),
        ),
      ),
      body:
          _isLoadingData
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Balance Info Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              if (Theme.of(context).brightness ==
                                  Brightness.light)
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blueAccent.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.account_balance_wallet,
                                  color: Colors.blueAccent,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Available Balance",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    NumberFormat.currency(
                                      locale: 'en_NG',
                                      symbol: '₦',
                                    ).format(_balance),
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          Theme.of(
                                            context,
                                          ).textTheme.bodyLarge?.color,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        Text(
                          "Withdrawal Amount",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.money,
                              color: Colors.blueAccent,
                            ),
                            hintText: "0.00",
                            filled: true,
                            fillColor: Theme.of(context).cardColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.blueAccent,
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter an amount";
                            }
                            final amount = double.tryParse(value);
                            if (amount == null || amount <= 0) {
                              return "Please enter a valid amount";
                            }
                            if (amount < (100 + _withdrawalCharge)) {
                              return "Minimum is ₦${(100 + _withdrawalCharge).toStringAsFixed(0)}";
                            }
                            if (amount > _balance) {
                              return "Amount exceeds balance";
                            }
                            return null;
                          },
                          onChanged: (val) {
                            setState(
                              () {},
                            ); // trigger rebuild to update calculation
                          },
                        ),

                        // Calculate Charge
                        if (_amountController.text.isNotEmpty &&
                            (double.tryParse(_amountController.text) ?? 0) > 0)
                          Builder(
                            builder: (context) {
                              final amt =
                                  double.tryParse(_amountController.text) ??
                                  0.0;
                              final charge =
                                  _isChargePercentage
                                      ? (amt * _withdrawalCharge / 100)
                                      : _withdrawalCharge;
                              final receiveAmt = amt - charge;

                              return Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.blueAccent.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.blueAccent.withOpacity(0.2),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            "Withdrawal Charge",
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            "₦${charge.toStringAsFixed(2)}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.redAccent,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      const Divider(),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "You Will Receive",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).textTheme.bodyLarge?.color,
                                            ),
                                          ),
                                          Text(
                                            "₦${(receiveAmt > 0 ? receiveAmt : 0).toStringAsFixed(2)}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                        const SizedBox(height: 32),

                        _buildOtherAccountForm(),

                        const SizedBox(height: 48),

                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submitWithdrawal,
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
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                    : const Text(
                                      "Request Payout",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }

  // Widget _buildEmptyAccountCard() {
  //   final bool canSaveOther =
  //       _otherBankCode != null &&
  //       _otherAccountNumberController.text.length == 10 &&
  //       _otherAccountNameController.text.isNotEmpty;

  //   return Container(
  //     width: double.infinity,
  //     padding: const EdgeInsets.all(24),
  //     decoration: BoxDecoration(
  //       color: Colors.orange.withOpacity(0.05),
  //       borderRadius: BorderRadius.circular(16),
  //       border: Border.all(color: Colors.orange.withOpacity(0.2)),
  //     ),
  //     child: Column(
  //       children: [
  //         Icon(Icons.info_outline, color: Colors.orange[700], size: 40),
  //         const SizedBox(height: 16),
  //         const Text(
  //           "No Withdrawal Account Linked",
  //           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
  //         ),
  //         const SizedBox(height: 8),
  //         Text(
  //           canSaveOther
  //               ? "You can save the account details entered in the 'Other Account' tab."
  //               : "Link a bank account to receive your funds automatically.",
  //           textAlign: TextAlign.center,
  //           style: TextStyle(color: Colors.grey[600], fontSize: 14),
  //         ),
  //         const SizedBox(height: 24),
  //         if (canSaveOther)
  //           SizedBox(
  //             width: double.infinity,
  //             height: 50,
  //             child: ElevatedButton.icon(
  //               onPressed: _isSaving ? null : _saveAsWithdrawalAccount,
  //               icon:
  //                   _isSaving
  //                       ? const SizedBox(
  //                         height: 18,
  //                         width: 18,
  //                         child: CircularProgressIndicator(
  //                           strokeWidth: 2,
  //                           color: Colors.white,
  //                         ),
  //                       )
  //                       : const Icon(Icons.save_outlined),
  //               label: const Text(
  //                 "Save as Withdrawal Account",
  //                 style: TextStyle(fontWeight: FontWeight.bold),
  //               ),
  //               style: ElevatedButton.styleFrom(
  //                 backgroundColor: Colors.blueAccent,
  //                 foregroundColor: Colors.white,
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(12),
  //                 ),
  //               ),
  //             ),
  //           )
  //         else
  //           SizedBox(
  //             width: double.infinity,
  //             height: 50,
  //             child: ElevatedButton.icon(
  //               onPressed:
  //                   () => context
  //                       .push('/wallet/withdrawal-account')
  //                       .then((_) => _loadData()),
  //               icon: const Icon(Icons.add),
  //               label: const Text(
  //                 "Add Account",
  //                 style: TextStyle(fontWeight: FontWeight.bold),
  //               ),
  //               style: ElevatedButton.styleFrom(
  //                 backgroundColor: Colors.orange[700],
  //                 foregroundColor: Colors.white,
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(12),
  //                 ),
  //               ),
  //             ),
  //           ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildAccountCard() {
  //   return Container(
  //     width: double.infinity,
  //     padding: const EdgeInsets.all(20),
  //     decoration: BoxDecoration(
  //       color: Theme.of(context).cardColor,
  //       borderRadius: BorderRadius.circular(16),
  //       boxShadow: [
  //         if (Theme.of(context).brightness == Brightness.light)
  //           BoxShadow(
  //             color: Colors.black.withOpacity(0.05),
  //             blurRadius: 10,
  //             offset: const Offset(0, 4),
  //           ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             Icon(Icons.account_balance, color: Colors.blueAccent, size: 20),
  //             const SizedBox(width: 8),
  //             Text(
  //               _withdrawalAccount!.bankName,
  //               style: TextStyle(
  //                 fontWeight: FontWeight.bold,
  //                 fontSize: 15,
  //                 color: Theme.of(context).textTheme.bodyLarge?.color,
  //               ),
  //             ),
  //             const Spacer(),
  //             TextButton(
  //               onPressed:
  //                   () => context
  //                       .push('/wallet/withdrawal-account')
  //                       .then((_) => _loadData()),
  //               style: TextButton.styleFrom(
  //                 padding: EdgeInsets.zero,
  //                 minimumSize: const Size(50, 30),
  //                 tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  //               ),
  //               child: const Text(
  //                 "Change",
  //                 style: TextStyle(
  //                   color: Colors.blueAccent,
  //                   fontWeight: FontWeight.bold,
  //                   fontSize: 13,
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 16),
  //         Text(
  //           _withdrawalAccount!.accountNumber,
  //           style: TextStyle(
  //             fontSize: 24,
  //             fontWeight: FontWeight.bold,
  //             letterSpacing: 1.2,
  //             color: Theme.of(context).textTheme.bodyLarge?.color,
  //           ),
  //         ),
  //         const SizedBox(height: 4),
  //         Text(
  //           _withdrawalAccount!.accountName,
  //           style: TextStyle(
  //             color: Colors.grey[600],
  //             fontSize: 14,
  //             fontWeight: FontWeight.w500,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildOtherAccountForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("Select Bank"),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WalletBankPicker()),
            );
            if (result != null) {
              setState(() {
                _otherBankNameController.text = result['name'];
                _otherBankCode = result['code'];
                _otherAccountNameController.clear();
              });
              if (_otherAccountNumberController.text.length == 10) {
                _resolveAccount();
              }
            }
          },
          child: AbsorbPointer(
            child: TextFormField(
              controller: _otherBankNameController,
              readOnly: true,
              decoration: _inputDecoration(
                hint: "Choose recipient bank",
                icon: Icons.account_balance,
              ),
              validator:
                  (v) =>
                      (_useOtherAccount && (v == null || v.isEmpty))
                          ? "Bank is required"
                          : null,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildLabel("Account Number"),
        const SizedBox(height: 8),
        TextFormField(
          controller: _otherAccountNumberController,
          keyboardType: TextInputType.number,
          maxLength: 10,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: _inputDecoration(
            hint: "10-digit account number",
            icon: Icons.numbers,
            counterText: "",
          ),
          onChanged: (v) {
            if (v.length == 10 && _otherBankCode != null) {
              _resolveAccount();
            }
          },
          validator:
              (v) =>
                  (_useOtherAccount && (v == null || v.length != 10))
                      ? "Enter a valid 10-digit account number"
                      : null,
        ),
        const SizedBox(height: 16),
        _buildLabel("Account Name"),
        const SizedBox(height: 8),
        TextFormField(
          controller: _otherAccountNameController,
          enabled: false,
          decoration: _inputDecoration(
            hint: "Account holder name",
            icon: Icons.person,
            prefixWidget:
                _isResolving
                    ? Container(
                      padding: const EdgeInsets.all(12),
                      child: const SizedBox(
                        height: 10,
                        width: 10,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.blueAccent,
                        ),
                      ),
                    )
                    : null,
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    String? counterText,
    Widget? prefixWidget,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon:
          prefixWidget ?? Icon(icon, color: Colors.blueAccent, size: 20),
      filled: true,
      fillColor: Theme.of(context).cardColor,
      counterText: counterText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _otherAccountNumberController.dispose();
    _otherBankNameController.dispose();
    _otherAccountNameController.dispose();
    super.dispose();
  }
}
