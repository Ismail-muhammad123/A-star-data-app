import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/features/profile/data/repositories/profile_repo.dart';
import 'package:app/features/profile/providers/profile_provider.dart';
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

  upgradeAccountTier() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await ProfileService().upgradeAccount(
        context.read<AuthProvider>().authToken ?? "",
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Your Profile has been updated to Tier ${selectedTier == 1 ? 'One' : 'Two'} Successfully.",
          ),
          backgroundColor: Colors.green,
        ),
      );
      if (mounted) {
        context.read<ProfileProvider>().loadProfile(
          context.read<AuthProvider>().authToken ?? "",
        );
        context.canPop() ? context.pop() : context.go("/profile");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile Tier Update failed."),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    selectedTier =
        Provider.of<ProfileProvider>(context, listen: false).profile?.tier;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var profileInfoRef =
        Provider.of<ProfileProvider>(context, listen: true).profile;
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: Colors.white,
          onPressed:
              () => context.canPop() ? context.pop() : context.go('/home'),
        ),
        title: const Text(
          'Upgrade Account',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        surfaceTintColor: Colors.blue,
      ),

      body: Padding(
        padding: const EdgeInsets.all(10.0),

        child:
            (profileInfoRef?.bvn ?? "").isEmpty ||
                    (profileInfoRef?.email ?? "").isEmpty ||
                    (profileInfoRef?.firstName ?? "").isEmpty ||
                    (profileInfoRef?.lastName ?? "").isEmpty
                ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Your profile is incomplete! \nComplete your profile to be able to upgrade your account tier",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.redAccent),
                    ),
                    SizedBox(height: 10),
                    MaterialButton(
                      onPressed:
                          _isLoading
                              ? null
                              : () => context.push("/profile/update"),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      height: 35,
                      minWidth: 150,
                      color: Colors.blueAccent,
                      child:
                          _isLoading
                              ? CircularProgressIndicator()
                              : Text(
                                "Complete Profile",
                                style: TextStyle(color: Colors.white),
                              ),
                    ),
                  ],
                )
                : SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            "Select Account Tier",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Card(
                          color: Colors.white,
                          child: ListTile(
                            onTap: () => setState(() => selectedTier = 1),
                            dense: true,
                            leading: Icon(
                              selectedTier == 1
                                  ? Icons.radio_button_on
                                  : Icons.radio_button_off,
                            ),
                            title: Text(
                              "Tier One",
                              // style: TextStyle(
                              //   fontWeight: FontWeight.bold,
                              //   fontSize: 18,
                              // ),
                            ),
                            subtitle: Text(
                              "Temporary Account Information for Wallet top-up.",
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Card(
                          color: Colors.white,
                          child: ListTile(
                            onTap: () => setState(() => selectedTier = 2),
                            dense: true,
                            leading: Icon(
                              selectedTier == 2
                                  ? Icons.radio_button_on
                                  : Icons.radio_button_off,
                            ),
                            title: Text(
                              "Tier Two",
                              // style: TextStyle(
                              //   fontWeight: FontWeight.bold,
                              //   fontSize: 18,
                              // ),
                            ),
                            subtitle: Text(
                              "Permanent Account Information for Wallet top-up.",
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                      Center(
                        child: MaterialButton(
                          onPressed:
                              _isLoading && profileInfoRef?.tier == selectedTier
                                  ? null
                                  : upgradeAccountTier,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          height: 50,
                          minWidth: 200,
                          color: Colors.blueAccent,
                          child:
                              _isLoading
                                  ? CircularProgressIndicator()
                                  : Text(
                                    "Submit",
                                    style: TextStyle(color: Colors.white),
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
