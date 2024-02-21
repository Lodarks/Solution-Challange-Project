import 'dart:io';
import 'package:flutter/material.dart';
import 'package:food_share/features/restaurant_feature/repository/restaurant_repository.dart';
import 'package:food_share/features/restaurant_feature/screens/restaurant_main_screen.dart';
// ignore: depend_on_referenced_packages
import 'package:riverpod/riverpod.dart';

final restaurantControllerProvider = Provider((ref) {
  final restaurantRepository = ref.watch(restaurantRepositoryProvider);
  return RestaurantController(
      restaurantRepository: restaurantRepository, ref: ref);
});

class RestaurantController {
  final RestaurantRepository restaurantRepository;
  final ProviderRef ref;

  RestaurantController({required this.restaurantRepository, required this.ref});

  void addPostToFirebase(BuildContext context, String name, File? image,
      String restaurantId, String restaurantName, String adress) async {
    await restaurantRepository.addFoodPost(
        foodName: name,
        postImage: image,
        restaurantId: restaurantId,
        restaurantName: restaurantName,
        adress: adress,
        ref: ref);
    // ignore: use_build_context_synchronously
    Navigator.pushNamedAndRemoveUntil(
        context, RestaurantMainScreen.routeName, (route) => false);
  }
}
