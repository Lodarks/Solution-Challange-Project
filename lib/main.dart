import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_share/features/auth/screens/login.dart';
import 'package:food_share/router.dart';
import 'features/restaurant_feature/screens/restaurant_main_screen.dart';
import 'features/user_feature/screens/user_main_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Share',
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (settings) => generateRoute(settings),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: FutureBuilder<User?>(
        future: FirebaseAuth.instance.authStateChanges().first,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }
            if (snapshot.hasData) {
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('restaurants')
                    .doc(snapshot.data!.uid)
                    .get(),
                builder: (context, restaurantSnapshot) {
                  if (restaurantSnapshot.connectionState ==
                      ConnectionState.done) {
                    if (restaurantSnapshot.hasData &&
                        restaurantSnapshot.data!.exists) {
                      // Eğer restaurants koleksiyonunda belge varsa ve bu belge mevcutsa
                      return const RestaurantMainScreen();
                    } else {
                      // Eğer restaurants koleksiyonunda belge yoksa veya belge boşsa
                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(snapshot.data!.uid)
                            .get(),
                        builder: (context, userSnapshot) {
                          if (userSnapshot.connectionState ==
                              ConnectionState.done) {
                            if (userSnapshot.hasData &&
                                userSnapshot.data!.exists) {
                              // Eğer users koleksiyonunda belge varsa ve bu belge mevcutsa
                              return const UserMainScreen();
                            } else {
                              // Eğer users koleksiyonunda belge yoksa veya belge boşsa
                              return const LoginScreen();
                            }
                          } else {
                            return const Scaffold(
                              body: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                        },
                      );
                    }
                  } else {
                    return const Scaffold(
                      body: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                },
              );
            } else {
              // Oturum açmış kullanıcı yoksa
              return LoginScreen();
            }
          } else {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
    );
  }
}
