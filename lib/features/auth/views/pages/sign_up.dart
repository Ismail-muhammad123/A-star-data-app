import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
// import 'package:provider/provider.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  // bool _rememberMe = false;

  String? countryCode = "+234";

  bool _isLoading = false;

  void handleSignUp() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    setState(() {
      _isLoading = true;
    });

    // Remove leading zero from phone number if present
    String phone = _phoneController.text.trim();
    if (phone.startsWith('0')) {
      phone = phone.substring(1);
    }

    try {
      var res = await authProvider.register(
        phone,
        _pinController.text.trim(),
        countryCode: countryCode ?? "+234",
        email: _emailController.text.trim(),
      );
      setState(() {
        _isLoading = false;
      });
      if (res!['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              "Your account has been created successfully. Please verify your phone Number now.",
            ),
          ),
        );
        if (!mounted) return;
        context.go('/activate-account', extra: _phoneController.text);
      } else {
        if (mounted) {
          await showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: Text("Error"),
                  content: Text(
                    "Failed to complete registration! An error occurred",
                  ),
                ),
          );
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }
    } catch (e) {
      if (mounted) {
        await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text("Error"),
                icon: Icon(Icons.error, color: Colors.blue),
                content: Text(
                  "Failed to complete account registration! please check all foelds and try again",
                ),
              ),
        );
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }
  }

  bool _hidePassword = true;

  final Map<String, String> countryPhoneCodes = {
    "Afghanistan": "+93",
    "Albania": "+355",
    "Algeria": "+213",
    "Andorra": "+376",
    "Angola": "+244",
    "Antigua and Barbuda": "+1-268",
    "Argentina": "+54",
    "Armenia": "+374",
    "Australia": "+61",
    "Austria": "+43",
    "Azerbaijan": "+994",
    "Bahamas": "+1-242",
    "Bahrain": "+973",
    "Bangladesh": "+880",
    "Barbados": "+1-246",
    "Belarus": "+375",
    "Belgium": "+32",
    "Belize": "+501",
    "Benin": "+229",
    "Bhutan": "+975",
    "Bolivia": "+591",
    "Bosnia and Herzegovina": "+387",
    "Botswana": "+267",
    "Brazil": "+55",
    "Brunei": "+673",
    "Bulgaria": "+359",
    "Burkina Faso": "+226",
    "Burundi": "+257",
    "Cambodia": "+855",
    "Cameroon": "+237",
    "Canada": "+1",
    "Cape Verde": "+238",
    "Central African Republic": "+236",
    "Chad": "+235",
    "Chile": "+56",
    "China": "+86",
    "Colombia": "+57",
    "Comoros": "+269",
    "Congo (Brazzaville)": "+242",
    "Congo (Kinshasa)": "+243",
    "Costa Rica": "+506",
    "Croatia": "+385",
    "Cuba": "+53",
    "Cyprus": "+357",
    "Czech Republic": "+420",
    "Denmark": "+45",
    "Djibouti": "+253",
    "Dominica": "+1-767",
    "Dominican Republic": "+1-809",
    "Ecuador": "+593",
    "Egypt": "+20",
    "El Salvador": "+503",
    "Equatorial Guinea": "+240",
    "Eritrea": "+291",
    "Estonia": "+372",
    "Eswatini": "+268",
    "Ethiopia": "+251",
    "Fiji": "+679",
    "Finland": "+358",
    "France": "+33",
    "Gabon": "+241",
    "Gambia": "+220",
    "Georgia": "+995",
    "Germany": "+49",
    "Ghana": "+233",
    "Greece": "+30",
    "Grenada": "+1-473",
    "Guatemala": "+502",
    "Guinea": "+224",
    "Guinea-Bissau": "+245",
    "Guyana": "+592",
    "Haiti": "+509",
    "Honduras": "+504",
    "Hungary": "+36",
    "Iceland": "+354",
    "India": "+91",
    "Indonesia": "+62",
    "Iran": "+98",
    "Iraq": "+964",
    "Ireland": "+353",
    "Israel": "+972",
    "Italy": "+39",
    "Jamaica": "+1-876",
    "Japan": "+81",
    "Jordan": "+962",
    "Kazakhstan": "+7",
    "Kenya": "+254",
    "Kiribati": "+686",
    "Kuwait": "+965",
    "Kyrgyzstan": "+996",
    "Laos": "+856",
    "Latvia": "+371",
    "Lebanon": "+961",
    "Lesotho": "+266",
    "Liberia": "+231",
    "Libya": "+218",
    "Liechtenstein": "+423",
    "Lithuania": "+370",
    "Luxembourg": "+352",
    "Madagascar": "+261",
    "Malawi": "+265",
    "Malaysia": "+60",
    "Maldives": "+960",
    "Mali": "+223",
    "Malta": "+356",
    "Marshall Islands": "+692",
    "Mauritania": "+222",
    "Mauritius": "+230",
    "Mexico": "+52",
    "Micronesia": "+691",
    "Moldova": "+373",
    "Monaco": "+377",
    "Mongolia": "+976",
    "Montenegro": "+382",
    "Morocco": "+212",
    "Mozambique": "+258",
    "Myanmar (Burma)": "+95",
    "Namibia": "+264",
    "Nauru": "+674",
    "Nepal": "+977",
    "Netherlands": "+31",
    "New Zealand": "+64",
    "Nicaragua": "+505",
    "Niger": "+227",
    "Nigeria": "+234",
    "North Korea": "+850",
    "North Macedonia": "+389",
    "Norway": "+47",
    "Oman": "+968",
    "Pakistan": "+92",
    "Palau": "+680",
    "Palestine": "+970",
    "Panama": "+507",
    "Papua New Guinea": "+675",
    "Paraguay": "+595",
    "Peru": "+51",
    "Philippines": "+63",
    "Poland": "+48",
    "Portugal": "+351",
    "Qatar": "+974",
    "Romania": "+40",
    "Russia": "+7",
    "Rwanda": "+250",
    "Saint Kitts and Nevis": "+1-869",
    "Saint Lucia": "+1-758",
    "Saint Vincent and the Grenadines": "+1-784",
    "Samoa": "+685",
    "San Marino": "+378",
    "Sao Tome and Principe": "+239",
    "Saudi Arabia": "+966",
    "Senegal": "+221",
    "Serbia": "+381",
    "Seychelles": "+248",
    "Sierra Leone": "+232",
    "Singapore": "+65",
    "Slovakia": "+421",
    "Slovenia": "+386",
    "Solomon Islands": "+677",
    "Somalia": "+252",
    "South Africa": "+27",
    "South Korea": "+82",
    "South Sudan": "+211",
    "Spain": "+34",
    "Sri Lanka": "+94",
    "Sudan": "+249",
    "Suriname": "+597",
    "Sweden": "+46",
    "Switzerland": "+41",
    "Syria": "+963",
    "Taiwan": "+886",
    "Tajikistan": "+992",
    "Tanzania": "+255",
    "Thailand": "+66",
    "Togo": "+228",
    "Tonga": "+676",
    "Trinidad and Tobago": "+1-868",
    "Tunisia": "+216",
    "Turkey": "+90",
    "Turkmenistan": "+993",
    "Tuvalu": "+688",
    "Uganda": "+256",
    "Ukraine": "+380",
    "United Arab Emirates": "+971",
    "United Kingdom": "+44",
    "United States": "+1",
    "Uruguay": "+598",
    "Uzbekistan": "+998",
    "Vanuatu": "+678",
    "Vatican City": "+379",
    "Venezuela": "+58",
    "Vietnam": "+84",
    "Yemen": "+967",
    "Zambia": "+260",
    "Zimbabwe": "+263",
  };

  List<DropdownMenuItem<String>> get countryDropdownItems {
    return [DropdownMenuItem(value: "+234", child: Text("Nigeria (+234)"))];
  }

  @override
  void initState() {
    Provider.of<AuthProvider>(context, listen: false).checkAuth().then((_) {
      if (Provider.of<AuthProvider>(context, listen: false).isAuthenticated) {
        context.go('/');
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SizedBox(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  Card(
                    elevation: 8.0,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Hero(
                            tag: "logo",
                            child: Image.asset(
                              "assets/images/logo/a-star_app_logo.png",
                              height: 150,
                              width: 150,
                              fit: BoxFit.contain,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Create an account".toUpperCase(),
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.blue,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 20),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: "Select Country",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(12),
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                              value: countryCode,
                              items:
                                  countryPhoneCodes.entries.map((entry) {
                                    final country = entry.key;
                                    final code = entry.value;
                                    return DropdownMenuItem<String>(
                                      value: code,
                                      child: SizedBox(
                                        width: 200,
                                        child: Text("$country ($code)"),
                                      ),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  countryCode = value;
                                });
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              enabled: !_isLoading,
                              controller: _phoneController,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                prefixText: "$countryCode ",
                                label: Text("Your Phone Number"),
                                prefixIcon: Icon(Icons.phone),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              enabled: !_isLoading,
                              controller: _pinController,
                              obscureText: _hidePassword,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(6),
                              ],
                              textAlign: TextAlign.center,

                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                hintText: "* * * * * *",
                                suffix: GestureDetector(
                                  onTap:
                                      () => setState(
                                        () => _hidePassword = !_hidePassword,
                                      ),
                                  child: Icon(
                                    _hidePassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                ),
                                label: Text("Pin"),
                                prefixIcon: Icon(Icons.lock),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 20),
                          MaterialButton(
                            onPressed: _isLoading ? null : handleSignUp,
                            color: Colors.blueAccent,
                            height: 50,
                            minWidth: 300,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child:
                                _isLoading
                                    ? CircularProgressIndicator()
                                    : Text(
                                      "Create Account",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                          ),
                          SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () => context.go('/login'),
                                child: Text(
                                  "Already have an account?",
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
