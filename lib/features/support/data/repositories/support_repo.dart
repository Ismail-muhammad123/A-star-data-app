import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:app/core/constants/api_endpoints.dart';
import 'package:app/features/support/data/models/support_model.dart';

class SupportService {
  final Dio _dio = Dio();
  final SupportEndpoints endpoints = SupportEndpoints();

  Future<List<SupportTicket>> fetchTickets(String authToken) async {
    final response = await _dio.get(
      endpoints.support,
      options: Options(
        validateStatus: (status) => true,
        headers: {'Authorization': 'Bearer $authToken'},
      ),
    );
    if (response.statusCode == 200) {
      return (response.data as List)
          .map((json) => SupportTicket.fromJson(json))
          .toList();
    } else {
      throw Exception(response.data['detail'] ?? 'Failed to fetch tickets');
    }
  }

  Future<SupportTicket> createTicket(
    String authToken,
    String subject,
    String message,
    String description,
    String category,
  ) async {
    final response = await _dio.post(
      endpoints.support,
      data: jsonEncode({
        "subject": subject,
        "description": description,
        "category": category,
        "related_reference": "string",
      }),
      options: Options(
        validateStatus: (status) => true,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ),
    );
    print(response.data);
    if (response.statusCode == 201) {
      return SupportTicket.fromJson(response.data);
    } else {
      throw Exception(response.data['detail'] ?? 'Failed to create ticket');
    }
  }

  Future<List<SupportMessage>> fetchMessages(
    String authToken,
    int ticketId,
  ) async {
    final response = await _dio.get(
      "${endpoints.support}$ticketId",
      options: Options(
        validateStatus: (status) => true,
        headers: {'Authorization': 'Bearer $authToken'},
      ),
    );
    print(response.data['messages']);
    if (response.statusCode == 200) {
      return (response.data["messages"] as List)
          .map((json) => SupportMessage.fromJson(json))
          .toList();
    } else {
      throw Exception(response.data['detail'] ?? 'Failed to fetch messages');
    }
  }

  Future<SupportMessage> sendMessage(
    String authToken,
    int ticketId,
    String text,
  ) async {
    final response = await _dio.post(
      endpoints.messages(ticketId),
      data: jsonEncode({'message': text}),
      options: Options(
        validateStatus: (status) => true,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ),
    );
    if (response.statusCode == 201) {
      return SupportMessage.fromJson(response.data);
    } else {
      throw Exception(response.data['detail'] ?? 'Failed to send message');
    }
  }

  Future<void> closeTicket(String authToken, int ticketId) async {
    final response = await _dio.post(
      endpoints.closeTicket(ticketId),
      options: Options(
        validateStatus: (status) => true,
        headers: {'Authorization': 'Bearer $authToken'},
      ),
    );
    if (response.statusCode != 200) {
      throw Exception(response.data['detail'] ?? 'Failed to close ticket');
    }
  }
}
