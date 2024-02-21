import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void showSnackBar({required BuildContext context, required String content}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(content)));
}

// Future<File?> pickImageFromCamera(BuildContext context) async {
//   File? image;
//   try {
//     final pickedImage =
//         await ImagePicker().pickImage(source: ImageSource.camera,

//         );
//     if (pickedImage != null) {
//       image = File(pickedImage.path);
//     }
//   } catch (e) {
//     showSnackBar(context: context, content: e.toString());
//   }
//   return image;
// }

Future<File?> pickImageFromCamera(BuildContext context) async {
  File? image;
  try {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 80, // Resim kalitesi
      maxHeight: 800, // Maksimum yükseklik
      maxWidth: 800, // Maksimum genişlik
    );
    if (pickedImage != null) {
      // Alınan dosyanın resim olup olmadığını kontrol edin
      if (pickedImage.path.endsWith('.jpg') ||
          pickedImage.path.endsWith('.jpeg') ||
          pickedImage.path.endsWith('.png')) {
        image = File(pickedImage.path);
      } else {
        // ignore: use_build_context_synchronously
        showSnackBar(context: context, content: 'Lütfen bir resim seçin');
      }
    }
  } catch (e) {
    showSnackBar(context: context, content: e.toString());
  }
  return image;
}