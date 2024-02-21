import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_share/models/food_post_model.dart';
import 'package:food_share/models/restaurant_model.dart';

import '../../../common/repository/common_firebase_storage_repository.dart';

final restaurantRepositoryProvider = Provider((ref) => RestaurantRepository(
    auth: FirebaseAuth.instance, firestore: FirebaseFirestore.instance));

class RestaurantRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  RestaurantRepository({required this.auth, required this.firestore});

  Future<void> addFoodPost({
    required String foodName,
    required File? postImage,
    required String restaurantId,
    required String restaurantName,
    required String adress,
    required ProviderRef ref,
  }) async {
    try {
      String uid = auth.currentUser!.uid;
      String fileName = '$uid-${DateTime.now().millisecondsSinceEpoch}';
      var imageUrl = await ref
          .read(commonFirebaseStorageRepositoryProvider)
          .storeFileToFirebase('postImage/$fileName', postImage!);

      var food = FoodPostModel(
          foodName: foodName,
          imageUrl: imageUrl,
          restaurantId: restaurantId,
          restaurantName: restaurantName,
          adress: adress,
          createdAt: DateTime.now().millisecondsSinceEpoch);

      await firestore.collection('food_posts').doc().set(food.toMap());
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }
  }

  Stream<List<FoodPostModel>> getFoodPostsStream() {
    try {
      var foodPostsStream = firestore.collection('food_posts').snapshots();
      return foodPostsStream.map((snapshot) => snapshot.docs
          .map((doc) => FoodPostModel.fromMap(doc.data()))
          .toList());
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
      // Hata durumunda boş bir Stream döndürüyoruz
      return Stream.value([]);
    }
  }

  Future<FoodPostModel?> getPostDetail(String postId) async {
    try {
      var postDetail =
          await firestore.collection('food_posts').doc(postId).get();
      if (postDetail.exists) {
        var post = postDetail.data();
        if (kDebugMode) {
          print('Post Detail: $post');
        }
        return FoodPostModel.fromMap(post!);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }
    // Tüm kod yolları sona erdiğinde null döndür.
    return null;
  }

  Future<RestaurantModel?> getRestaurantData(String id) async {
    QuerySnapshot restaurantSnapshot =
        await firestore.collection('restaurants').get();

    RestaurantModel? restaurant;

    for (QueryDocumentSnapshot doc in restaurantSnapshot.docs) {
      RestaurantModel model =
          RestaurantModel.fromMap(doc.data() as Map<String, dynamic>);
      if (model.restaurantId == id) {
        restaurant = model;
        break;
      }
    }

    return restaurant;
  }
}
