import 'dart:convert';
import 'dart:io';
import 'package:biux/config/colors.dart';
import 'package:biux/config/images.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/data/models/group.dart';
import 'package:biux/data/models/user.dart';
import 'package:biux/data/models/analitics.dart';
import 'package:biux/data/models/city.dart';
import 'package:biux/data/repositories/groups/groups_repository.dart';
import 'package:biux/ui/screens/home.dart';
import 'package:biux/ui/screens/user/edit_profile.dart';
import 'package:biux/ui/widgets/loading_widget.dart';
import 'package:biux/ui/widgets/textField_widget.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:biux/data/repositories/users/user_repository.dart';
import 'package:biux/data/shared_preferences/localstorage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class GroupScreen extends StatefulWidget {
  @override
  _GroupScreenState createState() => _GroupScreenState();
}

// Declare this variable
int selectedRadio = 0;

class _GroupScreenState extends State<GroupScreen> {
  final formKey = GlobalKey<FormState>();
  late BiuxUser _user;
  var _name;
  var _description;
  var _whatsapp;
  var _facebook;
  var _instagram;
  var _city;
  int size = 30;
  late int id;
  List<bool> isSelected = [false, true, false, true];
  FocusNode focusNodeButton1 = FocusNode();
  FocusNode focusNodeButton2 = FocusNode();
  FocusNode focusNodeButton3 = FocusNode();
  FocusNode focusNodeButton4 = FocusNode();
  late List<FocusNode> focusToggle;
  late String _myActivity;
  late String _myActivity2;
  late String _myActivity3;
  late Group _group;
  late bool face = false;
  var ciudad;
  String instagram = Images.kInstagramLogo;
  setSelectedRadio(int val) {
    setState(() {
      selectedRadio = val;
    });
  }

  late List<Group> listNamesGroups;
  var nameGroup;
  var validate = 1;
  var _image;
  bool _isChecked = false;
  bool loading = false;
  bool successCreate = false;
  final _formKey = GlobalKey<FormState>();
  // Future getImageFromGallery() async {
  //   var image = await ImagePicker.pickImage(
  //       source: ImageSource.gallery, maxHeight: 300, maxWidth: 300);
  //   if (image == null) {
  //     return;
  //   }
  //   setState(() {
  //     _image = image;
  //   });
  // }

