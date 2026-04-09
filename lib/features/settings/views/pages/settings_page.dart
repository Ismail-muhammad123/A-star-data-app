import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/features/settings/data/models/profile_model.dart';
import 'package:app/features/settings/providers/profile_provider.dart';
import 'package:app/features/settings/views/widgets/settings_tile.dart';
import 'package:app/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app/core/themes/theme_provider.dart';
import 'package:app/core/providers/balance_visibility_provider.dart';
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
  bool _isUpdatingTwoFactor = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileProvider = context.read<ProfileProvider>();
      if (profileProvider.profile == null) {
        final authToken = context.read<AuthProvider>().authToken ?? "";
        profileProvider.loadProfile(authToken);
      }
    });
  }

  Future<void> _toggleTwoFactor(bool enabled) async {
    if (_isUpdatingTwoFactor) return;

    setState(() => _isUpdatingTwoFactor = true);
    try {
      final authProvider = context.read<AuthProvider>();
      final res = await authProvider.update2FASettings(
        isEnabled: enabled,
        twoFactorMethod: enabled ? 'sms' : 'none',
      );
      if (res['success'] != true) {
        throw Exception(res['message'] ?? 'Unable to update 2FA right now.');
      }
      await context.read<ProfileProvider>().loadProfile(authProvider.authToken ?? "");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            enabled
                ? "Two-factor authentication has been enabled."
                : "Two-factor authentication has been disabled.",
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceAll('Exception: ', '').trim().isEmpty
                ? "Unable to update 2FA right now. Please try again."
                : e.toString().replaceAll('Exception: ', ''),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isUpdatingTwoFactor = false);
    }
  }

  Future<void> openWhatsAppChat(
    BuildContext context,
    String phoneNumber, {
    String message = "Hello, I need help with the A-Star Data app.",
  }) async {
    final Uri whatsappUrl = Uri.parse(
      "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}",
    );

    try {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
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

  void _showWhatsAppSupportOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "WhatsApp Support",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "How would you like to reach us?",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 24),
                _buildSupportOption(
                  context,
                  title: "Chat with Support",
                  subtitle: "Directly chat with our agent",
                  icon: FontAwesomeIcons.whatsapp,
                  iconColor: Colors.green,
                  onTap: () {
                    Navigator.pop(context);
                    openWhatsAppChat(context, "+2348067682425");
                  },
                ),
                const SizedBox(height: 12),
                _buildSupportOption(
                  context,
                  title: "Support & Updates Channel",
                  subtitle: "Join our channel for latest news",
                  icon: Icons.campaign_rounded,
                  iconColor: Colors.blue,
                  onTap: () async {
                    Navigator.pop(context);
                    final Uri channelUrl = Uri.parse(
                      "https://whatsapp.com/channel/0029Vb7rJr035fLz4bUIKS1d",
                    );
                    if (await canLaunchUrl(channelUrl)) {
                      await launchUrl(
                        channelUrl,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
    );
  }

  Widget _buildSupportOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child:
                  icon is FontAwesomeIcons
                      ? FaIcon(icon, color: iconColor, size: 24)
                      : Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  double _calculateProfileCompletion(UserProfile? profile) {
    if (profile == null) return 0;
    int completedFields = 0;
    int totalFields = 4;

    if (profile.firstName?.isNotEmpty ?? false) completedFields++;
    if (profile.lastName?.isNotEmpty ?? false) completedFields++;
    if (profile.phoneNumber.isNotEmpty) completedFields++;
    if (profile.email?.isNotEmpty ?? false) completedFields++;

    return completedFields / totalFields;
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final profile = profileProvider.profile;
    final completion = _calculateProfileCompletion(profile);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                "Settings",
                style: TextStyle(
                  color: Theme.of(context).appBarTheme.foregroundColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).appBarTheme.backgroundColor,
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -50,
                      top: -50,
                      child: CircleAvatar(
                        radius: 100,
                        backgroundColor: Colors.white.withOpacity(0.05),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 35,
                              backgroundColor:
                                  Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey[800]
                                      : Colors.white,
                              backgroundImage:
                                  (profile?.profileImage != null &&
                                          profile!.profileImage!.isNotEmpty)
                                      ? NetworkImage(profile!.profileImage!)
                                      : null,
                              child:
                                  (profile?.profileImage == null ||
                                          profile!.profileImage!.isEmpty)
                                      ? Icon(
                                        Icons.person,
                                        size: 40,
                                        color:
                                            Theme.of(context).colorScheme.primary,
                                      )
                                      : null,
                            ),
                            const SizedBox(width: 15),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      profile == null
                                          ? "Loading..."
                                          : (profile.fullName.isNotEmpty)
                                          ? profile.fullName.capitalize()
                                          : profile.phoneNumber,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (profile?.isVerified ?? false) ...[
                                      const SizedBox(width: 8),
                                      const Icon(
                                        Icons.verified,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
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
                  // Verification Prompts
                  if (profile != null && !profile.isVerified) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "Verify Your Account",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color:
                                      Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.orange[300]
                                          : Colors.orange[800],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Complete your verification to enjoy full access and increased security.",
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.color?.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: ElevatedButton.icon(
                              onPressed:
                                  () => context.push(
                                    '/activate-account',
                                    extra: profile.phoneNumber,
                                  ),
                              icon: Icon(Icons.phone_android, size: 18),
                              label: Text("Verify Now"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 10,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Profile Completion Section
                  if (completion < 1.0) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:
                            Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF1E1E1E)
                                : Colors.blue.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Profile Completion",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              Text(
                                "${(completion * 100).toInt()}%",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          LinearProgressIndicator(
                            value: completion,
                            backgroundColor:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey[800]
                                    : Colors.white,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.primary,
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
                    title: "Identity Verification (KYC)",
                    subTitle: "NIN, BVN & Identification",
                    leadingIcon: Icons.verified_user_outlined,
                    onTap: () => context.push("/profile/kyc"),
                  ),

                  const SizedBox(height: 24),
                  _buildSectionHeader("Security"),
                  SettingsTile(
                    title: "Change Login PIN",
                    subTitle: "Used to unlock the app",
                    leadingIcon: Icons.lock_open_outlined,
                    onTap: () => context.push("/profile/change-pin"),
                  ),
                  SettingsTile(
                    title:
                        (profile?.hasTransactionPin ?? false)
                            ? "Change Transaction PIN"
                            : "Set Transaction PIN",
                    subTitle: "Authorize payments and transfers",
                    leadingIcon: Icons.lock_outline,
                    onTap: () {
                      if (profile?.hasTransactionPin ?? false) {
                        context.push("/profile/transaction-pin/change");
                      } else {
                        context.push("/profile/transaction-pin/set");
                      }
                    },
                  ),
                  SettingsTile(
                    title: "Two-Factor Authentication (2FA)",
                    subTitle:
                        (profile?.twoFactorEnabled ?? false)
                            ? "Extra sign-in protection is active"
                            : "Add an extra verification step on login",
                    leadingIcon: Icons.security_outlined,
                    showChevron: false,
                    trailing: Switch.adaptive(
                      value: profile?.twoFactorEnabled ?? false,
                      activeColor: Colors.blueAccent,
                      onChanged:
                          _isUpdatingTwoFactor || profile == null
                              ? null
                              : _toggleTwoFactor,
                    ),
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
                  _buildSectionHeader("Appearance"),
                  SettingsTile(
                    title: "App Theme",
                    subTitle: _getThemeName(
                      context.watch<ThemeProvider>().themeMode,
                    ),
                    leadingIcon: Icons.brightness_6_outlined,
                    onTap: () => _showThemeDialog(context),
                  ),
                  Consumer<BalanceVisibilityProvider>(
                    builder: (context, balanceVisibility, child) {
                      return SettingsTile(
                        title: "Hide Balance",
                        subTitle: "Hide wallet balance on all pages",
                        leadingIcon: Icons.visibility_off_outlined,
                        showChevron: false,
                        trailing: Switch.adaptive(
                          value: balanceVisibility.isBalanceHidden,
                          activeColor: Colors.blueAccent,
                          onChanged: (value) async {
                            await balanceVisibility.toggleBalanceVisibility();
                          },
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),
                  _buildSectionHeader("Support"),
                  SettingsTile(
                    title: "Help Desk",
                    subTitle: "Tickets, FAQs & Support",
                    leadingIcon: Icons.support_agent_rounded,
                    onTap: () => context.push('/support'),
                  ),
                  SettingsTile(
                    title: "Refer & Earn",
                    subTitle: "Invite friends & earn rewards",
                    leadingIcon: Icons.stars_rounded,
                    onTap: () => context.push('/referral'),
                  ),
                  SettingsTile(
                    title: "WhatsApp Support",
                    subTitle: "Chat or join our updates channel",
                    leading: const FaIcon(
                      FontAwesomeIcons.whatsapp,
                      color: Colors.green,
                      size: 24,
                    ),
                    onTap: () => _showWhatsAppSupportOptions(context),
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

  String _getThemeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return "Light";
      case ThemeMode.dark:
        return "Dark";
      case ThemeMode.system:
        return "System Default";
    }
  }

  void _showThemeDialog(BuildContext context) {
    final themeProvider = context.read<ThemeProvider>();
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Select Theme"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<ThemeMode>(
                  value: ThemeMode.system,
                  groupValue: themeProvider.themeMode,
                  onChanged: (val) {
                    themeProvider.setThemeMode(val!);
                    Navigator.of(ctx).pop();
                  },
                  title: const Text("System Default"),
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.light,
                  groupValue: themeProvider.themeMode,
                  onChanged: (val) {
                    themeProvider.setThemeMode(val!);
                    Navigator.of(ctx).pop();
                  },
                  title: const Text("Light"),
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.dark,
                  groupValue: themeProvider.themeMode,
                  onChanged: (val) {
                    themeProvider.setThemeMode(val!);
                    Navigator.of(ctx).pop();
                  },
                  title: const Text("Dark"),
                ),
              ],
            ),
          ),
    );
  }
}
