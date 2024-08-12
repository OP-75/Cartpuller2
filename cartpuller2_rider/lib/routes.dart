import 'package:cartpuller2_rider/Pages/home_page.dart';
import 'package:cartpuller2_rider/Pages/login_page.dart';
import 'package:cartpuller2_rider/Pages/order_details_page.dart';
import 'package:cartpuller2_rider/Pages/signup_page.dart';

final appRoutes = {
  "/login": (context) => LoginPage(),
  "/signup": (context) => const SignupPage(),
  "/home": (context) => const HomePage(),
  "/order-details": (context) => const OrderDetailsPage(),
};
