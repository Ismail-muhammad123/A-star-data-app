import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/features/orders/data/services.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class TvServiceProvidersListPage extends StatefulWidget {
  const TvServiceProvidersListPage({super.key});

  @override
  State<TvServiceProvidersListPage> createState() =>
      TvServiceProvidersListPageState();
}

class TvServiceProvidersListPageState
    extends State<TvServiceProvidersListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Select TV Service Provider',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        surfaceTintColor: Colors.blueAccent,
      ),
      body: FutureBuilder(
        future: OrderServices().fetchTVServices(
          context.read<AuthProvider>().authToken ?? "",
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('No available TV service providers found.'),
            );
          } else {
            final providers = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: providers.length,
                itemBuilder: (context, index) {
                  final provider = providers[index];
                  return Card(
                    color: Colors.white,
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        leading:
                            (provider.imageUrl ?? "").isNotEmpty
                                ? Image.network(
                                  provider.imageUrl!,
                                  webHtmlElementStrategy:
                                      WebHtmlElementStrategy.prefer,
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                          Icon(Icons.tv),
                                )
                                : Icon(Icons.tv),
                        title: Text(provider.serviceName),
                        onTap: () {
                          context.push(
                            "/orders/select-tv-plan",
                            extra: provider,
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
    );
  }
}
