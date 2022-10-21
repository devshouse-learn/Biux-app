import 'dart:io';
import 'package:biux/config/colors.dart';
import 'package:biux/config/router/router_path.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/data/models/user.dart';
import 'package:biux/data/repositories/authentication_repository.dart';
import 'package:biux/data/repositories/groups/groups_firebase_repository.dart';
import 'package:biux/data/repositories/users/user_firebase_repository.dart';
import 'package:biux/utils/snackbar_utils.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../../data/models/group.dart';

class GroupCreateBloc extends ChangeNotifier {
  BiuxUser user = BiuxUser();
  var imageProfileCover;
  var imageLogo;
  var publicValidator;
  final nameController = TextEditingController();
  final whatsappController = TextEditingController();
  final ciudadController = TextEditingController();
  final facebookController = TextEditingController();
  final instagramController = TextEditingController();
  final descripcionController = TextEditingController();

  GroupCreateBloc() {
    loadData();
  }

  Future<void> loadData() async {
    Future.delayed(Duration.zero, () async {
      await getUser();
    });
  }

  Future<void> getUser() async {
    String? userId = AuthenticationRepository().getUserId;
    final dataUser = await UserFirebaseRepository().getUserId(userId);
    user = dataUser;
    notifyListeners();
  }

  Future<File> getImageProfileCover() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile pickedFile;
    pickedFile = (await imagePicker.getImage(
        source: ImageSource.gallery, imageQuality: 20))!;
    File image = File(pickedFile.path);
    if (image != null) {
      imageProfileCover = image;
    }
    notifyListeners();
    return image;
  }

  Future<File> getImageLogo() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile pickedFile;
    pickedFile = (await imagePicker.getImage(
        source: ImageSource.gallery, imageQuality: 20))!;
    File image = File(pickedFile.path);
    if (image != null) {
      imageLogo = image;
    }
    notifyListeners();
    return image;
  }

  Future<void> uploadGroup(BuildContext context) async {
    final result = await GroupsFirebaseRepository().createGroup(
      Group(
        active: true,
        name: nameController.text,
        whatsapp: whatsappController.text,
        //here add the id of the city where you are
        cityId: 'ibague',
        facebook: facebookController.text,
        instagram: instagramController.text,
        description: descripcionController.text,
        adminId: user.id,
        cityAdmin: user.cityId.name,
        logoADM: user.photo,
        public: publicValidator,
      ),
      imageLogo,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBarUtils.customSnackBar(
          content: AppStrings.groupCreatedText,
          backgroundColor: AppColors.strongCyan),
    );
    onTapPop(context);
    Navigator.pushNamed(context, AppRoutes.viewGroupRoute, arguments: {
      AppStrings.adminIdText: user.id,
      AppStrings.groupIdText: result
    });
    notifyListeners();
  }

  Future<void> onTapPop(BuildContext context) async {
    Navigator.pop(context);
    notifyListeners();
  }

  Future<void> onTapValidator(String validator) async {
    if (validator == AppStrings.public)
      publicValidator = true;
    else if (validator == AppStrings.private) publicValidator = false;
    notifyListeners();
    return publicValidator;
  }
}
