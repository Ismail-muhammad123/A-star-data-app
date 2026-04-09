import 'dart:async';

import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/core/constants/support_phone_number.dart';
import 'package:app/core/widgets/whatsapp_support_bottom_sheet.dart';
import 'package:app/features/orders/data/models.dart';
import 'package:app/features/orders/data/services.dart';
import 'package:app/core/providers/balance_visibility_provider.dart';
import 'package:app/features/notifications/data/models/notification_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:app/features/wallet/providers/wallet_provider.dart';
import 'package:app/features/notifications/providers/notification_provider.dart';

class OrdersTab extends StatefulWidget {
  const OrdersTab({super.key});

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> {
  static const String _whatsAppChannelUrl =
      "https://whatsapp.com/channel/0029Vb7rJr035fLz4bUIKS1d";
  final PageController _announcementPageController = PageController();
  Timer? _announcementTimer;
  int _currentAnnouncementPage = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.authToken != null) {
        final token = authProvider.authToken!;
        context.read<WalletProvider>().fetchBalance(token);
        context.read<NotificationProvider>().refreshAll(token);
        _startAnnouncementAutoSlide();
      }
    });
  }

  Future<void> _refresh() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.authToken != null) {
      final token = authProvider.authToken!;
      await Future.wait([
        context.read<WalletProvider>().fetchBalance(token),
        context.read<NotificationProvider>().refreshAll(token),
      ]);
    }
    setState(() {});
  }

  @override
  void dispose() {
    _announcementTimer?.cancel();
    _announcementPageController.dispose();
    super.dispose();
  }

  void _startAnnouncementAutoSlide() {
    _announcementTimer?.cancel();
    _announcementTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted || !_announcementPageController.hasClients) return;

      final announcements =
          context.read<NotificationProvider>().announcementsWithImages;
      if (announcements.length <= 1) return;

      if (_currentAnnouncementPage >= announcements.length) {
        _currentAnnouncementPage = 0;
      }

      final nextPage = (_currentAnnouncementPage + 1) % announcements.length;
      _announcementPageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final balanceVisibility = context.watch<BalanceVisibilityProvider>();
    final walletProvider = context.watch<WalletProvider>();

    return Scaffold(
      backgroundColor:
          Theme.of(context).scaffoldBackgroundColor, // sleek background
      appBar: AppBar(
        title: const Text(
          "Starboy Global",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        actions: [
          IconButton(
            tooltip: "WhatsApp",
            onPressed:
                () => showWhatsAppSupportBottomSheet(
                  context,
                  chatPhoneNumber: supportPhoneNumber,
                  channelUrl: _whatsAppChannelUrl,
                  chatMessage: "Hello, I need help with my order.",
                ),
            icon: const FaIcon(FontAwesomeIcons.whatsapp, size: 20),
          ),
          Consumer<NotificationProvider>(
            builder: (context, notifications, child) {
              return Stack(
                children: [
                  IconButton(
                    onPressed: () => context.push('/notifications'),
                    icon: const Icon(Icons.notifications_outlined),
                  ),
                  if (notifications.unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          notifications.unreadCount > 9
                              ? "9+"
                              : notifications.unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: Colors.blueAccent,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Wallet Balance Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors:
                        Theme.of(context).brightness == Brightness.dark
                            ? const [
                              Color(0xFF0F2027),
                              Color(0xFF203A43),
                              Color(0xFF2C5364),
                            ]
                            : const [Colors.blueAccent, Colors.lightBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F2027).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "Available Balance",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const Spacer(),
                        InkWell(
                          onTap:
                              () => context
                                  .push("/wallet")
                                  .then((_) => setState(() {})),

                          child: const Text(
                            "Go to Wallet",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (walletProvider.isLoading &&
                            walletProvider.balance == 0)
                          const SizedBox(
                            height: 38,
                            width: 38,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        else
                          Text(
                            balanceVisibility.isBalanceHidden
                                ? "****"
                                : NumberFormat.currency(
                                  locale: 'en_NG',
                                  symbol: '₦',
                            ).format(walletProvider.balance),
                            style: const TextStyle(
                              fontSize: 28,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap:
                              () => balanceVisibility.toggleBalanceVisibility(),
                          child: Icon(
                            balanceVisibility.isBalanceHidden
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.white.withOpacity(0.8),
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _buildAnnouncementsCarousel(),
              const SizedBox(height: 32),

              // Services Section
              Text(
                "Quick Services",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 16),

              GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.1,
                children: [
                  _buildServiceCard(
                    title: "Buy Airtime",
                    icon: Icons.call,
                    color: Colors.blueAccent,
                    onTap:
                        () => context
                            .push("/orders/buy-airtime")
                            .then((_) => setState(() {})),
                  ),
                  _buildServiceCard(
                    title: "Buy Data",
                    icon: Icons.wifi,
                    color: Colors.teal,
                    onTap:
                        () => context
                            .push("/orders/buy-data")
                            .then((_) => setState(() {})),
                  ),
                  _buildServiceCard(
                    title: "Internet",
                    icon: Icons.router_outlined,
                    color: Colors.indigo,
                    onTap:
                        () => context
                            .push("/orders/buy-internet")
                            .then((_) => setState(() {})),
                  ),
                  _buildServiceCard(
                    title: "Education",
                    icon: Icons.school_outlined,
                    color: Colors.brown,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Education Services Coming Soon"),
                        ),
                      );
                    },
                  ),
                  _buildServiceCard(
                    title: "Electricity",
                    icon: Icons.electric_bolt,
                    color: Colors.orange,
                    onTap:
                        () => context
                            .push("/orders/select-electricity-provider")
                            .then((_) => setState(() {})),
                  ),
                  _buildServiceCard(
                    title: "Cable/TV",
                    icon: Icons.tv,
                    color: Colors.purple,
                    onTap:
                        () => context
                            .push("/orders/select-tv-service")
                            .then((_) => setState(() {})),
                  ),
                  _buildServiceCard(
                    title: "Smile",
                    icon: Icons.router_outlined,
                    color: Colors.pinkAccent,
                    onTap:
                        () => context
                            .push("/orders/buy-internet", extra: "smile")
                            .then((_) => setState(() {})),
                  ),
                  _buildServiceCard(
                    title: "Kirani",
                    icon: Icons.router_outlined,
                    color: Colors.green,
                    onTap:
                        () => context
                            .push("/orders/buy-internet", extra: "kirani")
                            .then((_) => setState(() {})),
                  ),
                  _buildServiceCard(
                    title: "Ratel",
                    icon: Icons.router_outlined,
                    color: Colors.deepOrange,
                    onTap:
                        () => context
                            .push("/orders/buy-internet", extra: "ratel")
                            .then((_) => setState(() {})),
                  ),
                  // _buildServiceCard(
                  //   title: "History",
                  //   icon: Icons.history,
                  //   color: Colors.blueAccent,
                  //   onTap:
                  //       () => context
                  //           .push("/orders/history")
                  //           .then((_) => setState(() {})),
                  // ),
                ],
              ),

              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Recent Purchases",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push("/orders/history"),
                    child: const Text(
                      "View All",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              FutureBuilder<List<OrderHistory>>(
                future: OrderServices().getTransactions(
                  context.read<AuthProvider>().authToken ?? "",
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (!snapshot.hasData || snapshot.hasError) {
                    return const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Center(
                        child: Text(
                          "Error loading transactions",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  }
                  var transactions = snapshot.data!;
                  if (transactions.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.history,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "No recent transactions",
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  transactions.sort((a, b) => b.time.compareTo(a.time));
                  transactions = transactions.take(10).toList();

                  return Column(
                    children:
                        transactions
                            .map(
                              (transaction) => OrderTransactionTile(
                                transaction: transaction,
                              ),
                            )
                            .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnnouncementsCarousel() {
    final notificationProvider = context.watch<NotificationProvider>();
    final announcements = notificationProvider.announcementsWithImages;
    final hasSlides = announcements.isNotEmpty;

    if (notificationProvider.isLoadingAnnouncements && !hasSlides) {
      return const SizedBox(
        height: 140,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (!hasSlides) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Announcements",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 140,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: PageView.builder(
              controller: _announcementPageController,
              itemCount: announcements.length,
              onPageChanged: (index) {
                if (!mounted) return;
                setState(() {
                  _currentAnnouncementPage = index;
                });
              },
              itemBuilder: (context, index) {
                final announcement = announcements[index];
                return GestureDetector(
                  onTap: () => _showAnnouncementDetails(announcement),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        announcement.image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            alignment: Alignment.center,
                            child: const Icon(Icons.broken_image_outlined),
                          );
                        },
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.08),
                              Colors.black.withOpacity(0.55),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 12,
                        right: 12,
                        bottom: 12,
                        child: Text(
                          announcement.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        if (announcements.length > 1) const SizedBox(height: 8),
        if (announcements.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(announcements.length, (index) {
              final isActive = index == _currentAnnouncementPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isActive ? 14 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: isActive ? Colors.blueAccent : Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            }),
          ),
      ],
    );
  }

  void _showAnnouncementDetails(Announcement announcement) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(
              announcement.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            content: SingleChildScrollView(
              child: Text(
                announcement.body,
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Close"),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
    );
  }

  Widget _buildServiceCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    String? image,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            if (Theme.of(context).brightness == Brightness.light)
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(image != null ? 14 : 16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child:
                  image != null
                      ? Image.asset(image, width: 30, height: 30)
                      : Icon(icon, size: 24, color: color),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderTransactionTile extends StatelessWidget {
  final OrderHistory transaction;
  const OrderTransactionTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor,
      child: ListTile(
        onTap: () => context.push("/orders/history/${transaction.id}"),
        leading: Icon(
          transaction.purchaseType == "data" ? Icons.wifi : Icons.phone_android,
        ),
        title: Text(
          "${transaction.purchaseType} Purchase".toUpperCase(),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        subtitle: Text(
          "To: ${transaction.beneficiary}",
          style: TextStyle(fontSize: 11),
        ),
        // subtitle: Text(DateFormat.yMMMd().format(date)),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              NumberFormat.currency(
                locale: 'en_NG',
                symbol: '₦',
              ).format(transaction.amount).toString(),
              style: TextStyle(
                color: transaction.amount >= 0 ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              DateFormat.yMMMd().format(transaction.time),
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
