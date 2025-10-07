// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:intl/intl.dart';
// import 'package:tubali_app/core/extenstions/string_extention.dart';
// import 'package:tubali_app/features/auth/providers/auth_provider.dart';
// import 'package:tubali_app/features/profile/data/models/bank_info_model.dart';
// import 'package:tubali_app/features/profile/data/repositories/profile_repo.dart';
// import 'package:tubali_app/features/wallet/data/repository/wallet_repo.dart';

// class WithdrawalFormPage extends StatefulWidget {
//   const WithdrawalFormPage({super.key});

//   @override
//   State<WithdrawalFormPage> createState() => _WithdrawalFormPageState();
// }

// class _WithdrawalFormPageState extends State<WithdrawalFormPage> {
//   final TextEditingController _amountController = TextEditingController();
//   bool _isLoading = false;

//   @override
//   void dispose() {
//     _amountController.dispose();
//     super.dispose();
//   }

//   _requestWithdrawal() async {
//     if (_amountController.text.isEmpty ||
//         double.tryParse(_amountController.text) == null ||
//         double.parse(_amountController.text) < 100) {
//       showDialog(
//         context: context,
//         builder:
//             (context) => AlertDialog(
//               title: Text('Invalid Amount'),
//               content: Text('Please enter a valid amount of at least ₦100.'),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: Text('OK'),
//                 ),
//               ],
//             ),
//       );
//       return;
//     }
//     setState(() => _isLoading = true);

//     try {
//       var res = await WalletService().withdrawFunds(
//         context.read<AuthProvider>().authToken ?? '',
//         double.parse(_amountController.text),
//       );
//       if (res == null) {
//         throw Exception('Failed to initiate withdrawal from wallet');
//       }

//       // if (res['status'] != 'success') {
//       //   throw Exception(res['message'] ?? 'Withdrawal request failed');
//       // }

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               'Withdrawal request submitted successfully',
//               style: TextStyle(color: Colors.white),
//             ),
//             backgroundColor: Colors.green,
//           ),
//         );
//         context.pop();
//       }
//     } catch (e) {
//       if (mounted) {
//         await showDialog(
//           context: context,
//           builder:
//               (context) => AlertDialog(
//                 title: Text('Error'),
//                 content: Text(e.toString()),
//                 actions: [
//                   TextButton(
//                     onPressed: () => Navigator.pop(context),
//                     child: Text('OK'),
//                   ),
//                 ],
//               ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Withdraw Money", style: TextStyle(color: Colors.white)),
//         backgroundColor: Colors.redAccent,
//         surfaceTintColor: Colors.redAccent,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(10.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               height: 170,
//               width: double.maxFinite,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(10),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.redAccent.withOpacity(0.5),
//                     blurRadius: 12.0,
//                     offset: Offset(4, 4),
//                   ),
//                 ],
//               ),
//               padding: EdgeInsets.all(10),
//               child: FutureBuilder<BankInformationModel?>(
//                 future: ProfileService().retriveBankInformation(
//                   context.read<AuthProvider>().authToken ?? '',
//                 ),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return Center(child: CircularProgressIndicator());
//                   }
//                   if (snapshot.hasError) {
//                     return Center(child: Text("Error: ${snapshot.error}"));
//                   }

//                   var bankInfo = snapshot.data;
//                   if (bankInfo == null) {
//                     return Center(child: Text("No bank information found."));
//                   }
//                   return Column(
//                     children: [
//                       Row(
//                         children: [
//                           Text(
//                             "Recieving Account",
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           Spacer(),
//                           MaterialButton(
//                             onPressed: () {},
//                             color: Colors.grey[300],
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             height: 30,
//                             minWidth: 100,
//                             child: Text("Edit"),
//                           ),
//                         ],
//                       ),
//                       Row(
//                         children: [
//                           Text(
//                             bankInfo.accountNumber,
//                             style: TextStyle(
//                               fontSize: 30,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.redAccent,
//                             ),
//                           ),
//                         ],
//                       ),
//                       Row(
//                         children: [
//                           Text(
//                             "Account Name:",
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           SizedBox(width: 10),
//                           Text(
//                             bankInfo.accountName.toTitleCase(),
//                             style: TextStyle(fontSize: 14),
//                           ),
//                         ],
//                       ),
//                       Row(
//                         children: [
//                           Text(
//                             "Bank Name:",
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           SizedBox(width: 10),
//                           Text(
//                             bankInfo.bankName.toTitleCase(),
//                             style: TextStyle(fontSize: 14),
//                           ),
//                         ],
//                       ),
//                     ],
//                   );
//                 },
//               ),
//             ),
//             SizedBox(height: 20),
//             FutureBuilder<String?>(
//               future: WalletService().getBalance(
//                 context.read<AuthProvider>().authToken ?? '',
//               ),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return Center(child: CircularProgressIndicator());
//                 }
//                 if (snapshot.hasError) {
//                   return Center(child: Text("Error: ${snapshot.error}"));
//                 }
//                 if (!snapshot.hasData || snapshot.data == null) {
//                   return Center(child: Text("No balance data found."));
//                 }
//                 var balance = double.tryParse(snapshot.data!);
//                 if (balance == null) {
//                   return Center(child: Text("Invalid balance data."));
//                 }
//                 if (balance < 100) {
//                   return Text(
//                     "Minimum balance for withdrawal is ₦100. Please fund your wallet.",
//                     style: TextStyle(color: Colors.red),
//                   );
//                 }
//                 return Row(
//                   children: [
//                     Text("Available: ", style: TextStyle(color: Colors.grey)),
//                     Text(
//                       NumberFormat.currency(
//                         locale: 'en_NG',
//                         symbol: '₦',
//                         decimalDigits: 2,
//                       ).format(balance),
//                       style: TextStyle(color: Colors.grey),
//                     ),
//                   ],
//                 );
//               },
//             ),
//             SizedBox(height: 20),
//             Text("Amount"),
//             TextFormField(
//               controller: _amountController,
//               enabled: !_isLoading,
//               keyboardType: TextInputType.number,
//               inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//               decoration: InputDecoration(
//                 border: OutlineInputBorder(),
//                 hintText: "Min. of N100",
//               ),
//             ),
//             SizedBox(height: 20),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Center(
//                 child: MaterialButton(
//                   onPressed: _isLoading ? null : _requestWithdrawal,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   height: 50,
//                   minWidth: 250,
//                   color: Colors.redAccent,
//                   child:
//                       _isLoading
//                           ? CircularProgressIndicator()
//                           : Text(
//                             "Proceed",
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
