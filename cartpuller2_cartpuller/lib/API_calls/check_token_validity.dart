import 'dart:async';
import 'dart:io';
import 'package:cartpuller2_cartpuller/Helper_functions/get_auth_token.dart';
import 'package:cartpuller2_cartpuller/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as dev;

Future<bool> isTokenValid() async {
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
      return true;
    } else {
      return false;
    }
  } catch (e) {
    dev.log("isTokenValid() API call: ${e.toString()}");
    rethrow;
  }
}