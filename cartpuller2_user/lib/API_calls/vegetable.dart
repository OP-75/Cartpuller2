import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cartpuller2_user/Helper_functions/get_auth_token.dart';
import 'package:cartpuller2_user/Custom_exceptions/invalid_token.dart';
import 'package:cartpuller2_user/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as dev;

Future<List<Vegetable>> getVegetables() async {
  try {
    String token = await getAuthToken();

    final response = await http.get(
      Uri.parse('$SERVER_URL/api/all-vegetables'),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );

    if (response.statusCode == 403) {
      dev.log(
          "Vegetables API call response code: ${response.statusCode.toString()}");
      throw const InvalidTokenException("Please Login");
    }

    List<Vegetable> result = [];
    List<dynamic> inputList = jsonDecode(response.body) as List<dynamic>;
    for (final jsonMap in inputList) {
      result.add(Vegetable.fromJson(jsonMap));
    }

    dev.log(result.toString());
    return result;
  } catch (e) {
    dev.log("Vegetable API call: ${e.toString()}");
    rethrow;
  }
}

class Vegetable {
  String? id;
  String? title;
  int? price;
  String? error;

  Vegetable({this.id, this.title, this.price, this.error});

  factory Vegetable.fromJson(Map<String, dynamic> json) {
    return Vegetable(
      id: json['id'] as String?,
      title: json['title'] as String?,
      price: json['price'] as int?,
      error: json['error'] as String?,
    );
  }

  @override
  String toString() {
    return 'Vegetable{id: $id, title: $title, price: $price, error: $error}';
  }
}
