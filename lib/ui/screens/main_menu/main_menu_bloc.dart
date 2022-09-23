import 'package:biux/data/models/user.dart';
import 'package:biux/data/models/user_membership.dart';
import 'package:biux/data/repositories/users/user_firebase_repository.dart';
import 'package:flutter/material.dart';
import 'package:biux/data/local_storage/localstorage.dart';

class MainMenuBloc extends ChangeNotifier {
  int pageIndex = 0;
  BiuxUser user = BiuxUser();
  UserMembership userMembership = UserMembership();
  

  MainMenuBloc() {
    loadData();
  }

  Future<void> loadData() async {
    Future.delayed(Duration.zero, () async {
      await getUser();
    });
  }

  Future<void> getUser() async {
    String? userId = await LocalStorage().getUserId();
    final dataUser = await UserFirebaseRepository().getUserId(userId!);
    user = dataUser;
    notifyListeners();
  }

  Future<void> onTabTapped(int? index) async {
    pageIndex = index!;
    notifyListeners();
  }
}
