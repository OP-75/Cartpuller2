import 'package:cartpuller2_cartpuller/Pages/home_page.dart';
import 'package:cartpuller2_cartpuller/Pages/login_page.dart';
import 'package:cartpuller2_cartpuller/Pages/signup_page.dart';

final appRoutes = {
  "/login": (context) => LoginPage(),
  "/signup": (context) => const SignupPage(),
  "/home": (context) => const HomePage(),
};
