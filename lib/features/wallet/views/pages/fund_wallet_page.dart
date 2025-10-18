import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/features/wallet/data/repository/wallet_repo.dart';
import 'package:app/features/wallet/views/widgets/transfer_deposit_account_info_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class FundWalletFormPage extends StatefulWidget {
  const FundWalletFormPage({super.key});

  @override
  State<FundWalletFormPage> createState() => _FundWalletFormPageState();
}

class _FundWalletFormPageState extends State<FundWalletFormPage> {
  final TextEditingController _amountController = TextEditingController();
  bool _isLoading = false;

  String paymentMethod = "transfer";

  Map<String, dynamic>? paymentInfo;

  _initCardPayment() async {
    if (_amountController.text.isEmpty ||
        double.tryParse(_amountController.text) == null ||
        double.parse(_amountController.text) < 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a valid amount (Min. of N100)")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      paymentInfo = null;
    });

    try {
      var res = await WalletService().fundWithCard(
        Provider.of<AuthProvider>(context, listen: false).authToken ?? '',
        double.parse(_amountController.text),
      );
      if (res == null) {
        throw Exception('Failed to fetch payment info');
      }

      var checkoutUrl = res['responseBody']['checkoutUrl'];
      var uri = Uri.parse(checkoutUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        print("cant launch payment URL");
      }

      if (mounted) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text("Payment Initiated"),
                content: Text(
                  "Your card payment has been initiated. If the payment page did not open, tap the button below to open it manually in your browser.",
                ),
                actions: [
                  TextButton(
                    onPressed: () async {
                      var checkoutUrl = res['responseBody']['checkoutUrl'];
                      var uri = Uri.parse(checkoutUrl);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Could not launch payment link"),
                          ),
                        );
                      }
                    },
                    child: Text("Open Payment Link"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      setState(() {
                        _amountController.clear();
                      });
                      context.canPop() ? context.pop() : context.go("/wallet");
                    },
                    child: Text("Done"),
                  ),
                ],
              ),
        );
        // setState(() {
        //   _amountController.clear();
        // });
        // context.canPop() ? context.pop() : context.go("/wallet");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to load payment info! ${e.toString()}"),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  _getPaymentInfo() async {
    if (_amountController.text.isEmpty ||
        double.tryParse(_amountController.text) == null ||
        double.parse(_amountController.text) < 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a valid amount (Min. of N100)")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      paymentInfo = null;
    });
    try {
      var res = await WalletService().fundWithTransfer(
        Provider.of<AuthProvider>(context, listen: false).authToken ?? '',
        double.parse(_amountController.text),
      );
      if (res == null) {
        throw Exception('Failed to fetch payment info');
      }

      setState(() {
        paymentInfo = (res['responseBody'] as Map<String, dynamic>);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to load payment info! ${e.toString()}"),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Future<void> _launchInBrowser(String url) async {
  //   final uri = Uri.parse(url);
  //   if (await canLaunchUrl(uri)) {
  //     await launchUrl(uri, mode: LaunchMode.externalApplication);
  //   } else {
  //     throw 'Could not launch payment link';
  //   }
  // }

  // _initiateFunding() async {
  //   setState(() => _isLoading = true);

  //   try {
  //     var res = await WalletService().addFunds(
  //       Provider.of<AuthProvider>(context, listen: false).authToken ?? '',
  //       double.parse(_amountController.text),
  //     );
  //     if (res == null) {
  //       throw Exception('Failed to initiate deposit into wallet');
  //     }

  //     var paymentUrl = res['data']['authorization_url'];

  //     if (kIsWeb) {
  //       Future.microtask(() async {
  //         await _launchInBrowser(paymentUrl);
  //       });
  //     } else {
  //       await Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (_) => PaymentWebViewPage(paymentUrl: paymentUrl),
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       showDialog(
  //         context: context,
  //         builder:
  //             (context) => AlertDialog(
  //               title: Text("Error"),
  //               content: Text(e.toString()),
  //               actions: [
  //                 TextButton(
  //                   onPressed: () => Navigator.of(context).pop(),
  //                   child: Text("OK"),
  //                 ),
  //               ],
  //             ),
  //       );
  //     }
  //   }
  //   if (mounted) {
  //     setState(() => _isLoading = false);
  //     context.canPop() ? context.pop() : context.go("/home");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: Colors.white,
          onPressed:
              () => context.canPop() ? context.pop() : context.go("/wallet"),
        ),
        title: Text(
          "Fund Wallet",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        backgroundColor: Colors.lightBlue,
        surfaceTintColor: Colors.lightBlue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 8.0),
        child: MaterialButton(
          minWidth: double.maxFinite,
          onPressed:
              _isLoading
                  ? null
                  : paymentMethod == "card"
                  ? _initCardPayment
                  : paymentInfo == null
                  ? _getPaymentInfo
                  : () =>
                      context.canPop() ? context.pop() : context.go("/wallet"),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          height: 50,
          color: Colors.lightBlue,
          child:
              _isLoading
                  ? CircularProgressIndicator()
                  : Text(
                    paymentInfo == null ? "Proceed" : "Finish",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Amount:"),
            SizedBox(height: 5.0),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              enabled: !_isLoading,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator:
                  (value) =>
                      value == null || value.isEmpty
                          ? 'Please enter an amount'
                          : double.tryParse(value) == null
                          ? 'Please enter a valid number'
                          : double.tryParse(value) == null ||
                              double.parse(value) < 100
                          ? 'Amount must be at least N100'
                          : null,
              enableSuggestions: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Min. of N100",
                contentPadding: EdgeInsets.symmetric(horizontal: 4.0),
              ),
            ),
            SizedBox(height: 20),
            Text("Payment Method:"),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: GestureDetector(
                    onTap:
                        _isLoading
                            ? null
                            : () {
                              setState(() => paymentMethod = "transfer");
                            },
                    child: Container(
                      padding: EdgeInsets.all(6.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          width: paymentMethod == "transfer" ? 2 : 1,
                          color:
                              paymentMethod == "transfer"
                                  ? Colors.blue
                                  : Colors.lightBlue[100]!,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.send),
                          SizedBox(width: 10),
                          Text("Bank Transfer"),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Flexible(
                  child: GestureDetector(
                    onTap:
                        _isLoading
                            ? null
                            : () {
                              setState(() => paymentMethod = "card");
                            },
                    child: Container(
                      padding: EdgeInsets.all(6.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          width: paymentMethod == "card" ? 2 : 1,
                          color:
                              paymentMethod == "card"
                                  ? Colors.blue
                                  : Colors.lightBlue[100]!,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.credit_card),
                          SizedBox(width: 4),
                          Text("Card Payment"),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),
            paymentInfo == null
                ? SizedBox()
                : TransferDepositAccountInfoCard(
                  accountName: paymentInfo!['accountName'],
                  accountNumber: paymentInfo!['accountNumber'],
                  bankName: paymentInfo!['bankName'],
                  amount: double.tryParse(_amountController.text) ?? 0,
                ),
          ],
        ),
      ),
    );
  }
}
