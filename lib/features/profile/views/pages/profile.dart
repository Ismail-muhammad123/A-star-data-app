import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/features/profile/data/models/profile_model.dart';
import 'package:app/features/profile/providers/profile_provider.dart';
import 'package:app/features/profile/views/widgets/sub_profile_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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

  int _calculateProfileCompletion(UserProfile? profile) {
    int completedFields = 0;
    int totalFields = 0;

    if (profile == null) {
      return 0;
    }

    // Check firstName
    totalFields++;
    if (profile.firstName != null && profile.firstName!.isNotEmpty) {
      completedFields++;
    }

    // Check lastName
    totalFields++;
    if (profile.lastName != null && profile.lastName!.isNotEmpty) {
      completedFields++;
    }

    // Check phoneNumber
    totalFields++;
    if (profile.phoneNumber.isNotEmpty) {
      completedFields++;
    }

    // Check email
    totalFields++;
    if (profile.email != null && profile.email!.isNotEmpty) {
      completedFields++;
    }

    // Check email
    totalFields++;
    if (profile.bvn != null && profile.bvn!.isNotEmpty) {
      completedFields++;
    }

    // Check tier
    totalFields++;
    if (profile.tier == 2) {
      completedFields++;
    }

    return (completedFields / (totalFields)) * 100 ~/ 1;
  }

  @override
  Widget build(BuildContext context) {
    var profileInfoRef =
        Provider.of<ProfileProvider>(context, listen: true).profile;
    return Scaffold(
      appBar: AppBar(
        title: Text("My Profile", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.lightBlue,
        surfaceTintColor: Colors.lightBlue,
      ),
      backgroundColor: Colors.lightBlue[50],
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey[100],
                            radius: 30,
                            child: Icon(Icons.person, size: 30),
                          ),
                          SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profileInfoRef?.phoneNumber ?? "Phone Number",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Tier ${profileInfoRef?.tier ?? "N/A"}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          MaterialButton(
                            onPressed:
                                () => context
                                    .push("/profile/update")
                                    .then(
                                      (_) => ProfileProvider().loadProfile(
                                        context
                                                .read<AuthProvider>()
                                                .authToken ??
                                            "",
                                      ),
                                    ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            height: 30,
                            minWidth: 100,
                            color: Colors.lightBlueAccent,
                            child: Text("Edit Profile"),
                          ),
                          SizedBox(width: 10),
                          MaterialButton(
                            onPressed:
                                () => context.push("/profile/change-pin"),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            height: 30,
                            minWidth: 100,
                            color: Colors.lightBlueAccent,
                            child: Text("Change PIN"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 10),
              GestureDetector(
                onTap:
                    () => context
                        .push("/profile/update")
                        .then(
                          (_) => ProfileProvider().loadProfile(
                            context.read<AuthProvider>().authToken ?? "",
                          ),
                        ),
                child: ProfileSubSectionTile(
                  title: "My Profile",
                  subTitle:
                      "${_calculateProfileCompletion(profileInfoRef)}% Complete",
                  leadingIcon: Icons.person,
                  isCompleted: true,
                ),
              ),
              SizedBox(height: 6.0),
              GestureDetector(
                onTap: () => context.push('/profile/tier'),
                child: ProfileSubSectionTile(
                  title: "Upgrade Account",
                  subTitle: "Currently: Tier ${profileInfoRef?.tier}",
                  leadingIcon: Icons.perm_identity,
                  isCompleted: true,
                ),
              ),
              SizedBox(height: 6.0),
              GestureDetector(
                onTap: () => openWhatsAppChat(context, "+2348123456789"),
                child: ProfileSubSectionTile(
                  title: "Support",
                  subTitle: "Contact us on WhatsApp",
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FaIcon(FontAwesomeIcons.whatsapp),
                  ),
                  isCompleted: true,
                  // trailing: Padding(
                  //   padding: const EdgeInsets.all(8.0),
                  //   child: Icon(Icons.copy),
                  // ),
                ),
              ),
              Divider(),
              GestureDetector(
                onTap:
                    () => context.read<AuthProvider>().logout().then(
                      (_) => context.go("/"),
                    ),
                child: ProfileSubSectionTile(
                  title: "Logout",
                  subTitle: "log out of your account",
                  leadingIcon: Icons.logout,
                  leadingIconColor: Colors.red,
                  // trailing: Icons.check_circle_sharp,
                  // isCompleted: true,
                ),
              ),
              Divider(),
              GestureDetector(
                onTap:
                    () => showDialog(
                      context: context,
                      builder:
                          (ctx) => AlertDialog(
                            icon: Icon(Icons.warning, color: Colors.red),
                            title: const Text("Close Account"),
                            content: const Text(
                              "Are you sure you want to permanently close your account? This action cannot be undone.",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(ctx).pop();
                                  context
                                      .read<AuthProvider>()
                                      .closeAccount()
                                      .then((_) => context.go("/"));
                                },
                                child: const Text(
                                  "Close Account",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                    ),
                child: ProfileSubSectionTile(
                  title: "Close Account",
                  subTitle: "permanently close your account",
                  leadingIcon: Icons.delete_forever,
                  leadingIconColor: Colors.red,
                  // trailing: Icons.check_circle_sharp,
                  // isCompleted: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
