import 'dart:async';

import 'package:cartpuller2_cartpuller/API_calls/accept_order.dart';
import 'package:cartpuller2_cartpuller/API_calls/activate_cartpuller.dart';
import 'package:cartpuller2_cartpuller/API_calls/check_activity_status.dart';
import 'package:cartpuller2_cartpuller/API_calls/deactivate_cartpuller.dart';
import 'package:cartpuller2_cartpuller/API_calls/get_orders.dart';
import 'package:cartpuller2_cartpuller/API_calls/get_past_order.dart';
import 'package:cartpuller2_cartpuller/API_calls/update_location.dart';
import 'package:cartpuller2_cartpuller/Custom_exceptions/bad_request.dart';
import 'package:cartpuller2_cartpuller/Custom_exceptions/inactive.dart';
import 'package:cartpuller2_cartpuller/Custom_exceptions/invalid_token.dart';
import 'package:cartpuller2_cartpuller/Custom_exceptions/order_already_accepted.dart';
import 'package:cartpuller2_cartpuller/Helper_functions/delete_all_tokens.dart';
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

  int _selectedIndex = 0;
  final service = FlutterBackgroundService();

  //Timer for polling
  Timer? _timer;

  //Back list for when a user cancels order, it becomes everytime user closes the app
  final Set<String> _blackList = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndSetStoreStatus();
    });

    //we need to do polling every X seconds to refresh available order,
    //we can just use empty set state since the future builder in build()
    // will make the call every time build is called
    _timer = Timer.periodic(const Duration(seconds: 10), (Timer t) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Homepage"),
        actions: [
          IconButton(
            onPressed: () => _toggleServiceStatus(context),
            icon: const Icon(Icons.store),
            color: _storeIconColor,
            iconSize: 35,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            tooltip: "Click to toggle store is closed or open",
          ),
          _logoutButton(context),
        ],
      ),
      body: _getWidgetOfSelectedIndex(_selectedIndex, context),
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

  Widget _liveOrderWidget(BuildContext context) {
    return FutureBuilder(
      future: _fetchAvailableOrders(context),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Map<String, dynamic>> data = snapshot.data!;

          //remove elements from black list
          data.removeWhere((order) => _blackList.contains(order['id']));

          return _ordersListView(data);
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  Widget _ordersListView(List<Map<String, dynamic>> ordersList) {
    return ListView.builder(
        itemCount: ordersList.length,
        itemBuilder: (context, index) {
          final currOrder = ordersList[index];

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
                              String orderId = currOrder['id'];
                              _acceptOrder(orderId, context);
                            },
                            icon: const Icon(Icons.check)),
                      ),
                      Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: IconButton(
                              onPressed: () {
                                setState(() {
                                  String orderId = currOrder['id'];
                                  _blackList.add(orderId);
                                });
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

  Widget _pastOrderWidget(BuildContext context) {
    return FutureBuilder(
      future: _fetchPastOrders(context),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return _pastOrdersListView(snapshot.data!);
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  Widget _pastOrdersListView(List<Map<String, dynamic>> ordersList) {
    return ListView.builder(
        itemCount: ordersList.length,
        itemBuilder: (context, index) {
          final currOrder = ordersList[index];

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.5)),
              tileColor: currOrder['orderStatus'] == "ACCEPTED" ||
                      currOrder['orderStatus'] == "RIDER_ASSIGNED"
                  ? Colors.amber
                  : Colors.grey[300],
              title: Text(
                  "Order ID: ${currOrder['id']}, Status = ${currOrder['orderStatus']}"),
              subtitle: _buildTable(currOrder),
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

  _toggleServiceStatus(BuildContext context) async {
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
        await sendCartpullerLocation(location);
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
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
        }
      }
      dev.log(e.toString());
    }
  }

  Future<void> _acceptOrder(String id, BuildContext context) async {
    try {
      await acceptOrder(id);
      setState(() {});
    } on BadRequestException catch (e) {
      dev.log(e.message);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                "${e.message}, try activating & deactivating your store from app if you are already active")));
      }
    } on OrderAlreadyAcceptedException catch (e) {
      dev.log(e.message);
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (e) {
      dev.log(e.toString());
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
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

  Future<List<Map<String, dynamic>>> _fetchPastOrders(
      BuildContext context) async {
    try {
      return getPastOrders();
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
    getActivityStatus().then((value) {
      setState(() {
        _isStoreActive = value;
        if (_isStoreActive) {
          _storeIconColor = Colors.green;
          startBackgroundService();
        } else {
          _storeIconColor = Colors.red;
          startBackgroundService();
        }
      });
    });
  }

  void _changeIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getWidgetOfSelectedIndex(int index, BuildContext context) {
    switch (_selectedIndex) {
      case 0:
        return _liveOrderWidget(context);
      case 1:
        //  return _loadAcceptedOrdersListView();
        return _pastOrderWidget(context);
      default:
        return Text(
            "_getWidgetOfSelectedIndex() Error: Index $index isnt know");
    }
  }

  _logoutButton(BuildContext context) {
    return IconButton(
        onPressed: () async {
          await deleteAllToken();
          if (context.mounted) {
            Navigator.of(context)
                .pushNamedAndRemoveUntil("/login", (route) => false);
          }
        },
        icon: const Icon(Icons.logout));
  }
}
