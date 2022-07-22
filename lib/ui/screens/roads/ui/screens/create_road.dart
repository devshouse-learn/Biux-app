import 'dart:convert';
import 'dart:io';
import 'package:biux/config/colors.dart';
import 'package:biux/config/images.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/data/shared_preferences/localstorage.dart';
import 'package:biux/data/models/group.dart';
import 'package:biux/data/models/member.dart';
import 'package:biux/data/models/road.dart';
import 'package:biux/data/models/user.dart';
import 'package:biux/data/models/analitics.dart';
import 'package:biux/data/repositories/groups/groups_repository.dart';
import 'package:biux/data/repositories/members/members_repository.dart';
import 'package:biux/data/repositories/roads/roads_repository.dart';
import 'package:biux/data/repositories/users/user_repository.dart';
import 'package:biux/ui/screens/group/ui/screens/group_slider/edit_group.dart';
import 'package:biux/ui/screens/home.dart';
import 'package:biux/ui/screens/user/edit_profile.dart';
import 'package:biux/ui/widgets/loading_widget.dart';
import 'package:biux/ui/widgets/textField_widget.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class CreateRoad extends StatefulWidget {
  @override
  _CreateRoadState createState() => _CreateRoadState();
}

// Declare this variable
int selectedRadio = 0;
var a = AppStrings.numbers;
var ab = json.decode(a);

class _CreateRoadState extends State<CreateRoad> {
  final _formKey = GlobalKey<FormState>();
  late Group _group;
  var _nameRoute;
  var _difficulty;
  var _distanceR = 0.0;
  var _description;
  var _meeting;
  late DateTime date;
  late TimeOfDay time;
  var userId;
  late BiuxUser user;
  List<bool> isSelected = [false, true, false, true];
  FocusNode focusNodeButton1 = FocusNode();
  FocusNode focusNodeButton2 = FocusNode();
  FocusNode focusNodeButton3 = FocusNode();
  FocusNode focusNodeButton4 = FocusNode();
  late List<FocusNode> focusToggle;
  late String username;
  late Member member;
  bool loading = false;
  setSelectedRadio(int val) {
    setState(
      () {
        selectedRadio = val;
      },
    );
  }

  List<FocusNode> _focusNodes = [
    FocusNode(),
    FocusNode(),
    FocusNode(),
  ];
  var groupId;
  @override
  void initState() {
    super.initState();
    getUserProfile();
    focusToggle = [
      focusNodeButton1,
      focusNodeButton2,
      focusNodeButton3,
    ];
  }

  getUserProfile() async {
    // var id = await LocalStorage().obtenerGrupoId();
    // userId = id!;
    username = (await LocalStorage().getUser())!;
    user = await UserRepository().getPerson(username);
    final nMember = await MembersRepository().getMyGroupsUser(user.id!);
    _group = await GroupsRepository().getSpecificGroup(nMember.group!.id!);
    this.setState(
      () {
        if (_group.admin!.id! == user.id)
          groupId = _group.id!;
        else {
          groupId = 0;
        }
      },
    );
    if (user.photo == AppStrings.urlBiuxApp ||
        user.profileCover == AppStrings.urlBiuxApp) {
      complete(context);
    } else {}
    if (username == _group.admin!.userName) {
      if (_group.logo == null || _group.profileCover == null) {
        complete2(context);
      }
    }
    this.setState(() {});
  }

  @override
  final GlobalKey<ScaffoldState> _scaffolState = GlobalKey<ScaffoldState>();
  void dispose() {
    focusNodeButton1.dispose();
    focusNodeButton2.dispose();
    focusNodeButton3.dispose();
    super.dispose();
  }

  final descriptionController = TextEditingController();
  final pathnameController = TextEditingController();
  final meetingController = TextEditingController();
  final dateController = TextEditingController();
  final distanceController = TextEditingController();
  final format = DateFormat(AppStrings.dateFormat4);
  var _image;

