import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/features/settings/data/repositories/kyc_repo.dart';

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
          _idNumberController.text = status['id_number'];
          _selectedIdType = status['id_type'] ?? 'NIN';
        }
      });
    } catch (e) {
      debugPrint("KYC Status Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitKyc() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final auth = context.read<AuthProvider>();
      await KycService().submitKyc(auth.authToken ?? "", {
        'id_type': _selectedIdType,
        'id_number': _idNumberController.text.trim(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("KYC documents submitted successfully!"), backgroundColor: Colors.green),
      );
      _fetchStatus(); // Refresh to show pending status
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll("Exception: ", "")), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = _currentKyc?['status']?.toString().toLowerCase(); // 'pending', 'approved', 'rejected'

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text("Identity Verification (KYC)"), elevation: 0),
      body: _isLoading && _currentKyc == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (status != null) _buildStatusCard(status, theme),
                  const SizedBox(height: 24),
                  if (status != 'approved' && status != 'pending')
                    _buildKycForm(theme)
                  else if (status == 'pending')
                    _buildInfoNote("Our team is currently reviewing your documents. You'll be notified once approved.", Icons.hourglass_empty, Colors.orange)
                  else
                    _buildInfoNote("Your identity has been verified. You now have full access to all features.", Icons.verified, Colors.green),
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
              const Text("Status", style: TextStyle(fontSize: 12, color: Colors.grey)),
              Text(label, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
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
          const Text("Complete Verification", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Upload a valid ID to remove limits and unlock premium features.", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 32),

          _buildLabel("Select ID Type"),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedIdType,
            decoration: _inputDecoration(icon: Icons.badge_outlined),
            items: ['NIN', 'BVN', 'Driver\'s License', 'International Passport', 'Voter\'s Card']
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: (v) => setState(() => _selectedIdType = v!),
          ),

          const SizedBox(height: 24),

          _buildLabel("ID Number"),
          const SizedBox(height: 8),
          TextFormField(
            controller: _idNumberController,
            validator: (v) => (v?.isEmpty ?? true) ? "Required" : null,
            decoration: _inputDecoration(hint: "Enter your ID number", icon: Icons.numbers_rounded),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Submit Documents", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoNote(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 16),
          Expanded(child: Text(text, style: TextStyle(color: color, height: 1.4))),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey));
  }

  InputDecoration _inputDecoration({String? hint, required IconData icon}) {
    final theme = Theme.of(context);
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: theme.colorScheme.primary, size: 20),
      filled: true,
      fillColor: theme.cardColor,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: theme.dividerColor)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: theme.colorScheme.primary, width: 2)),
    );
  }
}
