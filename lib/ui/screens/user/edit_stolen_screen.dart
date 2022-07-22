import 'dart:io';

import 'package:biux/config/colors.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/config/themes/theme.dart';
import 'package:biux/data/models/bike.dart';
import 'package:biux/data/models/stole_bikes.dart';
import 'package:biux/data/repositories/bikes/bike_repository.dart';
import 'package:biux/data/repositories/stoles_bikes/stole_bikes_repository.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditStolenScreen extends StatefulWidget {
  final Bike bike;
  EditStolenScreen({required this.bike});
  @override
  _EditStolenScreenState createState() => _EditStolenScreenState();
}

class _EditStolenScreenState extends State<EditStolenScreen> {
  late String _description;
  late String _serial;
  late String _stolen;
  late String _direction;
  late File _image01;
  late File _image02;
  late File _image03;
  late File _image04;
  late File _image05;
  late File _image06;

  getImage(flag) async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile pickedFile;
    pickedFile = (await imagePicker.getImage(
      source: ImageSource.gallery,
      imageQuality: 20,
    ))!;
    switch (flag) {
      case 1:
        setState(
          () {
            File image = File(pickedFile.path);
            _image01 = image;
          },
        );
        break;
      case 2:
        setState(
          () {
            File image = File(pickedFile.path);
            _image02 = image;
          },
        );
        break;
      case 3:
        setState(
          () {
            File image = File(pickedFile.path);
            _image03 = image;
          },
        );
        break;
      case 4:
        setState(
          () {
            File image = File(pickedFile.path);
            _image04 = image;
          },
        );
        break;
      case 5:
        setState(
          () {
            File image = File(pickedFile.path);
            _image05 = image;
          },
        );
        break;
      case 6:
        setState(
          () {
            File image = File(pickedFile.path);
            _image06 = image;
          },
        );
        break;
    }
  }

  final descriptionController = TextEditingController();
  final serialController = TextEditingController();
  final stolenController = TextEditingController();
  final directionController = TextEditingController();

  ThemeData theme = darkTheme;
  var _darkTheme = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          Container(
            alignment: Alignment.topCenter,
            height: 650,
            child: Card(
              color: AppColors.white,
              margin: EdgeInsets.all(35),
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(19.0),
                child: ListView(
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  // mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15.0),
                      child: Container(
                        height: 22,
                        padding: EdgeInsets.only(
                          left: 10,
                        ),
                        child: Row(
                          children: <Widget>[
                            Container(
                              child: Text(
                                AppStrings.stolenBicycleText,
                                style: Styles.clipRRectBlack,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Align(
                          alignment: Alignment(-1.0, 2.5),
                          child: GestureDetector(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: AppColors.gray.withOpacity(0.2),
                              ),
                              height: 90,
                              width: 90,
                              child: _image01 == null
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
                                                getImage(1);
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
                                              _image01.path != null
                                                  ? _image01
                                                  : getImage(1),
                                            ),
                                          ),
                                          borderRadius: BorderRadius.all(
                                            const Radius.circular(10.0),
                                          ),
                                        ),
                                      ),
                                      onTap: () {
                                        setState(
                                          () {
                                            getImage(1);
                                          },
                                        );
                                      },
                                    ),
                            ),
                            onTap: () {
                              setState(
                                () {
                                  getImage(1);
                                },
                              );
                            },
                          ),
                        ),
                        Container(
                          width: 5,
                        ),
                        Align(
                          alignment: Alignment(-1.0, 2.5),
                          child: GestureDetector(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: AppColors.gray.withOpacity(0.2),
                              ),
                              height: 90,
                              width: 90,
                              child: _image02 == null
                                  ? Stack(
                                      children: <Widget>[
                                        GestureDetector(
                                          child: Center(
                                            child: Icon(Icons.camera_alt),
                                          ),
                                          onTap: () {
                                            setState(
                                              () {
                                                getImage(2);
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
                                              _image02.path != null
                                                  ? _image02
                                                  : getImage(2),
                                            ),
                                          ),
                                          borderRadius: BorderRadius.all(
                                            const Radius.circular(
                                              10.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                      onTap: () {
                                        setState(
                                          () {
                                            getImage(2);
                                          },
                                        );
                                      },
                                    ),
                            ),
                            onTap: () {
                              setState(
                                () {
                                  getImage(2);
                                },
                              );
                            },
                          ),
                        ),
                        Container(
                          width: 5,
                        ),
                        Align(
                          alignment: Alignment(-1.0, 2.5),
                          child: GestureDetector(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: AppColors.gray.withOpacity(0.2),
                              ),
                              height: 90,
                              width: 90,
                              child: _image03 == null
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
                                                getImage(3);
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
                                              _image03.path != null
                                                  ? _image03
                                                  : getImage(3),
                                            ),
                                          ),
                                          borderRadius: BorderRadius.all(
                                            const Radius.circular(
                                              10.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                      onTap: () {
                                        setState(
                                          () {
                                            getImage(3);
                                          },
                                        );
                                      },
                                    ),
                            ),
                            onTap: () {
                              setState(
                                () {
                                  getImage(3);
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          child: Text(
                            AppStrings.completeBike,
                            style: Styles.rowItem,
                          ),
                        ),
                        Container(
                          width: 40,
                        ),
                        Container(
                          child: Text(
                            AppStrings.bill,
                            style: Styles.rowItem,
                          ),
                        ),
                        Container(
                          width: 40,
                        ),
                        Container(
                          child: Text(
                            AppStrings.frontBike,
                            style: Styles.rowItem,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Align(
                          alignment: Alignment(
                            -1.0,
                            2.5,
                          ),
                          child: GestureDetector(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: AppColors.gray.withOpacity(0.2),
                              ),
                              height: 90,
                              width: 90,
                              child: _image04 == null
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
                                                getImage(4);
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
                                              _image04.path != null
                                                  ? _image04
                                                  : getImage(4),
                                            ),
                                          ),
                                          borderRadius: BorderRadius.all(
                                            const Radius.circular(
                                              10.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                      onTap: () {
                                        setState(
                                          () {
                                            getImage(4);
                                          },
                                        );
                                      },
                                    ),
                            ),
                            onTap: () {
                              setState(
                                () {
                                  getImage(4);
                                },
                              );
                            },
                          ),
                        ),
                        Container(
                          width: 5,
                        ),
                        Align(
                          alignment: Alignment(-1.0, 2.5),
                          child: GestureDetector(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: AppColors.gray.withOpacity(0.2),
                              ),
                              height: 90,
                              width: 90,
                              child: _image05 == null
                                  ? Stack(
                                      children: <Widget>[
                                        GestureDetector(
                                            child: Center(
                                              child: Icon(Icons.camera_alt),
                                            ),
                                            onTap: () {
                                              setState(() {
                                                getImage(5);
                                              });
                                            }),
                                      ],
                                    )
                                  : InkWell(
                                      child: Container(
                                        alignment: (Alignment(-1.0, 2.5)),
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: FileImage(
                                              _image05.path != null
                                                  ? _image05
                                                  : getImage(5),
                                            ),
                                          ),
                                          borderRadius: BorderRadius.all(
                                            const Radius.circular(
                                              10.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                      onTap: () {
                                        setState(
                                          () {
                                            getImage(5);
                                          },
                                        );
                                      },
                                    ),
                            ),
                            onTap: () {
                              setState(
                                () {
                                  getImage(5);
                                },
                              );
                            },
                          ),
                        ),
                        Container(
                          width: 5,
                        ),
                        Align(
                          alignment: Alignment(-1.0, 2.5),
                          child: GestureDetector(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: AppColors.gray.withOpacity(0.2),
                              ),
                              height: 90,
                              width: 90,
                              child: _image06 == null
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
                                                getImage(6);
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
                                              _image06.path != null
                                                  ? _image06
                                                  : getImage(6),
                                            ),
                                          ),
                                          borderRadius: BorderRadius.all(
                                            const Radius.circular(
                                              10.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                      onTap: () {
                                        setState(
                                          () {
                                            getImage(6);
                                          },
                                        );
                                      },
                                    ),
                            ),
                            onTap: () {
                              setState(
                                () {
                                  getImage(6);
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          child: Text(
                            AppStrings.bicycleGroup,
                            style: Styles.rowItem,
                          ),
                        ),
                        Container(
                          width: 40,
                        ),
                        Container(
                          child: Text(
                            AppStrings.serialPhoto,
                            style: Styles.rowItem,
                          ),
                        ),
                        Container(
                          width: 40,
                        ),
                        Container(
                          child: Text(
                            AppStrings.propertyCard,
                            style: Styles.rowItem,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          width: 230,
                          child: TextFormField(
                            maxLines: 5,
                            controller: descriptionController,
                            style: Styles.accentTextThemeBlack,
                            decoration: InputDecoration(
                              fillColor: AppColors.white,
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppColors.black54,
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
                              hintText: AppStrings.descriptionText,
                              hintStyle: Styles.rowHintStyleBlack,
                            ),
                            onSaved: (String? value) {
                              _description = value!;
                            },
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          width: 230,
                          child: TextFormField(
                            controller: directionController,
                            style: Styles.accentTextThemeBlack,
                            decoration: InputDecoration(
                              fillColor: AppColors.white,
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppColors.black54,
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
                              hintText: AppStrings.address,
                              hintStyle: Styles.rowHintStyleBlack,
                            ),
                            onSaved: (String? value) {
                              _direction = value!;
                            },
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        SizedBox(
                          width: 130,
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              side: BorderSide(
                                width: 3,
                                color: AppColors.lightNavyBlue,
                              ),
                            ),
                            color: _darkTheme == true
                                ? AppColors.deepNavyBlue
                                : AppColors.white,
                            child: Text(
                              AppStrings.report,
                              style: _darkTheme == true
                                  ? Styles.sizedBoxWhite
                                  : Styles.sizedBoxBlack,
                            ),
                            onPressed: () async {
                              _description = descriptionController.text;
                              _direction = directionController.text;
                              _serial = serialController.text;
                              var stoleBike = StoleBikes(
                                bike: widget.bike,
                               // bikeId: widget.bike.id,
                                description: _description,
                                direction: _direction,
                                // fechaCreacion: DateTime.now().toString(),
                                datetimeStole: DateTime.now().toString(),
                              );
                              var response = StoleBikesRepository()
                                  .sendDatesStoleBikes(stoleBike);
                              if (response == 200) {
                                showDialog1(context);
                              }
                              BikeRepository().uploadBike(
                                widget.bike.id!.toString(),
                                _image01,
                                _image02,
                                _image03,
                                _image04,
                                _image05,
                                _image06,
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
        ],
      ),
    );
  }

  void showDialog1(
    BuildContext context,
  ) {
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
          title: Text(AppStrings.success),
          content: Text(
            AppStrings.reportedBike,
          ),
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
}
