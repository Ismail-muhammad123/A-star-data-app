import 'package:app/features/auth/data/repository/auth_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class ConfirmPinReset extends StatefulWidget {
  const ConfirmPinReset({super.key, required this.phoneNumber});
  final String phoneNumber;

  @override
  State<ConfirmPinReset> createState() => _ConfirmPinResetState();
}

class _ConfirmPinResetState extends State<ConfirmPinReset> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _newPinController = TextEditingController();
  DateTime? _lastResend;
  bool _isLoading = false;
  bool _hideText = true;

  _changePin() async {
    try {
      setState(() {
        _isLoading = true;
      });
      var phone = _phoneNumberController.text.trim();
      if (phone.startsWith("0")) {
        phone = _phoneNumberController.text.substring(1);
      }
      await AuthService().confirmPinReset(
        _codeController.text.trim(),
        _newPinController.text.trim(),
        phone,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text("Password Changed Successfully! Please Login"),
        ),
      );
      context.go('/login');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to Reset password! ${e.toString()}")),
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
  void initState() {
    _phoneNumberController.text = widget.phoneNumber;
    super.initState();
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    _codeController.dispose();
    _newPinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Set New Password", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.lightBlue,
        leading: BackButton(
          color: Colors.white,
          onPressed:
              () => context.canPop() ? context.pop() : context.go("/reset-pin"),
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
                  "A one time code has been sent to your whatsApp and SMS. Please check your Inbox and use the OTP you recieved to set a new password.",
                  textAlign: TextAlign.center,
                ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                enabled: false,
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
                obscureText: true,
                enabled: !_isLoading,
                controller: _codeController,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  label: Text("OTP Code"),
                  prefixIcon: Icon(Icons.password),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                enabled: !_isLoading,
                obscureText: _hideText,
                controller: _newPinController,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                obscuringCharacter: "*",
                decoration: InputDecoration(
                  suffix: GestureDetector(
                    onTap: () => setState(() => _hideText = !_hideText),
                    child: Icon(
                      _hideText ? Icons.visibility : Icons.visibility_off,
                    ),
                  ),
                  label: Text("New Pin"),
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: MaterialButton(
                height: 40,
                minWidth: 200,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.lightBlueAccent,
                onPressed: () => _isLoading ? null : _changePin(),
                child: Text("Submit"),
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
                            await AuthService().resetPin(widget.phoneNumber);
                            setState(() {
                              _lastResend = DateTime.now();
                              _isLoading = false;
                            });
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Failed to resent Pin reset OTP! Please try again later.",
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
