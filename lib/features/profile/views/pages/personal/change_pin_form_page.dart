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
  final TextEditingController _oldPinController = TextEditingController();
  final TextEditingController _newPinController = TextEditingController();
  bool isLoading = false;
  @override
  void dispose() {
    _oldPinController.dispose();
    _newPinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Change Pin",
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        backgroundColor: Colors.lightBlue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton:
          isLoading
              ? CircularProgressIndicator()
              : MaterialButton(
                onPressed: () async {
                  if (_oldPinController.text.isEmpty ||
                      _newPinController.text.isEmpty) {
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
                      _oldPinController.text.trim(),
                      _newPinController.text.trim(),
                    );
                    if (res) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('PIN changed successfully'),
                          backgroundColor: Colors.green,
                        ),
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
              controller: _oldPinController,
              autofocus: true,
              decoration: InputDecoration(
                label: Text("Current PIN"),
                border: OutlineInputBorder(
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
              controller: _newPinController,
              decoration: InputDecoration(
                label: Text("New PIN"),
                border: OutlineInputBorder(
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
