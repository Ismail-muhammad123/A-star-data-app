// dashboard_page.dart
import 'package:app/features/orders/views/pages/orders_tab.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/features/profile/providers/profile_provider.dart';
import 'package:app/features/profile/views/pages/profile.dart';
import 'package:app/features/wallet/views/pages/wallet.dart';

class HomePage extends StatefulWidget {
  final int index;
  const HomePage({super.key, this.index = 0});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int currentPage = 0;
  List<Widget> pages = [OrdersTab(), WalletPage(), ProfilePage()];

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
        indicatorColor: Colors.blue,
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
              Icons.account_balance_wallet,
              color: currentPage == 0 ? Colors.white : Colors.black,
            ),
            label: 'Orders',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.savings,
              color: currentPage == 1 ? Colors.white : Colors.black,
            ),
            label: 'Wallet',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.person,
              color: currentPage == 2 ? Colors.white : Colors.black,
            ),
            label: 'Profile',
          ),
        ],
      ),
      body: SafeArea(child: pages[currentPage]),
    );
  }
}
