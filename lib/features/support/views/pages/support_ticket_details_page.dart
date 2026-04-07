import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/features/support/providers/support_provider.dart';
import 'package:app/features/support/data/models/support_model.dart';
import 'package:intl/intl.dart';

class SupportTicketDetailsPage extends StatefulWidget {
  final SupportTicket ticket;
  const SupportTicketDetailsPage({super.key, required this.ticket});

  @override
  State<SupportTicketDetailsPage> createState() => _SupportTicketDetailsPageState();
}

class _SupportTicketDetailsPageState extends State<SupportTicketDetailsPage> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchMessages();
    });
  }

  Future<void> _fetchMessages() async {
    final auth = context.read<AuthProvider>();
    await context.read<SupportProvider>().fetchMessages(auth.authToken ?? "", widget.ticket.id);
  }

  Future<void> _handleSend() async {
    if (_msgController.text.trim().isEmpty) return;

    setState(() => _isSending = true);
    try {
      final auth = context.read<AuthProvider>();
      final res = await context.read<SupportProvider>().sendMessage(
        auth.authToken ?? "",
        widget.ticket.id,
        _msgController.text.trim(),
      );

      if (!mounted) return;

      if (res['success'] == true) {
        _msgController.clear();
        _scrollToBottom();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? "Failed to send message")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final supportProvider = context.watch<SupportProvider>();
    final messages = supportProvider.getMessages(widget.ticket.id);
    final isClosed = widget.ticket.status == 'closed';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.ticket.subject,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              "Ticket #${widget.ticket.id} • ${widget.ticket.status.toUpperCase()}",
              style: TextStyle(fontSize: 11, color: isClosed ? Colors.grey : Colors.green[200]),
            ),
          ],
        ),
        actions: [
          if (!isClosed)
            PopupMenuButton<String>(
              onSelected: (v) async {
                if (v == 'close') {
                  final auth = context.read<AuthProvider>();
                  await supportProvider.closeTicket(auth.authToken ?? "", widget.ticket.id);
                  if (mounted) Navigator.pop(context);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'close', child: Text("Close Ticket", style: TextStyle(color: Colors.red))),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: supportProvider.isLoading && messages.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : messages.isEmpty
                    ? const Center(child: Text("No messages yet."))
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          final isMe = msg.sender == 'user';
                          return _buildMessageBubble(msg, isMe, theme);
                        },
                      ),
          ),
          if (!isClosed) _buildInputArea(theme) else _buildClosedBanner(theme),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(SupportMessage msg, bool isMe, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            decoration: BoxDecoration(
              color: isMe ? theme.colorScheme.primary : theme.cardColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMe ? 16 : 0),
                bottomRight: Radius.circular(isMe ? 0 : 16),
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
              ],
            ),
            child: Text(
              msg.text,
              style: TextStyle(
                color: isMe ? Colors.white : theme.textTheme.bodyLarge?.color,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('HH:mm').format(msg.createdAt),
            style: TextStyle(fontSize: 10, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, bottom: MediaQuery.of(context).padding.bottom + 16, top: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _msgController,
              maxLines: null,
              decoration: InputDecoration(
                hintText: "Type a message...",
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey[500]),
                filled: true,
                fillColor: isDark ? theme.colorScheme.surface : Colors.grey[50],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: theme.colorScheme.primary,
            child: IconButton(
              icon: _isSending ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.send, color: Colors.white, size: 18),
              onPressed: _isSending ? null : _handleSend,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClosedBanner(ThemeData theme) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 16, top: 16),
      width: double.infinity,
      color: theme.cardColor,
      child: Center(
        child: Text(
          "This ticket has been closed.",
          style: TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic),
        ),
      ),
    );
  }
}
