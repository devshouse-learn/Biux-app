import 'dart:io';
import 'package:autocomplete_textfield_ns/autocomplete_textfield_ns.dart';
import 'package:biux/config/colors.dart';
import 'package:biux/config/images.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/config/themes/theme.dart';
import 'package:biux/data/local_storage/localstorage.dart';
import 'package:biux/data/models/user.dart';
import 'package:biux/data/models/analitics.dart';
import 'package:biux/data/models/city.dart';
import 'package:biux/data/models/state.dart';
import 'package:biux/data/models/country.dart';
import 'package:biux/ui/screens/home.dart';
import 'package:biux/ui/screens/user/password_screen.dart';
import 'package:biux/ui/screens/user/social_networks_screen.dart';
import 'package:biux/ui/widgets/loading_widget.dart';
import 'package:biux/ui/widgets/textField_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:biux/data/repositories/users/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class ViewEditProfile extends StatefulWidget {
  static final ViewEditProfile editProfile = ViewEditProfile();

  ViewEditProfile({
    Key? key,
  }) : super(key: key);

  _ViewEditProfileState createState() => _ViewEditProfileState();
}

class _ViewEditProfileState extends State<ViewEditProfile> {
  final formKey = GlobalKey<FormState>();
  late BiuxUser user;
  bool isLoggedIn = false;
  var profile;
  var username;
  bool pressGeoON = false;
  var _image;
  bool loading = false;
  late City cityData;
  late City city;
  String letter = (Images.kLetter);
  var _names;
  var _nameUser;
  var _gender;
  var _cellPhone;
  var _facebook;
  var base64Image;
  var _email;
  var _surnames;
  var _city;
  var _cityId;
  var _password;
  var _dateBirth;
  var _instagram;
  var photo;
  int size = 30;
  var _myActivity;
  late SharedPreferences _prefs;
  var validate = 1;
  var update;
  final surnamesController = TextEditingController();
  final nameUserController = TextEditingController();
  final nameController = TextEditingController();
  final cellPhoneController = TextEditingController();
  final facebookController = TextEditingController();
  final instagramController = TextEditingController();
  final cityController = TextEditingController();
  final genderController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final dateBirthController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool cmbscritta = false;
  var googleauth;
  var facebookauth;
  var editProfile = ViewEditProfile();
  late List<String> listStringCity = [];
  List<City> listCities = [];

  @override
  void initState() {
    super.initState();
    user = BiuxUser(
      surnames: "",
      cellphone: "",
      password: "",
      facebook: "",
      email: "",
      photo: "",
      names: "",
    );
    cityData = City(
      name: "",
      state: '0',
      id: '0',
    );
    city = City();
    listCities = [];
    listStringCity = [];
    Future.delayed(
      Duration.zero,
      () async {
        listCities = await UserRepository().getCities();
        this.setState(
          () {
            listCities.forEach(
              (e) => listStringCity.add(e.name),
            );
          },
        );
      },
    );
    getUserFacebook();
    getUserGoogle();
    getUserProfile();
  }

  List<FocusNode> _focusNodes = [
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
  ];
  final _formKey = GlobalKey<FormState>();

  Widget _showPhoto() {
    if (user.profileCover != null) {
      return FadeInImage(
        image: NetworkImage(user.profileCover!),
        placeholder: AssetImage(Images.kBike),
        height: 300.0,
        fit: BoxFit.contain,
      );
    } else {
      return Image(
        image: AssetImage(_image.path),
        height: 300.0,
        fit: BoxFit.cover,
      );
    }
  }

  getUserProfile() async {
    username = await LocalStorage().getUser();
    user = await UserRepository().getPerson(username!);
    city = await UserRepository().getSpecifiCities(user.cityId!);
    setState(
      () {
        isLoggedIn = true;
      },
    );
    nameController.text = user.names!;
    surnamesController.text = user.surnames!;
    nameUserController.text = user.userName!;
    cityController.text = city.name;
    emailController.text = user.email!;
    cityData = await UserRepository().getCityId(cityController.text);
  }

  getUserGoogle() async {
    googleauth = FirebaseAuth.instance.currentUser!;
  }

