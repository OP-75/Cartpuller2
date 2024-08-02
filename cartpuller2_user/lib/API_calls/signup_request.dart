import 'dart:async';
import 'dart:convert';
import 'package:cartpuller2_user/constants.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> signup(Map<String, String> signupForm) async {
  try {
    final response = await http.post(
      Uri.parse('$SERVER_URL/api/user/auth/signup'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(signupForm),
    );

    return jsonDecode(response.body) as Map<String, dynamic>;
  } catch (e) {
    rethrow;
  }
}
