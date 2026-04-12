class NotificationChannels {
  static const String generalId = 'general';
  static const String transactionId = 'transactions';
  static const String supportId = 'support';
  static const String walletId = 'wallet';

  static const String generalName = 'General Notifications';
  static const String transactionName = 'Transactions';
  static const String supportName = 'Support Tickets';
  static const String walletName = 'Wallet Activities';

  /// Maps the server-sent `channel` field to a GoRouter path.
  static String? routeForChannel(String? channel, {String? extraId}) {
    switch (channel) {
      case 'transaction':
      case 'order':
        return extraId != null
            ? '/orders/history/$extraId'
            : '/orders/history';
      case 'wallet':
        return extraId != null
            ? '/wallet/history/$extraId'
            : '/wallet';
      case 'support':
        // SupportTicket object needed for details page, for now route to list
        return '/support';
      case 'notification':
      case 'general':
      default:
        return '/notifications';
    }
  }

  static String channelIdForChannel(String? channel) {
    switch (channel) {
      case 'transaction':
      case 'order':
        return transactionId;
      case 'wallet':
        return walletId;
      case 'support':
        return supportId;
      default:
        return generalId;
    }
  }
}
