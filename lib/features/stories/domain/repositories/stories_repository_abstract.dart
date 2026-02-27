import 'dart:io';
import 'package:biux/features/stories/data/models/story.dart';

abstract class StoriesRepositoryAbstract {
  Future<List<Story>> getStories();
  Future<bool> createStory({
    required Story story,
    required List<File> listFile,
  });
  Future<List<String>> uploadStory({
    required String id,
    required List<File> listFile,
  });
  Future deleteStory(String id);
}
