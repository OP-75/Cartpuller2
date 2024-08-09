import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cartpuller2_cartpuller/Custom_exceptions/bad_request.dart';
import 'package:cartpuller2_cartpuller/Custom_exceptions/invalid_token.dart';
import 'package:cartpuller2_cartpuller/Helper_functions/get_auth_token.dart';
import 'package:cartpuller2_cartpuller/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as dev;

Future<List<Map<String, dynamic>>> getPastOrders() async {
  try {
    String token = await getAuthToken();

    final response = await http.get(
      Uri.parse('$SERVER_URL/api/cartpuller/past-accepted-orders'),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );

    if (response.statusCode == HttpStatus.forbidden ||
        response.statusCode == HttpStatus.unauthorized) {
      dev.log(
          "get Orders API call response code: ${response.statusCode.toString()}");
      throw const InvalidTokenException("Please Login");
    }

    if (response.statusCode == HttpStatus.badRequest) {
      final errorJson = jsonDecode(response.body);
      throw BadRequestException(errorJson["error"] as String);
    }

    dev.log(response.body);
    return (jsonDecode(response.body) as List)
        .map((e) => e as Map<String, dynamic>)
        .toList();
  } catch (e) {
    dev.log("Order API call: ${e.toString()}");
    rethrow;
  }
}
