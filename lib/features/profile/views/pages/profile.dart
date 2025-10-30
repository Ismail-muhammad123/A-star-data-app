import 'package:app/features/auth/providers/auth_provider.dart';
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

  @override
  Widget build(BuildContext context) {
    var profileInfoRef =
        Provider.of<ProfileProvider>(context, listen: true).profile;
    return Scaffold(
      appBar: AppBar(
        title: Text("My Profile", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.lightBlue,
        centerTitle: true,
      ),
      backgroundColor: Colors.lightBlue[50],
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                radius: 40,
                child: Icon(Icons.person, size: 40),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MaterialButton(
                    onPressed:
                        () => context
                            .push("/profile/update")
                            .then(
                              (_) => ProfileProvider().loadProfile(
                                context.read<AuthProvider>().authToken ?? "",
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
                    onPressed: () => context.push("/profile/change-pin"),
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
                  title: "Full Name",
                  subTitle:
                      profileInfoRef?.fullName ?? "Click here to add your name",
                  leadingIcon: Icons.person,
                  isCompleted: true,
                ),
              ),
              SizedBox(height: 6.0),
              GestureDetector(
                child: ProfileSubSectionTile(
                  title: "Phone Number",
                  subTitle:
                      profileInfoRef != null
                          ? profileInfoRef.phoneNumber
                          : "Your Phone Number",
                  leadingIcon: Icons.phone,
                  isCompleted: true,
                ),
              ),
              SizedBox(height: 6.0),
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
                  title: "Email",
                  subTitle:
                      (profileInfoRef?.email ?? "").isEmpty
                          ? "Click here to add your email"
                          : profileInfoRef?.email ?? "",
                  leadingIcon: Icons.email,
                  isCompleted: true,
                ),
              ),
              SizedBox(height: 6.0),
              GestureDetector(
                // onTap: () => context.push('/profile/tier'),
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
            ],
          ),
        ),
      ),
    );
  }
}
