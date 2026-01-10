import 'package:biux/core/config/router/router_path.dart';
import 'package:biux/features/roads/data/models/competitor_road.dart';
import 'package:biux/features/roads/data/repositories/roads_firebase_repository.dart';
import 'package:biux/features/stories/data/models/story.dart';
import 'package:biux/features/stories/data/repositories/stories_firebase_repository.dart';
import 'package:biux/features/users/data/models/user.dart';
import 'package:biux/features/authentication/data/repositories/authentication_repository.dart';
import 'package:biux/features/users/data/repositories/user_firebase_repository.dart';
import 'package:flutter/material.dart';

class UserScreenBloc extends ChangeNotifier {
  BiuxUser user = BiuxUser();
  List<Story> stories = [];
  List<CompetitorRoad> competitorRoad = [];

  UserScreenBloc() {
    loadData();
  }

  Future<void> loadData() async {
    Future.delayed(Duration.zero, () async {
      await getUser();
      await getStorie();
      await getroads();
    });
  }

  Future<void> getUser() async {
    String? userId = AuthenticationRepository().getUserId;
    final dataUser = await UserFirebaseRepository().getUserId(userId);
    user = dataUser;
    notifyListeners();
  }

  Future<void> getStorie() async {
    final dataStory = await StoriesFirebaseRepository().getStoriesId(user.id);
    stories = dataStory;
    notifyListeners();
  }

  Future<void> getroads() async {
    final dataCompetidorRoad = await RoadsFirebaseRepository()
        .getListassistedRoads();
    competitorRoad = dataCompetidorRoad
        .where((road) => road.userId == user.id)
        .toList();
    notifyListeners();
  }

  Future<void> onTapEdit(BuildContext context) async {
    await Navigator.pushNamed(context, AppRoutes.editUserScreenRoute);
    notifyListeners();
    getUser();
  }
}
