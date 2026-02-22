import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:app/features/auth/providers/auth_provider.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _onboardingData = [
    OnboardingData(
      title: "Fast & Reliable",
      description:
          "Buy airtime and data instantly at the best rates in Nigeria. Stay connected always!",
      image: Icons.bolt,
      color: Colors.blue.shade900,
    ),
    OnboardingData(
      title: "Secure Payments",
      description:
          "Pay your electricity and cable TV bills securely with our encrypted payment system.",
      image: Icons.security,
      color: Colors.blue.shade700,
    ),
    OnboardingData(
      title: "Wallet Management",
      description:
          "Manage your finances, fund your wallet, and track all your transactions in one place.",
      image: Icons.account_balance_wallet,
      color: Colors.blue.shade500,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _onboardingData.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return _buildPage(_onboardingData[index]);
            },
          ),
          Positioned(
            bottom: 60,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _onboardingData.length,
                    (index) => _buildIndicator(index),
                  ),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_currentPage == _onboardingData.length - 1) {
                        await context.read<AuthProvider>().markFirstTimeSeen();
                        if (mounted) context.go('/register');
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue.shade900,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      _currentPage == _onboardingData.length - 1
                          ? "Get Started"
                          : "Next",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (_currentPage < _onboardingData.length - 1)
                  TextButton(
                    onPressed: () async {
                      await context.read<AuthProvider>().markFirstTimeSeen();
                      if (mounted) context.go('/register');
                    },
                    child: const Text(
                      "Skip",
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingData data) {
    return Container(
      width: double.infinity,
      color: data.color,
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(data.image, size: 150, color: Colors.white),
          const SizedBox(height: 48),
          Text(
            data.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color:
            _currentPage == index
                ? Colors.white
                : Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final IconData image;
  final Color color;

  OnboardingData({
    required this.title,
    required this.description,
    required this.image,
    required this.color,
  });
}
