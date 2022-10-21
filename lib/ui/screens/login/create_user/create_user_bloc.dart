import 'dart:io';
import 'package:biux/config/strings.dart';
import 'package:biux/data/models/city.dart';
import 'package:biux/data/models/response.dart';
import 'package:biux/data/models/user.dart';
import 'package:biux/data/repositories/authentication_repository.dart';
import 'package:biux/data/repositories/cities/cities_firebase_repository.dart';
import 'package:biux/data/repositories/users/user_firebase_repository.dart';
import 'package:flutter/material.dart';

class CreateUserBloc extends ChangeNotifier {
  final CitiesFirebaseRepository citiesFirebaseRepository =
      CitiesFirebaseRepository();
  final UserFirebaseRepository userFirebaseRepository =
      UserFirebaseRepository();
  final AuthenticationRepository authenticationRepository =
      AuthenticationRepository();
  List<City> listCities = [];
  bool obscureText = true;
  bool isChecked = false;
  bool loading = false;
  String validateColor1 = '';
  String validateColor2 = '';
  String dropdownValueCity = AppStrings.selectedCityText;
  File image = File('');

  CreateUserBloc() {
    getCities();
  }

  void getCities() async {
    listCities = await citiesFirebaseRepository.getCities();
    dropdownValueCity = listCities.first.name;
    notifyListeners();
  }

  void toggle() {
    this.obscureText = !obscureText;
    notifyListeners();
  }

  void replaceDropdownValueCity(String dropdownValueCity) {
    this.dropdownValueCity = dropdownValueCity;
    notifyListeners();
  }

  void changeChecked(bool checked) {
    this.isChecked = checked;
    notifyListeners();
  }

  void changeLoading(bool loading) {
    this.loading = loading;
    notifyListeners();
  }

  void replacevalidateColor1(String validateColor1) {
    this.validateColor1 = validateColor1;
    notifyListeners();
  }

  void replacevalidateColor2(String validateColor2) {
    this.validateColor2 = validateColor2;
    notifyListeners();
  }

  void replaceImage(File image) {
    this.image = image;
    notifyListeners();
  }

  Future<bool> getValidationUserName(String userName) async {
    var user = await userFirebaseRepository.getValidationUserName(userName);
    notifyListeners();
    return user;
  }

  Future<ResponseRepo> registerUser(BiuxUser user) async {
    final responseRepo =
        await authenticationRepository.registerUser(user: user);
    notifyListeners();
    return responseRepo;
  }

  Future<void> uploadPhoto(String id) async {
    await userFirebaseRepository.uploadPhoto(
      id,
      image,
    );
    notifyListeners();
  }
}
