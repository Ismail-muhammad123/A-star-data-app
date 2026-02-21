import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/features/settings/providers/profile_provider.dart';
import 'package:app/features/wallet/data/repository/wallet_repo.dart';
import 'package:app/features/wallet/views/pages/funding_guide_page.dart';
import 'package:app/features/wallet/views/pages/webview_payment_page.dart';
import 'package:app/features/wallet/views/widgets/transfer_deposit_account_info_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class FundWalletFormPage extends StatefulWidget {
  const FundWalletFormPage({super.key});

  @override
  State<FundWalletFormPage> createState() => _FundWalletFormPageState();
}

class _FundWalletFormPageState extends State<FundWalletFormPage> {
  final TextEditingController _amountController = TextEditingController();
  bool _isLoading = false;
  String paymentMethod = "transfer";
  Map<String, dynamic>? paymentInfo;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  _initCardPayment() async {
    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText);

    if (amount == null || amount < 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid amount (Min. ₦100)"),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      paymentInfo = null;
    });

    try {
      var res = await WalletService().fundWithCard(
        context.read<AuthProvider>().authToken ?? '',
        amount,
      );
      if (res == null) throw Exception('Failed to fetch payment info');

      var checkoutUrl = res['authorization_url'];

      if (!kIsWeb) {
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PaymentWebViewPage(paymentUrl: checkoutUrl),
            ),
          );
        }
      } else {
        var uri = Uri.parse(checkoutUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        }

        if (mounted) {
          _showPaymentInitiatedDialog(res);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Payment failed: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showPaymentInitiatedDialog(dynamic res) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Payment Initiated"),
            content: const Text(
              "Your card payment has been initiated. If the payment page did not open, you can manually open it.",
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  var checkoutUrl =
                      res['responseBody']?['checkoutUrl'] ??
                      res['authorization_url'];
                  var uri = Uri.parse(checkoutUrl);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                child: const Text("Open Manually"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.pop();
                },
                child: const Text("Done"),
              ),
            ],
          ),
    );
  }

  _getPaymentInfo() async {
    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText);

    if (amount == null || amount < 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid amount (Min. ₦100)"),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      paymentInfo = null;
    });

    try {
      var res = await WalletService().fundWithTransfer(
        context.read<AuthProvider>().authToken ?? '',
        amount,
      );
      if (res == null) throw Exception('Failed to fetch payment info');

      setState(() {
        paymentInfo = (res['responseBody'] as Map<String, dynamic>);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    final isTier2 = profile?.tier == 2;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Fund Wallet",
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info
            Text(
              "Add Funds",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Choose your preferred method to add money to your wallet.",
              style: TextStyle(
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),

            // Funding Guide Link
            InkWell(
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FundingGuidePage()),
                  ),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blueAccent.withOpacity(0.2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.help_outline, color: Colors.blueAccent),
                    SizedBox(width: 12),
                    Text(
                      "Need help? View funding guide",
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Spacer(),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.blueAccent,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Payment Method Selection (If not Tier 2)
            if (!isTier2) ...[
              Text(
                "Payment Method",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildMethodCard(
                      id: "transfer",
                      label: "Transfer",
                      icon: Icons.account_balance_outlined,
                      isSelected: paymentMethod == "transfer",
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMethodCard(
                      id: "card",
                      label: "Card",
                      icon: Icons.credit_card_outlined,
                      isSelected: paymentMethod == "card",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],

            // Amount Input
            Text(
              "How much would you like to add?",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              enabled: !_isLoading,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: "Enter amount",
                prefixText: "₦ ",
                prefixStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Colors.blueAccent,
                    width: 2,
                  ),
                ),
              ),
            ),

            if (paymentInfo != null) ...[
              const SizedBox(height: 32),
              Text(
                "Transfer Details",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 12),
              TransferDepositAccountInfoCard(
                accountName: paymentInfo!['accountName'],
                accountNumber: paymentInfo!['accountNumber'],
                bankName: paymentInfo!['bankName'],
                amount: double.tryParse(_amountController.text) ?? 0,
              ),
            ],

            const SizedBox(height: 48),

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed:
                    _isLoading
                        ? null
                        : (isTier2 || paymentMethod == "card"
                            ? _initCardPayment
                            : (paymentInfo == null
                                ? _getPaymentInfo
                                : () => context.pop())),
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
                        : Text(
                          paymentInfo == null ? "Continue" : "Done",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodCard({
    required String id,
    required String label,
    required IconData icon,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: _isLoading ? null : () => setState(() => paymentMethod = id),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blueAccent : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isSelected
                    ? Colors.blueAccent
                    : (Theme.of(context).brightness == Brightness.light
                        ? Colors.grey.shade200
                        : Colors.transparent),
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.blueAccent.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.blueAccent),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color:
                    isSelected
                        ? Colors.white
                        : Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
