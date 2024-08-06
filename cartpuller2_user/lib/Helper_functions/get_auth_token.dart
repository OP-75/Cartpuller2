import 'package:cartpuller2_user/Custom_exceptions/invalid_token.dart';
import 'package:cartpuller2_user/constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future<String> getAuthToken() async {
  try {
    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: TOKEN);

    if (token == null) {
      throw const InvalidTokenException("Please Login");
    } else {
      return token;
    }
  } catch (e) {
    rethrow;
  }
}
