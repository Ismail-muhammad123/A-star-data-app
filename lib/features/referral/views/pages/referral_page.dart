import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/features/referral/data/models/referral_model.dart';
import 'package:app/features/referral/data/repositories/referral_repo.dart';
import 'package:intl/intl.dart';

class ReferralPage extends StatefulWidget {
  const ReferralPage({super.key});

  @override
  State<ReferralPage> createState() => _ReferralPageState();
}

class _ReferralPageState extends State<ReferralPage> {
  bool _isLoading = true;
  ReferralInfo? _info;

  @override
  void initState() {
    super.initState();
    _loadInfo();
  }

  Future<void> _loadInfo() async {
    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();
    final info = await ReferralService().fetchReferralInfo(auth.authToken ?? "");
    setState(() {
      _info = info;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text("Refer & Earn"), elevation: 0),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadInfo,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    _buildPromoCard(theme, isDark),
                    const SizedBox(height: 32),
                    _buildStatsRow(theme),
                    const SizedBox(height: 32),
                    _buildReferralCodeSection(theme),
                    const SizedBox(height: 48),
                    _buildHistorySection(theme),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPromoCard(ThemeData theme, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark ? [theme.cardColor, theme.cardColor.withOpacity(0.8)] : [Colors.blue.shade700, Colors.blue.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Icon(Icons.stars_rounded, color: Colors.white, size: 64),
          const SizedBox(height: 24),
          const Text("Invite Friends, Get Rewarded!", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(
            "Share your unique referral code with friends. Once they sign up and fund their wallet, you both get a bonus!",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(ThemeData theme) {
    return Row(
      children: [
        _buildStatCard("Total Referrals", _info?.referralCount.toString() ?? "0", Icons.people_outline, theme),
        const SizedBox(width: 16),
        _buildStatCard("Earnings", NumberFormat.currency(locale: 'en_NG', symbol: '₦').format(_info?.referralEarnings ?? 0), Icons.payments_outlined, theme),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, ThemeData theme) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: theme.dividerColor)),
        child: Column(
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 24),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildReferralCodeSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Your Referral Code", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: theme.dividerColor, style: BorderStyle.solid)),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _info?.referralCode ?? "---",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 2),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy_rounded, color: Colors.blue),
                onPressed: () {
                  if (_info?.referralCode != null) {
                    Clipboard.setData(ClipboardData(text: _info!.referralCode));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Code copied!")));
                  }
                },
              ),
              IconButton(icon: const Icon(Icons.share_rounded, color: Colors.blue), onPressed: () {}),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistorySection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Referral Activity", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            if (_info?.referredUsers.isNotEmpty ?? false)
              Text("${_info?.referredUsers.length} Users", style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 16),
        if (_info?.referredUsers.isEmpty ?? true)
          _buildEmptyHistory(theme)
        else
          ..._info!.referredUsers.map((u) => _buildUserListTile(u, theme)).toList(),
      ],
    );
  }

  Widget _buildEmptyHistory(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(32),
      width: double.infinity,
      decoration: BoxDecoration(color: theme.cardColor.withOpacity(0.5), borderRadius: BorderRadius.circular(16)),
      child: const Column(
        children: [
          Icon(Icons.history_rounded, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text("No activity yet", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildUserListTile(ReferredUser user, ThemeData theme) {
    final statusColor = user.status == 'active' ? Colors.green : Colors.orange;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: theme.colorScheme.primary.withOpacity(0.1), child: Text(user.fullName[0], style: TextStyle(color: theme.colorScheme.primary))),
        title: Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(DateFormat('MMM dd, yyyy').format(user.dateJoined), style: const TextStyle(fontSize: 12)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Text(user.status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
