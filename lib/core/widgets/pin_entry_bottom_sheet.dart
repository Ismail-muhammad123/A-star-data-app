import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:app/features/settings/providers/profile_provider.dart';
import 'package:go_router/go_router.dart';

class PinEntryBottomSheet extends StatefulWidget {
  final String title;
  final String subtitle;
  final int pinLength;
  final Function(String) onPinEntered;

  const PinEntryBottomSheet({
    super.key,
    this.title = "Verify Transaction PIN",
    this.subtitle = "Enter your 4-digit transaction PIN to continue",
    this.pinLength = 4,
    required this.onPinEntered,
  });

  @override
  State<PinEntryBottomSheet> createState() => _PinEntryBottomSheetState();
}

class _PinEntryBottomSheetState extends State<PinEntryBottomSheet> {
  String _pin = "";

  void _onKeyTap(String key) {
    if (_pin.length < widget.pinLength) {
      HapticFeedback.lightImpact();
      setState(() {
        _pin += key;
      });
      if (_pin.length == widget.pinLength) {
        Future.delayed(const Duration(milliseconds: 200), () {
          widget.onPinEntered(_pin);
          Navigator.pop(context, _pin);
        });
      }
    }
  }

  void _onBackspace() {
    if (_pin.isNotEmpty) {
      HapticFeedback.lightImpact();
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final profile = context.watch<ProfileProvider>().profile;
    final hasTransactionPin =
        profile?.hasTransactionPin ??
        true; // assume true if profile not yet loaded, though unlikely

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          if (!hasTransactionPin) ...[
            Icon(
              Icons.lock_outline,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              "Transaction PIN Required",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.headlineSmall?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "You have not set up a transaction PIN yet. Please set one up to continue.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.push('/profile/transaction-pin/set');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Set Up PIN",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ] else ...[
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.headlineSmall?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.pinLength, (index) {
                bool isFilled = index < _pin.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        isFilled
                            ? theme.colorScheme.primary
                            : (isDark ? Colors.grey[800] : Colors.grey[300]),
                    border: Border.all(
                      color:
                          isFilled
                              ? theme.colorScheme.primary
                              : (isDark
                                  ? Colors.grey[700]!
                                  : Colors.grey[400]!),
                      width: 1,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 40),
            _buildKeypad(theme),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildKeypad(ThemeData theme) {
    return Column(
      children: [
        Row(children: [_buildKey("1"), _buildKey("2"), _buildKey("3")]),
        Row(children: [_buildKey("4"), _buildKey("5"), _buildKey("6")]),
        Row(children: [_buildKey("7"), _buildKey("8"), _buildKey("9")]),
        Row(
          children: [
            const Expanded(child: SizedBox.shrink()),
            _buildKey("0"),
            Expanded(
              child: InkWell(
                onTap: _onBackspace,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 70,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.backspace_outlined,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKey(String label) {
    final theme = Theme.of(context);
    return Expanded(
      child: InkWell(
        onTap: () => _onKeyTap(label),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 70,
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
        ),
      ),
    );
  }
}

Future<String?> showPinEntrySheet(
  BuildContext context, {
  String title = "Verify Transaction PIN",
  String subtitle = "Enter your 4-digit transaction PIN to continue",
  int pinLength = 4,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder:
        (context) => PinEntryBottomSheet(
          title: title,
          subtitle: subtitle,
          pinLength: pinLength,
          onPinEntered: (pin) {},
        ),
  );
}
