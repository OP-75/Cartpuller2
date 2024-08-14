import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cartpuller2_user/Helper_functions/get_auth_token.dart';
import 'package:cartpuller2_user/Custom_exceptions/invalid_token.dart';
import 'package:cartpuller2_user/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as dev;

Future<List<Map<String, dynamic>>> getPastOrders() async {
  try {
    String token = await getAuthToken();

    final response = await http.get(
      Uri.parse('$SERVER_URL/api/customer/past-orders'),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );

    if (response.statusCode == HttpStatus.forbidden ||
        response.statusCode == HttpStatus.unauthorized) {
      throw const InvalidTokenException("Please Login");
    }

    dev.log(response.body);
    List<Map<String, dynamic>> result = (jsonDecode(response.body) as List)
        .map((val) => val as Map<String, dynamic>)
        .toList();
    return result;
  } catch (e) {
    dev.log("getPastOrders API call: ${e.toString()}");
    rethrow;
  }
}
