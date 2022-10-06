import 'package:biux/config/router/router_path.dart';
import 'package:biux/data/models/competitor_road.dart';
import 'package:biux/data/models/story.dart';
import 'package:biux/data/models/user.dart';
import 'package:biux/data/repositories/roads/roads_firebase_repository.dart';
import 'package:biux/data/repositories/stories/stories_firebase_repository.dart';
import 'package:biux/data/repositories/users/user_firebase_repository.dart';
import 'package:flutter/material.dart';
import 'package:biux/data/local_storage/localstorage.dart';

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
    String? userId = await LocalStorage().getUserId();
    final dataUser = await UserFirebaseRepository().getUserId(
      userId!,
    );
    user = dataUser;
    notifyListeners();
  }

  Future<void> getStorie() async {
    final dataStory = await StoriesFirebaseRepository().getStoriesId(
      user.id,
    );
    stories = dataStory;
    notifyListeners();
  }

  Future<void> getroads() async {
    final dataCompetidorRoad =
        await RoadsFirebaseRepository().getListassistedRoads();
    competitorRoad = dataCompetidorRoad
        .where(
          (road) => road.userId == user.id,
        )
        .toList();
    notifyListeners();
  }

  Future<void> onTapEdit(BuildContext context) async {
    await Navigator.pushNamed(
      context,
      AppRoutes.editUserScreenRoute,
    );
    notifyListeners();
    getUser();
  }
}
