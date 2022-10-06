import 'dart:io';
import 'package:biux/config/colors.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/data/models/analitics.dart';
import 'package:biux/data/local_storage/localstorage.dart';
import 'package:biux/ui/screens/home.dart';
import 'package:diacritic/diacritic.dart';
import 'package:biux/data/models/group.dart';
import 'package:biux/data/models/user.dart';
import 'package:biux/data/models/city.dart';
import 'package:biux/data/repositories/users/user_repository.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:loading_overlay/loading_overlay.dart';

class UserNormal extends StatefulWidget {
  final String? nameF;
  final String? emailF;
  UserNormal({
    this.nameF,
    this.emailF,
  });
  @override
  _UserNormalState createState() => _UserNormalState();
}

class _UserNormalState extends State<UserNormal> {
  late String _names;
  late String _userName;
  late String _gender;
  late String base64Image;
  late String base64ImageProfileCover;
  late String _surnames;
  late String _city;
  late String _password;
  late String cellphone;
  late String _email;
  late String photo;
  late String _instagram;
  late String _facebook;
  // String _myAccountState = "MTB";
  // String _myAccountState1 = "RUTA";
  // String _myAccountState2 = "DOWNHILL";
  // String _myAccountState3 = "URBANO";
  late String _myActivity;
  late String _myActivity2;
  bool loading = false;
  bool loggedIn = false;
  List<bool> isSelected = [false, true, false, true];
  String _date = AppStrings.selectDateText;
  int size = 30;
  late int selectedRadio;
  final surnamesController = TextEditingController();
  final userNameController = TextEditingController();
  final nameController = TextEditingController();
  final cellphoneController = TextEditingController();
  final facebookController = TextEditingController();
  final instagramController = TextEditingController();
  final cityController = TextEditingController();
  final genderController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final birthDateController = TextEditingController();
  TextEditingController controller = TextEditingController();

