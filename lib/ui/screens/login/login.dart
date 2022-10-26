import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:biux/config/colors.dart';
import 'package:biux/config/images.dart';
import 'package:biux/config/router/router_path.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/config/themes/theme.dart';
import 'package:biux/config/themes/theme_notifier.dart';
import 'package:biux/data/local_storage/local_storage.dart';
import 'package:biux/data/models/response.dart';
import 'package:biux/data/repositories/cities/cities_firebase_repository.dart';
import 'package:biux/data/repositories/users/user_firebase_repository.dart';
import 'package:biux/data/models/user.dart';
import 'package:biux/data/models/analitics.dart';
import 'package:biux/data/models/city.dart';
import 'package:biux/data/repositories/authentication_repository.dart';
import 'package:biux/ui/screens/login/recover_password.dart';
import 'package:biux/ui/widgets/loading_widget.dart';
import 'package:biux/ui/widgets/textField_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool autoValidate = false;
  String message = AppStrings.message;
  bool obscureText = true;
  final TextEditingController namecontroller = TextEditingController();
  final TextEditingController newUserController = TextEditingController();
  final TextEditingController newUser2Controller = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  Map<String, dynamic>? _userData;
  AccessToken? _accessToken;
  bool loading = false;
  bool checking = true;
  late City cityData;
  bool logged = false;
  late User user;
  var nameUser;
  late BiuxUser userfacebook;
  late BiuxUser userEmail;
  late File imageNetworks;

  void _toggle() {
    setState(
      () {
        obscureText = !obscureText;
      },
    );
  }

  String prettyPrint(Map json) {
    JsonEncoder encoder = JsonEncoder.withIndent('  ');
    String pretty = encoder.convert(json);
    return pretty;
  }

  Future<File> urlToFile(var imageUrl) async {
    var rng = Random();
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    File file = File(
      '$tempPath' + (rng.nextInt(100)).toString() + AppStrings.pngText,
    );
    http.Response response = await http.get(imageUrl);
    await file.writeAsBytes(response.bodyBytes);
    imageNetworks = file;
    return file;
  }

  Future<Map<String, dynamic>> _getDataFacebook(
      {required LoginResult result}) async {
    if (result.status == LoginStatus.success) {
      setState(
        () {
          logged = true;
        },
      );
      _accessToken = result.accessToken;
      final graphResponse = await AuthenticationRepository.getDataFacebook(
        accessToken: _accessToken!,
      );
      final profile = jsonDecode(graphResponse.body);
      setState(
        () {
          checking = false;
          _userData = profile;
        },
      );
      return profile;
    } else {
      return {};
    }
  }

  var _darkTheme = true;

  List<FocusNode> _focusNodes = [
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
  ];
  @override
  void initState() {
    super.initState();
    cityData = City(
      name: "",
      state: '0',
      id: '0',
    );
  }

  final GlobalKey<ScaffoldState> _scaffolState = GlobalKey<ScaffoldState>();
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    _darkTheme = (themeNotifier.getTheme() == darkTheme);
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    return MaterialApp(
      home: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          key: _scaffolState,
          backgroundColor: AppColors.darkBlue,
          body: loading == true
              ? Loading()
              : Form(
                  key: _formKey,
                  autovalidateMode: autoValidate
                      ? AutovalidateMode.always
                      : AutovalidateMode.disabled,
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(Images.kBackground),
                        fit: BoxFit.cover,
                      ),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: ListView(
                      children: <Widget>[
                        Container(
                          height: 100,
                          margin: const EdgeInsets.only(
                            top: 70,
                          ),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                Images.kBiuxLogoLettersWhite,
                              ),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Stack(
                          children: [
                            Center(
                              child: Container(
                                height: 250,
                                width: 370,
                                child: Card(
                                  color: AppColors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                ),
                              ),
                            ),
                            Center(
                              child: Container(
                                margin: EdgeInsets.only(
                                  top: 15,
                                ),
                                child: Text(
                                  AppStrings.loginText,
                                  style: Styles.textStyle,
                                ),
                              ),
                            ),
                            Center(
                              child: Container(
                                margin: EdgeInsets.only(
                                  top: 40,
                                ),
                                child: SizedBox(
                                  child: TexFieldWidget(
                                    obscureText: false,
                                    focusNode: _focusNodes[0],
                                    nameController: namecontroller,
                                    icon: Icon(
                                      Icons.pedal_bike_outlined,
                                      color: _focusNodes[0].hasFocus
                                          ? AppColors.strongCyan
                                          : AppColors.gray,
                                    ),
                                    text: AppStrings.correoText,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return AppStrings
                                            .errorEnterYourUsername;
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                            Center(
                              child: Container(
                                margin: EdgeInsets.only(
                                  top: 105,
                                ),
                                child: SizedBox(
                                  child: TexFieldWidget(
                                    focusNode: _focusNodes[1],
                                    nameController: passwordController,
                                    icon: Icon(
                                      Icons.lock,
                                      color: _focusNodes[1].hasFocus
                                          ? AppColors.strongCyan
                                          : AppColors.gray,
                                    ),
                                    iconButton: IconButton(
                                      icon: Icon(
                                        obscureText
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                      ),
                                      color: AppColors.strongCyan,
                                      onPressed: _toggle,
                                    ),
                                    obscureText: obscureText,
                                    text: AppStrings.passwordText,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return AppStrings.enterPassword;
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                            Center(
                              child: GestureDetector(
                                child: Container(
                                  margin: EdgeInsets.only(
                                    top: 170,
                                  ),
                                  child: Text(AppStrings.forgetYourPassword),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          RecoverPassword(),
                                    ),
                                  );
                                },
                              ),
                            ),
                            GestureDetector(
                              child: Container(
                                margin: EdgeInsets.only(top: 200),
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
                                          )
                                        ],
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.strongCyan,
                                        ),
                                        height: 60,
                                        width: 60,
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
                                _validateInputs();
                                setState(
                                  () {
                                    loading = true;
                                  },
                                );
                                ResponseRepo logged =
                                    await AuthenticationRepository().login(
                                  namecontroller.text,
                                  passwordController.text,
                                );
                                if (logged.status) {
                                  Analitycs.login(namecontroller.text);
                                  final biuxUser =
                                      await UserFirebaseRepository().getUserId(
                                    logged.message,
                                  );
                                  LocalStorage().setUserName(biuxUser.userName);
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    AppRoutes.mainMenuRoute,
                                    (route) => false,
                                  );
                                } else {
                                  setState(
                                    () {
                                      loading = false;
                                    },
                                  );
                                  Future.delayed(
                                    Duration(milliseconds: 5),
                                    () async {
                                      final snackBar = SnackBar(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(40),
                                            topRight: Radius.circular(40),
                                          ),
                                        ),
                                        backgroundColor: AppColors.red,
                                        content: Text(
                                          namecontroller.text == '' &&
                                                  passwordController.text == ''
                                              ? AppStrings.enterData
                                              : namecontroller.text == ''
                                                  ? AppStrings
                                                      .errorEnterYourUsername
                                                  : passwordController.text ==
                                                          ''
                                                      ? AppStrings
                                                          .errorEnterYourPassword
                                                      : logged.message,
                                          style: Styles.advertisingTitle,
                                        ),
                                      );
                                      _scaffolState.currentState!
                                          .showSnackBar(snackBar);
                                    },
                                  );
                                }
                              },
                            ),
                            loading == true ? Loading() : Container(),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              child: Stack(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: AppColors.white,
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(
                                      top: 10,
                                      left: 12,
                                    ),
                                    width: 25,
                                    height: 25,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                          Images.kFacebookLogo,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () async {
                                setState(
                                  () {
                                    loading = true;
                                  },
                                );
                                LoginResult result =
                                    await AuthenticationRepository
                                        .signInWithFacebook();
                                UserCredential? userCredential =
                                    await AuthenticationRepository
                                        .signInWithCredential(result: result);
                                await _getDataFacebook(result: result);
                                if (result.status != LoginStatus.success) {
                                  setState(
                                    () {
                                      loading = false;
                                    },
                                  );
                                  _showDialog2(
                                    AppStrings.messageFacebookCancel,
                                  );
                                }
                                urlToFile(
                                  Uri.parse(
                                    _userData![AppStrings.pictureText]
                                            [AppStrings.dataText]
                                        [AppStrings.urlText],
                                  ),
                                );
                                userfacebook = await UserFirebaseRepository()
                                    .getValidationEmails(
                                  userCredential?.user?.email ?? '',
                                );
                                cityData =
                                    await CitiesFirebaseRepository().getCityId(
                                  AppStrings.ibagueText.toLowerCase(),
                                );
                                if (userfacebook.facebook.isEmpty) {
                                  setState(
                                    () {
                                      loading = false;
                                    },
                                  );
                                  await _completeUser(userCredential);
                                }
                                if (_userData![AppStrings.emailUser] ==
                                    userfacebook.email) {
                                  createUser(
                                    BiuxUser(
                                      id: userCredential!.user!.uid,
                                      userName: userfacebook.facebook != ''
                                          ? userfacebook.userName
                                          : nameUser,
                                      modality: [
                                        AppStrings.urbanoText.toLowerCase(),
                                        AppStrings.rutaText.toLowerCase()
                                      ],
                                      dateBirth: AppStrings.fechaText,
                                      fullName: _userData![
                                              AppStrings.firstNameText] +
                                          ' ' +
                                          _userData![AppStrings.lastNameText],
                                      cityId: cityData,
                                      premium: false,
                                      email: userCredential.user!.email!,
                                      password: AppStrings.keyCode,
                                      facebook: AppStrings.validationFacebook(
                                        userdata: _userData!,
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                            const SizedBox(
                              width: 30,
                            ),
                            buttonStartDataData(),
                            const SizedBox(
                              width: 30,
                            ),
                            GestureDetector(
                              child: Stack(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: AppColors.white,
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(
                                      top: 10,
                                      left: 12,
                                    ),
                                    width: 25,
                                    height: 25,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                          Images.kGoogleLogo,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () async {
                                setState(
                                  () {
                                    loading = true;
                                  },
                                );
                                user = await AuthenticationRepository
                                    .signInWithGoogle(context: context);
                                if (user == null) {
                                  setState(
                                    () {
                                      loading = false;
                                    },
                                  );
                                  _showDialog2(
                                    AppStrings.gmailCancel,
                                  );
                                }
                                urlToFile(
                                  Uri.parse(user.photoURL!),
                                );
                                userEmail = await UserFirebaseRepository()
                                    .getValidationEmails(user.email!);
                                cityData =
                                    await CitiesFirebaseRepository().getCityId(
                                  AppStrings.ibagueText.toLowerCase(),
                                );
                                if (userEmail.email == null) {
                                  setState(
                                    () {
                                      loading = false;
                                    },
                                  );
                                  await _completeUser2();
                                }
                                if (user.email == userEmail.email) {
                                  createUser(
                                    BiuxUser(
                                      followerS: userEmail.followerS,
                                      followers: userEmail.followers,
                                      following: userEmail.following,
                                      gender: userEmail.gender,
                                      groupId: userEmail.groupId,
                                      id: userEmail.id,
                                      photo: userEmail.photo,
                                      profileCover: userEmail.profileCover,
                                      situationAccident:
                                          userEmail.situationAccident,
                                      token: userEmail.token,
                                      whatsapp: userEmail.token,
                                      userName: userEmail.userName,
                                      modality: ["urbano", "ruta"],
                                      dateBirth: "fecha",
                                      fullName: user.displayName!,
                                      cityId: cityData,
                                      premium: false,
                                      email: user.email!,
                                      password: "000000",
                                    ),
                                    us: user,
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              width: 120,
                              height: 1,
                              color: AppColors.white,
                            ),
                            Container(
                              child: Text(
                                'o',
                                style: Styles.rowContainer,
                              ),
                              height: 20,
                            ),
                            Container(
                              width: 120,
                              height: 1,
                              color: AppColors.white,
                            ),
                          ],
                        ),
                        Container(
                          height: 10,
                        ),
                        SizedBox(
                          height: 50,
                          width: 180,
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                15.0,
                              ),
                            ),
                            color: _darkTheme == true
                                ? AppColors.greyishNavyBlue
                                : AppColors.strongCyan,
                            child: Text(
                              AppStrings.createUser,
                              style: _darkTheme == true
                                  ? Styles.sizedBoxWhite
                                  : Styles.sizedBoxWhite,
                            ),
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.createUserRoute,
                              );
                            },
                          ),
                        ),
                        Container(
                          height: 10,
                        ),
                        Container(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  void _validateInputs() {}
  Widget buttonStartDataData() {
    if (Platform.isIOS) {
      return GestureDetector(
        child: Stack(
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: AppColors.white,
              ),
              child: SignInWithAppleButton(
                text: "",
                onPressed: () async {
                  final credential = await SignInWithApple.getAppleIDCredential(
                    scopes: [
                      AppleIDAuthorizationScopes.email,
                      AppleIDAuthorizationScopes.fullName,
                    ],
                  );
                },
              ),
            )
          ],
        ),
        onTap: () async {},
      );
    } else {
      return Container();
    }
  }

  createUser(
    BiuxUser biuxUser, {
    User? us,
  }) async {
    final uriResponse = await UserFirebaseRepository().getValidationEmails(
      biuxUser.email,
    );
    if (uriResponse.email == '' || uriResponse.email != '') {
      if (uriResponse.email == '' && us != null) {
        // If the user non-existent and is GoogleSign
        await UserFirebaseRepository().registerUser(
          user: biuxUser,
        );
        Future.delayed(
          Duration(seconds: 1),
          () async {
            await UserFirebaseRepository().uploadPhoto(
              biuxUser.id,
              imageNetworks,
            );
            setState(
              () {
                loading = false;
              },
            );
            LocalStorage().setUserName(biuxUser.userName);
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.mainMenuRoute,
              (route) => false,
            );
          },
        );
        Analitycs.sendSignUp(biuxUser.id);
      } else {
        if (_userData != null) {
          if (uriResponse.email == '' &&
              _userData![AppStrings.firstNameText] != null) {
            await UserFirebaseRepository().registerUser(
              user: biuxUser,
            );
            Future.delayed(
              Duration(seconds: 1),
              () async {
                await UserFirebaseRepository().uploadPhoto(
                  biuxUser.id,
                  imageNetworks,
                );
                setState(() {
                  loading = false;
                });
                LocalStorage().setUserName(biuxUser.userName);
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.mainMenuRoute,
                  (route) => false,
                );
              },
            );
            Analitycs.sendSignUp(biuxUser.id);
          }
          if (uriResponse.email != '' &&
              _userData![AppStrings.firstNameText] != null) {
            LocalStorage().setUserName(userfacebook.userName);
            setState(
              () {
                loading = false;
              },
            );
            Analitycs.login(_userData![AppStrings.emailText]!);
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.mainMenuRoute,
              (route) => false,
            );
          }
        } else {
          if (uriResponse.email != '' && us!.email != null) {
            // If user exits and is GoogleSign
            setState(
              () {
                loading = false;
              },
            );
            LocalStorage().setUserName(biuxUser.userName);
            Analitycs.login(us.email!);
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.mainMenuRoute,
              (route) => false,
            );
          }
        }
      }
    } else {
      setState(
        () {
          loading = false;
        },
      );
    }
  }

  Future<void> _completeUser(UserCredential? userCredential) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MaterialApp(
          home: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
              side: BorderSide(
                width: 3,
                color: AppColors.greyishNavyBlue,
              ),
            ),
            content: Text(AppStrings.errorEnterYourUsername),
            actions: <Widget>[
              Center(
                child: TexFieldWidget(
                  obscureText: false,
                  color: AppColors.black,
                  focusNode: _focusNodes[2],
                  nameController: newUserController,
                  text: AppStrings.nameUserText,
                  icon: Icon(
                    Icons.person_outline,
                    color: _focusNodes[2].hasFocus
                        ? AppColors.strongCyan
                        : AppColors.gray,
                  ),
                ),
              ),
              Center(
                child: FlatButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    side: BorderSide(
                      width: 3,
                      color: AppColors.greyishNavyBlue,
                    ),
                  ),
                  onPressed: () async {
                    final valUser = await UserFirebaseRepository()
                        .getValidationUserName(newUserController.text);
                    if (newUserController.text.length >= 4 && !valUser ||
                        userfacebook.facebook ==
                            AppStrings.validationFacebook(
                              userdata: _userData!,
                            )) {
                      nameUser = newUserController.text;
                      Navigator.pop(context);
                      setState(
                        () {
                          loading = true;
                        },
                      );
                      createUser(
                        BiuxUser(
                          userName: nameUser,
                          modality: [
                            AppStrings.urbanoText.toLowerCase(),
                            AppStrings.rutaText.toLowerCase()
                          ],
                          dateBirth: AppStrings.fechaText,
                          photo: _userData![AppStrings.pictureText]
                              [AppStrings.dataText][AppStrings.urlText],
                          fullName: _userData![AppStrings.firstNameText] +
                              ' ' +
                              _userData![AppStrings.lastNameText],
                          cityId: cityData,
                          premium: false,
                          email: userCredential!.user?.email ?? '',
                          id: userCredential.user?.uid ?? '',
                          password: AppStrings.keyCode,
                          facebook: AppStrings.validationFacebook(
                            userdata: _userData!,
                          ),
                          instagram: "",
                        ),
                      );
                    } else {
                      _showDialog2(
                        newUserController.text.length < 4
                            ? AppStrings.errorUsernameShort
                            : AppStrings.messageRegisteredUser(
                                message: newUserController.text,
                              ),
                      );
                    }
                  },
                  child: Text(
                    AppStrings.accept,
                    style: Styles.accentTextThemeBlack,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _completeUser2() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MaterialApp(
          home: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
              side: BorderSide(
                width: 3,
                color: AppColors.greyishNavyBlue,
              ),
            ),
            content: Text(AppStrings.errorEnterYourUsername),
            actions: <Widget>[
              Center(
                child: TexFieldWidget(
                  obscureText: false,
                  color: AppColors.black,
                  focusNode: _focusNodes[3],
                  nameController: newUser2Controller,
                  text: AppStrings.nameUserText,
                  icon: Icon(
                    Icons.person_outline,
                    color: _focusNodes[3].hasFocus
                        ? AppColors.strongCyan
                        : AppColors.gray,
                  ),
                ),
              ),
              Center(
                child: FlatButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    side: BorderSide(
                      width: 3,
                      color: AppColors.greyishNavyBlue,
                    ),
                  ),
                  onPressed: () async {
                    final valUser = await UserFirebaseRepository()
                        .getValidationUserName(newUser2Controller.text);
                    if (newUser2Controller.text.length >= 4 && !valUser) {
                      nameUser = newUser2Controller.text;
                      var text = user.displayName!.split(" ");
                      Navigator.pop(context);
                      setState(
                        () {
                          loading = true;
                        },
                      );
                      createUser(
                        BiuxUser(
                          id: user.uid,
                          userName: nameUser,
                          modality: [
                            AppStrings.urbanoText.toLowerCase(),
                            AppStrings.rutaText.toLowerCase()
                          ],
                          dateBirth: AppStrings.fechaText,
                          photo: user.photoURL!,
                          fullName: user.displayName!,
                          cityId: cityData,
                          premium: false,
                          email: user.email!,
                          password: AppStrings.keyCode,
                        ),
                        us: user,
                      );
                    } else {
                      _showDialog2(
                        newUser2Controller.text.length < 4
                            ? AppStrings.errorUsernameShort
                            : AppStrings.messageRegisteredUser(
                                message: newUser2Controller.text,
                              ),
                      );
                    }
                  },
                  child: Text(
                    AppStrings.accept,
                    style: Styles.accentTextThemeBlack,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDialog2(String response) {
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