  getUserFacebook() async {
    facebookauth = await FacebookAuth.instance.getUserData();
  }

  Future getImageFromGallery() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile pickedFile;
    pickedFile = (await imagePicker.getImage(
        source: ImageSource.gallery, imageQuality: 30))!;
    File image = File(pickedFile.path);
    if (image != null) {
      setState(() {
        _image = image;
      });
    }
  }

  void reassemble() {
    super.reassemble();
    if (_image != null) {
      setState(() {});
    }
  }

  var _image2;
  Future getImagePhoto() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile pickedFile;
    pickedFile = (await imagePicker.getImage(
        source: ImageSource.gallery, imageQuality: 40))!;
    File image = File(pickedFile.path);
    if (image != null) {
      setState(() {
        _image2 = image;
      });
    }
  }

  Future init() async {
    this._prefs = await SharedPreferences.getInstance();
  }

  var _darkTheme = true;
  ThemeData theme = darkTheme;
  GlobalKey<AutoCompleteTextFieldState<String>> key = GlobalKey();
  @override
  final GlobalKey<ScaffoldState> _scaffolState = GlobalKey<ScaffoldState>();
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(
        key: _scaffolState,
        backgroundColor: AppColors.darkBlue,
        body: username == null && user.id == null || city.name == null
            ? Loading()
            : ListView(
                children: [
                  Form(
                    key: _formKey,
                    child: Stack(
                      children: [
                        Container(
                          padding: EdgeInsets.only(top: 0, left: 0),
                          height: 150,
                          width: 400,
                          child: Stack(
                            children: <Widget>[
                              _image2 != null
                                  ? Container(
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: FileImage(_image2),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      height: 150,
                                      width: 400,
                                    )
                                  : Container(
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: NetworkImage(user
                                                      .profileCover ==
                                                  null
                                              ? AppStrings.urlBiuxApp
                                              : user.profileCover!),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      height: 150,
                                      width: 400,
                                    ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 18.0,
                                  right: 20,
                                ),
                                child: Align(
                                  alignment: Alignment.topRight,
                                  child: SizedBox(
                                    height: 40,
                                    width: 120,
                                    child: RaisedButton(
                                      color: AppColors.strongCyan,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          15.0,
                                        ),
                                        side: BorderSide(
                                          width: 3,
                                          color: AppColors.strongCyan,
                                        ),
                                      ),
                                      child: Text(
                                        AppStrings.uploadCover,
                                        style: Styles.uploadProfileCoverText,
                                      ),
                                      onPressed: getImagePhoto,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        _image2 == null
                            ? Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 10,
                                      top: 20,
                                    ),
                                    child: GestureDetector(
                                      child: Icon(
                                        Icons.arrow_back_outlined,
                                        size: 30,
                                        color: AppColors.white,
                                      ),
                                      onTap: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(
                                      top: 20,
                                      left: 10,
                                    ),
                                    child: Text(
                                      AppStrings.updateProfile,
                                      textAlign: TextAlign.center,
                                      style: Styles.createGroupText,
                                    ),
                                  ),
                                ],
                              )
                            : Container(),
                        Padding(
                          padding: const EdgeInsets.only(top: 65),
                          child: Stack(

                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 50),
                                child: Stack(

                                  //   alignment: Alignment.center,
                                  children: [
                                    Center(
                                      child: Container(
                                        height: 600,
                                        width: 370,
                                        child: Card(
                                          color: AppColors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16.0),
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(top: 20),
                                              ),
                                              TexFieldWidget(
                                                obscureText: false,
                                                focusNode: _focusNodes[0],
                                                nameController: nameController,
                                                text: AppStrings.nameText,
                                                icon: Icon(
                                                  Icons.person_outline,
                                                  color: _focusNodes[0].hasFocus
                                                      ? AppColors.strongCyan
                                                      : AppColors.gray,
                                                ),
                                              ),
                                              TexFieldWidget(
                                                obscureText: false,
                                                focusNode: _focusNodes[1],
                                                nameController:
                                                    surnamesController,
                                                text: AppStrings.surnameText,
                                                icon: Icon(
                                                  Icons.person_outline,
                                                  color: _focusNodes[1].hasFocus
                                                      ? AppColors.strongCyan
                                                      : AppColors.gray,
                                                ),
                                              ),
                                              TexFieldWidget(
                                                enabled: false,
                                                obscureText: false,
                                                focusNode: _focusNodes[2],
                                                nameController:
                                                    nameUserController,
                                                text: AppStrings.nameUserText,
                                                icon: Icon(
                                                  Icons.person_outline,
                                                  color: _focusNodes[2].hasFocus
                                                      ? AppColors.strongCyan
                                                      : AppColors.gray,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 15,
                                                  right: 15,
                                                  top: 5,
                                                  bottom: 5,
                                                ),
                                                child: SizedBox(
                                                  height: 48,
                                                  child:
                                                      SimpleAutoCompleteTextField(
                                                    key: key,
                                                    focusNode: _focusNodes[3],
                                                    style: Styles.sizedBox,
                                                    textInputAction:
                                                        TextInputAction.next,
                                                    decoration: InputDecoration(
                                                      prefixIcon: Icon(
                                                        Icons.place,
                                                        color: _focusNodes[3]
                                                                .hasFocus
                                                            ? AppColors
                                                                .strongCyan
                                                            : AppColors.gray,
                                                      ),
                                                      fillColor:
                                                          AppColors.white,
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: AppColors.gray,
                                                          width: 1,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          45,
                                                        ),
                                                      ),
                                                      filled: true,
                                                      contentPadding:
                                                          EdgeInsets.fromLTRB(
                                                        10.0,
                                                        15.0,
                                                        20.0,
                                                        15.0,
                                                      ),
                                                      hintText: AppStrings.cityText,
                                                      errorBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color:
                                                              AppColors.green,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          15,
                                                        ),
                                                      ),
                                                      focusedErrorBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color:
                                                              AppColors.green,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          15,
                                                        ),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color:
                                                                AppColors.gray),
                                                        borderRadius:
                                                            BorderRadius.all(
                                                          Radius.circular(
                                                            45,
                                                          ),
                                                        ),
                                                      ),
                                                      hintStyle: Styles
                                                          .paddingHintText,
                                                    ),
                                                    controller: cityController,
                                                    suggestions: listStringCity,
                                                    textChanged: (text) =>
                                                        listStringCity.first =
                                                            text,
                                                    clearOnSubmit: false,
                                                    textSubmitted: (text) {
                                                      setState(
                                                        () async {
                                                          if (text != "") {
                                                            // _ciudad = text;
                                                            cityData =
                                                                await UserRepository()
                                                                    .getCityId(
                                                                        text);
                                                            if (cityData.name !=
                                                                "") {
                                                              _city =
                                                                  listStringCity
                                                                      .first;
                                                            } else {
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .showSnackBar(
                                                                SnackBar(
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .only(
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              40),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              40),
                                                                    ),
                                                                  ),
                                                                  backgroundColor:
                                                                      AppColors
                                                                          .red,
                                                                  content: Text(
                                                                    AppStrings.cityNotExist,
                                                                    style: Styles
                                                                        .advertisingTitle,
                                                                  ),
                                                                ),
                                                              );
                                                            }
                                                          }
                                                        },
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                              TexFieldWidget(
                                                enabled: googleauth != null
                                                    ? false
                                                    : true,
                                                obscureText: false,
                                                color: AppColors.black,
                                                focusNode: _focusNodes[4],
                                                nameController: emailController,
                                                text: AppStrings.gmail,
                                                icon: Image.asset(
                                                  letter,
                                                  scale: 30,
                                                ),
                                              ),
                                              Container(
                                                height: 5,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  SizedBox(
                                                    width: size.width * 0.85,
                                                    height: 50,
                                                    child: RaisedButton(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(45),
                                                        side: BorderSide(
                                                          color: AppColors.gray,
                                                          width: 1,
                                                        ),
                                                      ),
                                                      color: AppColors.white,
                                                      child: Text(
                                                        AppStrings.editProfileSocialNetweorks,
                                                        style: Styles
                                                            .sizedBoxBlack,
                                                      ),
                                                      onPressed: () async {
                                                        final result =
                                                            await Navigator
                                                                .push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (BuildContext
                                                                    context) =>
                                                                SocialNetworksScreen(
                                                              user,
                                                            ),
                                                          ),
                                                        );
                                                        if (result != null) {
                                                          final userData =
                                                              result
                                                                  as BiuxUser;
                                                          _facebook = userData
                                                              .facebook!;
                                                          _instagram = userData
                                                              .instagram!;
                                                          _cellPhone = userData
                                                              .cellphone!;
                                                          setState(() {});
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Container(
                                                height: 10,
                                              ),
                                              googleauth != null ||
                                                      facebookauth != null
                                                  ? Container()
                                                  : Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        SizedBox(
                                                          width:
                                                              size.width * 0.85,
                                                          height: 50,
                                                          child: RaisedButton(
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          45),
                                                              side: BorderSide(
                                                                color: AppColors
                                                                    .gray,
                                                                width: 1,
                                                              ),
                                                            ),
                                                            color:
                                                                AppColors.white,
                                                            child: Text(
                                                              AppStrings.editProfileChangePassword,
                                                              style: Styles
                                                                  .sizedBoxBlack,
                                                            ),
                                                            onPressed:
                                                                () async {
                                                              final result =
                                                                  await Navigator
                                                                      .push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder: (BuildContext
                                                                          context) =>
                                                                      PasswordScreen(
                                                                    user,
                                                                  ),
                                                                ),
                                                              );
                                                              if (result !=
                                                                  null) {
                                                                final userData =
                                                                    result
                                                                        as BiuxUser;
                                                                _password =
                                                                    userData
                                                                        .password!;
                                                                setState(() {});
                                                              }
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                child: Container(
                                  margin: EdgeInsets.only(top: 600),
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Material(
                                      elevation: 20,
                                      borderRadius: BorderRadius.circular(55.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(60.0),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.white,
                                              spreadRadius: 10,
                                            ),
                                          ],
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: AppColors.strongCyan,
                                          ),
                                          height: 70,
                                          width: 70,
                                          child: Stack(
                                            children: <Widget>[
                                              Center(
                                                child: Icon(
                                                  Icons.arrow_forward,
                                                  color: AppColors.white,
                                                  size: 40,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                onTap: () async {
                                  setState(() {
                                    loading = true;
                                  });
                                  var emailList = await UserRepository()
                                      .getValidationEmails(
                                    emailController.text,
                                  );
                                  var userRepeted =
                                      await UserRepository().getValidationUser(
                                    nameUserController.text,
                                  );
                                  if (user.photo != null || _image != null) {
                                    if (user.profileCover != null ||
                                        _image2 != null) {
                                      if (user.cellphone != '' ||
                                          _cellPhone != null) {
                                        if (emailList.email! == user.email ||
                                            emailList.email!.isEmpty &&
                                                userRepeted.userName! ==
                                                    user.userName ||
                                            userRepeted.userName!.isEmpty) {
                                          _nameUser = nameUserController.text;
                                          _names = nameController.text;
                                          _surnames = surnamesController.text;
                                          _gender = genderController.text;
                                          _cityId = cityData.id;
                                          _city = cityController.text;
                                          _email = emailController.text;
                                          _dateBirth = dateBirthController.text;
                                          Future.delayed(
                                            Duration(seconds: 2),
                                            () {
                                              Analitycs.editUser(
                                                _nameUser,
                                                user.id!,
                                              );
                                              _scaffolState.currentState!
                                                  .showSnackBar(
                                                SnackBar(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      topLeft: Radius.circular(
                                                        40,
                                                      ),
                                                      topRight: Radius.circular(
                                                        40,
                                                      ),
                                                    ),
                                                  ),
                                                  backgroundColor:
                                                      AppColors.strongCyan,
                                                  content: Text(
                                                    AppStrings.usernameBeingUpdated,
                                                    style: Styles.advertisingTitle,
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                          var userN = BiuxUser(
                                            names: _names,
                                            surnames: _surnames,
                                            email: _email,
                                            cellphone: _cellPhone,
                                            id: user.id,
                                            cityId: _cityId,
                                            facebook: _facebook,
                                            instagram: _instagram,
                                            userName: _nameUser,
                                            password: _password,
                                          );
                                          // var membresia = Membresia(
                                          //   id: 4,
                                          //   nombre: "Premium",
                                          // );
                                          // var usuarioMembresia = UsuarioMembresia(
                                          //   estadoMembresia: true,
                                          //   id: 4,
                                          //   inicioMembresia: "18-01-2021 05:25:00",
                                          //   membresiaId: 4,
                                          //   membresia: membresia,
                                          //   updatedAt: "12-02-2021 21:34:43",
                                          //   vencimientoMembresia: "18-01-2022 05:25:00",
                                          //   usuario: usuario,
                                          //   usuarioId: usuario.id,
                                          // );

                                          if (_image != null) {
                                            UserRepository().uploadPhoto(
                                              user.id!,
                                              _image,
                                            );
                                            uploadImage(_image).then(
                                              (data) {
                                                postToFireStore(
                                                  photo: data,
                                                  userId:
                                                      '${user.id!.toString()}U',
                                                );
                                              },
                                            );
                                          }
                                          if (_image2 != null) {
                                            UserRepository().uploadProfileCover(
                                              user.id!,
                                              _image2,
                                            );
                                            uploadImage2(_image2).then(
                                              (data2) {
                                                postToFireStore2(
                                                  photo2: data2,
                                                  userId:
                                                      '${user.id!.toString()}U',
                                                );
                                              },
                                            );
                                          }
                                          await UserRepository().updateUser(
                                            userN,
                                          );
                                          await updateLocalUser(
                                            userN,
                                          );
                                          var usu =
                                              await LocalStorage().getUser();
                                          postToFireStore3(
                                            name: _names,
                                            surname: _surnames,
                                            email: _email,
                                            user: _nameUser,
                                            userId: '${user.id!.toString()}U',
                                          );
                                          // await UsuariosRepositorio().obtenerMembresia(
                                          //   usuarioMembresia,
                                          // );
                                          Future.delayed(
                                            Duration(seconds: 2),
                                            () async {
                                              await Navigator.of(context)
                                                  .pushAndRemoveUntil(
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              MyHome()),
                                                      (Route<dynamic> route) =>
                                                          false)
                                                  .then(
                                                    (value) => setState(
                                                      () => {},
                                                    ),
                                                  );
                                            },
                                          );
                                        } else {
                                          Future.delayed(
                                            Duration(seconds: 2),
                                            () {
                                              setState(() {
                                                loading = false;
                                              });
                                              _showDialog2(
                                                emailList.email!.isNotEmpty
                                                    ? AppStrings.messageRegisteredGmail(message: emailController.text)
                                                    : userRepeted
                                                            .userName!.isNotEmpty
                                                        ? AppStrings.messageRegisteredUser(message: nameUserController.text)
                                                        : '',
                                              );
                                            },
                                          );
                                        }
                                      } else {
                                        Future.delayed(
                                          Duration(seconds: 2),
                                          () {
                                            setState(
                                              () {
                                                loading = false;
                                              },
                                            );
                                            _showDialog2(
                                                AppStrings.messageErrorSocialNetworks);
                                          },
                                        );
                                      }
                                    } else {
                                      Future.delayed(
                                        Duration(seconds: 2),
                                        () {
                                          setState(
                                            () {
                                              loading = false;
                                            },
                                          );
                                          _showDialog2(
                                              AppStrings.textErrorImageCover);
                                        },
                                      );
                                    }
                                  } else {
                                    Future.delayed(
                                      Duration(seconds: 2),
                                      () {
                                        setState(() {
                                          loading = false;
                                        });
                                        _showDialog2(
                                            AppStrings.textErrorImageProfile);
                                      },
                                    );
                                  }
                                },
                              ),
                              Align(
                                alignment: Alignment(0.0, 3.8),
                                child: GestureDetector(
                                  child: Material(
                                    elevation: 20,
                                    borderRadius: BorderRadius.circular(55.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(60.0),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.white,
                                            spreadRadius: 5,
                                          ),
                                        ],
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.strongCyan,
                                        ),
                                        height: 110,
                                        width: 110,
                                        child: _image != null
                                            ? InkWell(
                                                child: Container(
                                                  alignment: (Alignment(
                                                    -1.0,
                                                    2.5,
                                                  )),
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                      fit: BoxFit.cover,
                                                      image: FileImage(
                                                        _image,
                                                      ),
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      const Radius.circular(
                                                        80.0,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                onTap: () {
                                                  setState(
                                                    () {
                                                      getImageFromGallery();
                                                    },
                                                  );
                                                },
                                              )
                                            : InkWell(
                                                child: Container(
                                                  alignment: (Alignment(
                                                    -1.0,
                                                    2.5,
                                                  )),
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                      fit: BoxFit.cover,
                                                      image: NetworkImage(
                                                        user.photo == null
                                                            ? AppStrings.urlBiuxApp
                                                            : user.photo!,
                                                      ),
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      const Radius.circular(
                                                        80.0,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                onTap: () {
                                                  setState(
                                                    () {
                                                      getImageFromGallery();
                                                    },
                                                  );
                                                },
                                              ),
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    setState(
                                      () {
                                        getImageFromGallery();
                                      },
                                    );
                                  },
                                ),
                              ),
                              Positioned(
                                bottom: 570,
                                left: 86,
                                right: 0,
                                child: GestureDetector(
                                  child: Align(
                                    alignment: Alignment(0.0, 0.0),
                                    child: Material(
                                      elevation: 10,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(60.0),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.white,
                                              spreadRadius: 6,
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          Icons.camera_alt_outlined,
                                          color: AppColors.strongCyan,
                                          size: 19,
                                        ),
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    setState(
                                      () {
                                        getImageFromGallery();
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        loading == true ? Loading() : Container(),
                      ],
                    ),
                  ),
                  Container(
                    height: 50,
                  ),
                ],
              ),
      ),
    );
  }

  Future<String> uploadImage(var imageFile) async {
    var uuid = Uuid().v1();
    Reference ref = FirebaseStorage.instance.ref().child(AppStrings.postIdFirebase(uuid: uuid));
    UploadTask uploadTask = ref.putFile(imageFile);

    String downloadUrl = await (await uploadTask).ref.getDownloadURL();
    return downloadUrl;
  }

  void postToFireStore({String? photo, String? userId}) async {
    FirebaseFirestore.instance.collection(AppStrings.instaUsers).doc(userId).update(
      {
        AppStrings.photoText: photo,
      },
    );
  }

  Future<String> uploadImage2(var imageFile2) async {
    var uuid = Uuid().v1();
    Reference ref = FirebaseStorage.instance.ref().child(AppStrings.postIdFirebase(uuid: uuid));
    UploadTask uploadTask2 = ref.putFile(imageFile2);

    String downloadUrl2 = await (await uploadTask2).ref.getDownloadURL();
    return downloadUrl2;
  }

  void postToFireStore2({String? photo2, String? userId}) async {
    FirebaseFirestore.instance.collection(AppStrings.instaUsers).doc(userId).update(
      {
        AppStrings.profileCoverText: photo2,
      },
    );
  }

  Future updateLocalUser(BiuxUser user) async {
    LocalStorage().saveUser(user.userName!);
    // _prefs = await SharedPreferences.getInstance();
    // await _prefs.gu(username, _nombreUsuario);
  }

  void postToFireStore3({
    String? user,
    String? name,
    String? surname,
    String? email,
    String? userId,
  }) async {
    FirebaseFirestore.instance.collection(AppStrings.instaUsers).doc(userId).update({
      AppStrings.user: user,
      AppStrings.name: name,
      AppStrings.surname: surname,
      AppStrings.emailText: email,
      AppStrings.nameVal: user
    });

    FirebaseFirestore.instance.collection(AppStrings.instaPosts).doc(userId).update(
      {
        AppStrings.user: user,
        AppStrings.nameVal: user,
      },
    );
  }

  void _showDialog2(String response) {
    // flutter defined function
    Future.delayed(
      Duration.zero,
      () {
        _scaffolState.currentState!.showSnackBar(
          SnackBar(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
            ),
            backgroundColor: AppColors.red,
            content: Text(
              response,
              style: Styles.advertisingTitle,
            ),
          ),
        );
      },
    );
  }
}
