import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_share/features/restaurant_feature/repository/restaurant_repository.dart';
import 'package:food_share/models/restaurant_model.dart';
import 'package:url_launcher/url_launcher.dart';

class PostDetailPage extends ConsumerStatefulWidget {
  final String postId;
  final String restaurantName;
  final String adress;
  final String imageUrl;
  final String foodName;

  static const String routeName = '/post-detail';
  const PostDetailPage(
      {super.key,
      required this.postId,
      required this.adress,
      required this.imageUrl,
      required this.restaurantName,
      required this.foodName});

  @override
  ConsumerState<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends ConsumerState<PostDetailPage> {
  RestaurantModel? restaurantModel;
  double latitude = 0;
  double longitude = 0;
  // late Future<RestaurantModel> restaurantFuture;

  // @override
  // void initState() {
  //   super.initState();
  //   restaurantFuture = getRestaurantData();
  // }

  // void getRestaurantData(String id) async {
  //   RestaurantModel? restaurant = await ref
  //       .read(restaurantRepositoryProvider)
  //       .getRestaurantData(widget.postId);
  //   if (restaurant != null) {
  //     latitude = restaurant.latitude;
  //     longitude = restaurant.longitude;
  //   } else {
  //     // Restoran verisi alınamadı, hata işleme yapılabilir
  //     print('Restoran verisi bulunamadı.');
  //   }
  // }

  Future<void> launchURL() async {
    RestaurantModel? restaurant = await ref
        .read(restaurantRepositoryProvider)
        .getRestaurantData(widget.postId);

    if (restaurant != null) {
      latitude = restaurant.latitude;
      longitude = restaurant.longitude;
    }

    String googleMapslocationUrl =
        "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude";

    final String encodedURl = Uri.encodeFull(googleMapslocationUrl);

    if (await canLaunch(encodedURl)) {
      await launch(encodedURl);
    } else {
      print('Could not launch $encodedURl');
      throw 'Could not launch $encodedURl';
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Detail'),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: height * 0.02,
            ),
            Container(
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(20)),
              child: Image.network(
                widget.imageUrl,
                width: width * 0.9,
                height: height * 0.3,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(
              height: height * 0.02,
            ),
            SizedBox(width: width * 0.9, child: Text(widget.foodName)),
            SizedBox(
              height: height * 0.02,
            ),
            SizedBox(width: width * 0.9, child: Text(widget.restaurantName)),
            SizedBox(
              height: height * 0.02,
            ),
            SizedBox(width: width * 0.9, child: Text(widget.adress)),
            SizedBox(
              height: height * 0.02,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5))),
              onPressed: launchURL,
              child: const Text('Haritada Göster'),
            ),
          ],
        ),
      ),
    );
  }
}
