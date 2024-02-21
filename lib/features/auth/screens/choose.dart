import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_share/features/auth/repository/auth_repository.dart';
import 'package:food_share/features/auth/screens/restaurant_auth.dart';

class ChooseScreen extends ConsumerStatefulWidget {
  const ChooseScreen({super.key});
  static const String routeName = '/choose-screen';

  @override
  ConsumerState<ChooseScreen> createState() => _ChooseScreenState();
}

class _ChooseScreenState extends ConsumerState<ChooseScreen> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Center(
          child: Padding(
        padding: EdgeInsets.only(top: height * 0.15),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: height * 0.05),
              child: const Text(
                "Choose your role",
                style: TextStyle(fontSize: 30),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 150,
                  width: 155,
                  child: ElevatedButton(
                    onPressed: () {
                      ref
                          .read(authRepositoryProvider)
                          .saveUserDataToFirebase(context);
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blueGrey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      "User",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                SizedBox(
                  width: width * 0.04,
                ),
                SizedBox(
                  height: 150,
                  width: 155,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, RestaurantAuth.routeName);
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.brown,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      "Restaurant",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      )),
    );
  }
}
