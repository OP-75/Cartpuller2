import 'dart:async';

import 'package:cartpuller2_user/API_calls/order_detail.dart';
import 'package:cartpuller2_user/Helper_functions/map_utils.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:developer' as dev;

import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:widget_to_marker/widget_to_marker.dart';

class OrderDetailsPage extends StatefulWidget {
  const OrderDetailsPage({super.key});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  StreamController? _dataStreamController;
  PanelController _panelController = PanelController();
  Timer? _timer;
  String? _orderId;

  BitmapDescriptor? _homeIcon;
  BitmapDescriptor? _cartpullerIcon;
  BitmapDescriptor? _riderIcon;

  @override
  void initState() {
    super.initState();

    // Create a stream controller and add numbers to the stream.
    _dataStreamController = StreamController();
    _startFetchingData(); // Start adding numbers to the stream.
    _loadMapMarkerIcons();
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
        _timer?.cancel();
        _dataStreamController?.close();
        ScaffoldMessenger.of(context).clearMaterialBanners();
      },
      child: Scaffold(
          appBar: AppBar(
            title: const Text("Order details"),
          ),
          body: StreamBuilder(
            stream: _dataStreamController?.stream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else {
                if (snapshot.hasData) {
                  return SlidingUpPanel(
                      controller: _panelController,
                      panel: Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Column(
                          children: [
                            _displayData(snapshot.data!),
                          ],
                        ),
                      ),
                      body: _displayMap(snapshot.data!));
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

  Widget _displayData(Map<String, dynamic> order) {
    List<TableRow> tableRows = [];
    List<TableRow> orderDetailsRow = [];
    TableRow emptyRow = const TableRow(children: [Text(""), Text("")]);

    tableRows.add(TableRow(children: [
      const Text("Order ID"),
      Text(_convertToString(order["id"]))
    ]));
    tableRows.add(emptyRow);

    tableRows.add(TableRow(children: [
      const Text("Order status"),
      Text(_convertToString(order["orderStatus"]))
    ]));
    tableRows.add(emptyRow);

    //show order details
    orderDetailsRow.add(const TableRow(children: [
      Text("Vegetable"),
      Text("Qty"),
    ]));
    for (String vegetableId in order["orderDetails"].keys) {
      orderDetailsRow.add(TableRow(children: [
        Text(order["vegetableDetailMap"][vegetableId]["title"]),
        Text(_convertToString(order["orderDetails"][vegetableId])),
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
      const Text("Seller name"),
      Text(_convertToString(order["cartpullerName"]))
    ]));
    tableRows.add(emptyRow);

    tableRows.add(TableRow(children: [
      const Text("Seller Number"),
      Text(_convertToString(order["cartpullerNumber"]))
    ]));
    tableRows.add(emptyRow);

    tableRows.add(TableRow(children: [
      const Text("Rider Name"),
      Text(_convertToString(order["riderName"]))
    ]));
    tableRows.add(emptyRow);

    tableRows.add(TableRow(children: [
      const Text("Rider number"),
      Text(_convertToString(order["riderNumber"]))
    ]));
    tableRows.add(emptyRow);

    tableRows.add(TableRow(children: [
      const Text("Delivery address"),
      Text(_convertToString(order["deliveryAddress"]))
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

  String _convertToString(dynamic val) {
    if (val == null) {
      return "";
    } else {
      return val.toString();
    }
  }

  Widget _displayMap(Map<String, dynamic> order) {
    Set<Marker> markers = {};

    //mark delivery location
    double lat = double.parse(order["deliveryLatitude"]);
    double long = double.parse(order["deliveryLongitude"]);
    LatLng deliveryLatLng = LatLng(lat, long);
    markers.add(Marker(
        markerId: const MarkerId("Delivery location"),
        position: deliveryLatLng,
        icon: _homeIcon ?? BitmapDescriptor.defaultMarker));

    //mark cartpuller location
    if (order["cartpullerLatitude"] != null &&
        order["cartpullerLongitude"] != null) {
      double lat = double.parse(order["cartpullerLatitude"]);
      double long = double.parse(order["cartpullerLongitude"]);
      LatLng cartpullerLatLng = LatLng(lat, long);
      markers.add(Marker(
          markerId: const MarkerId("Cartpuller location"),
          position: cartpullerLatLng,
          icon: _cartpullerIcon ?? BitmapDescriptor.defaultMarker));
    }

    //mark rider location
    if (order["riderLatitude"] != null && order["riderLongitude"] != null) {
      double lat = double.parse(order["riderLatitude"]);
      double long = double.parse(order["riderLongitude"]);
      LatLng riderLatLng = LatLng(lat, long);
      markers.add(Marker(
          markerId: const MarkerId("Rider location"),
          position: riderLatLng,
          icon: _riderIcon ?? BitmapDescriptor.defaultMarker));
    }

    CameraPosition initPosition = CameraPosition(
      target: deliveryLatLng,
      zoom: 14,
    );

    return GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: initPosition,
        onMapCreated: (GoogleMapController controller) {
          controller.getVisibleRegion();

          Future.delayed(
              const Duration(milliseconds: 200),
              () => controller.animateCamera(CameraUpdate.newLatLngBounds(
                  MapUtils.boundsFromLatLngList(markers), 170)));
        },
        markers: markers);
  }

  void _loadMapMarkerIcons() {
    const double logicalSize = 110;
    const double imageSize = 300;
    const Icon(Icons.home)
        .toBitmapDescriptor(
            logicalSize: const Size(logicalSize, logicalSize),
            imageSize: const Size(imageSize, imageSize),
            waitToRender: Duration.zero)
        .then((icon) {
      _homeIcon = icon;
    });
    const Icon(Icons.store)
        .toBitmapDescriptor(
            logicalSize: const Size(logicalSize, logicalSize),
            imageSize: const Size(imageSize, imageSize),
            waitToRender: Duration.zero)
        .then((icon) {
      _cartpullerIcon = icon;
    });
    const Icon(Icons.motorcycle)
        .toBitmapDescriptor(
            logicalSize: const Size(logicalSize, logicalSize),
            imageSize: const Size(imageSize, imageSize),
            waitToRender: Duration.zero)
        .then((icon) {
      _riderIcon = icon;
    });
  }
}
