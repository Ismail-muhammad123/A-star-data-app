import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/features/profile/providers/profile_provider.dart';
import 'package:app/features/profile/views/widgets/sub_profile_tile.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey[200],
                radius: 70,
                child: Icon(Icons.person, size: 80),
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
                  leading: Icons.person,
                  isCompleted: true,
                ),
              ),
              SizedBox(height: 10),
              GestureDetector(
                child: ProfileSubSectionTile(
                  title: "Phone Number",
                  subTitle:
                      profileInfoRef != null
                          ? profileInfoRef.phoneNumber
                          : "Your Phone Number",
                  leading: Icons.phone,
                  isCompleted: true,
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
                  title: "Email",
                  subTitle:
                      (profileInfoRef?.email ?? "").isEmpty
                          ? "Click here to add your email"
                          : profileInfoRef?.email ?? "",
                  leading: Icons.email,
                  isCompleted: true,
                ),
              ),
              SizedBox(height: 10),
              // GestureDetector(
              //   onTap: () => context.push('/profile/bank-info'),
              //   child: ProfileSubSectionTile(
              //     title: "Bank Information",
              //     subTitle: "Bank information for withdrawals",
              //     leading: Icons.account_balance,
              //     isCompleted: true,
              //   ),
              // ),
              // SizedBox(height: 10),
              Divider(),
              SizedBox(height: 10),
              GestureDetector(
                onTap:
                    () => context.read<AuthProvider>().logout().then(
                      (_) => context.go("/"),
                    ),
                child: ProfileSubSectionTile(
                  title: "Logout",
                  subTitle: "log out of your account",
                  leading: Icons.logout,
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
