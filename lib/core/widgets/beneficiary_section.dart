import 'package:app/core/utils/error_handler.dart';
import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/features/orders/data/services.dart';
import 'package:app/features/wallet/data/repositories/wallet_repo.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum BeneficiaryType { purchase, transfer }

class BeneficiaryDisplayModel {
  final int id;
  final String identifier;
  final String name;
  final String subtitle;

  BeneficiaryDisplayModel({
    required this.id,
    required this.identifier,
    required this.name,
    this.subtitle = '',
  });
}

class BeneficiarySection extends StatefulWidget {
  final List<BeneficiaryDisplayModel> initialBeneficiaries;
  final String selectedIdentifier;
  final Function(BeneficiaryDisplayModel) onSelect;
  final BeneficiaryType type;

  const BeneficiarySection({
    super.key,
    required this.initialBeneficiaries,
    required this.selectedIdentifier,
    required this.onSelect,
    required this.type,
  });

  @override
  State<BeneficiarySection> createState() => _BeneficiarySectionState();
}

class _BeneficiarySectionState extends State<BeneficiarySection> {
  late List<BeneficiaryDisplayModel> _beneficiaries;

  @override
  void initState() {
    super.initState();
    _beneficiaries = List.from(widget.initialBeneficiaries);
  }

  @override
  void didUpdateWidget(covariant BeneficiarySection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialBeneficiaries != widget.initialBeneficiaries) {
      _beneficiaries = List.from(widget.initialBeneficiaries);
    }
  }

  void _onDelete(BeneficiaryDisplayModel ben) async {
    try {
      final token = context.read<AuthProvider>().authToken;
      if (token == null) return;

      if (widget.type == BeneficiaryType.purchase) {
        await OrderServices().deletePurchaseBeneficiary(token, ben.id);
      } else {
        await WalletService().deleteTransferBeneficiary(token, ben.id);
      }

      setState(() {
        _beneficiaries.removeWhere((b) => b.id == ben.id);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Beneficiary deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ErrorHandler.getFriendlyMessage(e))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_beneficiaries.isEmpty) return const SizedBox.shrink();

    final showViewAll = _beneficiaries.length > 4;
    final displayList =
        showViewAll ? _beneficiaries.take(4).toList() : _beneficiaries;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Saved Beneficiaries",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Theme.of(
                  context,
                ).textTheme.bodyLarge?.color?.withOpacity(0.7),
              ),
            ),
            if (showViewAll)
              TextButton(
                onPressed: () => _showAllBeneficiaries(context),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(50, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  "View All",
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: widget.type == BeneficiaryType.transfer ? 85 : 70,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: displayList.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final ben = displayList[index];
              final isSelected = widget.selectedIdentifier == ben.identifier;

              return GestureDetector(
                onTap: () => widget.onSelect(ben),
                child: Container(
                  width: 130,
                  padding: const EdgeInsets.all(12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          isSelected ? Colors.blueAccent : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.type == BeneficiaryType.transfer) ...[
                        Text(
                          ben.name, // Bank Name
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          ben.identifier, // Account Number
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ] else ...[
                        Text(
                          ben.identifier, // Phone Number
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAllBeneficiaries(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => BeneficiaryListSheet(
            beneficiaries: _beneficiaries,
            onSelect: widget.onSelect,
            onDelete: _onDelete,
            type: widget.type,
          ),
    );
  }
}

class BeneficiarySuggestions extends StatelessWidget {
  final List<BeneficiaryDisplayModel> beneficiaries;
  final String query;
  final Function(BeneficiaryDisplayModel) onSelect;

  const BeneficiarySuggestions({
    super.key,
    required this.beneficiaries,
    required this.query,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) return const SizedBox.shrink();

    // Auto-hide when number is complete or matches exactly
    final String q = query.toLowerCase();
    if (q.length >= 10) {
      final exactMatch = beneficiaries.any(
        (b) => b.identifier.toLowerCase() == q,
      );
      if (exactMatch || q.length == 11) {
        return const SizedBox.shrink();
      }
    }

    final filtered =
        beneficiaries.where((b) {
          return b.name.toLowerCase().contains(q) || b.identifier.contains(q);
        }).toList();

    if (filtered.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: filtered.length > 3 ? 3 : filtered.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final ben = filtered[index];
          return ListTile(
            onTap: () => onSelect(ben),
            leading: const CircleAvatar(
              radius: 14,
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.person, size: 14, color: Colors.white),
            ),
            title: Text(
              ben.name,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              ben.identifier,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }
}

class BeneficiaryListSheet extends StatefulWidget {
  final List<BeneficiaryDisplayModel> beneficiaries;
  final Function(BeneficiaryDisplayModel) onSelect;
  final Function(BeneficiaryDisplayModel) onDelete;
  final BeneficiaryType type;

  const BeneficiaryListSheet({
    super.key,
    required this.beneficiaries,
    required this.onSelect,
    required this.onDelete,
    required this.type,
  });

  @override
  State<BeneficiaryListSheet> createState() => _BeneficiaryListSheetState();
}

class _BeneficiaryListSheetState extends State<BeneficiaryListSheet> {
  late List<BeneficiaryDisplayModel> _list;

  @override
  void initState() {
    super.initState();
    _list = List.from(widget.beneficiaries);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Text(
                  "Saved Beneficiaries",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _list.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final ben = _list[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  onTap: () {
                    widget.onSelect(ben);
                    Navigator.pop(context);
                  },
                  leading: const CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(
                    widget.type == BeneficiaryType.transfer
                        ? "${ben.name} (${ben.identifier})"
                        : ben.identifier,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  subtitle:
                      widget.type == BeneficiaryType.transfer
                          ? null
                          : Text(
                            ben.name,
                            style: const TextStyle(fontSize: 11),
                          ), // Show nickname in list for clarity
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                    ),
                    onPressed: () => _confirmDelete(context, ben),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, BeneficiaryDisplayModel ben) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Delete Beneficiary?"),
            content: Text(
              "Are you sure you want to remove ${widget.type == BeneficiaryType.transfer ? ben.identifier : ben.name} from your saved beneficiaries?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  widget.onDelete(ben);
                  setState(() {
                    _list.removeWhere((b) => b.id == ben.id);
                  });
                  Navigator.pop(context);
                },
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          ),
    );
  }
}
