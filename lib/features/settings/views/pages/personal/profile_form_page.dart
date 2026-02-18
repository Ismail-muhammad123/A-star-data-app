import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/features/settings/data/repositories/profile_repo.dart';
import 'package:app/features/settings/providers/profile_provider.dart';
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  _initialize() {
    final profile = context.read<ProfileProvider>().profile;
    if (profile != null) {
      _emailController.text = profile.email ?? "";
      _firstNameController.text = profile.firstName ?? "";
      _lastNameController.text = profile.lastName ?? "";
      _middleNameController.text = profile.middleName ?? "";
      _bvnController.text = profile.bvn ?? "";
    }
  }

  _updateProfile() async {
    setState(() => _isLoading = true);
    try {
      final res = await ProfileService()
          .updateUserProfile(context.read<AuthProvider>().authToken ?? "", {
            "email": _emailController.text.trim(),
            "first_name": _firstNameController.text.trim(),
            "last_name": _lastNameController.text.trim(),
            "middle_name": _middleNameController.text.trim(),
            'bvn': _bvnController.text.trim(),
          });
      if (res != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profile Updated Successfully"),
            backgroundColor: Colors.green,
          ),
        );
        await context.read<ProfileProvider>().loadProfile(
          context.read<AuthProvider>().authToken ?? "",
        );
        if (mounted) context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profile Update failed"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: BackButton(
          color: Colors.white,
          onPressed: () => context.pop(),
        ),
        backgroundColor: Colors.blueAccent,
        title: const Text(
          'Personal Information',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Account Details",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Keep your personal information up to date.",
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 30),
            _buildTextField(
              controller: _firstNameController,
              label: "First Name",
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _lastNameController,
              label: "Last Name",
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _middleNameController,
              label: "Middle Name",
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _emailController,
              label: "Email Address",
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _bvnController,
              label: "BVN (Optional)",
              icon: Icons.security_outlined,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.maxFinite,
              height: 55,
              child: MaterialButton(
                onPressed: _isLoading ? null : _updateProfile,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.blueAccent,
                disabledColor: Colors.grey[300],
                child:
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                          "Update Profile",
                          style: TextStyle(
                            color: Colors.white,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
