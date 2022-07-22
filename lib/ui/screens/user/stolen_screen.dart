import 'package:biux/config/colors.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/config/themes/theme.dart';
import 'package:biux/data/models/user.dart';
import 'package:biux/data/models/bike.dart';
import 'package:biux/data/models/stole_bikes.dart';
import 'package:biux/data/repositories/stoles_bikes/stole_bikes_repository.dart';
import 'package:biux/data/shared_preferences/localstorage.dart';
import 'package:biux/ui/screens/user/edit_stolen_screen.dart';
import 'package:biux/ui/widgets/map_general_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StolenScreen extends StatefulWidget {
  final BiuxUser user;
  final Bike bike;

  StolenScreen(this.user, this.bike);
  @override
  _StolenScreenState createState() => _StolenScreenState();
}

class _StolenScreenState extends State<StolenScreen> {
  bool isLoggedIn = false;
  final directionCrontroller = TextEditingController();

  void initState() {
    super.initState();
    setState(
      () {
        getInfoStoleBike();
      },
    );
  }

  getInfoStoleBike() async {
    var id = await LocalStorage().getUserId();
    int finalId = int.parse(id!);
    setState(() {
      isLoggedIn = true;
    });
  }


  late String message;
  ThemeData theme = darkTheme;
  var _darkTheme = true;
  final format = DateFormat(AppStrings.dateFormat5);
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15.0),
                      child: Container(
                        height: 23,
                        padding: EdgeInsets.only(
                          left: 40,
                        ),
                        child: Row(
                          children: <Widget>[
                            Container(
                              child: Text(
                                AppStrings.reportBikeTheft,
                                style: Styles.containerReport,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 10,
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.only(
                                  bottom: 114,
                                ),
                                height: 90,
                                width: 90,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 5,
                                    color: AppColors.black54,
                                    style: BorderStyle.solid,
                                  ),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      widget.bike.photoBikeComplete == null
                                          ? AppStrings.urlBiuxApp
                                          : widget.bike.photoBikeComplete!,
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.circular(2.0),
                                ),
                              ),
                            ],
                          ),
                          onTap: () {},
                        ),
                        Container(
                          width: 5,
                        ),
                        GestureDetector(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.only(
                                  bottom: 114,
                                ),
                                height: 90,
                                width: 90,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 5,
                                    color: AppColors.black54,
                                    style: BorderStyle.solid,
                                  ),
                                  image: DecorationImage(
                                    image: NetworkImage(widget
                                                .bike.photoInvoice ==
                                            null
                                        ? AppStrings.urlBiuxApp
                                        : widget.bike.photoBikeComplete!),
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.circular(2.0),
                                ),
                              ),
                            ],
                          ),
                          onTap: () {},
                        ),
                        Container(
                          width: 5,
                        ),
                        GestureDetector(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.only(
                                  bottom: 114,
                                ),
                                height: 90,
                                width: 90,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 5,
                                    color: AppColors.black54,
                                    style: BorderStyle.solid,
                                  ),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      widget.bike.photoFrontal == null
                                          ? AppStrings.urlBiuxApp
                                          : widget.bike.photoBikeComplete!,
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.circular(2.0),
                                ),
                              ),
                            ],
                          ),
                          onTap: () {},
                        ),
                      ],
                    ),
                    Container(
                      height: 10,
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.only(
                                  bottom: 114,
                                ),
                                height: 90,
                                width: 90,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 5,
                                    color: AppColors.black54,
                                    style: BorderStyle.solid,
                                  ),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      widget.bike.photoGroupBike == null
                                          ? AppStrings.urlBiuxApp
                                          : widget.bike.photoBikeComplete!,
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.circular(2.0),
                                ),
                              ),
                            ],
                          ),
                          onTap: () {},
                        ),
                        Container(
                          width: 5,
                        ),
                        GestureDetector(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.only(
                                  bottom: 114,
                                ),
                                height: 90,
                                width: 90,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 5,
                                    color: AppColors.black,
                                    style: BorderStyle.solid,
                                  ),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      widget.bike.photoSerial == null
                                          ? AppStrings.urlBiuxApp
                                          : widget.bike.photoSerial!,
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.circular(2.0),
                                ),
                              ),
                            ],
                          ),
                          onTap: () {},
                        ),
                        Container(
                          width: 5,
                        ),
                        GestureDetector(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.only(
                                  bottom: 114,
                                ),
                                height: 90,
                                width: 90,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 5,
                                    color: AppColors.black,
                                    style: BorderStyle.solid,
                                  ),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      widget.bike.photoOwnershipCard == null
                                          ? AppStrings.urlBiuxApp
                                          : widget.bike.photoOwnershipCard!,
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.circular(2.0),
                                ),
                              ),
                            ],
                          ),
                          onTap: () {},
                        ),
                      ],
                    ),
                    Container(
                      height: 15,
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15.0),
                      child: Container(
                        padding: EdgeInsets.only(
                          left: 40,
                        ),
                        child: Row(
                          children: <Widget>[
                            Container(
                              child: Text(
                                widget.bike.description!,
                                overflow: TextOverflow.ellipsis,
                                style: Styles.wrapDrawerBlack,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 15,
                    ),
                    Row(
                      children: [
                        Container(
                          height: 26,
                          padding: EdgeInsets.only(
                            left: 40,
                          ),
                          child: Row(
                            children: <Widget>[
                              Container(
                                child: Text(
                                  AppStrings.serial,
                                  style: Styles.wrapDrawerBlue,
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          height: 26,
                          child: Row(
                            children: <Widget>[
                              Container(
                                child: Text(
                                  widget.bike.serial!,
                                  style: Styles.wrapDrawerBlack,
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 15,
                    ),
                    Container(
                      height: 20,
                      padding: EdgeInsets.only(
                        left: 95,
                      ),
                      child: Row(
                        children: <Widget>[
                          Container(
                            child: Text(
                              AppStrings.rolledIn,
                              style: Styles.wrapDrawerBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        GestureDetector(
                          child: SizedBox(
                            width: 230,
                            child: TextFormField(
                              controller: directionCrontroller..text = message,
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
                                enabled: false,
                                contentPadding: EdgeInsets.fromLTRB(
                                  10.0,
                                  15.0,
                                  20.0,
                                  15.0,
                                ),
                                hintText: message,
                                hintStyle: Styles.rowHintStyleBlack,
                              ),
                            ),
                          ),
                          onTap: () async {
                            FocusScope.of(context).requestFocus(FocusNode());
                            final coordinates = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MapGeneral(
                                  message: message,
                                ),
                              ),
                            );
                            if (coordinates != null) {
                              directionCrontroller.text =
                                  coordinates[AppStrings.addressText].toString();
                            }
                          },
                        ),
                      ],
                    ),
                    Container(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                              AppStrings.stolenBicycleText2,
                              style: _darkTheme == true
                                  ? Styles.sizedBoxWhite
                                  : Styles.sizedBoxBlack,
                            ),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    EditStolenScreen(
                                  bike: widget.bike,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 15,
                        ),
                        SizedBox(
                          width: 130,
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(20.0),
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
                              var stoleBikes = StoleBikes(
                                bike: widget.bike,
                               // bikeId: widget.bike.id,
                                description: widget.bike.description,
                                direction: directionCrontroller.text,
                                dateCreate: DateTime.now().toString(),
                                datetimeStole: DateTime.now().toString(),
                              );
                              var response = StoleBikesRepository()
                                  .sendDatesStoleBikes(stoleBikes);
                              showDialog1(context);
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
}
