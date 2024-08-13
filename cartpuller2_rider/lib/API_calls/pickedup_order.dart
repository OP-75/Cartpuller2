import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cartpuller2_rider/Custom_exceptions/bad_request.dart';
import 'package:cartpuller2_rider/Custom_exceptions/invalid_token.dart';
import 'package:cartpuller2_rider/Custom_exceptions/order_already_accepted.dart';
import 'package:cartpuller2_rider/Helper_functions/get_auth_token.dart';
import 'package:cartpuller2_rider/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as dev;

Future<Map<String, dynamic>> pickupOrder(String orderId) async {
  try {
    String token = await getAuthToken();

    final response = await http.post(
      Uri.parse('$SERVER_URL/api/rider/pickup-order/$orderId'),
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
    if (response.statusCode == HttpStatus.conflict) {
      final errorJson = jsonDecode(response.body);
      throw OrderAlreadyAcceptedException(errorJson["error"] as String);
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  } catch (e) {
    dev.log("API call: ${e.toString()}");
    rethrow;
  }
}
