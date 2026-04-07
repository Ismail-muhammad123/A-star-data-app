import 'package:flutter/foundation.dart';
import 'package:app/features/support/data/models/support_model.dart';
import 'package:app/features/support/data/repositories/support_repo.dart';

class SupportProvider extends ChangeNotifier {
  final SupportService _supportService = SupportService();
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<SupportTicket> _tickets = [];
  List<SupportTicket> get tickets => _tickets;

  Map<int, List<SupportMessage>> _ticketMessages = {};
  List<SupportMessage> getMessages(int ticketId) => _ticketMessages[ticketId] ?? [];

  Future<void> fetchTickets(String authToken) async {
    _isLoading = true;
    notifyListeners();
    try {
      _tickets = await _supportService.fetchTickets(authToken);
    } catch (e) {
      debugPrint("Support: Error fetching tickets: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> createTicket(String authToken, String subject, String message) async {
    _isLoading = true;
    notifyListeners();
    try {
      final ticket = await _supportService.createTicket(authToken, subject, message);
      _tickets.insert(0, ticket);
      return {'success': true, 'ticketId': ticket.id};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMessages(String authToken, int ticketId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final messages = await _supportService.fetchMessages(authToken, ticketId);
      _ticketMessages[ticketId] = messages;
    } catch (e) {
      debugPrint("Support: Error fetching messages for ticket $ticketId: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> sendMessage(String authToken, int ticketId, String text) async {
    try {
      final msg = await _supportService.sendMessage(authToken, ticketId, text);
      if (_ticketMessages[ticketId] == null) {
        _ticketMessages[ticketId] = [];
      }
      _ticketMessages[ticketId]!.add(msg);
      notifyListeners();
      return {'success': true};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<void> closeTicket(String authToken, int ticketId) async {
    try {
      await _supportService.closeTicket(authToken, ticketId);
      // Update ticket status locally
      var idx = _tickets.indexWhere((t) => t.id == ticketId);
      if (idx != -1) {
        var old = _tickets[idx];
        _tickets[idx] = SupportTicket(
          id: old.id,
          subject: old.subject,
          status: 'closed',
          createdAt: old.createdAt,
          updatedAt: DateTime.now(),
        );
      }
      notifyListeners();
    } catch (e) {
       debugPrint("Support: Error closing ticket: $e");
    }
  }
}
