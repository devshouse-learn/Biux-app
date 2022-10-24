import 'package:biux/config/strings.dart';
import 'package:biux/data/models/story.dart';
import 'package:biux/data/repositories/authentication_repository.dart';
import 'dart:io';
import 'package:biux/data/repositories/stories/stories_repository_abstract.dart';
import 'package:biux/utils/bytes_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_native_image/flutter_native_image.dart';

class StoriesFirebaseRepository extends StoriesRepositoryAbstract {
  static final collection = 'stories';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  @override
  Future<bool> createStory({
    required Story story,
    required List<File> listFile,
  }) async {
    try {
      final result = await firestore.collection(collection).add(
            story.toJson(),
          );
      final listImages = await uploadStory(
        id: result.id,
        listFile: listFile,
      );
      updateStory(
        id: result.id,
        story: Story(
          description: story.description,
          files: listImages,
          tags: story.tags,
          user: story.user,
          creationDate: story.creationDate,
          listReactions: story.listReactions,
        ),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future deleteStory(String id) async {
    try {
      await firestore.collection(collection).doc(id).delete();
    } catch (e) {}
  }

  @override
  Future<List<Story>> getStories() async {
    try {
      final result = await firestore.collection(collection).get();

      return result.docs
          .map(
            (e) => Story.fromJson(e.data(), e.id),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<String>> uploadStory({
    required String id,
    required List<File> listFile,
  }) async {
    List<String> listUrl = [];
    List<String> listNamesPhotos = [
      'photo1',
      'photo2',
      'photo3',
    ];
    for (var element in listFile) {
      final image = await uploadImageStory(
        nameUrl: listNamesPhotos.removeAt(0),
        id: id,
        fileUrl: element,
      );
      listUrl.add(image);
    }
    return listUrl;
  }

  Future<String> uploadImageStory({
    required String nameUrl,
    required String id,
    required File fileUrl,
  }) async {
    try {
      String bytes = BytesExtension().getBytes(fileUrl.lengthSync());
      if (bytes.replaceRange(0, bytes.length - 2, '') == AppStrings.megaBytes ||
          bytes.replaceRange(0, bytes.length - 2, '') == AppStrings.kiloBytes &&
              int.parse(
                      bytes.replaceRange(bytes.length - 2, bytes.length, '')) >=
                  200) fileUrl = await compressImage(fileUrl, bytes);
      final userId = AuthenticationRepository().getUserId;
      Reference ref = FirebaseStorage.instance.ref('$userId/$id/$nameUrl');
      UploadTask uploadTask = ref.putFile(fileUrl);
      String downloadUrl = await (await uploadTask).ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      return '';
    }
  }

  Future<File> compressImage(File image, String bytes) async {
    final compressImage = await FlutterNativeImage.compressImage(
      image.path,
      quality: 80,
      targetWidth:
          bytes.replaceRange(0, bytes.length - 2, '') == AppStrings.megaBytes
              ? 800
              : 900,
      targetHeight:
          bytes.replaceRange(0, bytes.length - 2, '') == AppStrings.megaBytes
              ? 800
              : 900,
    );
    return compressImage;
  }

  Future<bool> updateStory({required String id, required Story story}) async {
    try {
      await FirebaseFirestore.instance
          .collection(collection)
          .doc(id)
          .update(story.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<Story>> getStoriesId(String id) async {
    try {
      final response = await firestore
          .collection(collection)
          .where('userId', isEqualTo: id)
          .get();
      return response.docs
          .map(
            (e) => Story.fromJson(
              e.data(),
              e.id,
            ),
          )
          .toList();
    } catch (e) {
      return List.empty();
    }
  }
}
