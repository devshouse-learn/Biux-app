import 'dart:io';
import 'package:biux/config/colors.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/data/models/trademark_bike.dart';
import 'package:biux/data/models/type_bike.dart';
import 'package:biux/data/models/user.dart';
import 'package:biux/data/models/bike.dart';
import 'package:biux/data/repositories/trademarks_bikes/trademark_bike_repository.dart';
import 'package:biux/data/repositories/types_bikes/types_bike_repository.dart';
import 'package:biux/data/repositories/users/user_repository.dart';
import 'package:biux/data/local_storage/localstorage.dart';
import 'package:biux/ui/widgets/dropdowm_widget.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../data/repositories/bikes/bike_firebase_repository.dart';

class BikeScreen extends StatefulWidget {
  @override
  _BikeScreenState createState() => _BikeScreenState();
}

class _BikeScreenState extends State<BikeScreen> {
  late List<TrademarkBike> listBike;
  void initState() {
    getDatesBike();
    getDatesTypeBike();
    getUserProfile();
  }

  getDatesBike() async {
    Future.delayed(
      Duration.zero,
      () async {
        Bike bike = await BikeFirebaseRepository().getBikeRoad('1');
        listBike = await TrademarkBikeRepository().getTrademarksBike();
        await trademarkBike(listBike);
        setState(() {});
      },
    );
  }

  List<DropdownMenuItem<String>> menuItems = [
    DropdownMenuItem(child: Text("Specialized"), value: "Specialized"),
    DropdownMenuItem(child: Text("Cube bikes"), value: "Cube bikes"),
    DropdownMenuItem(child: Text("Cervelo"), value: "Cervelo"),
    DropdownMenuItem(child: Text("BMC bikes"), value: "BMC bikes"),
  ];

  List<DropdownMenuItem<String>> menuItems2 = [
    DropdownMenuItem(child: Text("BMX"), value: "BMX"),
    DropdownMenuItem(child: Text("urbanas"), value: "urbanas"),
    DropdownMenuItem(child: Text("montaña"), value: "montaña"),
    DropdownMenuItem(child: Text("híbridas"), value: "híbridas"),
  ];

  List<DropdownMenuItem<String>> datasource = [];

  trademarkBike(List<TrademarkBike> listBike) async {
    for (var i = 0; i < listBike.length; i++) {
      datasource.add(
        DropdownMenuItem<String>(
          child: Text(listBike[i].trademark!),
          value: listBike[i].id.toString(),
        ),
      );
    }
    setState(() {});
  }

  late List<TypeBike> listTypeBike;

  getDatesTypeBike() async {
    Future.delayed(
      Duration.zero,
      () async {
        listTypeBike = await TypesBikeRepository().getTypesBike();
        await typeBike(listTypeBike);
        setState(() {});
      },
    );
  }

  List<DropdownMenuItem<String>> datasource2 = [];

  typeBike(List<TypeBike> listTypeBike) async {
    for (var i = 0; i < listTypeBike.length; i++) {
      datasource2.add(
        new DropdownMenuItem<String>(
          child: new Text(listTypeBike[i].type!),
          value: listTypeBike[i].id.toString(),
        ),
      );
    }
    setState(() {});
  }

  getUserProfile() async {
    String? username = await LocalStorage().getUser();
    user = await UserRepository().getPerson(username!);
    setState(
      () {
        isLoggedIn = true;
      },
    );
  }

  late BiuxUser user;
  bool isLoggedIn = false;
  late int id;
  String? _measure;
  late Bike bike;
  String? _serial;
  String? _description;
  String? _storeBuy;
  String? _dateBuy;
  String? _tradeMark;
  String? _type;
  late String _myActivity3;
  String? _numberInvoice;
  late TimeOfDay time;
  late DateTime date;
  String _date = AppStrings.selectDateText;
  final dateController = TextEditingController();
  final serialController = TextEditingController();
  final descriptionController = TextEditingController();
  final storeBuyController = TextEditingController();
  final dateBuyController = TextEditingController();
  final numberInvoiceController = TextEditingController();
  final format = DateFormat(AppStrings.dateFormat2);
  // _seleccionarFoto() async {
  //   _procesarImagen(ImageSource.gallery);
  // }
  // _procesarImagen(ImageSource origen) async {
  //   var image = await ImagePicker.pickImage(source: origen);
  //   if (image != null) {}
  //   setState(() {});
  // }

