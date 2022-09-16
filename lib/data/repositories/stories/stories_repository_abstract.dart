import 'dart:io';

import 'package:biux/data/models/reaction_story.dart';
import 'package:biux/data/models/story.dart';

abstract class StoriesRepositoryAbstract {
  Future<List<Story>> getStories();
  Future<List<ReactionStory>> getReactionStory(String id);
  Future<bool> createStory({
    required Story story,
    required List<File> listFile,
  });
  Future reactionStory(String userId, String storyId);
  Future<List<String>> uploadStory({
    required String id,
    required List<File> listFile,
  });
  Future deleteStory(String id);
}
