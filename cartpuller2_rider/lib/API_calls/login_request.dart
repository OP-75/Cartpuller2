import 'dart:async';
import 'dart:convert';
import 'package:cartpuller2_rider/constants.dart';
import 'package:http/http.dart' as http;

Future<Token> login(Map<String, String> loginForm) async {
  try {
    final response = await http.post(
      Uri.parse('$SERVER_URL/api/auth/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(loginForm),
    );

    if (response.statusCode == 403) {
      return Token(null, null, "Login failed, username or password is wrong");
    }

    return Token.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  } catch (e) {
    rethrow;
  }
}

class Token {
  String? accessToken;
  String? refreshToken;
  String? error;

  Token(this.accessToken, this.refreshToken, this.error);

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(json['token'] as String?, json['refreshToken'] as String?,
        json['error'] as String?);
  }

  @override
  String toString() {
    return 'Token{accessToken: $accessToken, refreshToken: $refreshToken, error: $error}';
  }
}
