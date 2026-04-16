import 'package:app/core/utils/error_handler.dart';
import 'package:app/core/widgets/beneficiary_section.dart';
import 'package:app/features/wallet/data/repositories/wallet_repo.dart';
import 'package:app/features/wallet/data/models/transfer_beneficiary_model.dart';
import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/features/wallet/data/repositories/p2p_repo.dart';
import 'package:app/features/wallet/providers/wallet_provider.dart';
import 'package:app/core/widgets/pin_entry_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class P2PTransferPage extends StatefulWidget {
  const P2PTransferPage({super.key});

  @override
  State<P2PTransferPage> createState() => _P2PTransferPageState();
}

class _P2PTransferPageState extends State<P2PTransferPage> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  bool _isLoading = false;
  bool _isLookingUp = false;
  bool _saveBeneficiary = false;
  List<TransferBeneficiary> _beneficiaries = [];
  Map<String, dynamic>? _recipient;
  String? _lookupError;
  String? _lastAutoLookedUpNumber;

  @override
  void initState() {
    super.initState();
    _identifierController.addListener(_onIdentifierChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchBeneficiaries();
    });
  }

  Future<void> _fetchBeneficiaries() async {
    final token = context.read<AuthProvider>().authToken;
    if (token != null) {
      final fetched = await WalletService().getTransferBeneficiaries(token);
      if (mounted) {
        setState(() {
          _beneficiaries = fetched.where((b) => b.bankCode == 'P2P').toList();
        });
      }
    }
  }

  @override
  void dispose() {
    _identifierController.removeListener(_onIdentifierChanged);
    _identifierController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onIdentifierChanged() {
    final number = _identifierController.text.trim();

    if (number.length < 10) {
      if (_recipient != null || _lookupError != null) {
        setState(() {
          _recipient = null;
          _lookupError = null;
        });
      }
      _lastAutoLookedUpNumber = null;
      return;
    }

    if (number.length == 10 &&
        _lastAutoLookedUpNumber != number &&
        !_isLookingUp) {
      _lastAutoLookedUpNumber = number;
      _lookupUser();
    }
  }

  Future<void> _lookupUser() async {
    final identifier = _identifierController.text.trim();
    if (identifier.isEmpty) return;
    if (identifier.length != 10) {
      setState(() {
        _lookupError = "Enter a valid 10-digit phone number.";
        _recipient = null;
      });
      return;
    }
    if (_isLookingUp) return;

    setState(() {
      _isLookingUp = true;
      _lookupError = null;
      _recipient = null;
    });

    try {
      final token = context.read<AuthProvider>().authToken;
      final result = await P2PService().lookupUser(token ?? "", identifier);
      print(result);
      if (mounted) {
        setState(() {
          _recipient = result;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _lookupError = ErrorHandler.getFriendlyMessage(e);
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLookingUp = false);
      }
    }
  }

  Future<void> _initiateTransfer() async {
    if (!_formKey.currentState!.validate() || _recipient == null) return;

    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final wallet = context.read<WalletProvider>();

    if (amount > wallet.balance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Insufficient balance"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show PIN Drawer
    final pin = await showPinEntrySheet(
      context,
      title: "Confirm Transfer",
      subtitle: "Enter your transaction PIN to authorize this transfer.",
    );

    if (pin != null && pin.length == 4) {
      _executeTransfer(pin);
    }
  }

  Future<void> _executeTransfer(String pin) async {
    setState(() => _isLoading = true);
    try {
      final auth = context.read<AuthProvider>();
      if (_saveBeneficiary && _recipient != null) {
        try {
          await WalletService().saveTransferBeneficiary(
            auth.authToken ?? "",
            TransferBeneficiary(
              id: 0,
              bankName: 'Internal',
              bankCode: 'P2P',
              accountNumber: _recipient!['phone_number'],
              accountName: _recipient!['full_name'],
              nickname: _recipient!['full_name'],
            ),
          );
        } catch (e) {
          print("Failed to save P2P beneficiary: $e");
        }
      }

      await P2PService().executeTransfer(
        authToken: auth.authToken ?? "",
        recipientIdentifier: _recipient!['phone_number'],
        amount: double.parse(_amountController.text),
        pin: pin,
        note: _noteController.text.trim(),
      );

      if (!mounted) return;

      context.read<WalletProvider>().fetchBalance(auth.authToken ?? "");

      _showSuccessDialog();
    } catch (e) {
      print(e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ErrorHandler.getFriendlyMessage(e)),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 80,
                ),
                const SizedBox(height: 24),
                const Text(
                  "Transfer Successful!",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  "You have successfully sent ₦${_amountController.text} to ${_recipient!['full_name']}.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      context.pop(); // Go back to wallet
                    },
                    child: const Text("Done"),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wallet = context.watch<WalletProvider>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text("Send Money (P2P)"), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance Indicator
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.account_balance_wallet_outlined,
                      color: Colors.blueAccent,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Balance: ",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      NumberFormat.currency(
                        locale: 'en_NG',
                        symbol: '₦',
                      ).format(wallet.balance),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              BeneficiarySection(
                initialBeneficiaries:
                    _beneficiaries
                        .map(
                          (b) => BeneficiaryDisplayModel(
                            id: b.id,
                            identifier: b.accountNumber,
                            name: b.bankName,
                          ),
                        )
                        .toList(),
                selectedIdentifier: _identifierController.text,
                type: BeneficiaryType.transfer,
                onSelect: (ben) {
                  setState(() {
                    _identifierController.text = ben.identifier;
                    _saveBeneficiary = false;
                    _recipient = null;
                    _lookupError = null;
                  });
                  _lookupUser();
                },
              ),
              const SizedBox(height: 24),

              _buildLabel("Recipient Phone Number"),
              const SizedBox(height: 8),
              TextFormField(
                controller: _identifierController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                decoration: _inputDecoration(
                  hint: "Enter 10-digit phone number",
                  icon: Icons.person_search_outlined,
                  suffix:
                      _isLookingUp
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : IconButton(
                            icon: const Icon(Icons.arrow_forward),
                            onPressed: _lookupUser,
                          ),
                ),
                onFieldSubmitted: (_) => _lookupUser(),
                onChanged: (val) => setState(() {}),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return "Required";
                  if (v.trim().length != 10)
                    return "Enter a valid 10-digit phone number";
                  return null;
                },
              ),
              BeneficiarySuggestions(
                beneficiaries:
                    _beneficiaries
                        .map(
                          (b) => BeneficiaryDisplayModel(
                            id: b.id,
                            identifier: b.accountNumber,
                            name: b.bankName,
                          ),
                        )
                        .toList(),
                query: _identifierController.text,
                onSelect: (ben) {
                  setState(() {
                    _identifierController.text = ben.identifier;
                  });
                  _lookupUser();
                },
              ),
              if (_lookupError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 4),
                  child: Text(
                    _lookupError!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),

              if (_recipient != null) ...[
                const SizedBox(height: 16),
                _buildRecipientCard(_recipient!, theme),

                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text(
                    "Save this beneficiary for future transfers",
                    style: TextStyle(fontSize: 13),
                  ),
                  value: _saveBeneficiary,
                  onChanged: (val) {
                    setState(() {
                      _saveBeneficiary = val ?? false;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                ),

                const SizedBox(height: 32),

                _buildLabel("Amount to Send"),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: _inputDecoration(hint: "0.00", icon: Icons.money),
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Required";
                    final amt = double.tryParse(v) ?? 0;
                    if (amt <= 0) return "Invalid amount";
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                _buildLabel("Note (Optional)"),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _noteController,
                  decoration: _inputDecoration(
                    hint: "What's this for?",
                    icon: Icons.note_add_outlined,
                  ),
                ),

                const SizedBox(height: 48),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _initiateTransfer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child:
                        _isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text(
                              "Continue",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecipientCard(Map<String, dynamic> recipient, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.green,
            child:
                recipient['profile_image'] != null
                    ? Image.network(recipient['profile_image'])
                    : Text(
                      recipient['full_name'][0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipient['full_name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  recipient['phone_number'],
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: Colors.green),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.grey,
      ),
    );
  }

  InputDecoration _inputDecoration({
    String? hint,
    required IconData icon,
    Widget? suffix,
  }) {
    final theme = Theme.of(context);
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: theme.colorScheme.primary, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: theme.cardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: theme.dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
      ),
    );
  }
}
