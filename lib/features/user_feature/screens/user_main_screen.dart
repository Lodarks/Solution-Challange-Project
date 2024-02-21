import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_share/features/user_feature/screens/post_detail_page.dart';
import 'package:intl/intl.dart';

import '../../../models/food_post_model.dart';
import '../../auth/repository/auth_repository.dart';
import '../../restaurant_feature/repository/restaurant_repository.dart';

class UserMainScreen extends ConsumerStatefulWidget {
  const UserMainScreen({super.key});
  static const String routeName = '/user-main';

  @override
  ConsumerState<UserMainScreen> createState() => _UserMainScreenState();
}

class _UserMainScreenState extends ConsumerState<UserMainScreen> {
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
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          title: const Text('User Main Screen'),
          actions: [
            IconButton(
              onPressed: () {
                ref.read(authRepositoryProvider).signOut(context);
              },
              icon: const Icon(Icons.exit_to_app),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Center(
            child: SizedBox(
              width: width * 0.9,
              height: height * 0.9,
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
                          child: InkWell(
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return PostDetailPage(
                                  postId: foodPost.restaurantId,
                                  adress: foodPost.adress,
                                  imageUrl: foodPost.imageUrl,
                                  restaurantName: foodPost.restaurantName,
                                  foodName: foodPost.foodName,
                                );
                              }));
                            },
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
                                    padding:
                                        EdgeInsets.only(left: width * 0.05),
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
                                    padding:
                                        EdgeInsets.only(left: width * 0.05),
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
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ),
        ));
  }
}
