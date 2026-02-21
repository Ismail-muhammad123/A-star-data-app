import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/features/orders/data/models.dart';
import 'package:app/features/orders/data/services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SelectBundlePage extends StatefulWidget {
  final int networkId;

  const SelectBundlePage({super.key, required this.networkId});

  @override
  State<SelectBundlePage> createState() => _SelectBundlePageState();
}

class _SelectBundlePageState extends State<SelectBundlePage> {
  late Future<List<DataBundle>> _bundlesFuture;
  List<DataBundle> _allBundles = [];
  List<DataBundle> _filteredBundles = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _bundlesFuture = OrderServices().fetchDataBundles(
      context.read<AuthProvider>().authToken ?? "",
    );
    _bundlesFuture.then((bundles) {
      print(bundles.length);
      setState(() {
        _allBundles =
            bundles.where((b) => b.service.id == widget.networkId).toList()
              ..sort((a, b) => a.sellingPrice.compareTo(b.sellingPrice));
        _filteredBundles =
            bundles
                .where((b) => b.service.id == widget.networkId)
                .where(
                  (bundle) =>
                      (!bundle.name.toLowerCase().contains('smile') &&
                          !bundle.variationId.toLowerCase().contains(
                            'smile',
                          )) ||
                      (bundle.name.toLowerCase().contains('smile') &&
                          !bundle.name.toLowerCase().contains('voice')),
                )
                .toList()
              ..sort((a, b) => a.sellingPrice.compareTo(b.sellingPrice));
      });
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchController.text = query;
      _filteredBundles =
          _allBundles
              .where(
                (bundle) =>
                    bundle.name.toLowerCase().contains(query.toLowerCase()),
              )
              .toList()
            ..sort((a, b) => a.sellingPrice.compareTo(b.sellingPrice));
    });
  }

  void _onBundleSelected(DataBundle bundle) {
    Navigator.of(context).pop(bundle);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Select Data Plan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: FutureBuilder<List<DataBundle>>(
        future: _bundlesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Failed to load data plans'));
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search bundles...',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Colors.blueAccent,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onChanged: _onSearchChanged,
                ),
              ),
              Expanded(
                child:
                    _filteredBundles.isEmpty
                        ? const Center(child: Text('No bundles found'))
                        : ListView.builder(
                          itemCount: _filteredBundles.length,
                          itemBuilder: (context, index) {
                            final bundle = _filteredBundles[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                                horizontal: 2,
                              ),
                              child: Card(
                                color: Theme.of(context).cardColor,
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.blueAccent
                                        .withOpacity(0.1),
                                    radius: 20,
                                    child: Image.network(
                                      bundle.service.imageUrl,
                                      fit: BoxFit.contain,
                                      webHtmlElementStrategy:
                                          WebHtmlElementStrategy.prefer,
                                    ),
                                  ),
                                  title: Text(
                                    bundle.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          Theme.of(
                                            context,
                                          ).textTheme.bodyLarge?.color,
                                    ),
                                  ),
                                  subtitle: Text(
                                    bundle.service.serviceName,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color
                                          ?.withOpacity(0.7),
                                    ),
                                  ),
                                  trailing: Text(
                                    NumberFormat.currency(
                                      symbol: '₦',
                                      decimalDigits: 0,
                                    ).format(bundle.sellingPrice),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                  onTap: () => _onBundleSelected(bundle),
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ],
          );
        },
      ),
    );
  }
}
