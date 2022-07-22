import 'package:biux/data/models/story_item.dart';
import 'package:biux/data/models/story.dart';
import 'dart:io';

import 'package:biux/data/repositories/stories/stories_repository_abstract.dart';
import 'package:biux/utils/firebase_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StoriesFirebaseRepository extends StoriesRepositoryAbstract {
  static final collection = 'stories';
  static final collectionItem = 'storiesItem';
  static final collectionReaction = 'reactionsStory';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  @override
  Future<StoryItem?> createStoryItem(StoryItem storyItem) async {
    try {
      await firestore
          .collection(collectionItem)
          .doc(storyItem.id.toString())
          .set(storyItem.toJson());
      final response = await firestore
          .collection(collection)
          .where('id', isEqualTo: storyItem.id.toString())
          .get();
      return StoryItem.fromJson(
        response.docs.first.data(),
      );
    } catch (e) {
      return StoryItem();
    }
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
  Future<List<StoryItem>> getStoryItem() async {
    try {
      final result = await firestore.collection(collectionItem).get();
      return result.docs
          .map(
            (e) => StoryItem.fromJson(
              e.data(),
            ),
          )
          .toList();
    } catch (e) {
      return List.empty();
    }
  }

  @override
  Future reactionStory(int userId, int storyId) async {
    try {
      final response = await firestore.collection(collectionReaction).add({
        'userId': userId,
        'storyId': storyId,
      });
    } catch (e) {}
  }

  @override
  Future uploadImageStory(int id, File image) async {
    try {
      FirebaseUtils firebaseUtils = FirebaseUtils();
      final url = firebaseUtils.uploadImage(
        image: image,
        nameImage: 'ImageStory',
        imageFolder: 'ImageStory',
      );
    } catch (e) {}
  }
}
