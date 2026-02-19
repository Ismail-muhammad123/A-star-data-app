import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/features/wallet/data/models/withdrawal_account_model.dart';
import 'package:app/features/wallet/data/repository/wallet_repo.dart';
import 'package:app/features/settings/views/pages/bank_information/wallet_bank_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class WithdrawalAccountPage extends StatefulWidget {
  const WithdrawalAccountPage({super.key});

  @override
  State<WithdrawalAccountPage> createState() => _WithdrawalAccountPageState();
}

class _WithdrawalAccountPageState extends State<WithdrawalAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final _accountNumberController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNameController = TextEditingController();

  String? _bankCode;
  bool _isLoading = false;
  bool _isResolving = false;
  bool _isSaving = false;
  bool _isEditing = false;
  WithdrawalAccount? _currentAccount;

  @override
  void initState() {
    super.initState();
    _loadAccount();
    _accountNumberController.addListener(_onAccountNumberChanged);
  }

  void _onAccountNumberChanged() {
    if (_accountNumberController.text.length == 10) {
      if (_bankCode != null) {
        _resolveAccount();
      }
    } else {
      if (_accountNameController.text.isNotEmpty) {
        setState(() {
          _accountNameController.clear();
        });
      }
    }
  }

  Future<void> _loadAccount() async {
    setState(() => _isLoading = true);
    try {
      final token = context.read<AuthProvider>().authToken;
      if (token != null) {
        final account = await WalletService().getWithdrawalAccount(token);
        if (account != null) {
          setState(() {
            _currentAccount = account;
            _accountNumberController.text = account.accountNumber;
            _bankNameController.text = account.bankName;
            _accountNameController.text = account.accountName;
            _bankCode = account.bankCode;
            _isEditing = false;
          });
        }
      }
    } catch (e) {
      // Handle silently
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resolveAccount() async {
    if (_isResolving) return;
    setState(() => _isResolving = true);
    try {
      final token = context.read<AuthProvider>().authToken;
      if (token != null && _bankCode != null) {
        final name = await WalletService().resolveAccount(
          token,
          _bankCode!,
          _accountNumberController.text,
        );
        setState(() {
          _accountNameController.text = name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll("Exception: ", ""))),
        );
      }
    } finally {
      setState(() => _isResolving = false);
    }
  }

  Future<void> _saveAccount() async {
    if (!_formKey.currentState!.validate()) return;
    if (_accountNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please resolve account first")),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final token = context.read<AuthProvider>().authToken;
      if (token != null) {
        final account = WithdrawalAccount(
          bankName: _bankNameController.text,
          bankCode: _bankCode!,
          accountNumber: _accountNumberController.text,
          accountName: _accountNameController.text,
        );
        await WalletService().saveWithdrawalAccount(token, account);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Withdrawal account saved successfully"),
              backgroundColor: Colors.green,
            ),
          );
          _loadAccount();
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
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isReadOnly = _currentAccount != null && !_isEditing;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Withdrawal Account",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        leading: BackButton(
          color: Colors.white,
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_currentAccount != null)
            IconButton(
              icon: Icon(
                _isEditing ? Icons.cancel_outlined : Icons.edit_outlined,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _isEditing = !_isEditing;
                  if (!_isEditing) {
                    // Reset to current
                    _accountNumberController.text =
                        _currentAccount!.accountNumber;
                    _bankNameController.text = _currentAccount!.bankName;
                    _accountNameController.text = _currentAccount!.accountName;
                    _bankCode = _currentAccount!.bankCode;
                  }
                });
              },
            ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Linked Bank Account",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "This account will be used for all your withdrawals.",
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      const SizedBox(height: 32),

                      // Bank Selection
                      _buildLabel("Select Bank"),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap:
                            isReadOnly
                                ? null
                                : () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => const WalletBankPicker(),
                                    ),
                                  );
                                  if (result != null) {
                                    setState(() {
                                      _bankNameController.text = result['name'];
                                      _bankCode = result['code'];
                                      _accountNameController.clear();
                                    });
                                    if (_accountNumberController.text.length ==
                                        10) {
                                      _resolveAccount();
                                    }
                                  }
                                },
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: _bankNameController,
                            readOnly: true,
                            decoration: _inputDecoration(
                              hint: "Choose your bank",
                              icon: Icons.account_balance,
                            ),
                            validator:
                                (v) =>
                                    (v == null || v.isEmpty)
                                        ? "Bank is required"
                                        : null,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Account Number
                      _buildLabel("Account Number"),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _accountNumberController,
                        readOnly: isReadOnly,
                        keyboardType: TextInputType.number,
                        maxLength: 10,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: _inputDecoration(
                          hint: "0123456789",
                          icon: Icons.numbers,
                          counterText: "",
                        ),
                        onChanged: (v) {
                          if (v.length == 10 && _bankCode != null) {
                            _resolveAccount();
                          }
                        },
                        validator: (v) {
                          if (v == null || v.length != 10) {
                            return "Enter a valid 10-digit account number";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // Resolved Name
                      _buildLabel("Account Name"),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _accountNameController,
                        enabled: false,
                        style: const TextStyle(color: Colors.black87),
                        decoration: _inputDecoration(
                          hint: "Account holder name",
                          icon: Icons.person,
                          fillColor: Colors.grey[50],
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

                      const SizedBox(height: 48),

                      if (!isReadOnly)
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed:
                                _isSaving || _isResolving ? null : _saveAccount,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child:
                                _isSaving
                                    ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                    : Text(
                                      _currentAccount == null
                                          ? "Link Account"
                                          : "Update Account",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black54,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    String? counterText,
    Color? fillColor,
    Widget? prefixWidget,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon:
          prefixWidget ?? Icon(icon, color: Colors.blueAccent, size: 20),
      filled: true,
      fillColor: fillColor ?? Colors.white,
      counterText: counterText,
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
      ),
    );
  }

  @override
  void dispose() {
    _accountNumberController.dispose();
    _bankNameController.dispose();
    _accountNameController.dispose();
    super.dispose();
  }
}
