import 'dart:io';

import 'package:biux/data/models/story.dart';
import 'package:biux/data/models/story_item.dart';

abstract class StoriesRepositoryAbstract {
  Future<List<Story>> getStories();
  Future<List<StoryItem>> getStoryItem();
  Future<StoryItem?> createStoryItem(StoryItem storyItem);
  Future reactionStory(int userId, int storyId);
  Future uploadImageStory(int id, File image);
}
