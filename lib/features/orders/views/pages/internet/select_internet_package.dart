import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/features/orders/data/models.dart';
import 'package:app/features/orders/data/services.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SelectInternetPackagePage extends StatefulWidget {
  final InternetService provider;
  const SelectInternetPackagePage({super.key, required this.provider});

  @override
  State<SelectInternetPackagePage> createState() =>
      _SelectInternetPackagePageState();
}

class _SelectInternetPackagePageState extends State<SelectInternetPackagePage> {
  String _selectedSmileFilter = "Smile Voice";

  @override
  Widget build(BuildContext context) {
    bool isSmile =
        widget.provider.serviceName.toLowerCase().contains("smile") ||
        widget.provider.serviceId.toLowerCase().contains("smile");
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Select Package',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Available packages for ${widget.provider.serviceName}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isSmile) ...[
                  const SizedBox(height: 16),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children:
                            ["Smile Voice", "Smile Data"].map((filter) {
                              bool isSelected = _selectedSmileFilter == filter;
                              return GestureDetector(
                                onTap:
                                    () => setState(
                                      () => _selectedSmileFilter = filter,
                                    ),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        isSelected
                                            ? Colors.blueAccent
                                            : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow:
                                        isSelected
                                            ? [
                                              BoxShadow(
                                                color: Colors.blueAccent
                                                    .withOpacity(0.3),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                            : null,
                                  ),
                                  child: Text(
                                    filter,
                                    style: TextStyle(
                                      color:
                                          isSelected
                                              ? Colors.white
                                              : Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<InternetPackage>>(
              future: OrderServices().fetchInternetPackages(
                context.read<AuthProvider>().authToken ?? "",
                widget.provider.id,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No packages found.'));
                } else {
                  var packages = snapshot.data!;

                  if (isSmile) {
                    if (_selectedSmileFilter == "Smile Voice") {
                      packages =
                          packages
                              .where(
                                (p) =>
                                    p.name.toLowerCase().contains("smilevoice"),
                              )
                              .toList();
                    } else {
                      packages =
                          packages
                              .where(
                                (p) =>
                                    !p.name.toLowerCase().contains(
                                      "smilevoice",
                                    ),
                              )
                              .toList();
                    }
                  }

                  if (packages.isEmpty) {
                    return const Center(
                      child: Text('No packages in this category.'),
                    );
                  }

                  return ListView.builder(
                    itemCount: packages.length,
                    itemBuilder: (context, index) {
                      final package = packages[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.blueAccent.withOpacity(0.1),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child:
                                (package.service.image ?? "").isNotEmpty
                                    ? Image.network(
                                      package.service.image!,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(Icons.router_outlined),
                                    )
                                    : const Icon(Icons.router_outlined),
                          ),
                          title: Text(
                            package.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            package.service.serviceName,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                NumberFormat.currency(
                                  symbol: '₦',
                                  decimalDigits: 0,
                                ).format(package.sellingPrice),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            context.push(
                              "/orders/buy-internet",
                              extra: package,
                            );
                          },
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
