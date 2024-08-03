import 'package:cartpuller2_user/API_calls/vegetable.dart';
import 'package:cartpuller2_user/Custom_exceptions/invalid_token.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as dev;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<List<Vegetable>> _products = getVegetables();
  Map<String, int> cartItems = {}; //productId : quantity
  int count = 0;

  @override
  Widget build(BuildContext context) {
    dev.log(cartItems.toString());
    return Scaffold(
        appBar: AppBar(
          title: const Text("Cartpuller"),
        ),
        body: FutureBuilder(
          future: _products,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final List<Vegetable> vegetableList = snapshot.data!;
              return ListView.builder(
                itemCount: vegetableList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(vegetableList[index].title!),
                    subtitle: Text(vegetableList[index].price!.toString()),
                    trailing: Wrap(
                      children: [
                        IconButton(
                            onPressed: () {
                              setState(() {
                                _addItemToCart(vegetableList[index].id!);
                              });
                            },
                            icon: const Icon(Icons.add)),
                        SizedBox(
                            width: 50,
                            height: 50,
                            child: Center(
                              child: Text(
                                getQuantityFromCart(vegetableList[index].id!),
                                style: const TextStyle(fontSize: 20),
                                textAlign: TextAlign.center,
                              ),
                            )),
                        IconButton(
                            onPressed: () {
                              setState(() {
                                _removeItemFromCart(vegetableList[index].id!);
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
}
