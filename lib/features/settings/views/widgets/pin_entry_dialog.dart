import 'package:app/core/widgets/otp_input.dart';
import 'package:flutter/material.dart';

class PinEntryDialog extends StatefulWidget {
  final String title;
  final String description;

  const PinEntryDialog({
    super.key,
    this.title = "Transaction PIN",
    this.description = "Enter your 4-digit transaction PIN to continue.",
  });

  @override
  State<PinEntryDialog> createState() => _PinEntryDialogState();
}

class _PinEntryDialogState extends State<PinEntryDialog> {
  final TextEditingController _pinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: theme.cardColor,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(widget.description, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 24),
          OtpInput(
            controller: _pinController,
            length: 4,
            onCompleted: (pin) {
              Navigator.pop(context, pin);
            },
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  if (_pinController.text.length == 4) {
                    Navigator.pop(context, _pinController.text);
                  }
                },
                child: const Text("Confirm"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
