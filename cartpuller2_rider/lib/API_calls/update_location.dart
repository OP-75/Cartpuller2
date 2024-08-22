import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cartpuller2_rider/Custom_exceptions/inactive.dart';
import 'package:cartpuller2_rider/Custom_exceptions/invalid_token.dart';
import 'package:cartpuller2_rider/Helper_functions/get_auth_token.dart';
import 'package:cartpuller2_rider/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as dev;

Future<String> updateRiderLocation(Map<String, String> location) async {
  try {
    String token = await getAuthToken();

    final response = await http.post(
      Uri.parse('$SERVER_URL/api/rider/update-location'),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
      body: jsonEncode(location),
    );

    if (response.statusCode == HttpStatus.forbidden ||
        response.statusCode == HttpStatus.unauthorized) {
      throw const InvalidTokenException("Token Invalid please login in again");
    }
    if (response.statusCode == HttpStatus.badRequest) {
      //check the backend code to know about this
      final errorJson = jsonDecode(response.body);
      throw InactiveUserException(errorJson["error"] as String);
    }
    if (response.statusCode == HttpStatus.tooManyRequests) {
      throw Exception("Ngrok: Too many requests");
    }

    return response.body;
  } catch (e) {
    dev.log(e.toString());
    rethrow;
  }
}
