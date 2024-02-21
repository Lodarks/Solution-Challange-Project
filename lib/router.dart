import 'package:flutter/material.dart';
import 'package:food_share/features/auth/screens/choose.dart';
import 'package:food_share/features/auth/screens/login.dart';
import 'package:food_share/features/auth/screens/restaurant_auth.dart';
import 'package:food_share/features/restaurant_feature/screens/restaurant_main_screen.dart';
import 'package:food_share/features/user_feature/screens/add_food.dart';
import 'package:food_share/features/user_feature/screens/user_main_screen.dart';

import 'features/auth/screens/register_screen.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case LoginScreen.routeName:
      return MaterialPageRoute(builder: (context) => const LoginScreen());
    case RegisterScreen.routeName:
      return MaterialPageRoute(builder: (context) => const RegisterScreen());
    case ChooseScreen.routeName:
      return MaterialPageRoute(builder: (context) => const ChooseScreen());
    case RestaurantAuth.routeName:
      return MaterialPageRoute(builder: (context) => const RestaurantAuth());
    case RestaurantMainScreen.routeName:
      return MaterialPageRoute(
          builder: (context) => const RestaurantMainScreen());
    case UserMainScreen.routeName:
      return MaterialPageRoute(builder: (context) => const UserMainScreen());
    case AddFoodPage.routeName:
      return MaterialPageRoute(builder: (context) => const AddFoodPage());
    default:
      return MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Error'),
          ),
          body: const Center(
            child: Text('Page not found'),
          ),
        ),
      );
  }
}
