import 'dart:io';

import 'package:biux/config/strings.dart';
import 'package:biux/utils/bytes_utils.dart';
import 'package:firebase_storage/firebase_storage.dart';
//import 'package:flutter_native_image/flutter_native_image.dart';

class FirebaseUtils {
  Future<String> uploadImage({
    required String imageFolder,
    required String nameImage,
    required File image,
  }) async {
    try {
      String bytes = BytesExtension().getBytes(image.lengthSync());
      if (bytes.replaceRange(0, bytes.length - 2, '') == AppStrings.megaBytes ||
          bytes.replaceRange(0, bytes.length - 2, '') == AppStrings.kiloBytes &&
              int.parse(
                      bytes.replaceRange(bytes.length - 2, bytes.length, '')) >=
                  200) image = await compressImage(image, bytes);
      Reference ref =
          FirebaseStorage.instance.ref().child('$imageFolder/$nameImage');
      UploadTask uploadTask = ref.putFile(image);
      String downloadUrl = await (await uploadTask).ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      return '';
    }
  }

  Future<File> compressImage(File image, String bytes) async {
    // final compressImage = await FlutterNativeImage.compressImage(
    //   image.path,
    //   quality: 80,
    //   targetWidth:
    //       bytes.replaceRange(0, bytes.length - 2, '') == AppStrings.megaBytes
    //           ? 800
    //           : 900,
    //   targetHeight:
    //       bytes.replaceRange(0, bytes.length - 2, '') == AppStrings.megaBytes
    //           ? 800
    //           : 900,
    // );
    return image;
  }
}
