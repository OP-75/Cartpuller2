import 'package:cartpuller2_cartpuller/API_calls/activate_cartpuller.dart';
import 'package:cartpuller2_cartpuller/API_calls/deactivate_cartpuller.dart';
import 'package:cartpuller2_cartpuller/API_calls/get_orders.dart';
import 'package:cartpuller2_cartpuller/Custom_exceptions/inactive.dart';
import 'package:cartpuller2_cartpuller/Custom_exceptions/invalid_token.dart';
import 'package:cartpuller2_cartpuller/Helper_functions/determine_user_position.dart';
import 'package:cartpuller2_cartpuller/background_foreground_service_config/service.dart';
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
  bool _isStoreActive =
      false; //this is just a placeholder actual inital state is set by _checkAndSetStoreStatus
  Color _storeIconColor = Colors.red;
  final service = FlutterBackgroundService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndSetStoreStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Homepage"),
        actions: [
          IconButton(
            onPressed: () => _toggleServiceStatus(),
            icon: const Icon(Icons.store),
            color: _storeIconColor,
            iconSize: 35,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            tooltip: "Click to toggle store is closed or open",
          ),
        ],
      ),
      body: FutureBuilder(
        future: _fetchAvailableOrders(context),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return _ordersWidget(snapshot.data!);
          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }

  Widget _ordersWidget(List<Map<String, dynamic>> _ordersList) {
    return ListView.builder(
        itemCount: _ordersList.length,
        itemBuilder: (context, index) {
          final currOrder = _ordersList[index];

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.5)),
              tileColor: Colors.grey[300],
              title: Text("Order ID: ${currOrder['id']} "),
              subtitle: Column(children: [
                _buildTable(currOrder),
                Center(
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: IconButton(
                            onPressed: () {
                              _acceptOrder(currOrder['id']);
                            },
                            icon: const Icon(Icons.check)),
                      ),
                      Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: IconButton(
                              onPressed: () {
                                //TODO write this logic, utilize a tmp black list to reject orders
                              },
                              icon: const Icon(Icons.cancel))),
                    ],
                  ),
                )
              ]),
            ),
          );
        });
  }

  Widget _buildTable(Map<String, dynamic> currOrder) {
    List<TableRow> cartTableRows = [];
    cartTableRows.add(const TableRow(children: [
      Text("Veggie"),
      Text("Qty"),
      Text("Price/item"),
      Text("Total")
    ]));

    int total = 0;

    //for converting currOrder['orderDetails'] to Map<String, int> we use a loop
    Map<String, int> orderDetails = {};
    (currOrder['orderDetails'] as Map<String, dynamic>).forEach((key, val) {
      //orderDetails = Vegetable id - quantity map
      orderDetails[key] = val as int;
    });

    Map<String, dynamic> vegetableDetailMap = currOrder['vegetableDetailMap'];

    orderDetails.forEach(
      (id, qty) {
        total += (vegetableDetailMap[id]['price'] * qty) as int;

        cartTableRows.add(TableRow(children: [
          Text("${vegetableDetailMap[id]['title']}:"),
          Text("$qty"),
          Text("${vegetableDetailMap[id]['price']}"),
          Text("${vegetableDetailMap[id]['price'] * qty}")
        ]));
      },
    );

    cartTableRows.add(TableRow(children: [
      Text("Total = $total"),
      const Text(""),
      const Text(""),
      const Text("")
    ]));

    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: cartTableRows,
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
        stopBackgroundService();
        await deactivateCartpuller();
        setState(() {
          _isStoreActive = false;
          _storeIconColor = Colors.red;
        });
      } else {
        await activateCartpuller(location);
        startBackgroundService();
        setState(() {
          _isStoreActive = true;
          _storeIconColor = Colors.green;
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

  void _acceptOrder(currOrder) {
    //TODO write this api & logic
  }

  Future<List<Map<String, dynamic>>> _fetchAvailableOrders(
      BuildContext context) async {
    try {
      return getOrders();
    } on InvalidTokenException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
        Navigator.of(context).popAndPushNamed('/login');
      }
      rethrow;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
      rethrow;
    }
  }

  void _checkAndSetStoreStatus() {
    service.isRunning().then((value) {
      setState(() {
        _isStoreActive = value;
        if (_isStoreActive) {
          _storeIconColor = Colors.green;
        } else {
          _storeIconColor = Colors.red;
        }
      });
    });
  }
}
