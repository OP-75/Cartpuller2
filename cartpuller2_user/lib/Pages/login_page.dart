import 'package:cartpuller2_user/API_calls/login_request.dart';
import 'package:cartpuller2_user/constants.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Create storage to store JWT
  final storage = const FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const Padding(
                padding: EdgeInsets.only(top: 110.0),
                child: Center(
                  child: SizedBox(
                    width: 200,
                    height: 100,
                    child: Center(
                        child: Text(
                      "Cartpuller",
                      style: TextStyle(fontSize: 40),
                    )),
                  ),
                )),
            Padding(
              // padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                controller: emailController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                    hintText: 'Enter valid email id as abc@gmail.com'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 15.0, right: 15.0, top: 15, bottom: 0),
              //padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                    hintText: 'Enter password'),
              ),
            ),
            SizedBox(
              height: 65,
              width: 360,
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: ElevatedButton(
                  style: const ButtonStyle(
                    backgroundColor:
                        MaterialStatePropertyAll<Color>(Colors.lightBlue),
                  ),
                  child: const Text(
                    'Log in ',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  onPressed: () {
                    handleLogin(context);
                  },
                ),
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Center(
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 62),
                    child: Text('New to cartpuller?'),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 1.0),
                    child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, "/signup");
                        },
                        child: const Text(
                          'Sign up!',
                          style: TextStyle(fontSize: 14, color: Colors.blue),
                        )),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void handleLogin(BuildContext context) async {
    Map<String, String> loginForm = {
      "email": emailController.text,
      "password": passwordController.text,
    };

    try {
      Token responseTokens = await login(loginForm);
      developer.log(responseTokens.toString());
      if (responseTokens.error != null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error: ${responseTokens.error}")));
        }
      } else {
        await storage.delete(key: TOKEN);
        await storage.delete(key: REFRESH_TOKEN);
        // Write JWT in storage
        await storage.write(key: TOKEN, value: responseTokens.accessToken);
        await storage.write(
            key: REFRESH_TOKEN, value: responseTokens.refreshToken);

        // String? _token = await storage.read(key: TOKEN);
        // String? _refreshToken = await storage.read(key: REFRESH_TOKEN);
        // developer.log(
        //     "-----Storage-----\nToken: $_token, Refresh token: $_refreshToken");

        if (context.mounted) {
          Navigator.of(context).popAndPushNamed("/home");
        }
      }
    } catch (e) {
      developer.log("Error in handleSignup(): ${e.toString()}");
    }
  }
}
