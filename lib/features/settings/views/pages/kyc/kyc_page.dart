import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/features/settings/data/repositories/kyc_repo.dart';
import 'package:image_picker/image_picker.dart';

class KycPage extends StatefulWidget {
  const KycPage({super.key});

  @override
  State<KycPage> createState() => _KycPageState();
}

class _KycPageState extends State<KycPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _idNumberController = TextEditingController();
  String _selectedIdType = 'NIN'; // Default
  bool _isLoading = false;
  Map<String, dynamic>? _currentKyc;
  File? _idImage;
  File? _faceImage;
  String? _idImageUrl;
  String? _faceImageUrl;
  String? _remarks;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchStatus();
  }

  Future<void> _fetchStatus() async {
    setState(() => _isLoading = true);
    try {
      final auth = context.read<AuthProvider>();
      final status = await KycService().fetchKycStatus(auth.authToken ?? "");
      setState(() {
        _currentKyc = status;
        if (status['id_number'] != null) {
          _idNumberController.text = status['id_number'].toString();
          _selectedIdType = status['id_type'] ?? 'NIN';
        }
        _idImageUrl = status['id_image'];
        _faceImageUrl = status['face_image'];
        _remarks = status['remarks'];
      });
    } catch (e) {
      debugPrint("KYC Status Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage(ImageSource source, bool isFace) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          if (isFace) {
            _faceImage = File(pickedFile.path);
          } else {
            _idImage = File(pickedFile.path);
          }
        });
      }
    } catch (e) {
      debugPrint("Image Pick Error: $e");
    }
  }

  Future<void> _submitKyc() async {
    if (!_formKey.currentState!.validate()) return;
    if (_idImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please upload an ID image")),
      );
      return;
    }
    if (_faceImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please perform face verification")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final auth = context.read<AuthProvider>();
      await KycService().submitKyc(auth.authToken ?? "", {
        'id_type': _selectedIdType,
        'id_number': _idNumberController.text.trim(),
        'id_image': _idImage?.path,
        'face_image': _faceImage?.path,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("KYC documents submitted successfully!"),
          backgroundColor: Colors.green,
        ),
      );
      _fetchStatus(); // Refresh to show pending status
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll("Exception: ", "")),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status =
        _currentKyc?['status']
            ?.toString()
            .toLowerCase(); // 'pending', 'approved', 'rejected'

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Identity Verification (KYC)"),
        elevation: 0,
      ),
      body:
          _isLoading && _currentKyc == null
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (status != null) _buildStatusCard(status, theme),
                    if (status == 'rejected' && _remarks != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: _buildInfoNote(
                          "Reason for Rejection: $_remarks",
                          Icons.feedback_outlined,
                          Colors.red,
                        ),
                      ),
                    const SizedBox(height: 24),
                    if (status != 'approved' && status != 'pending')
                      _buildKycForm(theme)
                    else if (status == 'pending')
                      _buildInfoNote(
                        "Our team is currently reviewing your documents. You'll be notified once approved.",
                        Icons.hourglass_empty,
                        Colors.orange,
                      )
                    else
                      _buildInfoNote(
                        "Your identity has been verified. You now have full access to all features.",
                        Icons.verified,
                        Colors.green,
                      ),
                  ],
                ),
              ),
    );
  }

  Widget _buildStatusCard(String status, ThemeData theme) {
    Color color;
    IconData icon;
    String label;

    switch (status) {
      case 'approved':
        color = Colors.green;
        icon = Icons.verified_user_rounded;
        label = "VERIFIED";
        break;
      case 'pending':
        color = Colors.orange;
        icon = Icons.pending_actions_rounded;
        label = "PENDING REVIEW";
        break;
      case 'rejected':
        color = Colors.red;
        icon = Icons.error_outline_rounded;
        label = "REJECTED";
        break;
      default:
        color = Colors.blue;
        icon = Icons.help_outline_rounded;
        label = "NOT SUBMITTED";
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Status",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKycForm(ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Complete Verification",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Upload a valid ID to remove limits and unlock premium features.",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),

          _buildLabel("Select ID Type"),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedIdType,
            decoration: _inputDecoration(icon: Icons.badge_outlined),
            items:
                [
                      'NIN',
                      'BVN',
                      'Driver\'s License',
                      'International Passport',
                      'Voter\'s Card',
                    ]
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
            onChanged: (v) => setState(() => _selectedIdType = v!),
          ),

          const SizedBox(height: 24),

          TextFormField(
            controller: _idNumberController,
            validator: (v) => (v?.isEmpty ?? true) ? "Required" : null,
            decoration: _inputDecoration(
              hint: "Enter your ID number",
              icon: Icons.numbers_rounded,
            ),
            keyboardType: TextInputType.number,
          ),

          const SizedBox(height: 32),

          _buildLabel("ID Card Image"),
          const SizedBox(height: 12),
          _buildImagePickerCard(
            file: _idImage,
            imageUrl: _idImageUrl,
            label: "Tap to capture ID",
            onTap: () => _pickImage(ImageSource.camera, false),
            icon: Icons.add_a_photo_outlined,
            tips: [
              "Ensure all four corners are visible",
              "Avoid glare and shadows",
              "Text must be readable and clear",
            ],
          ),

          const SizedBox(height: 32),

          _buildLabel("Face Verification (Selfie)"),
          const SizedBox(height: 12),
          _buildImagePickerCard(
            file: _faceImage,
            imageUrl: _faceImageUrl,
            label: "Tap to take selfie",
            onTap: () => _pickImage(ImageSource.camera, true),
            icon: Icons.face_retouching_natural_outlined,
            tips: [
              "Center your face in the frame",
              "Look directly at the camera",
              "Good lighting is essential",
            ],
          ),

          const SizedBox(height: 48),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitKyc,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child:
                  _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                        "Submit Documents",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePickerCard({
    required File? file,
    required String? imageUrl,
    required String label,
    required VoidCallback onTap,
    required IconData icon,
    required List<String> tips,
  }) {
    final theme = Theme.of(context);
    final hasImage = file != null || imageUrl != null;

    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color:
                    hasImage ? theme.colorScheme.primary : theme.dividerColor,
                width: hasImage ? 2 : 1,
              ),
              image:
                  file != null
                      ? DecorationImage(
                        image: FileImage(file),
                        fit: BoxFit.cover,
                      )
                      : imageUrl != null
                      ? DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      )
                      : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child:
                !hasImage
                    ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          icon,
                          size: 40,
                          color: theme.colorScheme.primary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          label,
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                    : Container(
                      alignment: Alignment.bottomRight,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                          ],
                        ),
                      ),
                      child: CircleAvatar(
                        backgroundColor: theme.colorScheme.primary,
                        radius: 18,
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children:
                tips
                    .map(
                      (tip) => Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 14,
                              color: Colors.blue.shade700,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                tip,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoNote(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(text, style: TextStyle(color: color, height: 1.4)),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint, required IconData icon}) {
    final theme = Theme.of(context);
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: theme.colorScheme.primary, size: 20),
      filled: true,
      fillColor: theme.cardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: theme.dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
      ),
    );
  }
}
