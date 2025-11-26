
import 'package:biux/features/stories/data/models/reaction_story.dart';
import 'package:biux/features/stories/data/models/story.dart';
import 'package:biux/features/stories/data/repositories/stories_firebase_repository.dart';
import 'package:biux/shared/services/local_storage.dart';

import 'package:flutter/material.dart';

class StoryViewBloc extends ChangeNotifier {
  List<Story> listStory = [];
  final StoriesFirebaseRepository storiesFirebaseRepository =
      StoriesFirebaseRepository();

  StoryViewBloc() {
    getIntitalStories();
  }

  void getIntitalStories() async {
    final result = await storiesFirebaseRepository.getStories();
    listStory = result;
    notifyListeners();
  }

  void updateStoryLike({
    required String idUser,
    required Story story,
  }) async {
    bool exists = false;
    ReactionStory reactionStory = ReactionStory();
    List<ReactionStory> listReactions = story.listReactions;
    for (var element in story.listReactions) {
      if (element.id == idUser) {
        exists = true;
        reactionStory = element;
      }
    }
    if (!exists) {
      listReactions.add(
        ReactionStory(
          id: idUser,
          username: LocalStorage().getUserName(),
        ),
      );
    } else {
      listReactions.remove(reactionStory);
    }
    Story storyUpdate = Story(
      creationDate: story.creationDate,
      description: story.description,
      files: story.files,
      id: story.id,
      listReactions: listReactions,
      tags: story.tags,
      user: story.user,
    );
    final index = listStory.indexOf(story);
    listStory[index] = storyUpdate;
    notifyListeners();
    await storiesFirebaseRepository.updateStory(
      id: story.id,
      story: storyUpdate,
    );
  }

  void deleteStory({required Story story}) async {
    try {
      await storiesFirebaseRepository.deleteStory(story.id);
      listStory.removeWhere((element) => element.id == story.id);
      notifyListeners();
    } catch (e) {
      print('Error eliminando historia: $e');
    }
  }
}
