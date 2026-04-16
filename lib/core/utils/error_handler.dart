class ErrorHandler {
  /// Converts a technical error/exception into a human-friendly message.
  static String getFriendlyMessage(dynamic error) {
    if (error == null) return "An unexpected error occurred. Please try again.";
    
    final String raw = error.toString();
    final String lowerRaw = raw.toLowerCase();
    
    // 1. Handle Network/Connectivity Issues
    if (lowerRaw.contains('socketexception') || 
        lowerRaw.contains('network_error') || 
        lowerRaw.contains('connection failed') ||
        lowerRaw.contains('failed host lookup') ||
        lowerRaw.contains('timeout')) {
      return "Connection problem. Please check your internet and try again.";
    }

    // 2. Handle Authentication/Session Issues
    if (lowerRaw.contains('401') || 
        lowerRaw.contains('unauthorized') || 
        lowerRaw.contains('unauthenticated') ||
        lowerRaw.contains('token expired')) {
      return "Your session has expired. Please log in again to continue.";
    }

    // 3. Handle Common Business Logic Errors (if technical phrasing is caught)
    if (lowerRaw.contains('insufficient balance') || lowerRaw.contains('low balance')) {
      return "You do not have enough funds to complete this transaction.";
    }

    if (lowerRaw.contains('invalid pin')) {
      return "The PIN you entered is incorrect. Please try again.";
    }
    
    if (lowerRaw.contains('user not found')) {
      return "We couldn't find an account matching those details.";
    }

    // 4. Handle generic "Exception: ..." strings from standard error throwing
    if (raw.contains('Exception:')) {
      return raw.split('Exception:').last.trim();
    }

    // 5. If it's a short, non-technical message, return it as is but cleaned
    if (raw.length < 60 && !raw.contains('{') && !raw.contains('[') && !raw.contains('Stacktrace')) {
       // Clean up technical prefixes like "Exception: " or "Error: "
       return raw.replaceAll(RegExp(r'^(Exception|Error|GenericException):\s*', caseSensitive: false), '').trim();
    }

    // 6. Fallback for completely technical or unknown messagess
    return "Something went wrong on our end. Please try again in a moment.";
  }
}
