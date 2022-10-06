import 'dart:io';
import 'package:autocomplete_textfield_ns/autocomplete_textfield_ns.dart';
import 'package:biux/config/colors.dart';
import 'package:biux/config/images.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/data/models/response.dart';
import 'package:biux/data/models/user.dart';
import 'package:biux/data/models/analitics.dart';
import 'package:biux/data/models/city.dart';
import 'package:biux/data/models/state.dart';
import 'package:biux/data/models/country.dart';
import 'package:biux/data/repositories/authentication_repository.dart';
import 'package:biux/data/repositories/cities/cities_firebase_repository.dart';
import 'package:biux/data/repositories/users/user_firebase_repository.dart';
import 'package:biux/ui/screens/home.dart';
import 'package:biux/ui/widgets/loading_widget.dart';
import 'package:biux/ui/widgets/textField_widget.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class CreateUser extends StatefulWidget {
  final String? nameF;
  final String? emailF;
  CreateUser({
    this.nameF,
    this.emailF,
  });

  @override
  _CreateUserState createState() => _CreateUserState();
}

class _CreateUserState extends State<CreateUser> {
  final PageController controller = PageController(initialPage: 0);
  var _names;
  var username;
  var nameUser;
  late City cityData;
  var validarUser = false;
  var validarEmail = false;
  var validate = 1;
  late String base64Image;
  late String base64ImagePortada;
  var _surnames;
  var _city;
  var _password;
  var cellphone;
  var _email;
  var photo;
  var _instagram;
  var _facebook;
  final nameController = TextEditingController();
  final surnamesController = TextEditingController();
  final cellphoneController = TextEditingController();
  final cityController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final userNameController = TextEditingController();
  bool obscureText = true;
  bool _isChecked = false;
  bool loading = false;
  bool createdSuccess = false;
  late String _myActivity;
  late String _myActivity2;
  var _image;
  ScrollController _scrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();
  Future getImageFromGallery() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile pickedFile;
    pickedFile = (await imagePicker.getImage(source: ImageSource.gallery))!;
    File image = File(pickedFile.path);
    if (image != null) {
      setState(
        () {
          _image = image;
        },
      );
    }
  }

  var _imageProfileCover;

  Future getImageProfileCover() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile pickedFile;
    pickedFile = (await imagePicker.getImage(source: ImageSource.gallery))!;
    File image = File(pickedFile.path);
    if (image != null) {
      setState(() {
        _imageProfileCover = image;
      });
      if (image == null) {
        setState(() {});
      }
    }
  }

  void _toggle() {
    setState(() {
      obscureText = !obscureText;
    });
  }

  List<FocusNode> _focusNodes = [
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
  ];
  late List<String> listStringCities = [];
  List<String> cityValidation = [
    AppStrings.ciudadNoEncontrada,
  ];
  List<City> listCities = [];
  var validateColor1;
  var validateColor2;
  var emailRepeted;
  var userRepeted2;
  var color1 = AppColors.red;
  var color2 = AppColors.red;
  var color3 = AppColors.red;
  var color4 = AppColors.red;
  var color5 = AppColors.red;
  var color6 = AppColors.red;
  var color7 = AppColors.red;

  @override
  void initState() {
    _focusNodes.forEach(
      (node) {
        node.addListener(
          () {
            setState(() {});
          },
        );
      },
    );
    super.initState();
    cityData = City(
      name: "",
      state: '0',
      id: '0',
    );
    listCities = [];
    listStringCities = [];
    Future.delayed(
      Duration.zero,
      () async {
        listCities = await CitiesFirebaseRepository().getCities();
        this.setState(
          () {
            listCities.forEach((e) => listStringCities.add(e.name));
          },
        );
      },
    );
  }

  GlobalKey<AutoCompleteTextFieldState<String>> key = GlobalKey();
  @override
  final GlobalKey<ScaffoldState> _scaffolState = GlobalKey<ScaffoldState>();
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(
        key: _scaffolState,
        backgroundColor: AppColors.darkBlue,
        body: ListView(
          children: [
            Form(
              key: _formKey,
              child: Stack(
                children: [
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        colorFilter: ColorFilter.mode(
                          AppColors.darkBlue.withOpacity(0.4),
                          BlendMode.dstATop,
                        ),
                        image: AssetImage(Images.kAdBiciCombeima),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                          top: 15,
                          left: 10,
                        ),
                        child: Text(
                          AppStrings.welcomePart1,
                          textAlign: TextAlign.center,
                          style: Styles.wrapDrawerWhite,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                          top: 15,
                          left: 10,
                        ),
                        child: Text(
                          AppStrings.welcomePart2,
                          textAlign: TextAlign.center,
                          style: Styles.stackWhite,
                        ),
                      )
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 37, left: 12),
                    child: Text(
                      AppStrings.signUpToRoll,
                      textAlign: TextAlign.center,
                      style: Styles.containerDescription,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 55),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 50),
                          child: Stack(
                            children: [
                              Center(
                                child: Container(
                                  height: 620,
                                  width: 370,
                                  child: Card(
                                    color: AppColors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                            top: 20,
                                          ),
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
                                          validator: (value) {},
                                        ),
                                        TexFieldWidget(
                                          obscureText: false,
                                          focusNode: _focusNodes[1],
                                          nameController: surnamesController,
                                          text: AppStrings.surnameText,
                                          icon: Icon(
                                            Icons.person_outline,
                                            color: _focusNodes[1].hasFocus
                                                ? AppColors.strongCyan
                                                : AppColors.gray,
                                          ),
                                          validator: (value) {},
                                        ),
                                        TexFieldWidget(
                                          obscureText: false,
                                          color: validateColor1 ==
                                                  AppStrings.validatedText
                                              ? color1
                                              : AppColors.black,
                                          focusNode: _focusNodes[2],
                                          nameController: userNameController,
                                          text: AppStrings.nameUserText,
                                          icon: Icon(
                                            Icons.pedal_bike_outlined,
                                            color: _focusNodes[2].hasFocus
                                                ? AppColors.strongCyan
                                                : AppColors.gray,
                                          ),
                                          onChanged: (String value) async {},
                                          validator: (value) {},
                                        ),
                                        TexFieldWidget(
                                          obscureText: false,
                                          focusNode: _focusNodes[3],
                                          nameController: emailController,
                                          color: validateColor2 ==
                                                  AppStrings.validatedText
                                              ? color2
                                              : AppColors.black,
                                          text: AppStrings.correoText,
                                          icon: Icon(
                                            Icons.email,
                                            color: _focusNodes[3].hasFocus
                                                ? AppColors.strongCyan
                                                : AppColors.gray,
                                          ),
                                          validator: (value2) {
                                            if (emailController.text.contains(
                                                    AppStrings.gmailText) ||
                                                emailController.text.contains(
                                                    AppStrings.hotmailText) ||
                                                emailController.text.contains(
                                                    AppStrings.outlookText)) {
                                              setState(
                                                () {
                                                  _email = "";
                                                },
                                              );
                                            } else {
                                              setState(
                                                () {
                                                  _email =
                                                      AppStrings.novalidoText;
                                                },
                                              );
                                            }
                                          },
                                        ),
                                        SizedBox(
                                          height: 78,
                                          child: TexFieldWidget(
                                            obscureText: false,
                                            keyboardType: TextInputType.number,
                                            maxLength: 10,
                                            focusNode: _focusNodes[4],
                                            nameController: cellphoneController,
                                            text: AppStrings.phoneText,
                                            icon: Icon(
                                              Icons.phone_outlined,
                                              color: _focusNodes[4].hasFocus
                                                  ? AppColors.strongCyan
                                                  : AppColors.gray,
                                            ),
                                            validator: (value) {},
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
                                            child: SimpleAutoCompleteTextField(
                                              key: key,
                                              focusNode: _focusNodes[5],
                                              style: Styles.sizedBox,
                                              textInputAction:
                                                  TextInputAction.next,
                                              decoration: InputDecoration(
                                                prefixIcon: Icon(
                                                  Icons.place,
                                                  color: _focusNodes[5].hasFocus
                                                      ? AppColors.strongCyan
                                                      : AppColors.gray,
                                                ),
                                                fillColor: AppColors.white,
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: AppColors.gray,
                                                    width: 1,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
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
                                                errorBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: AppColors.green,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    15,
                                                  ),
                                                ),
                                                focusedErrorBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: AppColors.green,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    15,
                                                  ),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: AppColors.gray,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(
                                                      45,
                                                    ),
                                                  ),
                                                ),
                                                hintStyle:
                                                    Styles.paddingHintText,
                                              ),
                                              controller: cityController,
                                              suggestions: listStringCities,
                                              textChanged: (text) =>
                                                  listStringCities.first = text,
                                              clearOnSubmit: false,
                                              textSubmitted: (text) {
                                                setState(() async {
                                                  if (text != "") {
                                                    cityData =
                                                        await CitiesFirebaseRepository()
                                                            .getCityId(
                                                      text,
                                                    );
                                                    if (cityData.name != "") {
                                                      _city = listStringCities
                                                          .first;
                                                    } else {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .only(
                                                              topLeft: Radius
                                                                  .circular(
                                                                40,
                                                              ),
                                                              topRight: Radius
                                                                  .circular(
                                                                40,
                                                              ),
                                                            ),
                                                          ),
                                                          backgroundColor:
                                                              AppColors.red,
                                                          content: Text(
                                                            AppStrings
                                                                .cityNotExist,
                                                            style: Styles
                                                                .advertisingTitle,
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  }
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                        TexFieldWidget(
                                          focusNode: _focusNodes[6],
                                          nameController: passwordController,
                                          text: AppStrings.passwordText,
                                          icon: Icon(
                                            Icons.lock_outline,
                                            color: _focusNodes[6].hasFocus
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
                                          validator: (value) {},
                                        ),
                                        TexFieldWidget(
                                          focusNode: _focusNodes[7],
                                          nameController:
                                              confirmPasswordController,
                                          text: AppStrings.repeatPassword,
                                          icon: Icon(
                                            Icons.lock_outline,
                                            color: _focusNodes[7].hasFocus
                                                ? AppColors.strongCyan
                                                : AppColors.gray,
                                          ),
                                          obscureText: obscureText,
                                          validator: (value) {},
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Container(
                                              width: 10,
                                            ),
                                            SizedBox(
                                              height: 40.0,
                                              width: 50,
                                              child: Checkbox(
                                                activeColor:
                                                    AppColors.strongCyan,
                                                value: _isChecked,
                                                onChanged: (bool? val) {
                                                  if (_isChecked == false) {
                                                    setState(
                                                      () {
                                                        _isChecked = true;
                                                      },
                                                    );
                                                  } else if (_isChecked ==
                                                      true) {
                                                    setState(
                                                      () {
                                                        _isChecked = false;
                                                      },
                                                    );
                                                  }
                                                },
                                              ),
                                            ),
                                            GestureDetector(
                                              child: Container(
                                                child: Text(
                                                  AppStrings.termsConditions
                                                      .toUpperCase(),
                                                  style:
                                                      Styles.rowGestureDetector,
                                                ),
                                              ),
                                              onTap: () {},
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
                            margin: EdgeInsets.only(top: 630),
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Material(
                                elevation: 20,
                                borderRadius: BorderRadius.circular(55.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(60.0),
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
                                            size: 30,
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
                            if (_formKey.currentState!.validate() &&
                                    _image != null &&
                                    nameController.text.isNotEmpty &&
                                    surnamesController.text.isNotEmpty &&
                                    userNameController.text.isNotEmpty &&
                                    userNameController.text.length >= 4 &&
                                    emailController.text.isNotEmpty &&
                                    emailController.text
                                        .contains(AppStrings.gmailText) ||
                                emailController.text
                                    .contains(AppStrings.hotmailText) ||
                                emailController.text
                                        .contains(AppStrings.outlookText) &&
                                    cellphoneController.text.isNotEmpty &&
                                    cellphoneController.text.length == 10 &&
                                    cityController.text.isNotEmpty &&
                                    cityController.text == cityData.name &&
                                    passwordController.text.isNotEmpty &&
                                    confirmPasswordController.text.isNotEmpty &&
                                    confirmPasswordController.text.length > 7 &&
                                    passwordController.text ==
                                        confirmPasswordController.text) {
                              nameUser = userNameController.text.toLowerCase();
                              _names = nameController.text;
                              _city = cityController.text;
                              cellphone = cellphoneController.text;
                              _password = passwordController.text;
                              _email = emailController.text;
                              _surnames = surnamesController.text;
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
                                  dateBirth: AppStrings.selectDateText,
                                  names: _names,
                                  cityId: cityData.id,
                                  surnames: _surnames,
                                  premium: false,
                                  email: _email,
                                  password: _password,
                                  facebook: "",
                                  instagram: "",
                                ),
                              );
                            } else {
                              final snackBar = SnackBar(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(40),
                                    topRight: Radius.circular(40),
                                  ),
                                ),
                                backgroundColor: AppColors.red,
                                content: Text(
                                  _image == null
                                      ? AppStrings.textErrorImageProfile
                                      : nameController.text.isEmpty
                                          ? AppStrings.errorEnterYourName
                                          : surnamesController.text.isEmpty
                                              ? AppStrings
                                                  .errorEnterYourLastname
                                              : userNameController.text.isEmpty
                                                  ? AppStrings
                                                      .errorEnterYourUsername
                                                  : userNameController
                                                              .text.length <
                                                          4
                                                      ? AppStrings
                                                          .errorUsernameShort
                                                      : emailController
                                                              .text.isEmpty
                                                          ? AppStrings
                                                              .errorEnterYourEmail
                                                          : _email ==
                                                                      AppStrings
                                                                          .novalidoText &&
                                                                  emailController
                                                                      .text
                                                                      .isNotEmpty
                                                              ? AppStrings
                                                                  .errorEnterYourEmail
                                                              : cellphoneController
                                                                      .text
                                                                      .isEmpty
                                                                  ? AppStrings
                                                                      .errorEnterYourPhone
                                                                  : cellphoneController
                                                                              .text
                                                                              .length <
                                                                          10
                                                                      ? AppStrings
                                                                          .errorEnterYourPhone2
                                                                      : cityController
                                                                              .text
                                                                              .isEmpty
                                                                          ? AppStrings
                                                                              .errorEnterYourCity
                                                                          : cityData.name == ""
                                                                              ? AppStrings.errorCity
                                                                              : passwordController.text.isEmpty
                                                                                  ? AppStrings.errorEnterYourPassword
                                                                                  : passwordController.text.length <= 7
                                                                                      ? AppStrings.errorPassword
                                                                                      : confirmPasswordController.text.isEmpty || passwordController.text != confirmPasswordController.text
                                                                                          ? AppStrings.yourPasswordDoesNotMatch
                                                                                          : AppStrings.errorConfirmTermsConditions,
                                  style: Styles.advertisingTitle,
                                ),
                              );
                              _scaffolState.currentState!
                                  .showSnackBar(snackBar);
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
                                    borderRadius: BorderRadius.circular(60.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.white,
                                        spreadRadius: 5,
                                      )
                                    ]),
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.strongCyan,
                                  ),
                                  height: 100,
                                  width: 100,
                                  child: _image == null
                                      ? Stack(
                                          children: <Widget>[
                                            GestureDetector(
                                              onTap: () {
                                                setState(
                                                  () {
                                                    getImageFromGallery();
                                                  },
                                                );
                                              },
                                            ),
                                          ],
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
                                                  image: FileImage(
                                                    _image.path != null
                                                        ? _image
                                                        : getImageFromGallery(),
                                                  )),
                                              borderRadius: BorderRadius.all(
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
                          bottom: 600,
                          left: 86,
                          right: 0,
                          child: GestureDetector(
                            child: Align(
                              alignment: Alignment(0.0, 0.0),
                              child: Material(
                                elevation: 10,
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(60.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.white,
                                          spreadRadius: 6,
                                        )
                                      ]),
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
              height: 20,
            ),
          ],
        ),
      ),
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
                topRight: Radius.circular(
                  40,
                ),
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

  void createUser(BiuxUser user) async {
    try {
      var userRepeted = await UserFirebaseRepository()
          .getValidationUser(userNameController.text);
      if (_isChecked == true) {
        if (userRepeted.userName != userNameController.text) {
          setState(
            () {
              validateColor1 = AppStrings.novalidoText2;
            },
          );
          final ResponseRepo response =
              await AuthenticationRepository().registerUser(user: user);
          if (response.message != 'email-already-in-use') {
            setState(
              () {
                validateColor2 = AppStrings.novalidoText2;
              },
            );
            if (response.statusCode == 200) {
              Future.delayed(
                Duration(seconds: 3),
                () {
                  _scaffolState.currentState!.showSnackBar(
                    SnackBar(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                      ),
                      backgroundColor: AppColors.strongCyan,
                      content: Text(
                        AppStrings.biuxUserText,
                        style: Styles.advertisingTitle,
                      ),
                    ),
                  );
                },
              );
              String id = response.message;
              Future.delayed(
                Duration(seconds: 5),
                () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => MyHome(),
                    ),
                  );
                },
              );
              Analitycs.sendSignUp(id);
              Future.delayed(
                Duration(seconds: 10),
                () async {
                  await UserFirebaseRepository().uploadPhoto(
                    id,
                    _image,
                  );
                },
              );
              setState(
                () {
                  createdSuccess = true;
                },
              );
            } else {
              setState(
                () {
                  validateColor2 = AppStrings.validatedText;
                  loading = false;
                },
              );
              return _showDialog2(
                AppStrings.messageRegisteredGmail(
                  message: emailController.text,
                ),
              );
            }
          } else {
            setState(
              () {
                loading = false;
                validarUser = true;
                _formKey.currentState!.validate();
              },
            );
            return _showDialog2(
              response.message,
            );
          }
        } else {
          setState(
            () {
              validateColor1 = AppStrings.validatedText;
              loading = false;
            },
          );
          return _showDialog2(
            AppStrings.messageRegisteredUser(
              message: userNameController.text,
            ),
          );
        }
      } else {
        setState(
          () {
            loading = false;
          },
        );
        return _showDialog2(AppStrings.errorConfirmTermsConditions2);
      }
    } catch (e) {
      loading = false;
    }
  }
}
