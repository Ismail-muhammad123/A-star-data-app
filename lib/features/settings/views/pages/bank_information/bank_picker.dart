import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/features/settings/data/repositories/profile_repo.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BankPicker extends StatefulWidget {
  const BankPicker({super.key});

  @override
  State<BankPicker> createState() => _BankPickerState();
}

class _BankPickerState extends State<BankPicker> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: BackButton(
          color: Colors.white,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Select Bank',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        backgroundColor: Colors.blueAccent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              onChanged:
                  (value) => setState(() => _searchQuery = value.toLowerCase()),
              decoration: InputDecoration(
                hintText: "Search bank...",
                prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),

      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: ProfileService().fetchNigerianBanks(
          context.read<AuthProvider>().authToken ?? "",
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No banks available'));
          } else {
            final banks =
                snapshot.data!.where((bank) {
                  final name = (bank['name'] ?? '').toString().toLowerCase();
                  return name.contains(_searchQuery);
                }).toList();

            if (banks.isEmpty) {
              return const Center(child: Text('No banks match your search'));
            }

            return ListView.separated(
              itemCount: banks.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                var bank = banks[index]['name'] ?? 'Unknown Bank';
                return ListTile(
                  title: Text(
                    bank,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () {
                    Navigator.pop(context, bank);
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
