import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/features/support/providers/support_provider.dart';
import 'package:intl/intl.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      context.read<SupportProvider>().fetchTickets(auth.authToken ?? "");
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final supportProvider = context.watch<SupportProvider>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Help & Support",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final auth = context.read<AuthProvider>();
          await supportProvider.fetchTickets(auth.authToken ?? "");
        },
        child: supportProvider.isLoading && supportProvider.tickets.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : supportProvider.tickets.isEmpty
                ? _buildEmptyState(context)
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: supportProvider.tickets.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final ticket = supportProvider.tickets[index];
                      return _buildTicketTile(context, ticket);
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/support/create'),
        label: const Text("New Ticket"),
        icon: const Icon(Icons.add),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Center(
          child: Column(
            children: [
              Icon(Icons.support_agent_rounded, size: 80, color: Colors.grey[300]),
              const SizedBox(height: 16),
              const Text(
                "No Support Tickets",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "Need help? Create a ticket and we'll assist you.",
                style: TextStyle(color: Colors.grey[400]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTicketTile(BuildContext context, dynamic ticket) {
    final theme = Theme.of(context);
    final isClosed = ticket.status == 'closed';

    return InkWell(
      onTap: () => context.push('/support/ticket/${ticket.id}', extra: ticket),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isClosed ? Colors.grey[100] : theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isClosed ? Icons.lock_outline : Icons.chat_bubble_outline,
                color: isClosed ? Colors.grey : theme.colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ticket.subject,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Last updated: ${DateFormat('MMM dd, yyyy • HH:mm').format(ticket.updatedAt)}",
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isClosed ? Colors.grey[200] : Colors.green[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                ticket.status.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isClosed ? Colors.grey[700] : Colors.green[800],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