  Future getImageFromGallery() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile pickedFile;
    pickedFile = (await imagePicker.getImage(
        source: ImageSource.gallery, imageQuality: 30))!;
    File image = File(pickedFile.path);
    if (image != null) {
      this.setState(
        () {
          _image = image;
        },
      );
    }
  }

  String numberValidator(String? value) {
    if (value == null) {
      return "";
    }
    final n = num.tryParse(value);
    if (n == null) {
      return AppStrings.warningKm;
    }
    return "";
  }

  double rating = 0.0;
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
        body: ListView(
          children: [
            Form(
              key: _formKey,
              child: Stack(
                children: [
                  _image == null
                      ? Container(
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
                        )
                      : Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: FileImage(
                                _image,
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                          height: 150,
                          width: 400,
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
                        margin: EdgeInsets.only(top: 20, left: 10),
                        child: Text(
                          AppStrings.createYourRodada,
                          textAlign: TextAlign.center,
                          style: Styles.rowContainer,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 65),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 50),
                          child: Stack(
                            children: [
                              Center(
                                child: Container(
                                  height: 580,
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
                                            padding: const EdgeInsets.only(
                                              left: 15,
                                              right: 15,
                                            ),
                                            child: SizedBox()),
                                        Padding(
                                          padding: EdgeInsets.only(
                                            top: 10,
                                          ),
                                        ),
                                        TexFieldWidget(
                                          obscureText: false,
                                          focusNode: _focusNodes[0],
                                          nameController: pathnameController,
                                          text: AppStrings.nameRuta,
                                          icon: Icon(
                                            Icons.person_outline,
                                            color: AppColors.gray,
                                          ),
                                          validator: (value) {},
                                        ),
                                        TexFieldWidget(
                                          obscureText: false,
                                          focusNode: _focusNodes[1],
                                          nameController: meetingController,
                                          text: AppStrings.meetingPoint,
                                          icon: Icon(
                                            Icons.place_outlined,
                                            color: AppColors.gray,
                                          ),
                                          validator: (value) {},
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            new SizedBox(
                                              width: 100,
                                              height: 50,
                                              child: new TextFormField(
                                                keyboardType:
                                                    TextInputType.number,
                                                inputFormatters: <
                                                    TextInputFormatter>[
                                                  FilteringTextInputFormatter
                                                      .digitsOnly,
                                                ],
                                                maxLines: 1,
                                                controller: distanceController,
                                                decoration: InputDecoration(
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
                                                  hintText: AppStrings.km0,
                                                  errorBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: AppColors.gray,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      15,
                                                    ),
                                                  ),
                                                  focusedErrorBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: AppColors.gray,
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
                                                      Styles.sizedBoxHintStyle,
                                                ),
                                                validator: (value) {},
                                              ),
                                            ),
                                            Container(
                                              width: size.width * 0.15,
                                            ),
                                            Container(
                                              child: RatingStars(
                                                valueLabelMargin:
                                                    EdgeInsets.only(
                                                  top: 10,
                                                ),
                                                value: rating,
                                                onValueChanged: (v) {
                                                  this.rating = v;
                                                  setState(() {});
                                                },
                                                starBuilder: (index, color) =>
                                                    Icon(
                                                  Icons.star,
                                                  color: color,
                                                ),
                                                starCount: 5,
                                                starSize: 22,
                                                valueLabelColor: AppColors.grey,
                                                valueLabelTextStyle:
                                                    Styles.headline,
                                                valueLabelRadius: 10,
                                                maxValue: 5,
                                                starSpacing: 2,
                                                maxValueVisibility: true,
                                                valueLabelVisibility: true,
                                                animationDuration: Duration(
                                                    milliseconds: 1000),
                                                starOffColor: AppColors.white2,
                                                starColor: AppColors.strongCyan,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              SizedBox(
                                                width: size.width * 0.84,
                                                height: 120,
                                                child: TextFormField(
                                                  maxLines: 5,
                                                  controller:
                                                      descriptionController,
                                                  focusNode: _focusNodes[2],
                                                  style: Styles.sizedBox,
                                                  decoration: InputDecoration(
                                                    fillColor: AppColors.white,
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: AppColors.gray,
                                                        width: 1,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        15,
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
                                                    hintText: AppStrings
                                                        .descriptionRodada,
                                                    errorBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: AppColors.gray,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        15,
                                                      ),
                                                    ),
                                                    focusedErrorBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: AppColors.gray,
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
                                                          15,
                                                        ),
                                                      ),
                                                    ),
                                                    hintStyle: Styles
                                                        .sizedBoxHintStyle,
                                                  ),
                                                  validator: (value) {},
                                                  maxLength: 600,
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
                            margin: EdgeInsets.only(top: 580),
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
                                      ]),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.strongCyan,
                                    ),
                                    height: 70,
                                    width: 70,
                                    child: new Stack(
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
                            if (user.photo == AppStrings.urlBiuxApp ||
                                user.profileCover == AppStrings.urlBiuxApp) {
                              complete(context);
                            } else {
                              setState(() {
                                loading = true;
                              });
                              if (pathnameController.text.isNotEmpty &&
                                  _image != null &&
                                  dateController.text.isNotEmpty &&
                                  rating.toInt() != 0.0 &&
                                  descriptionController.text.isNotEmpty &&
                                  meetingController.text.isNotEmpty &&
                                  meetingController.text.length > 9 &&
                                  distanceController.text.isNotEmpty &&
                                  descriptionController.text.length >= 20) {
                                _createRoad(
                                  Road(
                                    name: pathnameController.text,
                                    dateTime: dateController.text,
                                    groupId: groupId,
                                    cityId: _group.city!.id,
                                    routeLevel: rating.toInt(),
                                    modality: [
                                      AppStrings.urbanoText.toUpperCase(),
                                      AppStrings.rutaText.toUpperCase()
                                    ],
                                    description: meetingController.text,
                                    pointmeeting: meetingController.text,
                                    status: true,
                                    type: true,
                                    distance: double.parse(
                                      distanceController.text,
                                    ),
                                  ),
                                );
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
                                            ? AppStrings.textErrorImageCover
                                            : dateController.text.isEmpty
                                                ? AppStrings.enterStartDate
                                                : pathnameController
                                                        .text.isEmpty
                                                    ? AppStrings.nameRuta
                                                    : meetingController
                                                            .text.isEmpty
                                                        ? AppStrings
                                                            .meetingPoint
                                                        : meetingController.text
                                                                    .length <
                                                                10
                                                            ? AppStrings
                                                                .meetingPointShort
                                                            : distanceController
                                                                    .text
                                                                    .isEmpty
                                                                ? AppStrings
                                                                    .distanceRoute
                                                                : rating.toInt() ==
                                                                        0.0
                                                                    ? AppStrings
                                                                        .difficultyRoute
                                                                    : descriptionController
                                                                            .text
                                                                            .isEmpty
                                                                        ? AppStrings
                                                                            .descriptionRodada
                                                                        : descriptionController.text.length <
                                                                                20
                                                                            ? AppStrings.descriptionRodadashort
                                                                            : AppStrings.textErrorCheck,
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
                                                ),
                                              ),
                                              borderRadius:
                                                  new BorderRadius.all(
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
                              setState(() {
                                getImageFromGallery();
                              });
                            },
                          ),
                        ),
                        Positioned(
                          bottom: size.height * 0.76,
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
              height: 20,
            )
          ],
        ),
      ),
    );
  }

  void _showDialog() {
    // flutter defined function
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(AppStrings.createRodada),
          content: Text(AppStrings.createRodadaSuccess),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              child: Text(AppStrings.close),
              onPressed: () {
                Navigator.of(context)
                    .pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => MyHome(),
                        ),
                        (Route<dynamic> route) => false)
                    .then(
                      (value) => setState(() => {}),
                    );
                // Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showDialog2(String response) {
    // flutter defined function
    Future.delayed(
      Duration(seconds: 2),
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
              AppStrings.dateFuture,
              style: Styles.advertisingTitle,
            ),
          ),
        );
      },
    );
  }

  void _showDialog4() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(50.0),
            ),
          ),
          title: Text(AppStrings.errorText),
          content: Text(AppStrings.textErrorImageCover),
          actions: <Widget>[
            FlatButton(
              child: Text(AppStrings.ok),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void complete(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return WillPopScope(
          onWillPop: () async => false,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              child: AlertDialog(
                backgroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(
                      10.0,
                    ),
                  ),
                ),
                content: new Text(
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
                            builder: (BuildContext context) =>
                                ViewEditProfile(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void complete2(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return WillPopScope(
          onWillPop: () async => false,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              child: AlertDialog(
                backgroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0))),
                content: new Text(
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
                      onPressed: () async {
                        Navigator.push(
                          context,
                          new MaterialPageRoute(
                            builder: (BuildContext context) =>
                                EditGroups(_group),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _createRoad(Road road) async {
    try {
      var uriResponse = await http.post(
        Uri.parse(AppStrings.urlBiuxRodadas),
        body: jsonEncode(
          road.toJson(),
        ),
        headers: {
          AppStrings.ContentTypeText: AppStrings.applicationJsonText,
        },
      );
      if (uriResponse.statusCode == 200) {
        final dataI = json.decode(uriResponse.body);
        String id = dataI[AppStrings.idText];
        Future.delayed(
          Duration(seconds: 2),
          () {
            Analitycs.createRoad(
              user.userName!,
              user.id!,
              pathnameController.text,
              double.parse(distanceController.text),
              rating.toInt(),
              _group.name!,
              _group.city!.name!,
              meetingController.text,
            );
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
                  AppStrings.createRodadaSuccess2,
                  style: Styles.advertisingTitle,
                ),
              ),
            );
          },
        );
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
                  (value) => setState(
                    () => {},
                  ),
                );
          },
        );
        await RoadsRepository().uploadProfileCoverRoad(
          id,
          _image,
        );
        return;
      } else {
        setState(
          () {
            loading = false;
          },
        );
        return _showDialog2(AppStrings.dateFuture);
      }
    } catch (e) {}
  }
}
