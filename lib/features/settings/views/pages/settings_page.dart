import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/features/settings/data/models/profile_model.dart';
import 'package:app/features/settings/providers/profile_provider.dart';
import 'package:app/features/settings/views/widgets/settings_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Future<void> openWhatsAppChat(
    BuildContext context,
    String phoneNumber,
  ) async {
    final Uri whatsappUrl = Uri.parse("https://wa.me/$phoneNumber");

    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      } else {
        _showNumberDialog(context, phoneNumber);
      }
    } catch (e) {
      _showNumberDialog(context, phoneNumber);
    }
  }

  void _showNumberDialog(BuildContext context, String phoneNumber) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("WhatsApp not available"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Unable to open WhatsApp. You can contact this number:",
                ),
                const SizedBox(height: 10),
                SelectableText(
                  phoneNumber,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: phoneNumber));
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Number copied to clipboard")),
                  );
                },
                child: const Text("Copy Number"),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text("Close"),
              ),
            ],
          ),
    );
  }

  double _calculateProfileCompletion(UserProfile? profile) {
    if (profile == null) return 0;
    int completedFields = 0;
    int totalFields = 5;

    if (profile.firstName?.isNotEmpty ?? false) completedFields++;
    if (profile.lastName?.isNotEmpty ?? false) completedFields++;
    if (profile.phoneNumber.isNotEmpty) completedFields++;
    if (profile.email?.isNotEmpty ?? false) completedFields++;
    if (profile.tier == 2) completedFields++;

    return completedFields / totalFields;
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final profile = profileProvider.profile;
    final completion = _calculateProfileCompletion(profile);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                "Settings",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.blueAccent, Colors.lightBlue],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -50,
                      top: -50,
                      child: CircleAvatar(
                        radius: 100,
                        backgroundColor: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 35,
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    Icons.person,
                                    size: 40,
                                    color: Colors.blue[700],
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      profile?.phoneNumber ?? "User",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        "Tier ${profile?.tier ?? "1"}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Completion Section
                  if (completion < 1.0) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.blueAccent.withOpacity(0.1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Profile Completion",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                              ),
                              Text(
                                "${(completion * 100).toInt()}%",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          LinearProgressIndicator(
                            value: completion,
                            backgroundColor: Colors.white,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.blueAccent,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            minHeight: 8,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  _buildSectionHeader("Account Details"),
                  SettingsTile(
                    title: "Personal Information",
                    subTitle: "Name, email & phone number",
                    leadingIcon: Icons.person_outline,
                    onTap:
                        () => context
                            .push("/profile/update")
                            .then(
                              (_) =>
                                  context.read<ProfileProvider>().loadProfile(
                                    context.read<AuthProvider>().authToken ??
                                        "",
                                  ),
                            ),
                  ),
                  SettingsTile(
                    title: "Bank Information",
                    subTitle: "Setup your payout bank",
                    leadingIcon: Icons.account_balance_outlined,
                    onTap: () => context.push("/profile/bank-info"),
                  ),
                  SettingsTile(
                    title: "Upgrade Tier",
                    subTitle: "Increase your transaction limits",
                    leadingIcon: Icons.trending_up,
                    onTap: () => context.push("/profile/tier"),
                  ),

                  const SizedBox(height: 24),
                  _buildSectionHeader("Security"),
                  SettingsTile(
                    title: "Change Transaction PIN",
                    subTitle: "Secure your transactions",
                    leadingIcon: Icons.lock_outline,
                    onTap: () => context.push("/profile/change-pin"),
                  ),
                  Consumer<AuthProvider>(
                    builder: (context, auth, child) {
                      return SettingsTile(
                        title: "Biometric Login",
                        subTitle: "Fingerprint or face lock",
                        leadingIcon: Icons.fingerprint,
                        showChevron: false,
                        trailing: Switch.adaptive(
                          value: auth.isBiometricEnabled,
                          activeColor: Colors.blueAccent,
                          onChanged: (value) async {
                            if (value) {
                              final success = await auth.enableBiometrics();
                              if (!success && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Failed to enable biometrics. Ensure you have biometrics set up on your device.",
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            } else {
                              await auth.disableBiometrics();
                            }
                          },
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),
                  _buildSectionHeader("Support"),
                  SettingsTile(
                    title: "Help & Support",
                    subTitle: "Chat with us on WhatsApp",
                    leading: const FaIcon(
                      FontAwesomeIcons.whatsapp,
                      color: Colors.green,
                      size: 24,
                    ),
                    onTap: () => openWhatsAppChat(context, "+2348067682425"),
                  ),

                  const SizedBox(height: 32),
                  SettingsTile(
                    title: "Logout",
                    subTitle: "Sign out of your account",
                    leadingIcon: Icons.logout,
                    leadingIconColor: Colors.red,
                    showChevron: false,
                    onTap:
                        () => context.read<AuthProvider>().logout().then(
                          (_) => context.go("/"),
                        ),
                  ),
                  const SizedBox(height: 8),
                  SettingsTile(
                    title: "Close Account",
                    subTitle: "Permanently delete your account",
                    leadingIcon: Icons.delete_forever_outlined,
                    leadingIconColor: Colors.red,
                    showChevron: false,
                    onTap: () => _showCloseAccountDialog(context),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  void _showCloseAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            icon: const Icon(
              Icons.warning_amber_rounded,
              color: Colors.red,
              size: 48,
            ),
            title: const Text("Close Account"),
            content: const Text(
              "Are you sure you want to permanently close your account? This action cannot be undone and you will lose all your data.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  context.read<AuthProvider>().closeAccount().then(
                    (_) => context.go("/"),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Close Permanently"),
              ),
            ],
          ),
    );
  }
}
