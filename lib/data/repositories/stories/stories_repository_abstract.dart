import 'dart:io';

import 'package:biux/data/models/reaction_story.dart';
import 'package:biux/data/models/story.dart';

abstract class StoriesRepositoryAbstract {
  Future<List<Story>> getStories();
  Future<List<ReactionStory>> getReactionStory(String id);
  Future createStory(Story story);
  Future reactionStory(String userId, String storyId);
  Future uploadStory(String id, File fileUrl1, File fileUrl2, File fileUrl3);
  Future deleteStory(String id);
}
