import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> showWhatsAppSupportBottomSheet(
  BuildContext context, {
  required String chatPhoneNumber,
  required String channelUrl,
  String chatMessage = "Hello, I need help with the A-Star Data app.",
}) async {
  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder:
        (sheetContext) => Container(
          decoration: BoxDecoration(
            color: Theme.of(sheetContext).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "WhatsApp Support",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "How would you like to reach us?",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 24),
              _SupportOptionTile(
                title: "Chat with Support",
                subtitle: "Directly chat with our agent",
                icon: FontAwesomeIcons.whatsapp,
                iconColor: Colors.green,
                onTap: () async {
                  Navigator.pop(sheetContext);
                  final sanitizedPhone = chatPhoneNumber.replaceAll('+', '');
                  final uri = Uri.parse(
                    "https://wa.me/$sanitizedPhone?text=${Uri.encodeComponent(chatMessage)}",
                  );
                  final launched = await launchUrl(
                    uri,
                    mode: LaunchMode.externalApplication,
                  );
                  if (!launched && context.mounted) {
                    _showNumberDialog(context, chatPhoneNumber);
                  }
                },
              ),
              const SizedBox(height: 12),
              _SupportOptionTile(
                title: "Support & Updates Channel",
                subtitle: "Join our channel for latest news",
                icon: Icons.campaign_rounded,
                iconColor: Colors.blue,
                onTap: () async {
                  Navigator.pop(sheetContext);
                  final uri = Uri.parse(channelUrl);
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
  );
}

void _showNumberDialog(BuildContext context, String phoneNumber) {
  showDialog(
    context: context,
    builder:
        (ctx) => AlertDialog(
          title: const Text("WhatsApp not available"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Unable to open WhatsApp. You can contact this number:"),
              const SizedBox(height: 10),
              SelectableText(
                phoneNumber,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: phoneNumber));
                if (!ctx.mounted) return;
                Navigator.of(ctx).pop();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Number copied to clipboard")),
                );
              },
              child: const Text("Copy Number"),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text("Close"),
            ),
          ],
        ),
  );
}

class _SupportOptionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _SupportOptionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child:
                  icon == FontAwesomeIcons.whatsapp
                      ? FaIcon(icon, color: iconColor, size: 24)
                      : Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
