import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/features/profile/data/repositories/profile_repo.dart';
import 'package:app/features/profile/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ProfileFormPage extends StatefulWidget {
  const ProfileFormPage({super.key});

  @override
  State<ProfileFormPage> createState() => _ProfileFormPageState();
}

class _ProfileFormPageState extends State<ProfileFormPage> {
  final TextEditingController _emailCOntroller = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailCOntroller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initialize();
  }

  _initialize() {
    var profileRef =
        Provider.of<ProfileProvider>(context, listen: true).profile;
    _emailCOntroller.text = profileRef?.email ?? "";
    _nameController.text = profileRef?.fullName ?? "";
  }

  _updateProfile() async {
    setState(() {
      _isLoading = true;
    });
    try {
      var res = await ProfileService().updateUserProfile(
        context.read<AuthProvider>().authToken ?? "",
        {"email": _emailCOntroller.text, "full_name": _nameController.text},
      );
      if (res != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profile Updated Successfully."),
            backgroundColor: Colors.green,
          ),
        );
        if (mounted) {
          context.read<ProfileProvider>().loadProfile(
            context.read<AuthProvider>().authToken ?? "",
          );
          context.canPop() ? context.pop() : context.go("/profile");
        }
      } else {
        throw Exception("An error has ocured");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile Updatee failed."),
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: Colors.white,
          onPressed:
              () => context.canPop() ? context.pop() : context.go("/profile"),
        ),
        backgroundColor: Colors.lightBlue,
        surfaceTintColor: Colors.lightBlue,
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                controller: _emailCOntroller,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 16),
              MaterialButton(
                onPressed: _isLoading ? null : _updateProfile,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                height: 50,
                minWidth: 200,
                color: Colors.lightBlue,
                child:
                    _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text("Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
