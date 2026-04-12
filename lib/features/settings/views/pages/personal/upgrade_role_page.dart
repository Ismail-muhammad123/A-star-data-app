import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/features/settings/data/services/upgrade_service.dart';
import 'package:app/features/wallet/providers/wallet_provider.dart';
import 'package:app/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class UpgradeRolePage extends StatefulWidget {
  const UpgradeRolePage({super.key});

  @override
  State<UpgradeRolePage> createState() => _UpgradeRolePageState();
}

class _UpgradeRolePageState extends State<UpgradeRolePage> {
  final UpgradeService _upgradeService = UpgradeService();
  UpgradeFeesResponse? _feesResponse;
  bool _isLoading = true;
  String? _selectedRole;
  bool _isUpgrading = false;

  @override
  void initState() {
    super.initState();
    _loadFees();
  }

  Future<void> _loadFees() async {
    try {
      final authToken = context.read<AuthProvider>().authToken ?? "";
      final response = await _upgradeService.fetchUpgradeFees(authToken);
      setState(() {
        _feesResponse = response;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _handleUpgrade() async {
    if (_selectedRole == null) return;

    if (_selectedRole == 'developer') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Developer role upgrade is coming soon!"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final feeInfo = _feesResponse?.availableUpgrades.firstWhere(
      (element) => element.toRole == _selectedRole,
    );
    final fee = double.tryParse(feeInfo?.fee ?? '0') ?? 0;
    final balance = context.read<WalletProvider>().balance;

    if (fee > balance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Insufficient balance for this upgrade."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isUpgrading = true);

    try {
      final authToken = context.read<AuthProvider>().authToken ?? "";
      final res = await _upgradeService.upgradeRole(
        authToken: authToken,
        toRole: _selectedRole!,
      );

      if (mounted) {
        context.read<WalletProvider>().fetchBalance(authToken);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message'] ?? "Upgrade successful!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().split(":").last.trim().capitalize()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpgrading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Upgrade Account",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.blueAccent.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Colors.blueAccent,
                            size: 40,
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Unlock Premium Benefits",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Upgrade your account to get lower prices on all services.",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color
                                        ?.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    Text(
                      "Choose Your New Role",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 15),

                    ...(_feesResponse?.availableUpgrades ?? []).map((upgrade) {
                      bool isSelected = _selectedRole == upgrade.toRole;
                      bool isSoon = upgrade.toRole == 'developer';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedRole = upgrade.toRole;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color:
                                    isSelected
                                        ? Colors.blueAccent
                                        : Colors.grey.withOpacity(0.2),
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: [
                                if (isSelected)
                                  BoxShadow(
                                    color: Colors.blueAccent.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: (isSoon
                                            ? Colors.grey
                                            : Colors.blueAccent)
                                        .withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    upgrade.toRole == 'agent'
                                        ? Icons.handshake_outlined
                                        : Icons.code_rounded,
                                    color:
                                        isSoon
                                            ? Colors.grey
                                            : Colors.blueAccent,
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            upgrade.toRole.toUpperCase(),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color:
                                                  isSoon
                                                      ? Colors.grey
                                                      : Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge
                                                          ?.color,
                                            ),
                                          ),
                                          if (isSoon) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.orange
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: const Text(
                                                "SOON",
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.orange,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      Text(
                                        upgrade.toRole == 'agent'
                                            ? "Perfect for resellers"
                                            : "Full API access",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  NumberFormat.currency(
                                    symbol: "₦",
                                    decimalDigits: 0,
                                  ).format(double.tryParse(upgrade.fee) ?? 0),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: isSoon ? Colors.grey : Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),

                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed:
                            (_selectedRole == null || _isUpgrading)
                                ? null
                                : _handleUpgrade,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child:
                            _isUpgrading
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : const Text(
                                  "Confirm Upgrade",
                                  style: TextStyle(
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