  var _image;
  var _image2;
  var _image3;
  var _image4;
  var _image5;
  var _image6;
  Future getImage(flag) async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile pickedFile;
    pickedFile = (await imagePicker.getImage(
        source: ImageSource.gallery, imageQuality: 20))!;
    switch (flag) {
      case 1:
        File image = File(pickedFile.path);
        setState(
          () {
            _image = image;
          },
        );
        break;
      case 2:
        File image = File(pickedFile.path);
        setState(
          () {
            _image2 = image;
          },
        );
        break;
      case 3:
        File image = File(pickedFile.path);
        setState(
          () {
            _image3 = image;
          },
        );
        break;
      case 4:
        File image = File(pickedFile.path);
        setState(
          () {
            _image4 = image;
          },
        );
        break;
      case 5:
        File image = File(pickedFile.path);
        setState(
          () {
            _image5 = image;
          },
        );
        break;
      case 6:
        File image = File(pickedFile.path);
        setState(
          () {
            _image6 = image;
          },
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.greyishNavyBlue,
          title: Text(AppStrings.dataMyBike),
        ),
        body: Form(
          child: Container(
            child: ListView(
              children: <Widget>[
                Container(
                  height: 10,
                ),
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    AppStrings.onTheBike,
                    style: Styles.containerWhite,
                  ),
                  height: 22,
                ),
                Container(
                  height: 10,
                ),
                Container(
                  child: Text(
                    AppStrings.bikeScreenBrand,
                    style: Styles.indicatePerson,
                  ),
                  height: 20,
                ),
                Container(
                  height: 10,
                ),
                Column(
                  children: [
                    Container(
                      //  height: 52,
                      width: 340,
                      decoration: ShapeDecoration(
                        color: AppColors.greyishNavyBlue3,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 0.0,
                            style: BorderStyle.solid,
                            color: AppColors.transparent,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(
                              20.0,
                            ),
                          ),
                        ),
                      ),
                      child: Container(
                        padding: EdgeInsets.only(left: 10),
                        child: DropdownButtonFormField(
                          decoration: InputDecoration(
                            hintText: AppStrings.bikeScreenSelect,
                            filled: false,
                          ),
                          value: _tradeMark,
                          onSaved: (String? value) {
                            setState(
                              () {
                                _tradeMark = value!;
                              },
                            );
                          },
                          onChanged: (String? value) {
                            setState(
                              () {
                                _tradeMark = value!;
                              },
                            );
                          },
                          items: menuItems,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 10,
                ),
                Container(
                  child: Text(
                    AppStrings.bikeSreenSerial,
                    style: Styles.indicatePerson,
                  ),
                  height: 22,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 340,
                      child: TextFormField(
                        controller: serialController,
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
                          hintText: AppStrings.serial2,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(4),
                            ),
                          ),
                          hintStyle: Styles.sizedBoxHint,
                        ),
                        onSaved: (String? value) {
                          _serial = value!;
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
                    AppStrings.bikeScreensize_measure,
                    style: Styles.indicatePerson,
                  ),
                  height: 22,
                ),
                Column(
                  children: <Widget>[
                    Container(
                      //  height: 52,
                      width: 340,
                      decoration: ShapeDecoration(
                        color: AppColors.greyishNavyBlue3,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                              width: 0.0,
                              style: BorderStyle.solid,
                              color: AppColors.transparent),
                          borderRadius: BorderRadius.all(
                            Radius.circular(20.0),
                          ),
                        ),
                      ),
                      child: DropDownFormField(
                        titleText: AppStrings.listMeasure,
                        hintText: (AppStrings.bikeScreenPleaseSelectOne),
                        filled: false,
                        value: _measure,
                        onChanged: (value) {
                          setState(
                            () {
                              _measure = value;
                            },
                          );
                        },
                        dataSource: [
                          {
                            AppStrings.displayText: "   ${AppStrings.s}",
                            AppStrings.valueText: AppStrings.s,
                          },
                          {
                            AppStrings.displayText: "   ${AppStrings.m}",
                            AppStrings.valueText: AppStrings.m,
                          },
                          {
                            AppStrings.displayText: "   ${AppStrings.l}",
                            AppStrings.valueText: AppStrings.l,
                          },
                          {
                            AppStrings.displayText: "   ${AppStrings.xl}",
                            AppStrings.valueText: AppStrings.xl,
                          },
                        ],
                        textField: AppStrings.displayText,
                        valueField: AppStrings.valueText,
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 10,
                ),
                Container(
                  child: Text(
                    AppStrings.bikeScreenBillNumber,
                    style: Styles.indicatePerson,
                  ),
                  height: 22,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 340,
                      child: TextFormField(
                        controller: numberInvoiceController,
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
                          hintText: AppStrings.billNumber,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(4),
                            ),
                          ),
                          hintStyle: Styles.sizedBoxHint,
                        ),
                        onSaved: (String? value) {
                          _numberInvoice = value!;
                        },
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 20,
                ),
                Container(
                  child: Text(
                    AppStrings.bikeScreenBikeType,
                    style: Styles.indicatePerson,
                  ),
                  height: 22,
                ),
                Column(
                  children: [
                    Container(
                      //  height: 52,
                      width: 340,
                      decoration: ShapeDecoration(
                        color: AppColors.greyishNavyBlue3,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 0.0,
                            style: BorderStyle.solid,
                            color: AppColors.transparent,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(20.0),
                          ),
                        ),
                      ),
                      child: Container(
                        padding: EdgeInsets.only(left: 10),
                        child: DropdownButtonFormField(
                          decoration: InputDecoration(
                            hintText: AppStrings.bikeScreenPleaseSelectOne,
                            filled: false,
                          ),
                          value: _type,
                          onSaved: (String? value) {
                            setState(
                              () {
                                _type = value!;
                              },
                            );
                          },
                          onChanged: (String? value) {
                            setState(
                              () {
                                _type = value!;
                              },
                            );
                          },
                          items: menuItems2,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 20,
                ),
                Container(
                  child: Text(
                    AppStrings.bikeScreenBikeDescription,
                    style: Styles.indicatePerson,
                  ),
                  height: 22,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: 340,
                      height: 90,
                      child: TextFormField(
                        controller: descriptionController,
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
                          hintText: AppStrings.bikeDescription,
                          hintStyle: Styles.hintStyle,
                        ),
                        maxLines: 5,
                        onSaved: (String? value) {
                          _description = value!;
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
                    AppStrings.bikeScreenWorkshopOrStore,
                    style: Styles.indicatePerson,
                  ),
                  height: 22,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 340,
                      child: TextFormField(
                        controller: storeBuyController,
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
                          hintText: AppStrings.storeText,
                          hintStyle: Styles.sizedBoxHint,
                        ),
                        onSaved: (String? value) {
                          _storeBuy = value!;
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
                    AppStrings.bikeScreenDatePurchase,
                    style: Styles.indicatePerson,
                  ),
                  height: 22,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                        width: 340,

                        /// Todo(jomazao): Find replacement for datetimefield widget
                        child:
                            SizedBox() /*DateTimeField(
                        controller: dateBuyController,
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
                          hintText: AppStrings.enterStartDate,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(4),
                            ),
                          ),
                          hintStyle: Styles.hintStyle,
                        ),
                        format: format,
                        onShowPicker: (
                          context,
                          currentData,
                        ) async {
                          date = (await showDatePicker(
                            locale: const Locale("es", "ES"),
                            context: context,
                            firstDate: DateTime(1900),
                            initialDate: currentData!,
                            lastDate: DateTime(2100),
                          ))!;
                          if (date != null) {
                            return date;
                          } else {
                            _date = currentData.toString();
                            return currentData;
                          }
                        },
                      ),*/
                        ),
                  ],
                ),
                Container(
                  height: 10,
                ),
                Container(
                  margin: EdgeInsets.only(top: 10, bottom: 10),
                  child: Text(
                    AppStrings.bikeScreenBikeCondition,
                    style: Styles.containerStatus,
                  ),
                  height: 22,
                ),
                Container(
                  child: Text(
                    AppStrings.bikeScreenAttachPhotos,
                    style: Styles.indicatePerson,
                  ),
                  height: 22,
                ),
                Container(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColors.gray.withOpacity(0.2),
                      ),
                      height: 80,
                      width: 80,
                      child: Stack(
                        children: <Widget>[
                          Stack(
                            children: <Widget>[
                              Center(
                                child: _image == null
                                    ? Stack(
                                        children: <Widget>[
                                          Container(
                                            alignment: Alignment.bottomRight,
                                            child: SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: GestureDetector(
                                                child: FloatingActionButton(
                                                  heroTag: 1,
                                                  child: Icon(
                                                    Icons.camera_alt,
                                                    size: 12,
                                                  ),
                                                  backgroundColor: AppColors
                                                      .gray
                                                      .withOpacity(0.5),
                                                  onPressed: () {
                                                    getImage(1);
                                                  },
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      )
                                    : Container(
                                        alignment: (Alignment(
                                          -1.0,
                                          2.5,
                                        )),
                                        height: 80,
                                        width: 80,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: FileImage(
                                              _image.path != null
                                                  ? _image
                                                  : _image,
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius: BorderRadius.all(
                                            const Radius.circular(10),
                                          ),
                                        ),
                                      ),
                              ),
                              Stack(
                                children: <Widget>[
                                  Container(
                                    alignment: Alignment.bottomRight,
                                    child: SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: GestureDetector(
                                        child: FloatingActionButton(
                                          heroTag: 7,
                                          child: Icon(
                                            Icons.camera_alt,
                                            size: 12,
                                          ),
                                          backgroundColor:
                                              AppColors.gray.withOpacity(0.5),
                                          onPressed: () {
                                            getImage(1);
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColors.gray.withOpacity(0.2),
                      ),
                      height: 80,
                      width: 80,
                      child: Stack(
                        children: <Widget>[
                          Stack(
                            children: <Widget>[
                              Center(
                                child: _image2 == null
                                    ? Stack(
                                        children: <Widget>[
                                          Container(
                                            alignment: Alignment.bottomRight,
                                            child: SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: GestureDetector(
                                                child: FloatingActionButton(
                                                  heroTag: 2,
                                                  child: Icon(
                                                    Icons.camera_alt,
                                                    size: 12,
                                                  ),
                                                  backgroundColor: AppColors
                                                      .gray
                                                      .withOpacity(0.5),
                                                  onPressed: () {
                                                    getImage(2);
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : new Container(
                                        alignment: (Alignment(
                                          -1.0,
                                          2.5,
                                        )),
                                        height: 80,
                                        width: 80,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: FileImage(
                                              _image2.path != null
                                                  ? _image2
                                                  : _image2,
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius: new BorderRadius.all(
                                            const Radius.circular(10),
                                          ),
                                        ),
                                      ),
                              ),
                              Stack(
                                children: <Widget>[
                                  Container(
                                    alignment: Alignment.bottomRight,
                                    child: SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: GestureDetector(
                                        child: FloatingActionButton(
                                          heroTag: 8,
                                          child: Icon(
                                            Icons.camera_alt,
                                            size: 12,
                                          ),
                                          backgroundColor:
                                              AppColors.gray.withOpacity(0.5),
                                          onPressed: () {
                                            getImage(2);
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColors.gray.withOpacity(0.2),
                      ),
                      height: 80,
                      width: 80,
                      child: Stack(
                        children: <Widget>[
                          Stack(
                            children: <Widget>[
                              Center(
                                child: _image3 == null
                                    ? new Stack(
                                        children: <Widget>[
                                          Container(
                                            alignment: Alignment.bottomRight,
                                            child: SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: GestureDetector(
                                                child: FloatingActionButton(
                                                  heroTag: 3,
                                                  child: Icon(
                                                    Icons.camera_alt,
                                                    size: 12,
                                                  ),
                                                  backgroundColor: AppColors
                                                      .gray
                                                      .withOpacity(0.5),
                                                  onPressed: () {
                                                    getImage(3);
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Container(
                                        alignment: (Alignment(
                                          -1.0,
                                          2.5,
                                        )),
                                        height: 80,
                                        width: 80,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: FileImage(
                                              _image3.path != null
                                                  ? _image3
                                                  : _image3,
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius: BorderRadius.all(
                                            const Radius.circular(10),
                                          ),
                                        ),
                                      ),
                              ),
                              Stack(
                                children: <Widget>[
                                  Container(
                                    alignment: Alignment.bottomRight,
                                    child: SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: GestureDetector(
                                        child: FloatingActionButton(
                                          heroTag: 9,
                                          child: Icon(
                                            Icons.camera_alt,
                                            size: 12,
                                          ),
                                          backgroundColor:
                                              AppColors.gray.withOpacity(0.5),
                                          onPressed: () {
                                            getImage(3);
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColors.gray.withOpacity(0.2),
                      ),
                      height: 80,
                      width: 80,
                      child: Stack(
                        children: <Widget>[
                          Stack(
                            children: <Widget>[
                              Center(
                                child: _image4 == null
                                    ? new Stack(
                                        children: <Widget>[
                                          Container(
                                            alignment: Alignment.bottomRight,
                                            child: SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: GestureDetector(
                                                child: FloatingActionButton(
                                                  heroTag: 4,
                                                  child: Icon(
                                                    Icons.camera_alt,
                                                    size: 12,
                                                  ),
                                                  backgroundColor: AppColors
                                                      .gray
                                                      .withOpacity(0.5),
                                                  onPressed: () {
                                                    getImage(4);
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Container(
                                        alignment: (Alignment(
                                          -1.0,
                                          2.5,
                                        )),
                                        height: 80,
                                        width: 80,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: FileImage(
                                              _image4.path != null
                                                  ? _image4
                                                  : _image4,
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius: new BorderRadius.all(
                                            const Radius.circular(10),
                                          ),
                                        ),
                                      ),
                              ),
                              Stack(
                                children: <Widget>[
                                  Container(
                                    alignment: Alignment.bottomRight,
                                    child: SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: GestureDetector(
                                        child: FloatingActionButton(
                                          heroTag: 10,
                                          child: Icon(
                                            Icons.camera_alt,
                                            size: 12,
                                          ),
                                          backgroundColor:
                                              AppColors.gray.withOpacity(0.5),
                                          onPressed: () {
                                            getImage(4);
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColors.gray.withOpacity(0.2),
                      ),
                      height: 80,
                      width: 80,
                      child: Stack(
                        children: <Widget>[
                          Stack(
                            children: <Widget>[
                              Center(
                                child: _image5 == null
                                    ? Stack(
                                        children: <Widget>[
                                          Container(
                                            alignment: Alignment.bottomRight,
                                            child: SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: GestureDetector(
                                                child: FloatingActionButton(
                                                  heroTag: 5,
                                                  child: Icon(
                                                    Icons.camera_alt,
                                                    size: 12,
                                                  ),
                                                  backgroundColor: AppColors
                                                      .gray
                                                      .withOpacity(0.5),
                                                  onPressed: () {
                                                    getImage(5);
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Container(
                                        alignment: (Alignment(
                                          -1.0,
                                          2.5,
                                        )),
                                        height: 80,
                                        width: 80,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: FileImage(
                                              _image5.path != null
                                                  ? _image5
                                                  : _image5,
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius: BorderRadius.all(
                                            const Radius.circular(10),
                                          ),
                                        ),
                                      ),
                              ),
                              Stack(
                                children: <Widget>[
                                  Container(
                                    alignment: Alignment.bottomRight,
                                    child: SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: GestureDetector(
                                        child: FloatingActionButton(
                                          heroTag: 11,
                                          child: Icon(
                                            Icons.camera_alt,
                                            size: 12,
                                          ),
                                          backgroundColor:
                                              AppColors.gray.withOpacity(0.5),
                                          onPressed: () {
                                            getImage(5);
                                          },
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColors.gray.withOpacity(0.2),
                      ),
                      height: 80,
                      width: 80,
                      child: Stack(
                        children: <Widget>[
                          Stack(
                            children: <Widget>[
                              Center(
                                child: _image6 == null
                                    ? Stack(
                                        children: <Widget>[
                                          Container(
                                            alignment: Alignment.bottomRight,
                                            child: SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: GestureDetector(
                                                child: FloatingActionButton(
                                                  heroTag: 6,
                                                  child: Icon(
                                                    Icons.camera_alt,
                                                    size: 12,
                                                  ),
                                                  backgroundColor: AppColors
                                                      .gray
                                                      .withOpacity(0.5),
                                                  onPressed: () {
                                                    getImage(6);
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Container(
                                        alignment: (Alignment(
                                          -1.0,
                                          2.5,
                                        )),
                                        height: 80,
                                        width: 80,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: FileImage(
                                              _image6.path != null
                                                  ? _image6
                                                  : _image6,
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius: BorderRadius.all(
                                            const Radius.circular(10),
                                          ),
                                        ),
                                      ),
                              ),
                              Stack(
                                children: <Widget>[
                                  Container(
                                    alignment: Alignment.bottomRight,
                                    child: SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: GestureDetector(
                                        child: FloatingActionButton(
                                          heroTag: 12,
                                          child: Icon(
                                            Icons.camera_alt,
                                            size: 12,
                                          ),
                                          backgroundColor:
                                              AppColors.gray.withOpacity(0.5),
                                          onPressed: () {
                                            getImage(6);
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: 120,
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(10.0),
                          side: BorderSide(
                            width: 3,
                            color: AppColors.greyishNavyBlue,
                          ),
                        ),
                        color: AppColors.greyishNavyBlue,
                        child: Text(
                          AppStrings.save,
                          style: Styles.sizedBoxWhite,
                        ),
                        onPressed: () async {
                          _measure = _measure!;
                          _serial = serialController.text;
                          _description = descriptionController.text;
                          _storeBuy = storeBuyController.text;
                          _dateBuy = dateController.text;
                          _numberInvoice = numberInvoiceController.text;
                          var bike = Bike(
                            typeBike: TypeBike(id: 0, type: _type),
                            trademarkBike:
                                TrademarkBike(id: 0, trademark: _tradeMark),
                            measurement: _measure,
                            userId: 1,
                            serial: _serial,
                            description: _description,
                            storeBuy: _storeBuy,
                            dateBuy: _dateBuy,
                            numberInvoice: _numberInvoice,
                          );

                          var finalId = await BikeFirebaseRepository()
                              .createDatesBike(bike);
                          // Navigator.pop(context, bike);
                          BikeFirebaseRepository().uploadBike(
                            'user.id',
                            _image,
                            _image2,
                            _image3,
                            _image4,
                            _image5,
                            _image6,
                          );
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
    );
  }
}
