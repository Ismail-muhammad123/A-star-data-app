import 'package:flutter/material.dart';

class FundingGuidePage extends StatelessWidget {
  const FundingGuidePage({super.key});

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 6),
    child: Text(
      text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ),
  );

  Widget _bullet(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "• ",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 15, height: 1.4)),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => Navigator.of(context).pop(),
          color: Colors.white,
        ),
        title: const Text(
          "How to Fund Your Account",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.lightBlue,
        surfaceTintColor: Colors.lightBlue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "You can fund your wallet using any of the following methods:",
              style: TextStyle(fontSize: 16),
            ),

            // 1️⃣ Direct Support Transfer
            _sectionTitle("1. Contact Support for Direct Transfer"),
            _bullet(
              "Send a direct bank transfer to our support account (details will be provided).",
            ),
            _bullet(
              "After making payment, contact the support team via WhatsApp or in-app chat.",
            ),
            _bullet(
              "Share your payment proof or reference number for manual verification.",
            ),
            _bullet(
              "Once confirmed, your wallet will be credited with the transferred amount.",
            ),

            // 2️⃣ Card Payment
            _sectionTitle("2. Fund Using Your Card"),
            _bullet(
              "Select the 'Pay with Card' option under the Fund Wallet section.",
            ),
            _bullet("Enter the amount you wish to deposit."),
            _bullet("Complete payment using your debit or credit card."),
            _bullet(
              "Your wallet will be credited automatically once payment is successful.",
            ),

            // 3️⃣ Virtual Account Funding
            _sectionTitle("3. Transfer to Your Wallet Account Number"),
            _bullet(
              "Complete your KYC/profile verification to activate your personal wallet account number.",
            ),
            _bullet(
              "Once verified, you'll receive a dedicated account number.",
            ),
            _bullet(
              "Send money directly to this account, and your wallet will be credited automatically.",
            ),

            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "💡 Tip: Always ensure you use your registered name and correct reference when making transfers to avoid delays.",
                style: TextStyle(fontSize: 15, color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