  late Group _group;
  List<BiuxUser> listUsers = [];
  var username;
  var validate = 1;
  int offset = 1;
  var concatenate = StringBuffer();
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
      setState(
        () {
          _imageProfileCover = image;
          loading = false;
        },
      );
      if (image == null) {
        setState(
          () {
            loading = true;
          },
        );
      }
    }
  }

  late List<City> listCities;
  List<City> listFiltered = [];
  void initState() {
    _group = Group(id: '');
    super.initState();
    Future.delayed(
      Duration.zero,
      () async {
        getListUsers();
      },
    );

    Future.delayed(
      Duration.zero,
      () async {
        listCities = await UserRepository().getCities();
        listFiltered = await UserRepository().getCities();

        await cityReady(listCities);
        setState(() {});
      },
    );
  }

  getListUsers() async {
    listUsers = await UserRepository().getUsernames();
    setState(
      () {
        // listadoUsuarios
        //     .sort((a, b) => a.numeroMiembros.compareTo(b.numeroMiembros));
      },
    );
  }

  onItemChanged(String value) {
    setState(
      () {
        listFiltered = listCities
            .where(
              (string) => string.name.toLowerCase().contains(
                    removeDiacritics(value).toLowerCase(),
                  ),
            )
            .toList();
      },
    );
  }

  List<DropdownMenuItem<String>> datasource = [];

  cityReady(List<City> listCities) async {
    for (var i = 0; i < listCities.length; i++) {
      datasource.add(
        DropdownMenuItem<String>(
          child: Text(listCities[i].name),
          value: listCities[i].id.toString(),
        ),
      );
    }
    setState(() {});
  }

  setSelectedRadio(int val) {
    setState(
      () {
        selectedRadio = val;
      },
    );
  }

  bool _isChecked = true;
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: loading,
      child: Form(
        key: _formKey,
        child: MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.darkDeepNavyBlue,
              title: Text(AppStrings.profileText),
            ),
            body: SafeArea(
              child: ListView(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(
                      top: 0,
                      left: 0,
                    ),
                    height: 150,
                    child: Stack(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(top: 30),
                          alignment: Alignment.topCenter,
                          child: Text(
                            AppStrings.completeYourProfile,
                            textAlign: TextAlign.center,
                            style: Styles.stackContainer,
                          ),
                          height: 20,
                        ),
                        Align(
                          alignment: Alignment(0.0, 3.8),
                          child: GestureDetector(
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.black,
                              ),
                              height: 120,
                              width: 120,
                              child: _image == null
                                  ? Stack(
                                      children: <Widget>[
                                        GestureDetector(
                                          child: Center(
                                            child: Icon(
                                              Icons.camera_alt,
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
                                                    : _image,
                                              )),
                                          borderRadius: new BorderRadius.all(
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
                            //                       Align(
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
                  Container(
                    height: 10,
                  ),
                  Container(
                    height: 50,
                  ),
                  Column(
                    children: <Widget>[],
                  ),
                  GestureDetector(
                    child: Align(
                      alignment: Alignment(
                        0.0,
                        3.5,
                      ),
                      child: GestureDetector(
                        child: Container(
                          height: 25,
                          width: 200,
                          padding: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: AppColors.darkDeepNavyBlue.withOpacity(0.5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Icon(Icons.camera_alt, size: 20),
                              Text(AppStrings.updateImageProfile),
                            ],
                          ),
                        ),
                        onTap: getImageFromGallery,
                      ),
                    ),
                    onTap: getImageFromGallery,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 20.0,
                      bottom: 20,
                    ),
                    child: Container(
                      height: 180,
                      child: Stack(
                        children: [
                          _imageProfileCover == null
                              ? GestureDetector(
                                  child: Container(
                                    color: AppColors.white,
                                  ),
                                  onTap: () {
                                    setState(
                                      () {
                                        getImageProfileCover();
                                      },
                                    );
                                  })
                              : Container(
                                  child: Image.file(
                                    _imageProfileCover.path != null
                                        ? _imageProfileCover
                                        : _image,
                                    fit: BoxFit.cover,
                                    height: 200,
                                    width: 500,
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Align(
                      alignment: Alignment(0, 1),
                      child: GestureDetector(
                        child: Container(
                          height: 25,
                          width: 200,
                          padding: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: AppColors.darkDeepNavyBlue.withOpacity(0.5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Icon(
                                Icons.camera_alt,
                                size: 20,
                              ),
                              Text(AppStrings.updateCover),
                            ],
                          ),
                        ),
                        onTap: getImageProfileCover,
                      ),
                    ),
                  ),
                  Container(
                    child: Text(
                      "      ${AppStrings.namesText}",
                      style: Styles.indicatePerson,
                    ),
                    height: 22,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: 340,
                        child: TextFormField(
                          textInputAction: TextInputAction.next,
                          controller: nameController
                            ..text = (widget.nameF != null
                                ? widget.nameF
                                : nameController.text)!,
                          decoration: InputDecoration(
                            //de aqui
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: AppColors.transparent),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            //hasta aqui
                            filled: true,
                            contentPadding: EdgeInsets.fromLTRB(
                              10.0,
                              15.0,
                              20.0,
                              15.0,
                            ),
                            hintText: AppStrings.namesText,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(4),
                              ),
                            ),
                            hintStyle: Styles.rowHintStyle,
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return AppStrings.errorEnterYourName;
                            }
                            return null;
                          },
                          onSaved: (String? value) {
                            _names = value!;
                          },
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 10,
                  ),
                  Container(
                    child: Text(
                      "      ${AppStrings.surnamesText}",
                      style: Styles.indicatePerson,
                    ),
                    height: 22,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: 340,
                        child: TextFormField(
                          textInputAction: TextInputAction.next,
                          controller: surnamesController,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: AppColors.transparent,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            filled: true,
                            contentPadding: EdgeInsets.fromLTRB(
                              10.0,
                              15.0,
                              20.0,
                              15.0,
                            ),
                            hintText: AppStrings.surnamesText,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(4),
                              ),
                            ),
                            hintStyle: Styles.sizedBoxHint,
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return AppStrings.errorEnterYourLastname;
                            }
                            return null;
                          },
                          onSaved: (String? value) {
                            _surnames = value!;
                          },
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 10,
                  ),
                  Container(
                    child: Text(
                      "      ${AppStrings.nameUserText}",
                      style: Styles.indicatePerson,
                    ),
                    height: 22,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: 340,
                        child: TextFormField(
                          autovalidateMode: AutovalidateMode.always,
                          textInputAction: TextInputAction.next,
                          controller: surnamesController,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: AppColors.transparent,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            filled: true,
                            contentPadding: EdgeInsets.fromLTRB(
                              10.0,
                              15.0,
                              20.0,
                              15.0,
                            ),
                            hintText: AppStrings.nameUserText,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(4),
                              ),
                            ),
                            hintStyle: Styles.sizedBoxHint,
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return AppStrings.warningUserName;
                            } else if (value.contains(" ")) {
                              return AppStrings.warningUserName2;
                              // final newValue = value.replaceAll(" ", "_");
                              // value = newValue.toLowerCase();
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _userName = value!;
                          },
                        ),
                      ),
                    ],
                  ),
                  Container(
                    child: Text(
                      "      ${AppStrings.gmail}",
                      style: Styles.indicatePerson,
                    ),
                    height: 22,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: 340,
                        child: TextFormField(
                          autovalidateMode: AutovalidateMode.always,
                          textInputAction: TextInputAction.next,
                          controller: emailController
                            ..text = (widget.emailF != null
                                ? widget.emailF
                                : emailController.text)!,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: AppColors.transparent),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            filled: true,
                            contentPadding: EdgeInsets.fromLTRB(
                              10.0,
                              15.0,
                              20.0,
                              15.0,
                            ),
                            hintText: AppStrings.correoText,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(4),
                              ),
                            ),
                            hintStyle: Styles.sizedBoxHint,
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return AppStrings.warningGmail;
                            } else if (value.contains(" ")) {
                              return AppStrings.warningGmail2;
                              // final newValue = value.replaceAll(" ", "_");
                              // value = newValue.toLowerCase();
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _email = value!;
                          },
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 10,
                  ),
                  Container(
                    child: Text(
                      "      ${AppStrings.phoneText}",
                      style: Styles.indicatePerson,
                    ),
                    height: 22,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: 340,
                        child: TextFormField(
                          controller: cellphoneController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: AppColors.transparent,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            contentPadding: EdgeInsets.fromLTRB(
                              10.0,
                              15.0,
                              20.0,
                              15.0,
                            ),
                            filled: true,
                            hintText: AppStrings.enterPhone,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(4),
                              ),
                            ),
                            hintStyle: Styles.textStyle,
                          ),
                          maxLength: 10,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return AppStrings.enterPhone;
                            }
                            return null;
                          },
                          onSaved: (String? value) {
                            cellphone = value!;
                          },
                        ),
                      ),
                    ],
                  ),
                  Container(
                    child: Text(
                      "      ${AppStrings.cityText}",
                      style: Styles.indicatePerson,
                    ),
                    height: 22,
                  ),
                  Column(
                    children: [
                      // Container(
                      //   //  height: 52,
                      //   width: 340,
                      //   decoration: ShapeDecoration(
                      //     color: AppColors.greyishNavyBlue3,
                      //     shape: RoundedRectangleBorder(
                      //       side: BorderSide(
                      //           width: 0.0,
                      //           style: BorderStyle.solid,
                      //           color: AppColors.transparent),
                      //       borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      //     ),
                      //   ),

                      //   child: Container(
                      //     padding: EdgeInsets.only(left: 10),
                      //     child: DropdownButtonFormField(
                      //       decoration: InputDecoration(
                      //         hintText: '  Seleccionar ciudad',
                      //         filled: false,
                      //       ),
                      //       value: _myActivity,
                      //       onSaved: (value) {
                      //         setState(() {
                      //           _myActivity = value;
                      //         });
                      //       },
                      //       onChanged: (value) {
                      //         setState(() {
                      //           _myActivity = value;
                      //         });
                      //       },
                      //       items: datasource,
                      //     ),
                      //   ),
                      // ),

                      Padding(
                        padding: const EdgeInsets.only(
                          left: 25,
                          right: 20,
                        ),
                        child: TextField(
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: AppColors.transparent,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            contentPadding: EdgeInsets.fromLTRB(
                              20.0,
                              15.0,
                              20.0,
                              15.0,
                            ),
                            filled: true,
                            hintText: removeDiacritics(""),
                            labelText: removeDiacritics(AppStrings.searchCity),
                          ),
                          onChanged: onItemChanged,
                          controller: cityController,
                        ),
                      ),
                      SizedBox(
                        height: 16.0,
                      ),
                    ],
                  ),
                  Container(
                    height: 10,
                  ),
                  Container(
                    height: 10,
                  ),
                  Container(
                    height: 10,
                  ),
                  Container(
                    child: Text(
                      "      ${AppStrings.birthDate}",
                      style: Styles.indicatePerson,
                    ),
                    height: 22,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: 340,
                        child: RaisedButton(
                          color: AppColors.greyishNavyBlue2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            side: BorderSide(
                              width: 1.0,
                              style: BorderStyle.solid,
                              color: AppColors.white,
                            ),
                          ),
                          elevation: 9.0,
                          onPressed: () {
                            /// Todo(jomazao): Select replacement for flutter date picker library
                            /*DatePicker.showDatePicker(
                              context,
                              locale: LocaleType.es,
                              theme: DatePickerTheme(
                                containerHeight: 210.0,
                              ),
                              showTitleActions: true,
                              minTime: DateTime(1900, 1, 1),
                              maxTime: DateTime(2010, 12, 31),
                              onConfirm: (date) {
                                _date = AppStrings.date(year: date.year.toString(), month: date.month.toString(), day: date.day.toString());
                                setState(() {});
                              },
                              currentTime: DateTime.now(),
                            );*/
                          },
                          child: Container(
                            alignment: Alignment.center,
                            height: 50.0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            " $_date",
                                            style: Styles.rowContainerWhite,
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 10,
                  ),
                  Container(
                    height: 10,
                  ),
                  Container(
                    child: Text(
                      "      ${AppStrings.passwordText}",
                      style: Styles.indicatePerson,
                    ),
                    height: 22,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: 340,
                        child: TextFormField(
                          controller: passwordController,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: AppColors.transparent,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            filled: true,
                            contentPadding: EdgeInsets.fromLTRB(
                              10.0,
                              15.0,
                              20.0,
                              15.0,
                            ),
                            hintText: AppStrings.passwordText,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(4),
                              ),
                            ),
                            hintStyle: Styles.sizedBoxHint,
                          ),
                          validator: (val) {
                            if (val!.isEmpty) return AppStrings.warningPassword;
                            return null;
                          },
                          obscureText: true,
                          onSaved: (String? value) {
                            _surnames = value!;
                          },
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 10,
                  ),
                  Container(
                    child: Text(
                      "     ${AppStrings.repeatPassword}",
                      style: Styles.indicatePerson,
                    ),
                    height: 22,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: 340,
                        child: TextFormField(
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(
                              RegExp(AppStrings.symbols),
                            ),
                          ],
                          controller: confirmPasswordController,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: AppColors.transparent,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            filled: true,
                            contentPadding: EdgeInsets.fromLTRB(
                              10.0,
                              15.0,
                              20.0,
                              15.0,
                            ),
                            hintText: AppStrings.repeatPassword,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(4),
                              ),
                            ),
                            hintStyle: Styles.sizedBoxHint,
                          ),
                          validator: (val) {
                            if (val!.isEmpty) return AppStrings.emptyText;
                            if (val != passwordController.text)
                              return AppStrings.warningPassword2;
                            return null;
                          },
                          obscureText: true,
                          onSaved: (String? value) {
                            _surnames = value!;
                          },
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 10,
                  ),
                  Container(
                    child: Text(
                      "       ${AppStrings.warningPassword3}",
                      style: Styles.containerPassword,
                    ),
                    height: 15,
                  ),
                  Row(
                    children: <Widget>[
                      GestureDetector(
                        child: Container(
                          child: Text(
                            "                 ${AppStrings.termsConditions}"
                                .toUpperCase(),
                            style: Styles.rowGestureDetector,
                          ),
                        ),
                        onTap: () {
                          //_showDialog();
                        },
                      ),
                      SizedBox(
                        height: 40.0,
                        width: 40,
                        child: Checkbox(
                          value: _isChecked,
                          onChanged: (val) {
                            setState(
                              () {
                                _isChecked = val!;
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: 120,
                        child: RaisedButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            side: BorderSide(
                                width: 3, color: AppColors.lightNavyBlue),
                          ),
                          color: AppColors.greyishNavyBlue2,
                          child: Text(
                            AppStrings.save,
                            style: Styles.sizedBoxWhite,
                          ),
                          onPressed: () {
                            if (_imageProfileCover == null && _image == null) {
                              _showDialog4();
                            } else {
                              if (_formKey.currentState!.validate()) {
                                _userName =
                                    userNameController.text.toLowerCase();
                                for (var i = 0; i < listUsers.length; i++) {
                                  username =
                                      listUsers[i].userName.contains(_userName);
                                  if (username) {
                                    validate = 2;
                                  }
                                }
                                _names = nameController.text;
                                _surnames = surnamesController.text;
                                _gender = genderController.text;
                                _instagram = instagramController.text;
                                _city = cityController.text;
                                cellphone = cellphoneController.text;
                                _password = passwordController.text;
                                _email = emailController.text;
                                LocalStorage().saveKey(_password);
                                validate != 2
                                    ? createUser(
                                        BiuxUser(
                                          userName: _userName,
                                          modality: [
                                            AppStrings.urbanoText.toLowerCase(),
                                            AppStrings.rutaText.toLowerCase()
                                          ],
                                          // modalidadToList(isSelected),
                                          // portada: base64ImagePortada,
                                          dateBirth: _date,
                                          names: _names,
                                          cityId: listFiltered.first.id,
                                          surnames: _surnames,
                                          premium: false,
                                          email: _email,
                                          password: _password,
                                          gender: _gender,
                                          facebook: _facebook,
                                          instagram: _instagram,
                                        ),
                                      )
                                    : _showDialog3();
                              } else {
                                return _showDialog2(
                                  AppStrings.warningSpace,
                                );
                              }
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
      ),
    );
  }

  // List modalidadToList(List selecciones) {
  //   List modalidad = new List();

  //   if (selecciones[0]) {
  //     modalidad.add("Urbano");
  //   }
  //   if (selecciones[1]) {
  //     modalidad.add("dowhill");
  //   }
  //   if (selecciones[2]) {
  //     modalidad.add("MTB");
  //   }
  //   if (selecciones[3]) {
  //     modalidad.add("Ruta");
  //   }
  //   return modalidad;
  // }

  void _showDialog() {
    // flutter defined function
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(40.0),
            ),
          ),
          title: new Text(AppStrings.userCreated),
          content: new Text(AppStrings.userCreatedSuccess),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              child: Text(AppStrings.ok),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => MyHome(),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showDialog2(String response) {
    // flutter defined function
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(50.0),
            ),
          ),
          title: Text(AppStrings.errorText),
          content: Text(response),
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

  void _showDialog3() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(
                50.0,
              ),
            ),
          ),
          title: Text(AppStrings.errorText),
          content: Text(AppStrings.existingUser),
          actions: <Widget>[
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

  void _showDialog4() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(
                50.0,
              ),
            ),
          ),
          title: Text(AppStrings.errorText),
          content: Text(AppStrings.warningprofilePictureCover),
          actions: <Widget>[
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

  void createUser(BiuxUser user) async {
    try {
      var uriResponse = await http.post(
        Uri.parse(AppStrings.urlBiuxUsuarios),
        body: jsonEncode(
          user.toJson(),
        ),
        headers: {
          AppStrings.ContentTypeText: AppStrings.applicationJsonText,
        },
      );
      if (uriResponse.statusCode == 200) {
        final data = json.decode(uriResponse.body);
        String user = data[AppStrings.userText];
        final dataC = json.decode(uriResponse.body);
        String key = dataC[AppStrings.keyText];
        final dataI = json.decode(uriResponse.body);
        String id = dataI[AppStrings.idText];
        String newIdd = id.toString();
        LocalStorage().saveUser(user);
        LocalStorage().saveUserId(newIdd);
        // await setLoginToken(token);
        var userName = await LocalStorage().getUser();
        var password = await LocalStorage().getKey();
        // id = await LocalStorage().obtenerUsuarioId();
        Analitycs.sendSignUp(newIdd);
        await UserRepository().login(userName!, password!);
        await UserRepository().uploadProfileCover(
          id,
          _image,
        );
        _showDialog();
        return;
      } else {
        return _showDialog2(uriResponse.body);
      }
    } catch (e) {}
  }
}
