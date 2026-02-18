// dashboard_page.dart
import 'package:app/features/orders/views/pages/orders_tab.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/features/settings/providers/profile_provider.dart';
import 'package:app/features/settings/views/pages/settings_page.dart';
import 'package:app/features/wallet/views/pages/wallet.dart';

class HomePage extends StatefulWidget {
  final int index;
  const HomePage({super.key, this.index = 0});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int currentPage = 0;
  List<Widget> pages = [OrdersTab(), WalletPage(), SettingsPage()];

  _bootstrap() async {
    await Provider.of<ProfileProvider>(
      context,
      listen: false,
    ).loadProfile(context.read<AuthProvider>().authToken ?? '');
  }

  @override
  void initState() {
    currentPage = widget.index;
    _bootstrap();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent.shade100,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentPage,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go("/home");
              break;
            case 1:
              context.go("/wallet");
              break;
            case 2:
              context.go("/profile");
              break;
            default:
              context.go("/home");
          }
        },
        backgroundColor: Colors.white,
        indicatorColor: Colors.blue.withOpacity(0.1),
        indicatorShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        labelTextStyle: WidgetStateProperty.all(
          TextStyle(color: Colors.black, fontSize: 14),
        ),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: Icon(
              Icons.dashboard_outlined,
              color: currentPage == 0 ? Colors.blue : Colors.black54,
            ),
            selectedIcon: const Icon(Icons.dashboard, color: Colors.blue),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.account_balance_wallet_outlined,
              color: currentPage == 1 ? Colors.blue : Colors.black54,
            ),
            selectedIcon: const Icon(
              Icons.account_balance_wallet,
              color: Colors.blue,
            ),
            label: 'Wallet',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.settings_outlined,
              color: currentPage == 2 ? Colors.blue : Colors.black54,
            ),
            selectedIcon: const Icon(Icons.settings, color: Colors.blue),
            label: 'Settings',
          ),
        ],
      ),
      body: SafeArea(child: pages[currentPage]),
    );
  }
}
