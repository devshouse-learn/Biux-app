import 'package:biux/core/config/router/router_path.dart';
import 'package:biux/features/users/data/models/user.dart';
import 'package:biux/data/models/user_membership.dart';
import 'package:biux/features/authentication/data/repositories/authentication_repository.dart';
import 'package:biux/features/users/data/repositories/user_firebase_repository.dart';
import 'package:flutter/material.dart';

class MainMenuBloc extends ChangeNotifier {
  int pageIndex = 0;
  BiuxUser user = BiuxUser();
  UserMembership userMembership = UserMembership();
  final AuthenticationRepository authenticationRepository =
      AuthenticationRepository();

  MainMenuBloc() {
    loadData();
  }

  Future<void> loadData() async {
    Future.delayed(Duration.zero, () async {
      await getUser();
    });
  }

  Future<void> signOut() async{
    await authenticationRepository.signOut();
    notifyListeners();
  }

  Future<void> getUser() async {
    String? userId =  AuthenticationRepository().getUserId;
    final dataUser = await UserFirebaseRepository().getUserId(userId);
    user = dataUser;
    notifyListeners();
  }

  Future<void> onTabTapped(int? index) async {
    pageIndex = index!;
    notifyListeners();
  }

  Future<void> onTapViewProfile(BuildContext context) async {
    await Navigator.pushNamed(context, AppRoutes.userScreenRoute);
    notifyListeners();
    getUser();
  }

  Future<void> onTapViewMyGroups(BuildContext context) async {
    await Navigator.pushNamed(context, AppRoutes.myGroupsRoute);
    notifyListeners();
    getUser();
  }
}
