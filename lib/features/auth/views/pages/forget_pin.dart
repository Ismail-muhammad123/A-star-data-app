import 'package:app/features/auth/data/repository/auth_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class ForgetPinPage extends StatefulWidget {
  const ForgetPinPage({super.key});

  @override
  State<ForgetPinPage> createState() => _ForgetPinPageState();
}

class _ForgetPinPageState extends State<ForgetPinPage> {
  final TextEditingController _phoneNumberController = TextEditingController();
  bool _isLoading = false;

  void _handlePinReset() async {
    if (_phoneNumberController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Invalid Phone Address")));
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });
    try {
      var phone = _phoneNumberController.text.trim();
      if (phone.startsWith("0")) {
        phone = _phoneNumberController.text.substring(1);
      }
      await AuthService().resetPin(phone);
      if (mounted) {
        await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                backgroundColor: Colors.white,
                contentPadding: EdgeInsets.all(20),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 80,
                      color: Colors.green,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Pin reset OTP has be sent to your SMS and WhatsApp inbox. Use it to set create password",
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
        );
        if (mounted) {
          context.go(
            "/confirm-pin-reset?phone=${_phoneNumberController.text.trim()}",
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Failed to send pin reset OTP at the moment! please try again later.",
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: double.maxFinite,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Card(
                    elevation: 8.0,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // SizedBox(height: 100),
                          Text(
                            "Recover PIN".toUpperCase(),
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.blue,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            "Enter the phone number used for your account",
                            style: TextStyle(fontStyle: FontStyle.italic),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              enabled: !_isLoading,
                              controller: _phoneNumberController,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.phone),
                                label: Text("Phone Number"),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 20),
                          MaterialButton(
                            onPressed: _isLoading ? null : _handlePinReset,
                            height: 50,
                            minWidth: 300,
                            color: Colors.lightBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child:
                                _isLoading
                                    ? CircularProgressIndicator()
                                    : Text(
                                      "Get OTP",
                                      style: TextStyle(fontSize: 20),
                                    ),
                          ),
                          SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () => context.go('/login'),
                                child: Text(
                                  "Back to Login",
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
