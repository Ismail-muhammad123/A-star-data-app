import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/features/profile/data/repositories/profile_repo.dart';
import 'package:app/features/profile/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ProfileFormPage extends StatefulWidget {
  const ProfileFormPage({super.key});

  @override
  State<ProfileFormPage> createState() => _ProfileFormPageState();
}

class _ProfileFormPageState extends State<ProfileFormPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _bvnController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _middleNameController.dispose();
    _emailController.dispose();
    _bvnController.dispose();
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
    _emailController.text = profileRef?.email ?? "";
    _firstNameController.text = profileRef?.firstName ?? "";
    _lastNameController.text = profileRef?.lastName ?? "";
    _middleNameController.text = profileRef?.middleName ?? "";
    _bvnController.text = profileRef?.bvn ?? "";
  }

  _updateProfile() async {
    setState(() {
      _isLoading = true;
    });
    try {
      var res = await ProfileService()
          .updateUserProfile(context.read<AuthProvider>().authToken ?? "", {
            "email": _emailController.text,
            "first_name": _firstNameController.text,
            "last_name": _lastNameController.text,
            "middle_name": _middleNameController.text,
            'bvn': _bvnController.text,
          });
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
        throw Exception("An error has occurred");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile Update failed."),
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
                controller: _firstNameController,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                  labelText: 'First Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                  labelText: 'Last Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _middleNameController,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                  labelText: 'Middle Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bvnController,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                  labelText: 'BVN (optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: MaterialButton(
        onPressed: _isLoading ? null : _updateProfile,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        height: 35,
        minWidth: 200,
        color: Colors.lightBlue,
        child:
            _isLoading
                ? CircularProgressIndicator(color: Colors.blue)
                : Text("Save", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
