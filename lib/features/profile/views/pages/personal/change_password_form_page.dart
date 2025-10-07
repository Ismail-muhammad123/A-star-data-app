import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/features/profile/data/repositories/profile_repo.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _oldpasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  bool isLoading = false;
  @override
  void dispose() {
    _oldpasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Change Pin", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.lightBlue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton:
          isLoading
              ? CircularProgressIndicator()
              : MaterialButton(
                onPressed: () async {
                  if (_oldpasswordController.text.isEmpty ||
                      _newPasswordController.text.isEmpty) {
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: Text('Error'),
                            content: Text('All fields are required'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text('OK'),
                              ),
                            ],
                          ),
                    );
                    return;
                  }
                  setState(() {
                    isLoading = true;
                  });
                  try {
                    var res = await ProfileService().changePin(
                      context.read<AuthProvider>().authToken ?? "",
                      _oldpasswordController.text.trim(),
                      _newPasswordController.text.trim(),
                    );
                    if (res) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('PIN changed successfully')),
                      );
                      if (mounted) {
                        context.canPop()
                            ? context.pop()
                            : context.go("/profile");
                      }
                    } else {
                      throw Exception("Error");
                    }
                  } catch (e) {
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: Text('Error'),
                            content: Text('PIN change has failed'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text('OK'),
                              ),
                            ],
                          ),
                    );
                  } finally {
                    if (mounted) {
                      setState(() {
                        isLoading = false;
                      });
                    }
                  }
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: Theme.of(context).primaryColor,
                minWidth: 200,
                height: 45,
                child: Text(
                  "Save",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextFormField(
              enabled: !isLoading,
              controller: _oldpasswordController,
              decoration: InputDecoration(
                label: Text("Current PIN"),
                border: InputBorder.none,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                filled: true,
                fillColor: Colors.grey.withValues(alpha: 0.2),
                hintText: "Your current PIN",
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              enabled: !isLoading,
              controller: _newPasswordController,
              decoration: InputDecoration(
                label: Text("New PIN"),
                border: InputBorder.none,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                filled: true,
                fillColor: Colors.grey.withValues(alpha: 0.2),
                hintText: "Enter New PIN",
                prefixIcon: Icon(Icons.lock),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
