import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future<void> deleteAllToken() async {
  // Create storage to store JWT
  const storage = FlutterSecureStorage();
  await storage.deleteAll();
}
