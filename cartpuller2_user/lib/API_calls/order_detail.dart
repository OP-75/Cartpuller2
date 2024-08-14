import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cartpuller2_user/Custom_exceptions/bad_request.dart';
import 'package:cartpuller2_user/Custom_exceptions/invalid_token.dart';
import 'package:cartpuller2_user/Helper_functions/get_auth_token.dart';
import 'package:cartpuller2_user/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as dev;

Future<Map<String, dynamic>> getOrderDetails(String orderId) async {
  try {
    String token = await getAuthToken();

    final response = await http.get(
      Uri.parse('$SERVER_URL/api/customer/order-details/$orderId'),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );

    if (response.statusCode == HttpStatus.forbidden ||
        response.statusCode == HttpStatus.unauthorized) {
      throw const InvalidTokenException("InvalidTokenException: Please Login");
    }

    if (response.statusCode == HttpStatus.badRequest) {
      final errorJson = jsonDecode(response.body);
      throw BadRequestException(errorJson["error"] as String);
    }

    dev.log(response.body);
    return (jsonDecode(response.body) as Map<String, dynamic>);
  } catch (e) {
    dev.log("API call: ${e.toString()}");
    rethrow;
  }
}
