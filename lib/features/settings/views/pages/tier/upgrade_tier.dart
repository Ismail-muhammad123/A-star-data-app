import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/features/settings/data/repositories/profile_repo.dart';
import 'package:app/features/settings/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AccountTierUpgradePage extends StatefulWidget {
  const AccountTierUpgradePage({super.key});

  @override
  State<AccountTierUpgradePage> createState() => _AccountTierUpgradePageState();
}

class _AccountTierUpgradePageState extends State<AccountTierUpgradePage> {
  bool _isLoading = false;
  int? selectedTier;

  @override
  void initState() {
    super.initState();
    selectedTier = context.read<ProfileProvider>().profile?.tier;
  }

  Future<void> upgradeAccountTier() async {
    final profile = context.read<ProfileProvider>().profile;

    if ((profile?.email ?? "").isEmpty ||
        (profile?.firstName ?? "").isEmpty ||
        (profile?.lastName ?? "").isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please complete your profile before upgrading."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ProfileService().upgradeAccount(
        context.read<AuthProvider>().authToken ?? "",
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Account successfully upgraded to Tier 2!"),
            backgroundColor: Colors.green,
          ),
        );
        await context.read<ProfileProvider>().loadProfile(
          context.read<AuthProvider>().authToken ?? "",
        );
        if (mounted) context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll("Exception: ", "")),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    final currentTier = profile?.tier ?? 1;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Upgrade Account',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        backgroundColor: Colors.blueAccent,
        leading: BackButton(
          color: Colors.white,
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Account Limits",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Upgrade your account to enjoy higher transaction limits and permanent virtual accounts.",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            _buildTierCard(
              tier: 1,
              title: "Tier One (Standard)",
              description:
                  "Basic features with temporary virtual accounts for top-ups.",
              currentTier: currentTier,
              onSelect: () => setState(() => selectedTier = 1),
            ),
            const SizedBox(height: 16),
            _buildTierCard(
              tier: 2,
              title: "Tier Two (Premium)",
              description:
                  "Full features with permanent virtual accounts and higher limits.",
              currentTier: currentTier,
              onSelect: () => setState(() => selectedTier = 2),
            ),

            const Spacer(),

            if (currentTier < 2)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : upgradeAccountTier,
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
                            "Request Upgrade",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "You are already on the highest tier available.",
                        style: TextStyle(
                          color: Colors.green[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTierCard({
    required int tier,
    required String title,
    required String description,
    required int currentTier,
    required VoidCallback onSelect,
  }) {
    final bool isCurrent = currentTier == tier;
    final bool isSelected = selectedTier == tier;

    return GestureDetector(
      onTap: isCurrent ? null : onSelect,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.blueAccent : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isCurrent) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "CURRENT",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? Colors.blueAccent : Colors.grey[300],
            ),
          ],
        ),
      ),
    );
  }
}
