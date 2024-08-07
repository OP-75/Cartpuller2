import 'package:cartpuller2_cartpuller/API_calls/activate_cartpuller.dart';
import 'package:cartpuller2_cartpuller/API_calls/deactivate_cartpuller.dart';
import 'package:cartpuller2_cartpuller/Custom_exceptions/inactive.dart';
import 'package:cartpuller2_cartpuller/Custom_exceptions/invalid_token.dart';
import 'package:cartpuller2_cartpuller/Helper_functions/determine_user_position.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:developer' as dev;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isStoreActive = false;
  Color _StoreIconColor = Colors.red;

  @override
  Widget build(BuildContext context) {
    //remove below code block
    final service = FlutterBackgroundService();
    service.startService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Homepage"),
        actions: [
          IconButton(
            onPressed: () => _toggleServiceStatus(),
            icon: const Icon(Icons.store),
            color: _StoreIconColor,
            iconSize: 35,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            tooltip: "Click to toggle store is closed or open",
          ),
        ],
      ),
    );
  }

  _toggleServiceStatus() async {
    try {
      Position position = await determinePosition();
      Map<String, String> location = {
        "longitude": position.longitude.toString(),
        "latitude": position.latitude.toString(),
      };

      if (_isStoreActive) {
        await deactivateCartpuller();
        setState(() {
          _isStoreActive = false;
          _StoreIconColor = Colors.red;
        });
      } else {
        await activateCartpuller(location);
        setState(() {
          _isStoreActive = true;
          _StoreIconColor = Colors.green;
        });
      }
    } catch (e) {
      if (e is InvalidTokenException && context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: ${e.message}")));
        Navigator.of(context).popAndPushNamed('/login');
      } else if (e is InactiveUserException && context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: ${e.message}")));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
        dev.log(e.toString());
      }
    }
  }
}
