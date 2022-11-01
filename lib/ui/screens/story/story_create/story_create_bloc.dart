import 'dart:io';

import 'package:biux/data/models/story.dart';
import 'package:biux/data/models/user.dart';
import 'package:biux/data/repositories/stories/stories_firebase_repository.dart';
import 'package:biux/data/repositories/users/user_firebase_repository.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class StoryCreateBloc extends ChangeNotifier {
  List<AssetEntity> imgList = [];
  List<AssetEntity> entitiesList = [];
  bool loading = false;
  int current = 0;
  final StoriesFirebaseRepository storiesFirebaseRepository =
      StoriesFirebaseRepository();
  final UserFirebaseRepository userFirebaseRepository =
      UserFirebaseRepository();

  void initialEntities({required List<AssetEntity> entitiesList}) {
    this.entitiesList = entitiesList;
    imgList = [entitiesList.first];
    notifyListeners();
  }

  void addAllEntities({required List<AssetEntity> entitiesList}) {
    this.entitiesList.addAll(entitiesList);
    notifyListeners();
  }

  void addEntity({required AssetEntity entity}) {
    entitiesList.insertAll(0, [entity]);
    notifyListeners();
  }

  void addImageSeleted({required AssetEntity image}) {
    imgList.add(image);
    notifyListeners();
  }

  void deleteImageSeleted({required AssetEntity image}) {
    imgList.removeWhere(
      (element) => element == image,
    );
    notifyListeners();
  }

  void changeCurrent({required int current}) {
    this.current = current;
    notifyListeners();
  }

  Future<BiuxUser> getUser({required String id}) async {
    final user = await userFirebaseRepository.getUserById(id);
    notifyListeners();
    return user;
  }

  void changeLoading(bool loading) {
    this.loading = loading;
    notifyListeners();
  }

  Future<bool> createStory({
    required Story story,
    required List<AssetEntity> list,
  }) async {
    try {
      List<File> listFiles = [];
      for (var element in list) {
        final file = await element.file;
        if (file != null) {
          listFiles.add(file);
        }
      }
      final result = await storiesFirebaseRepository.createStory(
        story: story,
        listFile: listFiles,
      );
      notifyListeners();
      return result;
    } catch (e) {
      return false;
    }
  }
}
