import 'dart:convert';
import 'dart:io';
import 'package:biux/config/colors.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/data/local_storage/localstorage.dart';
import 'package:biux/data/models/group.dart';
import 'package:biux/data/models/road.dart';
import 'package:biux/data/models/user.dart';
import 'package:biux/data/repositories/roads/roads_repository.dart';
import 'package:biux/ui/screens/home.dart';
import 'package:biux/ui/widgets/loading_widget.dart';
import 'package:biux/ui/widgets/selectable_widget.dart';
import 'package:biux/ui/widgets/textField_widget.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class EditRoad extends StatefulWidget {
  Road road;
  var dates;

  EditRoad(this.road, this.dates);
  _EditRoadState createState() => _EditRoadState();
}

// Declare this variable
int selectedRadio = 0;
var a = AppStrings.numbers;
var ab = json.decode(a);

class _EditRoadState extends State<EditRoad> {
  final formKey = GlobalKey<FormState>();
  late Group _group;
  late String _name;
  late String _description;
  late String _meeting;
  late String _facebook;
  late String _route;
  late double _routeLevel;
  late double _distance;
  String _date = AppStrings.selectDateText;
  late DateTime date;
  late TimeOfDay time;
  late BiuxUser _user;
  late String userId;
  bool loading = false;
  List<bool> isSelected = [false, true, false, true];
  FocusNode focusNodeButton1 = FocusNode();
  FocusNode focusNodeButton2 = FocusNode();
  FocusNode focusNodeButton3 = FocusNode();
  FocusNode focusNodeButton4 = FocusNode();
  late List<FocusNode> focusToggle;
  var response;
  setSelectedRadio(int val) {
    setState(() {
      selectedRadio = val;
    });
  }

  List<FocusNode> _focusNodes = [
    FocusNode(),
    FocusNode(),
    FocusNode(),
  ];

  @override
  void initState() {
    super.initState();
    getUserProfile();
    focusToggle = [focusNodeButton1, focusNodeButton2, focusNodeButton3];
    dateController.text =
        widget.road.dateTime.replaceAll(AppStrings.amText, AppStrings.idInitialized).replaceAll(AppStrings.pmText, AppStrings.idInitialized);
    pathnameController.text = widget.road.name;
    meetingController.text = widget.road.pointmeeting;
    rating = widget.road.routeLevel.floorToDouble();
    distanceController.text = widget.road.distance.toString();
    descriptionController.text = widget.road.description.toString();
  }

  getUserProfile() async {
    String? id = await LocalStorage().getGroupId();
    userId = id!;
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
  final facebookController = TextEditingController();
  final routeController = TextEditingController();
  final cityController = TextEditingController();
  final dateController = TextEditingController();
  final urbanController = TextEditingController();
  final downhillController = TextEditingController();
  final distanceController = TextEditingController();
  final format = DateFormat(AppStrings.dateFormat4);

  var _image;
  late SelectableWidget _selectableWidget;

  final _formKey = GlobalKey<FormState>();
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
      return AppStrings.numberinvalid(value: value);
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
                  _image != null
                      ? Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: FileImage(_image),
                              fit: BoxFit.cover,
                            ),
                          ),
                          height: 150,
                          width: 400,
                        )
                      : Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(
                                widget.road.image == null
                                    ? AppStrings.urlBiuxApp
                                    : widget.road.image,
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
                        margin: EdgeInsets.only(
                          top: 20,
                          left: 10,
                        ),
                        child: Text(
                          AppStrings.editRodada,
                          textAlign: TextAlign.center,
                          style: Styles.wrapDrawerWhite,
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
                                          child: SizedBox()

                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(top: 10),
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
                                            SizedBox(
                                              width: 100,
                                              height: 50,
                                              child: TextFormField(
                                                keyboardType:
                                                    TextInputType.number,
                                                inputFormatters: <
                                                    TextInputFormatter>[
                                                  FilteringTextInputFormatter
                                                      .digitsOnly
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
                                                      color: AppColors.grey,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(45),
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
                                                    EdgeInsets.only(top: 10),
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
                                                    Styles.valueLabel,
                                                valueLabelRadius: 10,
                                                maxValue: 5,
                                                starSpacing: 2,
                                                maxValueVisibility: true,
                                                valueLabelVisibility: true,
                                                animationDuration: Duration(
                                                  milliseconds: 1000,
                                                ),
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
                                              new SizedBox(
                                                width: size.width * 0.84,
                                                height: 120,
                                                child: new TextFormField(
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
                                                    hintText:
                                                        AppStrings.descriptionRodada,
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
                            setState(() {
                              loading = true;
                            });
                            if (pathnameController.text.isNotEmpty &&
                                descriptionController.text.isNotEmpty &&
                                meetingController.text.isNotEmpty &&
                                distanceController.text.isNotEmpty) {
                              _distance = double.parse(distanceController.text);
                              _date = dateController.text;
                              var road = Road(
                                id: widget.road.id,
                                dateTime: _date,
                                name: pathnameController.text,
                                cityId: widget.road.cityId,
                                routeLevel: rating.toInt(),
                                modality: [AppStrings.urbanoText.toUpperCase(), AppStrings.rutaText.toUpperCase()],
                                description: descriptionController.text,
                                pointmeeting: meetingController.text,
                                status: true,
                                type: true,
                                distance: _distance,
                                groupId: widget.road.groupId,
                                numberParticipants:
                                    widget.road.numberParticipants,
                                    group: Group()
                              );
                              response = await RoadsRepository().updateRoad(
                                road,
                              );
                              await RoadsRepository().uploadProfileCoverRoad(
                                widget.road.id,
                                _image,
                              );
                              _showDialog();
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
                                              : pathnameController.text.isEmpty
                                                  ? AppStrings.nameRuta
                                                  : meetingController
                                                          .text.isEmpty
                                                      ? AppStrings.meetingPoint
                                                      : meetingController
                                                                  .text.length <
                                                              10
                                                          ? AppStrings.meetingPointShort
                                                          : distanceController
                                                                  .text.isEmpty
                                                              ? AppStrings.distanceRoute
                                                              : rating.toInt() ==
                                                                      0.0
                                                                  ? AppStrings.difficultyRoute
                                                                  : descriptionController
                                                                          .text
                                                                          .isEmpty
                                                                      ? AppStrings.descriptionRodada
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
                          },
                        ),
                        Align(
                          alignment: Alignment(
                            0.0,
                            3.8,
                          ),
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
                                  height: 110,
                                  width: 110,
                                  child: _image != null
                                      ? InkWell(
                                          child: Container(
                                            alignment: (Alignment(-1.0, 2.5)),
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                fit: BoxFit.cover,
                                                image: FileImage(
                                                  _image,
                                                ),
                                              ),
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
                                        )
                                      : InkWell(
                                          child: new Container(
                                            alignment: (Alignment(-1.0, 2.5)),
                                            decoration: new BoxDecoration(
                                              image: DecorationImage(
                                                fit: BoxFit.cover,
                                                image: NetworkImage(
                                                  widget.road.image == null
                                                      ? AppStrings.urlBiuxApp
                                                      : widget.road.image,
                                                ),
                                              ),
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
          title: Text(AppStrings.updateRodada),
          content: Text(AppStrings.rodadaSuccessfullyUpdated),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(50.0),
                ),
              ),
              child: new Text(AppStrings.ok),
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

  void _showDialog2() {
    // flutter defined function
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(AppStrings.errorText),
          content: Text(AppStrings.warningSpace),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
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
}
