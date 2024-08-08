import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:geolocator/geolocator.dart';
import 'dart:developer' as dev;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isActive = false;
  int _selectedIndex = 0;
  Position? _currPosition;
  List _ordersList = [];
  List _acceptedOrders = [];

  @override
  Widget build(BuildContext context) {
    Widget? widgetToLoad;

    switch (_selectedIndex) {
      case 0:
        widgetToLoad = _loadLiveOrdersListView();
        break;
      case 1:
        widgetToLoad = _loadAcceptedOrdersListView();
        break;

      default:
        widgetToLoad = const Center(
            child: SizedBox(
          height: 60,
          width: 60,
          child: CircularProgressIndicator(),
        ));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Cartpuller vendor"),
        actions: [
          IconButton(
              onPressed: _handleActivation,
              icon: Icon(
                Icons.store,
                color: _isActive ? Colors.green : Colors.red,
              )),
          IconButton(onPressed: _handleLogout, icon: Icon(Icons.logout))
        ],
      ),
      body: widgetToLoad,
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.settings_input_antenna), label: "Live order"),
          BottomNavigationBarItem(
              icon: Icon(Icons.library_books_outlined),
              label: "Accepted Orders")
        ],
        currentIndex: _selectedIndex,
        onTap: _changeIndex,
      ),
    );
  }

  void _changeIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  _loadAcceptedOrdersListView() {
    return FutureBuilder(
      //dont make wasteful api calls store the result in accepted order (since we are streaming the location)
      future: _fetchAllOrders(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return RefreshIndicator(
              child: ListView.builder(
                  itemCount: _acceptedOrders.length,
                  itemBuilder: (context, index) {
                    final currOrder = _acceptedOrders[index];

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.5)),
                        tileColor: currOrder['orderStatus'] == "picked" ||
                                currOrder['orderStatus'] == "delivered"
                            ? Colors.grey[300]
                            : Colors.amber[200],
                        title: Text("Order ID: ${currOrder['_id']} "),
                        subtitle: Column(children: [
                          _buildTable(currOrder),
                          Text("Order status: ${currOrder['orderStatus']}")
                        ]),
                      ),
                    );
                  }),
              onRefresh: () async {
                setState(() {
                  _acceptedOrders = [];
                });
              });
        } else if (snapshot.hasError) {
          return Text("Error: ${snapshot.error.toString()}");
        } else {
          return const Center(
              child: SizedBox(
            height: 60,
            width: 60,
            child: CircularProgressIndicator(),
          ));
        }
      },
    );
  }

  Future<void> _handleLogout() async {
    // TODO: Create popup to ask before logout
    final FirebaseAuth auth = FirebaseAuth.instance;

    try {
      await auth.signOut();
      if (context.mounted) {
        Navigator.of(context).popAndPushNamed('/login');
      }
    } catch (e) {
      dev.log(e.toString());
      rethrow;
    }
  }

  Future<void> _acceptOrder(String orderId) async {
    try {
      final doc = await sendAcceptance(orderId, _user!.email!, _currPosition!);
      setState(() {
        _ordersList.removeWhere((element) => element["_id"] == orderId);
      });
    } catch (e) {
      dev.log(e.toString());
      Fluttertoast.showToast(
          msg: e.toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  Future<void> _handleActivation() async {
    // TODO: Create popup to ask before deativation/going offline of rider

    try {
      if (!_isActive) {
        _channel = WebSocketChannel.connect(
          Uri.parse('$WS_SERVER_URL/ws/vendor-update'),
        );

        const LocationSettings locationSettings = LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 100,
        );

        //add initial position
        Position p = await determinePosition();
        final updatedInfo = {
          "email": _user!.email,
          "name": _user!.displayName ?? "_",
          "number": _user!.phoneNumber ?? "_",
          "latitude": p.latitude,
          "longitude": p.longitude
        };

        final jsonUpdatedInfo = jsonEncode(updatedInfo);

        _channel!.sink.add(jsonUpdatedInfo);

        _positionStreamSubscription =
            Geolocator.getPositionStream(locationSettings: locationSettings)
                .listen((Position? position) {
          final updatedInfo = {
            "email": _user!.email,
            "name": _user!.displayName ?? "_",
            "number": _user!.phoneNumber ?? "_",
            "latitude": position!.latitude,
            "longitude": position.longitude
          };
          final jsonUpdatedInfo = jsonEncode(updatedInfo);
          _channel!.sink
              .add(jsonUpdatedInfo); //send location every time we move

          _currPosition = position;
        });

        _channelSubscrption = _channel?.stream.listen((msg) async {
          msg = jsonDecode(msg);

          //check to see if we have got the same order in our list
          final previosOrder = _ordersList.firstWhere(
              (element) => element["_id"] == msg["_id"],
              orElse: () => null);

          if (msg["_id"] != null && previosOrder == null) {
            Map<String, dynamic> cart = msg["cart"];

            Map<String, dynamic> mappedCart = {};

            await Future.forEach(cart.entries, (element) async {
              Veggie v = await getVeggie(element.key);
              mappedCart[v.name] = {
                "quantity": element.value,
                "price": v.price,
              };
            });

            msg["cart"] = mappedCart;

            setState(() {
              _ordersList.add(msg);
            });
          }
        });
      }

      if (_isActive) {
        //if deactivating the:
        await _channelSubscrption?.cancel();
        await _positionStreamSubscription?.cancel();
        await _channel?.sink.close();
      }

      setState(() {
        _isActive = !_isActive;
      });
    } catch (e) {
      dev.log(e.toString());
      Fluttertoast.showToast(
          msg: e.toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  Future<List> _fetchAllOrders() async {
    if (_acceptedOrders.isEmpty) {
      final List allOrder = await getAllMyOrders(_user!.email!);

      await Future.forEach(allOrder, (element) async {
        Map<String, dynamic> cart = element["cart"];

        Map<String, dynamic> mappedCart = {};

        await Future.forEach(cart.entries, (element) async {
          Veggie v = await getVeggie(element.key);
          mappedCart[v.name] = {
            "quantity": element.value,
            "price": v.price,
          };
        });

        element["cart"] = mappedCart;
        dev.log(element["cart"].toString());
      });

      _acceptedOrders = allOrder;
      return _acceptedOrders;
    } else {
      return Future(() => _acceptedOrders);
    }
  }
}
