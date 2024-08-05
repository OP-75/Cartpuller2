import 'package:cartpuller2_user/API_calls/order_post.dart';
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
  ScrollController _scrollController = ScrollController();
  Future<List<Vegetable>> _products = getVegetables();
  List<Vegetable>? _veggieList;
  Map<String, int> cartItems = {}; //productId : quantity
  int count = 0;

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
        body: Column(
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
                                    getQuantityFromCart(
                                        _veggieList![index].id!),
                                    style: const TextStyle(fontSize: 20),
                                    textAlign: TextAlign.center,
                                  ),
                                )),
                            IconButton(
                                onPressed: () {
                                  setState(() {
                                    _removeItemFromCart(
                                        _veggieList![index].id!);
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
            Padding(
              padding: const EdgeInsets.only(top: 500),
              child: _getCheckoutWidget(),
            )
          ],
        ));
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

  Widget _getCheckoutWidget() {
    return SizedBox(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: Text(_getTotal())),
          Center(
              child: TextButton(
                  onPressed: () => _handleCheckout(context),
                  child: const Text("Checkout")))
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
}
