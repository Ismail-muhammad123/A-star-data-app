import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/features/orders/data/models.dart';
import 'package:app/features/orders/data/services.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SelectTvPackagePage extends StatefulWidget {
  final CableTVService provider;
  const SelectTvPackagePage({super.key, required this.provider});

  @override
  State<SelectTvPackagePage> createState() => SelectTvPackagePageState();
}

class SelectTvPackagePageState extends State<SelectTvPackagePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Select TV Package', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        surfaceTintColor: Colors.blueAccent,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Select a package for ${widget.provider.serviceName}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: OrderServices().fetchTVPackages(
                context.read<AuthProvider>().authToken ?? "",
                widget.provider.serviceId,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No available TV packages found.'));
                } else {
                  final packages = snapshot.data!;
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                      itemCount: packages.length,
                      itemBuilder: (context, index) {
                        final package = packages[index];
                        return Card(
                          color: Colors.white,
                          elevation: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              leading: Icon(Icons.electrical_services),
                              title: Text(package.name),
                              subtitle: Text(package.service.serviceName),
                              trailing: Text(
                                NumberFormat.currency(
                                  symbol: '₦',
                                  decimalDigits: 0,
                                ).format(package.sellingPrice),
                              ),

                              onTap: () {
                                context.push(
                                  "/orders/buy-tv-subscription",
                                  extra: package,
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
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
