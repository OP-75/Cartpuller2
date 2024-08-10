import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cartpuller2_cartpuller/Custom_exceptions/invalid_token.dart';
import 'package:cartpuller2_cartpuller/Helper_functions/get_auth_token.dart';
import 'package:cartpuller2_cartpuller/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as dev;

Future<bool> getActivityStatus() async {
  try {
    String token = await getAuthToken();

    final response = await http.get(
      Uri.parse('$SERVER_URL/api/cartpuller/check-if-active'),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );

    if (response.statusCode == HttpStatus.ok) {
      return (jsonDecode(response.body) as Map<String, dynamic>)["active"]
          as bool;
    } else if (response.statusCode == HttpStatus.forbidden ||
        response.statusCode == HttpStatus.unauthorized) {
      throw const InvalidTokenException("Token Invalid, Please login");
    } else {
      throw Exception((jsonDecode(response.body)
          as Map<String, dynamic>)["error"] as String);
    }
  } catch (e) {
    dev.log("getActivityStatus() API call: ${e.toString()}");
    rethrow;
  }
}
