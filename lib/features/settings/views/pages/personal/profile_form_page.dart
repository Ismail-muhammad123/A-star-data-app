import 'dart:io';
import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/features/settings/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
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
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _countryCodeController = TextEditingController();

  bool _isLoading = false;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _middleNameController.dispose();
    _phoneController.dispose();
    _countryCodeController.dispose();
    _emailController.dispose();

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
      _phoneController.text = profile.phoneNumber;
      _countryCodeController.text = profile.phoneCountryCode;
    }
  }

  _updateProfile() async {
    setState(() => _isLoading = true);
    try {
      final authToken = context.read<AuthProvider>().authToken ?? "";
      final profileProvider = context.read<ProfileProvider>();
      
      final success = await profileProvider.updateProfile(
        authToken,
        {
          "email": _emailController.text.trim(),
          "first_name": _firstNameController.text.trim(),
          "last_name": _lastNameController.text.trim(),
          "middle_name": _middleNameController.text.trim(),
        },
        profileImagePath: _selectedImage?.path,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profile Updated Successfully"),
            backgroundColor: Colors.green,
          ),
        );
        if (mounted) context.pop();
      } else if (mounted) {
        throw Exception("Update failed");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: BackButton(
          color: Colors.white,
          onPressed: () => context.pop(),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: const Text(
          'Personal Information',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Account Details",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Keep your personal information up to date.",
              style: TextStyle(
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.blueAccent.withOpacity(0.1),
                    backgroundImage:
                        _selectedImage != null
                            ? FileImage(_selectedImage!)
                            : (context.read<ProfileProvider>().profile?.profileImage !=
                                        null
                                    ? NetworkImage(
                                      context
                                          .read<ProfileProvider>()
                                          .profile!
                                          .profileImage!,
                                    )
                                    : null)
                                as ImageProvider?,
                    child:
                        _selectedImage == null &&
                                context.read<ProfileProvider>().profile?.profileImage ==
                                    null
                            ? const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.blueAccent,
                            )
                            : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.blueAccent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _buildTextField(
              context,
              controller: _firstNameController,
              label: "First Name",
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              context,
              controller: _lastNameController,
              label: "Last Name",
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              context,
              controller: _middleNameController,
              label: "Middle Name",
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              context,
              controller: _phoneController,
              label: "Phone Number",
              icon: Icons.phone_android_outlined,
              enabled: false,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              context,
              controller: _countryCodeController,
              label: "Country Code",
              icon: Icons.public_outlined,
              enabled: false,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              context,
              controller: _emailController,
              label: "Email Address",
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
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

  Widget _buildTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
        ),
        filled: true,
        fillColor: Theme.of(context).cardColor,
      ),
    );
  }
}
