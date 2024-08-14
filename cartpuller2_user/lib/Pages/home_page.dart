import 'package:cartpuller2_user/API_calls/order_post.dart';
import 'package:cartpuller2_user/API_calls/past_orders.dart';
import 'package:cartpuller2_user/API_calls/vegetable.dart';
import 'package:cartpuller2_user/Custom_exceptions/empty_cart.dart';
import 'package:cartpuller2_user/Custom_exceptions/invalid_token.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as dev;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  Future<List<Vegetable>> _products = getVegetables();
  List<Vegetable>? _veggieList;
  Map<String, int> cartItems = {}; //productId : quantity
  int count = 0;

  int _currIndex = 0;

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    dev.log(cartItems.toString());
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cartpuller"),
      ),
      body: _getSelectedPageWidget(context),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue,
        currentIndex: _currIndex,
        onTap: (index) {
          setState(() {
            _currIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.local_grocery_store), label: "Products"),
          BottomNavigationBarItem(
              icon: Icon(Icons.history), label: "Your orders"),
        ],
      ),
    );
  }

  Widget _getSelectedPageWidget(BuildContext context) {
    switch (_currIndex) {
      case 0:
        return _getProductsPage(context);
      case 1:
        return _pastOrderWidget(context);

      default:
        return Text("_currIndex: $_currIndex is invalid");
    }
  }

  Widget _pastOrderWidget(BuildContext context) {
    return FutureBuilder(
      future: _fetchPastOrders(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            return _pastOrdersListView(snapshot.data!, context);
          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else {
            return const Text("");
          }
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  Widget _pastOrdersListView(
      List<Map<String, dynamic>> ordersList, BuildContext context) {
    return ListView.builder(
        itemCount: ordersList.length,
        itemBuilder: (context, index) {
          final currOrder = ordersList[index];

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.5)),
              tileColor: currOrder['orderStatus'] == "DELIVERED"
                  ? Colors.grey[300]
                  : Colors.amber,
              title: Text("Order ID: ${currOrder['id']}"),
              subtitle: Text("Status = ${currOrder['orderStatus']}"),
              trailing: currOrder['orderStatus'] == "DELIVERED"
                  ? const SizedBox(
                      width: 0,
                    )
                  : OutlinedButton(
                      child: const Text("Open"),
                      onPressed: () {
                        Navigator.of(context).pushNamed("/order-details",
                            arguments: currOrder['id']);
                      },
                    ),
            ),
          );
        });
  }

  Widget _getProductsPage(BuildContext context) {
    return Column(
      children: [
        FutureBuilder(
          future: _products,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              _veggieList = snapshot.data!;
              return ListView.builder(
                shrinkWrap: true,
                itemCount: _veggieList?.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_veggieList![index].title!),
                    subtitle: Text(_veggieList![index].price!.toString()),
                    trailing: Wrap(
                      children: [
                        IconButton(
                            onPressed: () {
                              setState(() {
                                _addItemToCart(_veggieList![index].id!);
                              });
                            },
                            icon: const Icon(Icons.add)),
                        SizedBox(
                            width: 50,
                            height: 50,
                            child: Center(
                              child: Text(
                                getQuantityFromCart(_veggieList![index].id!),
                                style: const TextStyle(fontSize: 20),
                                textAlign: TextAlign.center,
                              ),
                            )),
                        IconButton(
                            onPressed: () {
                              setState(() {
                                _removeItemFromCart(_veggieList![index].id!);
                              });
                            },
                            icon: const Icon(Icons.remove)),
                      ],
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              if (snapshot.error is InvalidTokenException) {
                WidgetsBinding.instance.addPostFrameCallback(
                    (_) => Navigator.of(context).popAndPushNamed('/login'));
                return const Text("");
              } else {
                return Column(
                  children: [
                    Center(
                      child: Text("Error ${snapshot.error.toString()}"),
                    ),
                    TextButton(
                        onPressed: () {
                          setState(() {
                            //use set state to refresh
                            count++;
                            _products = getVegetables();
                          });
                        },
                        child: const Text("Reload"))
                  ],
                );
              }
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
        Expanded(
            child: Align(
          alignment: Alignment.bottomCenter,
          // padding: const EdgeInsets.only(top: 470),
          child: _getCheckoutButton(),
        ))
      ],
    );
  }

  String getQuantityFromCart(String productId) {
    if (cartItems.containsKey(productId)) {
      return cartItems[productId].toString();
    } else {
      return "0";
    }
  }

  void _addItemToCart(String productId) {
    int existingQty = 0;
    if (cartItems.containsKey(productId)) {
      existingQty = cartItems[productId]!;
    }

    cartItems[productId] = existingQty + 1;
  }

  void _removeItemFromCart(String productId) {
    int existingQty = 0;
    if (cartItems.containsKey(productId)) {
      existingQty = cartItems[productId]!;
    }

    if (existingQty <= 1) {
      cartItems.remove(productId);
    } else {
      cartItems[productId] = existingQty - 1;
    }
  }

  Widget _getCheckoutButton() {
    return SizedBox(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: Text("Total: ${_getTotal()}")),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Center(
                child: TextButton(
                    style: const ButtonStyle(
                        padding: WidgetStatePropertyAll(
                            EdgeInsets.symmetric(horizontal: 22, vertical: 10)),
                        foregroundColor: WidgetStatePropertyAll(Colors.white),
                        backgroundColor: WidgetStatePropertyAll(Colors.blue)),
                    onPressed: () => _handleCheckout(context),
                    child: const Text("Checkout"))),
          )
        ],
      ),
    );
  }

  String _getTotal() {
    if (cartItems.isEmpty || _veggieList == null) {
      return "";
    } else {
      int total = 0;
      for (String productId in cartItems.keys) {
        for (Vegetable veggie in _veggieList!) {
          if (veggie.id == productId) {
            total += (veggie.price! * cartItems[productId]!);
          }
        }
      }
      return total.toString();
    }
  }

  Future<void> _handleCheckout(BuildContext context) async {
    try {
      Order order = await postOrder(cartItems);
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Order id: ${order.id}")));
      }
      setState(() {
        cartItems = {};
      });
    } catch (e) {
      if (e is EmptyCartException && context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      } else if (e is InvalidTokenException && context.mounted) {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(e.toString())));
          Navigator.of(context).popAndPushNamed('/login');
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(e.toString())));
        }
      }
    }
  }

  Future<List<Map<String, dynamic>>> _fetchPastOrders(
      BuildContext context) async {
    try {
      return await getPastOrders();
    } on InvalidTokenException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
      Navigator.of(context).popAndPushNamed("/login");
      rethrow;
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
      rethrow;
    }
  }
}
