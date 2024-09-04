import 'dart:async';
import 'dart:ui';
import 'dart:developer' as dev;

import 'package:cartpuller2_cartpuller/API_calls/update_location.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:geolocator/geolocator.dart';

/// Foreground and Background
/// Foreground and Background
Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: false,
      isForegroundMode: true,
      // notificationChannelId: 'my_foreground',
      // initialNotificationContent: 'running',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(),
  );
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });
    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }
  service.on('stopService').listen((event) async {
    await service.stopSelf();
  });

  const locationSettings =
      LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 100);

  Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position pos) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        try {
          Map<String, String> location = {
            "latitude": pos.latitude.toString(),
            "longitude": pos.longitude.toString(),
          };
          await sendCartpullerLocation(location);
          dev.log("Foreground service position stream: ${pos.toString()}");
        } catch (e) {
          // if we get an exception (like "cartpuller is inactive" exception then stop the service)
          try {
            await service.stopSelf();
            dev.log(
                "foreground service exception: ${e.toString()}, shutting down foreground service");
          } catch (serviceException) {
            dev.log(
                "service.stopSelf exception: ${serviceException.toString()}");
          }
        }
      }
    }
  }, onError: (error) {
    dev.log("positionStream error: ${error.toString()}");
  });
}

Future<void> startBackgroundService() async {
  final service = FlutterBackgroundService();
  await service.startService();
}

void stopBackgroundService() {
  final service = FlutterBackgroundService();
  service.invoke("stop");
}
