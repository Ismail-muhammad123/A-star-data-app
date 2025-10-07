// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';
// import 'package:tubali_app/features/auth/providers/auth_provider.dart';
// import 'package:tubali_app/features/profile/data/models/bank_info_model.dart';
// import 'package:tubali_app/features/profile/data/repositories/profile_repo.dart';
// import 'package:tubali_app/features/profile/views/pages/bank_information/bank_picker.dart';

// class BankInfoFormPage extends StatefulWidget {
//   const BankInfoFormPage({super.key});

//   @override
//   State<BankInfoFormPage> createState() => _BankInfoFormPageState();
// }

// class _BankInfoFormPageState extends State<BankInfoFormPage> {
//   bool _editing = false;
//   bool _loading = false;
//   BankInformationModel? currentBankInfo;

//   final TextEditingController _bankNameController = TextEditingController();
//   final TextEditingController _accountNameController = TextEditingController();
//   final TextEditingController _accountNumberController =
//       TextEditingController();

//   _createBankInfo(BankInformationModel data) async {
//     setState(() {
//       _editing = false;
//       _loading = true;
//     });

//     await ProfileService().addBankInformation(
//       context.read<AuthProvider>().authToken ?? "",
//       data,
//     );

//     setState(() {
//       _loading = false;
//     });
//     _loadCurrentBankInfo();
//   }

//   _updateBankInfo(BankInformationModel data) async {
//     setState(() {
//       _editing = false;

//       _loading = true;
//     });

//     await ProfileService().updateBankInformation(
//       context.read<AuthProvider>().authToken ?? "",
//       data,
//     );

//     setState(() {
//       _loading = false;
//     });
//     _loadCurrentBankInfo();
//   }

//   _loadCurrentBankInfo() async {
//     setState(() {
//       _loading = true;
//     });

//     var info = await ProfileService().retriveBankInformation(
//       context.read<AuthProvider>().authToken ?? "",
//     );
//     setState(() {
//       if (info != null) {
//         currentBankInfo = info;
//         _bankNameController.text = info.bankName;
//         _accountNameController.text = info.accountName;
//         _accountNumberController.text = info.accountNumber;
//       }
//       _loading = false;
//     });
//   }

//   @override
//   void initState() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _loadCurrentBankInfo();
//     });
//     super.initState();
//   }

//   @override
//   void dispose() {
//     _bankNameController.dispose();
//     _accountNameController.dispose();
//     _accountNumberController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: BackButton(
//           color: Colors.white,
//           onPressed:
//               () => context.canPop() ? context.pop() : context.go('/home'),
//         ),
//         title: const Text(
//           'Bank Information',
//           style: TextStyle(color: Colors.white),
//         ),
//         backgroundColor: Colors.redAccent,
//         surfaceTintColor: Colors.redAccent,
//         actions: [
//           TextButton(
//             onPressed: () => setState(() => _editing = !_editing),
//             child: Text(
//               _editing ? "Cancel" : "Edit",
//               style: TextStyle(color: _editing ? Colors.black : Colors.white),
//             ),
//           ),
//         ],
//       ),

//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             // AbsorbPointer(
//             //   child: GestureDetector(
//             //     onTap:
//             //         _editing
//             //             ? () async {
//             //               // Navigate to pick bank page and get result
//             //               final selectedBank = await Navigator.of(
//             //                 context,
//             //               ).push<String>(
//             //                 MaterialPageRoute(
//             //                   builder: (context) => const BankPicker(),
//             //                 ),
//             //               );
//             //               if (selectedBank != null && selectedBank.isNotEmpty) {
//             //                 setState(() {
//             //                   _bankNameController.text = selectedBank;
//             //                 });
//             //               }
//             //             }
//             //             : null,
//             //     child:
//             TextFormField(
//               controller: _bankNameController,
//               enabled: _editing,
//               onTap:
//                   _editing
//                       ? () async {
//                         // Navigate to pick bank page and get result
//                         final selectedBank = await Navigator.of(
//                           context,
//                         ).push<String>(
//                           MaterialPageRoute(
//                             builder: (context) => const BankPicker(),
//                           ),
//                         );
//                         if (selectedBank != null && selectedBank.isNotEmpty) {
//                           setState(() {
//                             _bankNameController.text = selectedBank;
//                           });
//                         }
//                       }
//                       : null,
//               decoration: const InputDecoration(
//                 labelText: 'Bank Name',
//                 border: OutlineInputBorder(),
//               ),
//               readOnly: true,
//             ),
//             //   ),
//             // ),
//             const SizedBox(height: 16),
//             TextFormField(
//               enabled: _editing,
//               controller: _accountNameController,
//               decoration: const InputDecoration(
//                 labelText: 'Account Name',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16),
//             TextFormField(
//               controller: _accountNumberController,
//               enabled: _editing,
//               decoration: const InputDecoration(
//                 labelText: 'Account Number',
//                 border: OutlineInputBorder(),
//               ),
//               keyboardType: TextInputType.number,
//               inputFormatters: [
//                 FilteringTextInputFormatter.digitsOnly,
//                 LengthLimitingTextInputFormatter(10),
//               ],
//             ),
//             const SizedBox(height: 16),
//             DropdownButtonFormField<String>(
//               decoration: InputDecoration(
//                 labelText: 'Currency',
//                 border: OutlineInputBorder(),
//                 enabled: _editing,
//               ),
//               value: 'NGN',
//               items: const [
//                 DropdownMenuItem(
//                   value: 'NGN',
//                   child: Text('Nigerian Naira (NGN)'),
//                 ),
//               ],
//               onChanged: _editing ? (value) {} : null,
//             ),
//             const SizedBox(height: 16),
//             MaterialButton(
//               onPressed:
//                   _loading
//                       ? null
//                       : currentBankInfo == null
//                       ? () {
//                         _createBankInfo(
//                           BankInformationModel(
//                             accountName: _accountNameController.text,
//                             accountNumber: _accountNumberController.text,
//                             bankName: _bankNameController.text,
//                             latUpdatedAt: DateTime.now().toString(),
//                           ),
//                         );
//                       }
//                       : () {
//                         _updateBankInfo(
//                           BankInformationModel(
//                             user: currentBankInfo?.user,
//                             accountName: _accountNameController.text,
//                             accountNumber: _accountNumberController.text,
//                             bankName: _bankNameController.text,
//                             latUpdatedAt: DateTime.now().toString(),
//                           ),
//                         );
//                       },
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               height: 50,
//               minWidth: 200,
//               color: Colors.redAccent,
//               child:
//                   _loading
//                       ? CircularProgressIndicator(color: Colors.red)
//                       : Text("Save", style: TextStyle(color: Colors.white)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
