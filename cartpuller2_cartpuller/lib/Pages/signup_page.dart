import 'package:cartpuller2_cartpuller/API_calls/signup_request.dart';
import 'package:cartpuller2_cartpuller/Helper_functions/determine_user_position.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

import 'package:geolocator/geolocator.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final addressController = TextEditingController();

  String? _error;

  @override
  Widget build(BuildContext context) {
    determinePosition();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Sign up as seller"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const Padding(
                padding: EdgeInsets.only(top: 0.0, left: 0),
                child: Center(
                  child: SizedBox(
                    width: 200,
                    height: 100,
                    child: Center(
                        child: Text(
                      "Cartpuller",
                      style: TextStyle(fontSize: 20),
                    )),
                  ),
                )),
            Padding(
              // padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
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
                keyboardType: TextInputType.visiblePassword,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                    hintText: 'Enter password'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 15.0, right: 15.0, top: 15, bottom: 0),
              // padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                controller: nameController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Name',
                    hintText: 'Enter your name'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 15.0, right: 15.0, top: 15, bottom: 0),
              // padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                controller: phoneNumberController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Phone number',
                    hintText: 'Enter your phone number'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 15.0, right: 15.0, top: 15, bottom: 0),
              // padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                controller: addressController,
                keyboardType: TextInputType.streetAddress,
                maxLines: 3,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Operating region',
                    hintText: 'Enter operating region'),
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
                        WidgetStatePropertyAll<Color>(Colors.lightBlue),
                  ),
                  child: const Text(
                    'Sign up',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  onPressed: () async {
                    developer.log("Signup callback");
                    await handleSignup(context);
                    developer.log("Signup callback end");
                  },
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Center(
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 62),
                    child: Text('Existing user?'),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 1.0),
                    child: InkWell(
                        onTap: () {
                          Navigator.popAndPushNamed(context, "/login");
                        },
                        child: const Text(
                          'Log in!',
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

  Future<void> handleSignup(BuildContext context) async {
    _error = null;

    try {
      developer.log("start of handleSignup()");

      Position currPosition = await determinePosition();

      developer.log(currPosition.toString());

      Map<String, String> signupForm = {
        "email": emailController.text,
        "password": passwordController.text,
        "name": nameController.text,
        "phoneNumber": phoneNumberController.text,
        "address": addressController.text,
        "longitude": currPosition.longitude.toString(),
        "latitude": currPosition.latitude.toString(),
      };
      developer.log(signupForm.toString());
      Map<String, dynamic> response = await signup(signupForm);
      developer.log(response.toString());
      if (response.containsKey("error")) {
        _error = response["error"] as String;
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("Error: ${_error!}")));
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Registered Sucessfully")));
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      developer.log("Error in handleSignup(): ${e.toString()}");
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Exeption: ${e.toString()}")));
      }
    }
  }
}
