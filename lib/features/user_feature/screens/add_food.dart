import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_share/features/auth/repository/auth_repository.dart';
import 'package:food_share/features/restaurant_feature/controller/restaurant_controller.dart';
import 'package:food_share/models/restaurant_model.dart';

import '../../../common/utils/utils.dart';

class AddFoodPage extends ConsumerStatefulWidget {
  static const String routeName = '/restaurant-add-food';
  const AddFoodPage({super.key});

  @override
  ConsumerState<AddFoodPage> createState() => _AddFoodPageState();
}

class _AddFoodPageState extends ConsumerState<AddFoodPage> {
  TextEditingController foodNameController = TextEditingController();
  File? image;

  void selectImage() async {
    image = await pickImageFromCamera(context);
    setState(() {});
  }

  void saveFood() async {
    RestaurantModel? restaurant =
        await ref.read(authRepositoryProvider).getRestaurantData();
    if (restaurant != null) {
      if (image != null && foodNameController.text.isNotEmpty) {
        // ignore: use_build_context_synchronously
        ref.read(restaurantControllerProvider).addPostToFirebase(
            context,
            foodNameController.text,
            image,
            restaurant.restaurantId,
            restaurant.restaurantName,
            restaurant.restaurantAddress);
      } else {
        // ignore: use_build_context_synchronously
        showSnackBar(context: context, content: 'Please fill all fields');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Food'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: height * 0.03),
                child: SizedBox(
                  width: width * 0.8,
                  child: TextField(
                    controller: foodNameController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.title),
                      labelText: 'Food Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: height * 0.03),
                child: SizedBox(
                  width: width * 0.8,
                  height: height * 0.06,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
                      ),
                      onPressed: () {
                        selectImage();
                      },
                      child: const Icon(Icons.add_a_photo_outlined)),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: height * 0.03),
                child: SizedBox(
                  width: width * 0.8,
                  height: height * 0.3,
                  child: image != null
                      ? Image.file(
                          image!,
                          fit: BoxFit.cover,
                        )
                      : const Center(
                          child: Text('No Image'),
                        ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: height * 0.24),
                child: SizedBox(
                  width: width * 0.8,
                  height: height * 0.06,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
                      ),
                      onPressed: () {
                        saveFood();
                      },
                      child: const Text("Post")),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
