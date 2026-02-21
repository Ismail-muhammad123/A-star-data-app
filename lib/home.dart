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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
        backgroundColor: Theme.of(context).colorScheme.surface,
        indicatorColor: Colors.blueAccent.withOpacity(0.1),
        indicatorShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            color:
                states.contains(WidgetState.selected)
                    ? Colors.blueAccent
                    : Theme.of(context).textTheme.bodyMedium?.color,
            fontSize: 14,
            fontWeight:
                states.contains(WidgetState.selected)
                    ? FontWeight.bold
                    : FontWeight.normal,
          ),
        ),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: Icon(
              Icons.dashboard_outlined,
              color:
                  currentPage == 0
                      ? Colors.blueAccent
                      : Theme.of(context).iconTheme.color?.withOpacity(0.6),
            ),
            selectedIcon: const Icon(Icons.dashboard, color: Colors.blueAccent),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.account_balance_wallet_outlined,
              color:
                  currentPage == 1
                      ? Colors.blueAccent
                      : Theme.of(context).iconTheme.color?.withOpacity(0.6),
            ),
            selectedIcon: const Icon(
              Icons.account_balance_wallet,
              color: Colors.blueAccent,
            ),
            label: 'Wallet',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.settings_outlined,
              color:
                  currentPage == 2
                      ? Colors.blueAccent
                      : Theme.of(context).iconTheme.color?.withOpacity(0.6),
            ),
            selectedIcon: const Icon(Icons.settings, color: Colors.blueAccent),
            label: 'Settings',
          ),
        ],
      ),
      body: pages[currentPage],
    );
  }
}
