import 'dart:async';

import 'package:cartpuller2_rider/API_calls/deliver_order.dart';
import 'package:cartpuller2_rider/API_calls/order_detail.dart';
import 'package:cartpuller2_rider/API_calls/pickedup_order.dart';
import 'package:cartpuller2_rider/Custom_exceptions/invalid_token.dart';
import 'package:cartpuller2_rider/Helper_functions/launch_map.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as dev;

class OrderDetailsPage extends StatefulWidget {
  const OrderDetailsPage({super.key});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  StreamController? _dataStreamController;
  Timer? _timer;
  String? _orderId;

  bool _showWarning = true;

  @override
  void initState() {
    super.initState();

    // Create a stream controller and add numbers to the stream.
    _dataStreamController = StreamController();
    _startFetchingData(); // Start adding numbers to the stream.
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
    _dataStreamController?.close();
  }

  @override
  Widget build(BuildContext context) {
    if (_orderId == null) {
      _orderId = ModalRoute.of(context)!.settings.arguments as String?;
      getOrderDetails(_orderId!)
          .then((val) => _dataStreamController!.sink.add(val))
          .catchError((error) => _dataStreamController!.sink.addError(error));
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _warningMaterialBanner(context);
    });

    return PopScope(
      onPopInvoked: (didPop) {
        ScaffoldMessenger.of(context).clearMaterialBanners();
      },
      child: Scaffold(
          appBar: AppBar(
            title: const Text("Order details"),
          ),
          body: StreamBuilder(
            stream: _dataStreamController?.stream,
            builder: (context, snapshot) {
              dev.log(snapshot.connectionState.toString());
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else {
                if (snapshot.hasData) {
                  return Column(
                    children: [
                      _displayData(snapshot.data!, context),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Text(snapshot.error!.toString());
                } else {
                  return const Text("No data");
                }
              }
            },
          )),
    );
  }

  void _warningMaterialBanner(BuildContext context) {
    //error message widget.
    if (_showWarning == true) {
      //if error is true then show error message box

      ScaffoldMessenger.of(context).showMaterialBanner(MaterialBanner(
          backgroundColor: Colors.orange[400],
          leading: const Icon(Icons.warning_amber_outlined),
          content: const Text(
            "The location of seller may change when you use the 'Track' button and open the route, to get updated coordinates of cartpuller come back to our app and click 'Track' again",
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  _showWarning = false;
                  ScaffoldMessenger.of(context).removeCurrentMaterialBanner();
                },
                icon: const Icon(Icons.cancel_outlined))
          ]));
    } else {
      //do nothing
    }
  }

  Future<void> _startFetchingData() async {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (_orderId != null) {
        try {
          _dataStreamController!.sink.add(await getOrderDetails(_orderId!));
        } catch (e) {
          _dataStreamController!.sink.addError(e);
        }
      }
    });
  }

  Widget _displayData(Map<String, dynamic> order, BuildContext context) {
    String orderId = order["id"];
    List<TableRow> tableRows = [];
    List<TableRow> orderDetailsRow = [];
    TableRow emptyRow = const TableRow(children: [Text(""), Text("")]);

    tableRows.add(TableRow(
        children: [const Text("Order ID"), Text(order["id"] as String)]));
    tableRows.add(emptyRow);

    //show order details
    orderDetailsRow.add(const TableRow(children: [
      Text("Vegetable"),
      Text("Qty"),
    ]));
    for (String vegetableId in order["orderDetails"].keys) {
      orderDetailsRow.add(TableRow(children: [
        Text(order["vegetableDetailMap"][vegetableId]["title"]),
        Text(order["orderDetails"][vegetableId].toString()),
      ]));
    }

    tableRows.add(TableRow(children: [
      const Text("Order Details"),
      Table(
        children: orderDetailsRow,
      )
    ]));
    tableRows.add(emptyRow);

    tableRows.add(TableRow(children: [
      const Text("Order status"),
      Text(order["orderStatus"] as String)
    ]));
    tableRows.add(emptyRow);

    tableRows.add(TableRow(children: [
      const Text("Customer Name"),
      Text(order["customerName"] as String)
    ]));
    tableRows.add(emptyRow);

    tableRows.add(TableRow(children: [
      const Text("Customer Number"),
      Text(order["customerNumber"] as String)
    ]));
    tableRows.add(emptyRow);

    tableRows.add(TableRow(children: [
      const Text("Seller name"),
      Text(order["cartpullerName"] as String)
    ]));
    tableRows.add(emptyRow);

    tableRows.add(TableRow(children: [
      const Text("Seller number"),
      Text(order["cartpullerNumber"] as String)
    ]));
    tableRows.add(emptyRow);

    tableRows.add(TableRow(children: [
      const Text("Delivery address"),
      Text(order["deliveryAddress"] as String)
    ]));
    tableRows.add(emptyRow);

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Table(
            children: tableRows,
            columnWidths: const {
              0: FlexColumnWidth(0.5),
              1: FlexColumnWidth(1),
            },
          ),
          ElevatedButton(
            style: const ButtonStyle(
                shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)))),
                backgroundColor: WidgetStatePropertyAll(Colors.blue),
                foregroundColor: WidgetStatePropertyAll(Colors.white),
                padding: WidgetStatePropertyAll(EdgeInsets.all(20))),
            onPressed: () async {
              double pickupLatitude = double.parse(order['pickupLatitude']);
              double pickupLongitude = double.parse(order['pickupLongitude']);
              double deliveryLatitude = double.parse(order['deliveryLatitude']);
              double deliveryLongitude =
                  double.parse(order['deliveryLongitude']);
              try {
                await launchMap(pickupLatitude, pickupLongitude,
                    deliveryLatitude, deliveryLongitude);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(e.toString())));
                }
              }
            },
            child: const Text("Track"),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: TextButton(
                style: const ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.blue),
                  foregroundColor: WidgetStatePropertyAll(Colors.white),
                ),
                onPressed: () {
                  _handlePickup(context, orderId);
                },
                child: const Text("Order picked up")),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
                style: const ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.blue),
                  foregroundColor: WidgetStatePropertyAll(Colors.white),
                ),
                onPressed: () {
                  _handleDelivery(context, orderId);
                },
                child: const Text("Order delivered")),
          )
        ],
      ),
    );
  }

  Future<void> _handlePickup(BuildContext context, String orderId) async {
    try {
      Map<String, dynamic> updatedOrderDetails = await pickupOrder(orderId);
      _dataStreamController!.sink.add(updatedOrderDetails);
    } on InvalidTokenException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _handleDelivery(BuildContext context, String orderId) async {
    try {
      await deliverOrder(orderId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearMaterialBanners();
        Navigator.of(context).pop();
      }
    } on InvalidTokenException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearMaterialBanners();
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }
}
