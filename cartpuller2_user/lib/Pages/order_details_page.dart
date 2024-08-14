import 'dart:async';

import 'package:cartpuller2_user/API_calls/order_detail.dart';
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
      const Text("Seller name"),
      Text(order["cartpullerName"] as String)
    ]));
    tableRows.add(emptyRow);

    tableRows.add(TableRow(children: [
      const Text("Seller Number"),
      Text(order["cartpullerNumber"] as String)
    ]));
    tableRows.add(emptyRow);

    tableRows.add(TableRow(children: [
      const Text("Rider Name"),
      Text(order["riderName"] as String)
    ]));
    tableRows.add(emptyRow);

    tableRows.add(TableRow(children: [
      const Text("Rider number"),
      Text(order["riderNumber"] as String)
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
        ],
      ),
    );
  }
}