  Future getImageFromGallery() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile pickedFile;
    pickedFile = (await imagePicker.getImage(
        source: ImageSource.gallery, imageQuality: 20))!;
    File image = File(pickedFile.path);
    if (image != null) {
      setState(() {
        _image = image;
      });
    }
  }

  var _image2;
  Future getImageProfileCover() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile pickedFile;
    pickedFile = (await imagePicker.getImage(
        source: ImageSource.gallery, imageQuality: 20))!;
    File image = File(pickedFile.path);
    if (image != null) {
      setState(() {
        _image2 = image;
      });
    }
  }

  bool autoValidate = false;
  List<FocusNode> _focusNodes = [
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
  ];
  List<City> listCities = [];
  var validateColor1;
  var validateColor2;
  var userRepeated;
  var emailRepeated;
  var color1 = AppColors.red;
  var color2 = AppColors.red;
  var color3 = AppColors.red;
  var color4 = AppColors.red;
  var color5 = AppColors.red;
  var color6 = AppColors.red;
  void initState() {
    super.initState();
    _user = BiuxUser(
      surnames: "",
      gender: "",
      names: "",
      id: '0',
    );
    getUserProfile();
    focusToggle = [focusNodeButton1, focusNodeButton2, focusNodeButton3];
  }

  getUserProfile() async {
    String? username = await LocalStorage().getUser();
    _user = await UserRepository().getPerson(username!);
    ciudad = await UserRepository().getSpecifiCities(_user.cityId!);
    setState(() {
      isLoggedIn = true;
    });
    if (_user.photo == AppStrings.urlBiuxApp ||
        _user.profileCover == AppStrings.urlBiuxApp) {
      complete(context);
    } else {}
  }

  @override
  final GlobalKey<ScaffoldState> _scaffolState = GlobalKey<ScaffoldState>();
  void dispose() {
    focusNodeButton1.dispose();
    focusNodeButton2.dispose();
    focusNodeButton3.dispose();
    super.dispose();
  }

  final nameGroupController = TextEditingController();
  final descriptionController = TextEditingController();
  final whatsappController = TextEditingController();
  final facebookController = TextEditingController();
  final instagramController = TextEditingController();
  final cityController = TextEditingController();
  final urbanController = TextEditingController();
  final downhillController = TextEditingController();
  bool isLoggedIn = false;
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(
        key: _scaffolState,
        backgroundColor: AppColors.darkBlue,
        body: Form(
          key: _formKey,
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(Images.kBackground),
                fit: BoxFit.cover,
              ),
            ),
            child: ListView(
              children: [
                Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.only(top: 0, left: 0),
                      height: 150,
                      width: 400,
                      child: Stack(
                        children: <Widget>[
                          _image2 == null
                              ? Container()
                              : Container(
                                  decoration: new BoxDecoration(
                                    image: new DecorationImage(
                                      image: new FileImage(
                                        _image2.path != null
                                            ? _image2
                                            : _image2,
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  height: 150,
                                  width: 400,
                                ),
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 18.0, right: 10),
                            child: Align(
                              alignment: Alignment.topRight,
                              child: SizedBox(
                                height: 40,
                                width: 120,
                                child: RaisedButton(
                                  color: AppColors.strongCyan,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(15.0),
                                    side: BorderSide(
                                      width: 3,
                                      color: AppColors.strongCyan,
                                    ),
                                  ),
                                  child: Text(
                                    AppStrings.uploadCover,
                                    style: Styles.uploadProfileCoverText,
                                  ),
                                  onPressed: getImageProfileCover,
                                ),
                              ),
                            ),
                          ),
                          Row(
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
                                  AppStrings.createGroupText,
                                  textAlign: TextAlign.center,
                                  style: Styles.createGroupText,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
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
                                    height: 520,
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
                                            padding: EdgeInsets.only(top: 20),
                                          ),
                                          TexFieldWidget(
                                            obscureText: false,
                                            focusNode: _focusNodes[0],
                                            nameController: nameGroupController,
                                            text: AppStrings.groupNameText,
                                            icon: Icon(
                                              Icons.person_outline,
                                              color: _focusNodes[0].hasFocus
                                                  ? AppColors.strongCyan
                                                  : AppColors.gray,
                                            ),
                                            validator: (value) {},
                                          ),
                                          SizedBox(
                                            height: 88,
                                            child: TexFieldWidget(
                                              obscureText: false,
                                              keyboardType:
                                                  TextInputType.number,
                                              maxLength: 10,
                                              focusNode: _focusNodes[2],
                                              nameController:
                                                  whatsappController,
                                              text: AppStrings.WhatsappText,
                                              icon: Icon(
                                                Icons.phone_outlined,
                                                color: _focusNodes[2].hasFocus
                                                    ? AppColors.strongCyan
                                                    : AppColors.gray,
                                              ),
                                              validator: (value) {},
                                            ),
                                          ),
                                          TexFieldWidget(
                                            obscureText: false,
                                            color: validateColor1 ==
                                                    AppStrings.validatedText
                                                ? color1
                                                : AppColors.black,
                                            focusNode: _focusNodes[3],
                                            nameController: facebookController,
                                            text: AppStrings.facebookText,
                                            icon: Icon(
                                              Icons.facebook,
                                              color: _focusNodes[3].hasFocus
                                                  ? AppColors.strongCyan
                                                  : AppColors.gray,
                                            ),
                                            validator: (value) {
                                              if (facebookController
                                                  .text.isEmpty) {
                                                _facebook =
                                                    AppStrings.notRegistered;
                                              } else {
                                                _facebook =
                                                    facebookController.text;
                                              }
                                            },
                                          ),
                                          TexFieldWidget(
                                            obscureText: false,
                                            focusNode: _focusNodes[4],
                                            nameController: instagramController,
                                            text: AppStrings.instagramText,
                                            icon: Image.asset(
                                              instagram,
                                              scale: 30,
                                            ),
                                            validator: (value) {
                                              if (instagramController.text ==
                                                  '') {
                                                _instagram =
                                                    AppStrings.notRegistered;
                                              } else {
                                                _instagram =
                                                    instagramController.text;
                                              }
                                            },
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                SizedBox(
                                                  width: size.width * 0.88,
                                                  height: 120,
                                                  child: TextFormField(
                                                    maxLines: 5,
                                                    controller:
                                                        descriptionController,
                                                    focusNode: _focusNodes[1],
                                                    style: Styles.sizedBox,
                                                    decoration: InputDecoration(
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
                                                                .circular(20),
                                                      ),
                                                      filled: true,
                                                      contentPadding:
                                                          EdgeInsets.fromLTRB(
                                                        10.0,
                                                        15.0,
                                                        20.0,
                                                        15.0,
                                                      ),
                                                      hintText: AppStrings
                                                          .descriptionText,
                                                      errorBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color:
                                                                AppColors.gray),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15),
                                                      ),
                                                      focusedErrorBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: AppColors.gray,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: AppColors.gray,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.all(
                                                          Radius.circular(15),
                                                        ),
                                                      ),
                                                      hintStyle: Styles
                                                          .sizedBoxHintStyle,
                                                    ),
                                                    autovalidateMode:
                                                        autoValidate
                                                            ? AutovalidateMode
                                                                .always
                                                            : AutovalidateMode
                                                                .disabled,
                                                    validator: (value) {},
                                                    onChanged: (value) {
                                                      _description = value;
                                                    },
                                                    maxLength: 600,
                                                    onSaved: (String? value) {
                                                      _description = value!;
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
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
                              margin: EdgeInsets.only(top: 525),
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
                                          new Center(
                                            child: new Icon(
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
                              if (_user.photo == AppStrings.urlBiuxApp ||
                                  _user.profileCover == AppStrings.urlBiuxApp) {
                                complete(context);
                              } else {
                                setState(() {
                                  loading = true;
                                });
                                if (_formKey.currentState!.validate() &&
                                        _image != null &&
                                        _image2 != null &&
                                        nameGroupController.text.isNotEmpty &&
                                        whatsappController.text.length == 10 &&
                                        facebookController.text.isEmpty ||
                                    facebookController.text
                                        .contains(AppStrings.urlFacebook)) {
                                  if (descriptionController.text.length >= 20) {
                                    Future.delayed(
                                      Duration(seconds: 2),
                                      () {
                                        Analitycs.createGroup(
                                            _user.userName!,
                                            _user.id!,
                                            nameGroupController.text,
                                            ciudad.nombre!);
                                        _scaffolState.currentState!
                                            .showSnackBar(
                                          SnackBar(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(40),
                                                topRight: Radius.circular(40),
                                              ),
                                            ),
                                            backgroundColor:
                                                AppColors.strongCyan,
                                            content: Text(
                                              AppStrings.groupCreatedText,
                                              style: Styles.advertisingTitle,
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                    createGroup(
                                      Group(
                                        cityAdmin: _user.cityId.toString(),
                                        name: nameGroupController.text,
                                        description: descriptionController.text,
                                        logoADM: _user.photo,
                                        profileCoverADM: _user.profileCover,
                                        namesAdmin: _user.names,
                                        active: true,
                                        surnamesAdmin: _user.surnames,
                                        whatsapp: whatsappController.text,
                                        type: true,
                                        cityId: _user.cityId,
                                        adminId: _user.id,
                                        facebook: _facebook,
                                        instagram: _instagram,
                                        modality: [
                                          AppStrings.urbanoText.toLowerCase()
                                        ],
                                      ),
                                    );
                                  } else {
                                    messageError(
                                      descriptionController.text.isEmpty
                                          ? AppStrings.textErrorDescription
                                          : descriptionController.text.length <
                                                  20
                                              ? AppStrings.textErrorDescription2
                                              : '',
                                    );
                                  }
                                } else {
                                  Future.delayed(
                                    Duration(seconds: 2),
                                    () {
                                      setState(() {
                                        loading = false;
                                      });
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
                                              : _image2 == null
                                                  ? AppStrings
                                                      .textErrorImageCover
                                                  : nameGroupController
                                                          .text.isEmpty
                                                      ? AppStrings.textErrorName
                                                      : whatsappController
                                                              .text.isEmpty
                                                          ? AppStrings
                                                              .textErrorWhatsapp
                                                          : whatsappController
                                                                      .text
                                                                      .length <
                                                                  10
                                                              ? AppStrings
                                                                  .textErrorWhatsapp2
                                                              : facebookController
                                                                          .text !=
                                                                      AppStrings
                                                                          .urlFacebook
                                                                  ? AppStrings
                                                                      .textErrorFacebook
                                                                  : AppStrings
                                                                      .textErrorCheck,
                                          style: Styles.advertisingTitle,
                                        ),
                                      );
                                      _scaffolState.currentState!
                                          .showSnackBar(snackBar);
                                    },
                                  );
                                }
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
                                    ],
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.strongCyan,
                                    ),
                                    height: 110,
                                    width: 110,
                                    child: _image == null
                                        ? Stack(
                                            children: <Widget>[
                                              GestureDetector(
                                                // child: new Center(
                                                //   child: new Icon(Icons.camera_alt),
                                                // ),
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
                                              alignment: (Alignment(-1.0, 2.5)),
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  fit: BoxFit.cover,
                                                  image: FileImage(
                                                    _image.path != null
                                                        ? _image
                                                        : getImageFromGallery(),
                                                  ),
                                                ),
                                                borderRadius: BorderRadius.all(
                                                  const Radius.circular(80.0),
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
                            bottom: 500,
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
                                              spreadRadius: 6)
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  void complete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            child: AlertDialog(
              backgroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(10.0),
                ),
              ),
              content: Text(
                AppStrings
                    .completedProfileBiux, //tituloactual == 0 ? titulo1 : titulo2,
                textAlign: TextAlign.center,
                style: Styles.showDialogTitleBlack,
              ),
              actions: <Widget>[
                // usually buttons at the bottom of the dialog
                Align(
                  alignment: Alignment.center,
                  child: FlatButton(
                    minWidth: 150,
                    color: AppColors.deepNavyBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Text(
                      AppStrings.completedText,
                      style: Styles.alignText,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => ViewEditProfile(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void messageError(String response) {
    Future.delayed(
      Duration(seconds: 2),
      () {
        setState(() {
          loading = false;
        });
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

//hasta aqui prro xd

  void createGroup(Group group) async {
    try {
      var uriResponse = await http.post(
        Uri.parse(AppStrings.urlBiuxGrupos),
        body: jsonEncode(group.toJson()),
        headers: {
          AppStrings.ContentTypeText: AppStrings.applicationJsonText,
        },
      );
      if (uriResponse.statusCode == 200) {
        final dataI = json.decode(uriResponse.body);
        String id = dataI[AppStrings.idText];
        LocalStorage().saveGroupId(
          id.toString(),
        );
        //  LocalStorage().eliminarGruposId();
        GroupsRepository().uploadLogoGroup(id, _image);
        GroupsRepository().uploadGroupProfileCover(id, _image2);
        Future.delayed(
          Duration(seconds: 5),
          () async {
            Navigator.of(context)
                .pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => MyHome(),
                    ),
                    (Route<dynamic> route) => false)
                .then(
                  (value) => setState(() => {}),
                );
          },
        );
        return;
      } else {
        return null;
      }
    } catch (e) {}
  }
}
