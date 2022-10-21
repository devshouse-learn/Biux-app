import 'dart:io';
import 'package:biux/data/models/city.dart';
import 'package:biux/data/models/user.dart';
import 'package:biux/data/repositories/authentication_repository.dart';
import 'package:biux/data/repositories/cities/cities_firebase_repository.dart';
import 'package:biux/data/repositories/users/user_firebase_repository.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditUserScreenBloc extends ChangeNotifier {
  BiuxUser user = BiuxUser();
  String imageLogo = '';
  List<City> listCities = [];
  City cityId = City();
  var imageNew;
  final FocusNode focusNodeCity = FocusNode();
  final nameController = TextEditingController();
  final nameUserController = TextEditingController();
  final correoController = TextEditingController();
  final numberController = TextEditingController();
  final cityController = TextEditingController();
  final descripcionController = TextEditingController();

  EditUserScreenBloc() {
    loadData();
  }

  Future<void> loadData() async {
    Future.delayed(Duration.zero, () async {
      await getUser();
      await getCities();
    });
  }

  Future<void> getUser() async {
    String? userId = AuthenticationRepository().getUserId;
    final dataUser = await UserFirebaseRepository().getUserId(
      userId,
    );
    final dataCity = await CitiesFirebaseRepository().getCityId(
      dataUser.cityId.name,
    );
    user = dataUser;
    imageLogo = user.photo;
    nameController.text = user.fullName;
    nameUserController.text = user.userName;
    correoController.text = user.email;
    numberController.text = user.whatsapp;
    cityController.text = dataCity.name;
    cityId = user.cityId;
    descripcionController.text = user.description;
    notifyListeners();
  }

  Future<File> getImageLogo() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile pickedFile;
    pickedFile = (await imagePicker.getImage(
      source: ImageSource.gallery,
      imageQuality: 20,
    ))!;
    File image = File(
      pickedFile.path,
    );
    if (image != null) {
      imageNew = image;
    }
    notifyListeners();
    return image;
  }

  Future<void> onTapCities(String nameCity, String cityIdSelected) async {
    cityController.text = nameCity;
    cityId = City(name: cityIdSelected);
    focusNodeCity.unfocus();
    notifyListeners();
  }

  Future<void> getCities() async {
    final dataCities = await CitiesFirebaseRepository().getCities();
    listCities = dataCities;
    notifyListeners();
  }

  Future<void> filterCities() async {
    final dataFilterCities = await CitiesFirebaseRepository().getCities();
    listCities = dataFilterCities
        .where(
          (cities) => cities.name.toLowerCase().contains(
                cityController.text.toLowerCase(),
              ),
        )
        .toList();
    notifyListeners();
  }

  Future<bool> setState() async {
    cityController.clear();
    notifyListeners();
    return Future.value(false);
  }

  Future<void> onTapPop(BuildContext context) async {
    Future.delayed(Duration(seconds: 3), () async {
      Navigator.pop(context);
    });
    notifyListeners();
  }

  Future<void> uploadUpdate(BuildContext context) async {
    final uploadUser = BiuxUser(
      id: user.id,
      fullName: nameController.text,
      whatsapp: numberController.text,
      cityId: cityId,
      description: descripcionController.text,
    );
    await UserFirebaseRepository().updateUser(
      uploadUser,
    );
    if (imageNew != null)
      await UserFirebaseRepository().uploadPhoto(
        user.id,
        imageNew,
      );
    notifyListeners();
  }
}
