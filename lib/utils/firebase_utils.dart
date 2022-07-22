import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseUtils {
  Future<String> uploadImage({
    required String imageFolder,
    required String nameImage,
    required File image,
  }) async {
    try {
      Reference ref =
          FirebaseStorage.instance.ref().child('$imageFolder/$nameImage');
      UploadTask uploadTask = ref.putFile(image);
      String downloadUrl = await (await uploadTask).ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      return '';
    }
  }
}
