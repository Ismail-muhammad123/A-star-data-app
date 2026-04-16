import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ContactHelper {
  static bool get isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  static Future<String?> pickPhoneNumber() async {
    if (!isMobile) return null;

    try {
      if (await FlutterContacts.requestPermission(readonly: true)) {
        final contact = await FlutterContacts.openExternalPick();
        if (contact != null && contact.phones.isNotEmpty) {
          // Strip non-digits except maybe a leading plus
          String phone = contact.phones.first.number;

          // Clean the number
          phone = phone.replaceAll(RegExp(r'[^\d+]'), '');

          // Handle Nigerian format if necessary
          // Nigerian mobile numbers: +234 + 10 digits (14 chars) or 234 + 10 digits (13 chars)
          if (phone.startsWith('+234') && phone.length == 14) {
            phone = '0${phone.substring(4)}';
          } else if (phone.startsWith('234') && phone.length == 13) {
            phone = '0${phone.substring(3)}';
          } else if (phone.startsWith('+')) {
            // Remove leading plus for other international numbers if desired,
            // but usually we want to keep it. For this app, only digits are usually needed.
            phone = phone.replaceAll('+', '');
          }

          return phone;
        }
      }
    } catch (e) {
      debugPrint('Error picking contact: $e');
    }
    return null;
  }
}
