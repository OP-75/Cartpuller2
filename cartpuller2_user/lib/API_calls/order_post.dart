import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cartpuller2_user/Helper_functions/get_auth_token.dart';
import 'package:cartpuller2_user/Custom_exceptions/empty_cart.dart';
import 'package:cartpuller2_user/Custom_exceptions/invalid_token.dart';
import 'package:cartpuller2_user/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as dev;

Future<Order> postOrder(Map<String, int> cartItems) async {
  try {
    String token = await getAuthToken();

    if (cartItems.isEmpty) {
      throw const EmptyCartException(
          "Add some items to your cart before checking out");
    }

    final response =
        await http.post(Uri.parse('$SERVER_URL/api/customer/order'),
            headers: <String, String>{
              HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
              HttpHeaders.authorizationHeader: 'Bearer $token',
            },
            body: jsonEncode(cartItems));

    if (response.statusCode == 403) {
      dev.log(
          "postOrder API call response code: ${response.statusCode.toString()}");
      throw const InvalidTokenException("Please Login");
    }

    return Order.fromJson(jsonDecode(response.body));
  } catch (e) {
    dev.log("postOrder API call: ${e.toString()}");
    rethrow;
  }
}

class Order {
  String? id;
  Map<String, int>? orderDetails;
  String? customerEmail;
  String? orderStatus;
  String? riderEmail;
  String? cartpullerEmail;

  Order({
    this.id,
    this.orderDetails,
    this.customerEmail,
    this.orderStatus,
    this.riderEmail,
    this.cartpullerEmail,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String?,
      orderDetails: Map<String, int>.from(json['orderDetails'] as Map),
      customerEmail: json['customerEmail'] as String?,
      orderStatus: json['orderStatus'] as String?,
      riderEmail: json['riderEmail'] as String?,
      cartpullerEmail: json['cartpullerEmail'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderDetails': orderDetails,
      'customerEmail': customerEmail,
      'orderStatus': orderStatus,
      'riderEmail': riderEmail,
      'cartpullerEmail': cartpullerEmail,
    };
  }

  @override
  String toString() {
    return 'Order{id: $id, orderDetails: $orderDetails, customerEmail: $customerEmail, orderStatus: $orderStatus, riderEmail: $riderEmail, cartpullerEmail: $cartpullerEmail}';
  }
}
