// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class ExtraApiServices {
//   // Query the list of Nigerian banks
//   Future<List<Map<String, dynamic>>> fetchNigerianBanks() async {
//     final url = Uri.parse('https://api.paystack.co/bank?country=nigeria');
//     final response = await http.get(
//       url,
//       headers: {
//         'Authorization': 'Bearer YOUR_PAYSTACK_SECRET_KEY',
//         'Content-Type': 'application/json',
//       },
//     );

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       return List<Map<String, dynamic>>.from(data['data']);
//     } else {
//       throw Exception('Failed to fetch Nigerian banks');
//     }
//   }

//   // Fetch the list of countries and their country codes
//   Future<List<Map<String, dynamic>>> fetchCountriesAndCodes() async {
//     final url = Uri.parse('https://restcountries.com/v3.1/all');
//     final response = await http.get(url);

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       return List<Map<String, dynamic>>.from(
//         data.map(
//           (country) => {
//             'name': country['name']['common'],
//             'code': country['cca2'],
//           },
//         ),
//       );
//     } else {
//       throw Exception('Failed to fetch countries');
//     }
//   }
// }
