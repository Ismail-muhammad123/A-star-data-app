import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/features/orders/data/models.dart';
import 'package:app/features/orders/data/services.dart';
import 'package:flutter/material.dart';
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
            bundles.where((b) => b.serviceType == widget.networkId).toList()
              ..sort((a, b) => a.sellingPrice.compareTo(b.sellingPrice));
        _filteredBundles =
            bundles
                .where((b) => b.serviceType == widget.networkId)
                .where(
                  (bundle) =>
                      (!bundle.name.toLowerCase().contains('smile') &&
                          !bundle.variationCode.toLowerCase().contains(
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
                    bundle.name.toLowerCase().contains(query.toLowerCase()) ||
                    bundle.description.toLowerCase().contains(
                      query.toLowerCase(),
                    ),
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
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.lightBlue,
        surfaceTintColor: Colors.lightBlue,
      ),
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
                  decoration: const InputDecoration(
                    hintText: 'Search bundles...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
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
                                child: ListTile(
                                  tileColor: Colors.white,
                                  title: Text(bundle.name),
                                  subtitle: Text(bundle.description),
                                  trailing: Text(
                                    '₦${bundle.sellingPrice.toStringAsFixed(0)}',
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
