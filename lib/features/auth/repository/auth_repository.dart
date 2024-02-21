import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_share/features/auth/screens/choose.dart';
import 'package:food_share/features/auth/screens/login.dart';
import 'package:food_share/features/restaurant_feature/screens/restaurant_main_screen.dart';
import 'package:food_share/features/user_feature/screens/user_main_screen.dart';
import 'package:food_share/models/restaurant_model.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../common/utils/utils.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final firebaseAuth = FirebaseAuth.instance;
  final googleSignIn = GoogleSignIn();
  final firestore = FirebaseFirestore.instance;
  return AuthRepository(
      firebaseAuth: firebaseAuth,
      googleSignIn: googleSignIn,
      firestore: firestore);
});

class AuthRepository {
  final FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;
  final FirebaseFirestore firestore;

  AuthRepository(
      {required this.firebaseAuth,
      required this.googleSignIn,
      required this.firestore});

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      // Google Sign In provider'ını oluştur
      final GoogleSignIn googleSignIn = GoogleSignIn();

      // Google hesabıyla oturum açma panelini aç ve kullanıcının seçim yapmasını bekle
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        // Google hesabından yetkilendirme verisini al
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        // Google hesabı ile Firebase'i yetkilendir
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        // Firebase Authentication üzerinden oturum aç ve kullanıcıyı al
        final UserCredential authResult =
            await FirebaseAuth.instance.signInWithCredential(credential);
        final User? user = authResult.user;

        if (user != null) {
          final restaurantRef = FirebaseFirestore.instance
              .collection('restaurants')
              .doc(user.uid);
          final restaurantSnapshot = await restaurantRef.get();

          final userRef =
              FirebaseFirestore.instance.collection('users').doc(user.uid);
          final userSnapshot = await userRef.get();

          if (restaurantSnapshot.exists) {
            // ignore: use_build_context_synchronously
            Navigator.pushNamedAndRemoveUntil(
                context, RestaurantMainScreen.routeName, (route) => false);
          } else if (userSnapshot.exists) {
            // ignore: use_build_context_synchronously
            Navigator.pushNamedAndRemoveUntil(
                context, UserMainScreen.routeName, (route) => false);
          } else {
            // ignore: use_build_context_synchronously
            Navigator.pushNamedAndRemoveUntil(
                context, ChooseScreen.routeName, (route) => false);
          }
        }
      }
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
      // Hata durumunda kullanıcıya bir uyarı gösterilebilir veya başka bir işlem yapılabilir
    }
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // ignore: use_build_context_synchronously
      await sendEmailVerification(context);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showSnackBar(
            context: context, content: "The password provided is too weak.");
      } else if (e.code == 'email-already-in-use') {
        showSnackBar(
            context: context,
            content: "The account already exists for that email.");
      }
      showSnackBar(context: context, content: e.message!);
    }
  }

  Future<void> loginWithEmail({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // ignore: use_build_context_synchronously
      Navigator.pushNamedAndRemoveUntil(
          context, ChooseScreen.routeName, (route) => false);
      if (!firebaseAuth.currentUser!.emailVerified) {
        // ignore: use_build_context_synchronously
        await sendEmailVerification(context);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        showSnackBar(
            context: context,
            content: "Wrong password provided for that user.");
      } else {
        showSnackBar(context: context, content: e.message!);
      }
    }
  }

  Future<void> sendEmailVerification(BuildContext context) async {
    try {
      firebaseAuth.currentUser!.sendEmailVerification();
      showSnackBar(context: context, content: "Email verification sent!");
    } on FirebaseAuthException catch (e) {
      showSnackBar(context: context, content: e.message!);
    }
  }

  Future<void> saveRestaurantDataToFirebase(
      BuildContext context,
      String restaurantAdress,
      String restaurantId,
      String restaurantName,
      double latitude,
      double longitude) async {
    try {
      RestaurantModel restaurant = RestaurantModel(
          restaurantName: restaurantName,
          restaurantMail: firebaseAuth.currentUser!.email!,
          restaurantAddress: restaurantAdress,
          restaurantId: restaurantId,
          latitude: latitude,
          longitude: longitude);
      if (firebaseAuth.currentUser!.emailVerified) {
        firestore
            .collection('restaurants')
            .doc(firebaseAuth.currentUser!.uid)
            .set(restaurant.toMap());
      }
      Navigator.pushNamedAndRemoveUntil(
          context, RestaurantMainScreen.routeName, (route) => false);
    } catch (e) {
      showSnackBar(context: context, content: e.toString());

      // ignore: use_build_context_synchronously
      Navigator.pushNamedAndRemoveUntil(
          context, RestaurantMainScreen.routeName, (route) => false);
    }
  }

  Future<void> saveUserDataToFirebase(BuildContext context) async {
    try {
      if (firebaseAuth.currentUser!.emailVerified) {
        firestore.collection('users').doc(firebaseAuth.currentUser!.uid).set({
          'userName': firebaseAuth.currentUser!.displayName,
          'userMail': firebaseAuth.currentUser!.email,
        });
      }
      // ignore: use_build_context_synchronously
      Navigator.pushNamedAndRemoveUntil(
          context, UserMainScreen.routeName, (route) => false);
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
      // ignore: use_build_context_synchronously
      Navigator.pushNamedAndRemoveUntil(
          context, LoginScreen.routeName, (route) => false);
    }
  }

  Future<RestaurantModel?> getRestaurantData() async {
    try {
      DocumentSnapshot documentSnapshot = await firestore
          .collection('restaurants')
          .doc(firebaseAuth.currentUser!.uid)
          .get();

      if (documentSnapshot.exists) {
        if (documentSnapshot.data() != null) {
          return RestaurantModel.fromMap(
              documentSnapshot.data() as Map<String, dynamic>);
        } else {
          // ignore: avoid_print
          print('Belgenin içinde veri yok.');
          return null;
        }
      } else {
        // ignore: avoid_print
        print('Belge bulunamadı.');
        return null;
      }
    } catch (e) {
      // ignore: avoid_print
      print('Restoran verilerini alma hatası: $e');
      return null;
    }
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await firebaseAuth.signOut();
      await googleSignIn.signOut();
      // ignore: use_build_context_synchronously
      Navigator.pushNamedAndRemoveUntil(
          context, LoginScreen.routeName, (route) => false);
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }
}
