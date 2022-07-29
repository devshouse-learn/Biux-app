import 'package:biux/data/models/reaction_story.dart';
import 'package:biux/data/models/story.dart';
import 'dart:io';

import 'package:biux/data/repositories/stories/stories_repository_abstract.dart';
import 'package:biux/utils/firebase_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StoriesFirebaseRepository extends StoriesRepositoryAbstract {
  static final collection = 'stories';
  static final collectionReaction = 'reactionStory';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  @override
  Future createStory(Story story) async {
    try {
      await firestore
          .collection(collection)
          .doc(story.id.toString())
          .set(story.toJson());
    } catch (e) {}
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
            (e) => Story.fromJson(
              e.data(),
            ),
          )
          .toList();
    } catch (e) {
      return List.empty();
    }
  }

  @override
  Future<List<ReactionStory>> getReactionStory(String id) async {
    try {
      final result = await firestore
          .collection(collection)
          .doc(id)
          .collection(collectionReaction)
          .get();
      return result.docs
          .map(
            (e) => ReactionStory.fromJson(
              e.data(),
            ),
          )
          .toList();
    } catch (e) {
      return List.empty();
    }
  }

  @override
  Future reactionStory(String userId, String storyId) async {
    try {
      final response = await firestore
          .collection(collection)
          .doc(storyId)
          .collection(collectionReaction)
          .doc(userId)
          .set({
        'userId': userId,
        'storyId': storyId,
      });
    } catch (e) {}
  }

  Future deleteReactionStory(String userId, String storyId) async {
    try {
      final response = await firestore
          .collection(collection)
          .doc(storyId)
          .collection(collectionReaction)
          .doc(userId)
          .delete();
    } catch (e) {}
  }

  @override
  Future uploadStory(
      String id, File fileUrl1, File fileUrl2, File fileUrl3) async {
    await this.uploadImageStory(
      nameUrl: 'fileUrl1',
      id: id,
      fileUrl: fileUrl1,
    );
    await this.uploadImageStory(
      nameUrl: 'fileUrl2',
      id: id,
      fileUrl: fileUrl1,
    );
    await this.uploadImageStory(
      nameUrl: 'fileUrl3',
      id: id,
      fileUrl: fileUrl1,
    );
  }

  Future uploadImageStory({
    required String nameUrl,
    required String id,
    required File fileUrl,
  }) async {
    try {
      Reference ref = FirebaseStorage.instance.ref('$id/$nameUrl');
      UploadTask uploadTask = ref.putFile(fileUrl);
      String downloadUrl = await (await uploadTask).ref.getDownloadURL();
      await this.updateImage(nameUrl, downloadUrl, id);
    } catch (e) {}
  }

  Future updateImage(String name, String urlImage, String id) async {
    var reference = FirebaseFirestore.instance.collection(collection);
    reference.doc(id).update({
      name: urlImage,
    });
  }
}
