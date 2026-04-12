import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  try {
    // Attempting an anonymous GET just to see if the structure throws a 401 and look at the schema, or maybe use an auth token.
    print("Testing");
  } catch (e) {
    print(e);
  }
}
