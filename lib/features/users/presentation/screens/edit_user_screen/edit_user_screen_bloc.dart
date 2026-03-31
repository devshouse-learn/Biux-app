import 'dart:io';

import 'package:biux/features/cities/data/models/city.dart';
import 'package:biux/features/users/data/models/user.dart';
import 'package:biux/features/authentication/data/repositories/authentication_repository.dart';
import 'package:biux/features/cities/data/repositories/cities_firebase_repository.dart';
import 'package:biux/features/users/data/repositories/user_firebase_repository.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_picker/image_picker.dart';

class EditUserScreenBloc extends ChangeNotifier {
  BiuxUser user = BiuxUser();
  String imageLogo = '';
  List<City> listCities = [];
  City cityId = City();
  var imageNew;
  var profileCoverNew; // Nueva variable para la foto de portada
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
    final dataUser = await UserFirebaseRepository().getUserId(userId);
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
    XFile pickedFile;
    pickedFile = (await imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    ))!;
    File image = File(pickedFile.path);

    imageNew = image;
    notifyListeners();
    return image;
  }

  /// Nuevo método para manejar imagen ya procesada desde ProfileImagePicker
  void setProcessedImage(File processedImage) {
    imageNew = processedImage;
    notifyListeners();
  }

  /// Método para establecer la foto de portada
  void setProfileCoverImage(File coverImage) {
    profileCoverNew = coverImage;
    notifyListeners();
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
    Navigator.pop(context);
  }

  Future<void> uploadUpdate(BuildContext context) async {
    try {
      debugPrint('📝 Preparando actualización de perfil...');

      // Crear usuario con todos los datos (preservar los que no cambian)
      final uploadUser = BiuxUser(
        id: user.id,
        fullName: nameController.text,
        whatsapp: numberController.text,
        cityId: cityId,
        description: descripcionController.text,
        userName: user.userName, // Preservar datos que no cambian
        email: user.email,
        gender: user.gender,
        dateBirth: user.dateBirth,
        facebook: user.facebook,
        photo: user.photo, // Foto actual (será reemplazada si hay imagen nueva)
        token: user.token,
        modality: user.modality,
        premium: user.premium,
        profileCover: user.profileCover,
        followerS: user.followerS,
        instagram: user.instagram,
        followers: user.followers,
        following: user.following,
        groupId: user.groupId,
        situationAccident: user.situationAccident,
      );

      debugPrint('📤 Enviando datos a Firebase...');
      await UserFirebaseRepository().updateUser(uploadUser);

      debugPrint('📷 Verificando si hay foto nueva para subir...');
      if (imageNew != null) {
        debugPrint('📤 Subiendo foto de perfil...');
        await UserFirebaseRepository().uploadPhoto(user.id, imageNew);
        debugPrint('✅ Foto subida correctamente');
      } else {
        debugPrint('ℹ️ No hay foto nueva');
      }

      // Verificar si hay foto de portada nueva para subir
      debugPrint('🖼️ Verificando si hay foto de portada nueva...');
      if (profileCoverNew != null) {
        debugPrint('📤 Subiendo foto de portada...');
        await UserFirebaseRepository().uploadProfileCover(
          user.id,
          profileCoverNew,
        );
        debugPrint('✅ Foto de portada subida correctamente');
      } else {
        debugPrint('ℹ️ No hay foto de portada nueva');
      }

      // Recargar datos del usuario para asegurar sincronización
      debugPrint('🔄 Recargando datos del perfil...');
      await getUser();

      debugPrint('✅ Perfil actualizado completamente');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error al actualizar perfil: $e');
      rethrow;
    }
  }
}
