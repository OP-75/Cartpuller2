import 'package:map_launcher/map_launcher.dart';
import 'dart:developer' as dev;

Future<void> launchMap(double pickupLatitude, double pickupLongitude,
    double deliveryLatitude, double deliveryLongitude) async {
  Coords deliveryCoords = Coords(deliveryLatitude, deliveryLongitude);

  try {
    MapLauncher.showDirections(
        mapType: MapType.google,
        waypoints: [Waypoint(pickupLatitude, pickupLongitude)],
        destination: deliveryCoords);
  } catch (e) {
    dev.log("launch maps error: ${e.toString()}");
    throw Exception("Cant open maps");
  }
}
