import 'package:app/features/auth/data/repository/auth_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class AccountActivationPage extends StatefulWidget {
  const AccountActivationPage({super.key, this.phoneNumber});
  final String? phoneNumber;

  @override
  State<AccountActivationPage> createState() => _AccountActivationPageState();
}

class _AccountActivationPageState extends State<AccountActivationPage> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  DateTime? _lastResend;
  bool _isLoading = false;

  @override
  void initState() {
    _phoneNumberController.text = widget.phoneNumber ?? "";
    super.initState();
  }

  _activateAccount() async {
    try {
      setState(() {
        _isLoading = true;
      });
      await AuthService().activateAccount(
        _phoneNumberController.text.trim(),
        _codeController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Account Activated Successfully! Please Login"),
        ),
      );
      context.go('/login');
    } catch (e) {
      print(e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to activate account! ${e.toString()}")),
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
        title: Text(
          "Account Activation",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        leading: BackButton(
          color: Colors.white,
          onPressed: () => context.canPop() ? context.pop() : context.go("/"),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _isLoading
                ? SizedBox()
                : Text(
                  "A one time password has been sent to your whatsApp and SMS. Please check your Inbox and use the OTP you recieved to verify your account.",
                  textAlign: TextAlign.center,
                ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                enabled: !_isLoading,
                controller: _phoneNumberController,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  label: Text("Your Phone Number"),
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                enabled: !_isLoading,
                controller: _codeController,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                keyboardType: TextInputType.phone,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  label: Text("Pin"),
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: MaterialButton(
                onPressed: () => _isLoading ? null : _activateAccount(),
                height: 40,
                minWidth: double.maxFinite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text("Verify Account"),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child:
                  _isLoading
                      ? CircularProgressIndicator()
                      : (_lastResend
                              ?.add(Duration(seconds: 60))
                              .isBefore(DateTime.now()) ??
                          true) // Check if its been 5 seconds since last resend
                      ? ElevatedButton(
                        onPressed: () async {
                          try {
                            setState(() {
                              _isLoading = true;
                            });
                            await AuthService().requestConfirmationOTP(
                              _phoneNumberController.text.trim(),
                            );
                            setState(() {
                              _lastResend = DateTime.now();
                              _isLoading = false;
                            });
                          } catch (e) {
                            print(e);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Failed to resent account verification OTP! Please try again later.",
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
                        },
                        child: Text("resend"),
                      )
                      : Text("You can resend in 60s"),
            ),
          ],
        ),
      ),
    );
  }
}
