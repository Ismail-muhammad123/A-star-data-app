// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:tubali_app/features/auth/providers/auth_provider.dart';
// import 'package:tubali_app/features/profile/data/repositories/profile_repo.dart';

// class BankPicker extends StatefulWidget {
//   const BankPicker({super.key});

//   @override
//   State<BankPicker> createState() => _BankPickerState();
// }

// class _BankPickerState extends State<BankPicker> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: BackButton(
//           color: Colors.white,
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         title: const Text('Select Bank', style: TextStyle(color: Colors.white)),
//         backgroundColor: Colors.red,
//       ),

//       body: FutureBuilder<List<Map<String, dynamic>>>(
//         future: ProfileService().fetchNigerianBanks(
//           context.read<AuthProvider>().authToken ?? "",
//         ),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text('No banks available'));
//           } else {
//             final banks = snapshot.data!;
//             return ListView.builder(
//               itemCount: banks.length,
//               itemBuilder: (context, index) {
//                 var bank = banks[index]['name'] ?? 'Unknown Bank';
//                 return ListTile(
//                   title: Text(bank),
//                   onTap: () {
//                     Navigator.pop(context, bank);
//                   },
//                 );
//               },
//             );
//           }
//         },
//       ),
//     );
//   }
// }
