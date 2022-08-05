import 'dart:io';
import 'package:biux/data/local_storage/localstorage.dart';
import 'package:biux/data/models/user.dart';
import 'package:biux/data/repositories/groups/groups_firebase_repository.dart';
import 'package:biux/data/repositories/users/user_firebase_repository.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../../data/models/group.dart';

class GroupCreateBloc extends ChangeNotifier {
  var imageProfileCover;
  var imageLogo;
  final nameController = TextEditingController();
  final whatsappController = TextEditingController();
  final ciudadController = TextEditingController();
  final facebookController = TextEditingController();
  final instagramController = TextEditingController();
  final descripcionController = TextEditingController();

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

  Future<bool> uploadGroup() async {
    String? idUser = await LocalStorage().getUserId();
    BiuxUser user = await UserFirebaseRepository().getUserId(idUser!);
    final result = await GroupsFirebaseRepository().createGroup(
      Group(
        active: true,
        name: nameController.text,
        whatsapp: whatsappController.text,
        cityId: ciudadController.text,
        facebook: facebookController.text,
        instagram: instagramController.text,
        description: descripcionController.text,
        adminId: user.id!,
        cityAdmin: user.cityId!,
        logoADM: user.photo!,
        profileCoverADM: user.profileCover!,
      ),
      imageLogo,
      imageProfileCover
    );
    notifyListeners();
    return result;
  }
}
