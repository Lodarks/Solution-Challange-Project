import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_share/features/auth/repository/auth_repository.dart';
import 'package:food_share/features/restaurant_feature/repository/restaurant_repository.dart';
import 'package:food_share/features/user_feature/screens/add_food.dart';
import 'package:food_share/models/food_post_model.dart';
import 'package:intl/intl.dart';

class RestaurantMainScreen extends ConsumerStatefulWidget {
  const RestaurantMainScreen({Key? key}) : super(key: key);
  static const String routeName = '/restaurant-main';

  @override
  _RestaurantMainScreenState createState() => _RestaurantMainScreenState();
}

class _RestaurantMainScreenState extends ConsumerState<RestaurantMainScreen> {
  Stream<List<FoodPostModel>>? foodPostsStream;

  @override
  void initState() {
    super.initState();
    getPosts();
  }

  void getPosts() {
    foodPostsStream =
        ref.read(restaurantRepositoryProvider).getFoodPostsStream();
    foodPostsStream!.listen((foodPosts) {
      setState(() {});
    }, onError: (error) {
      print('Error: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: height * 0.07,
        backgroundColor: Colors.blueGrey[900],
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              onPressed: () {
                ref.read(authRepositoryProvider).signOut(context);
              },
              icon: const Icon(Icons.exit_to_app),
              color: Colors.white,
            ),
          )
        ],
        title: Text(
          'Restaurant Name',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          Center(
            child: SizedBox(
              height: height * 0.9,
              width: width * 0.9,
              child: StreamBuilder<List<FoodPostModel>>(
                stream: foodPostsStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('There are no posts yet!'));
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final foodPost = snapshot.data![index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Container(
                            width: width * 0.7,
                            height: height * 0.49,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.grey[200],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: width * 0.05),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      foodPost.foodName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: EdgeInsets.only(left: width * 0.05),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      DateFormat.yMMMMd().format(
                                          DateTime.fromMillisecondsSinceEpoch(
                                              foodPost.createdAt)),
                                      style: const TextStyle(
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  height: height * 0.3,
                                  width: width * 0.7,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      image: NetworkImage(foodPost.imageUrl),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: width * 0.1,
            left: width * 0.1,
            child: Padding(
              padding: EdgeInsets.only(bottom: height * 0.05),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey[900],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, AddFoodPage.routeName);
                },
                child: const Text(
                  'Add Post',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
