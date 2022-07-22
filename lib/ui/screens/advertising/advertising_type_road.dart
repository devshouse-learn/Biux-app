import 'package:biux/config/colors.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/config/themes/theme.dart';
import 'package:biux/config/themes/theme_notifier.dart';
import 'package:biux/data/models/advertising.dart';
import 'package:biux/data/repositories/advertisements/advertising_repository.dart';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class AdvertisingTypeRoad extends StatefulWidget {
  Function? byEnd;
  int? indexPage;
  AdvertisingTypeRoad({this.byEnd, this.indexPage});
  @override
  _AdvertisingTypeRoadState createState() => _AdvertisingTypeRoadState();
}

class _AdvertisingTypeRoadState extends State<AdvertisingTypeRoad> {
  ThemeData theme = darkTheme;
  late Advertising advertising;
  late PaletteGenerator paletteGenerator;
  void initState() {
    super.initState();
    advertising = Advertising(
      title: "",
      costOpen: 0.0,
      costWatch: 0.0,
      description: "",
      money: 0.0,
      photoAd: "",
      docId: '0',
      textButton: "",
      url: "∫",
    );
    getAdvertising();
    setState(() {});
  }

  getAdvertising() {
    Future.delayed(
      Duration.zero,
      () async {
        advertising = await AdvertisingRepository().getAdvertising();
        var data = Advertising(
          money: advertising.money - advertising.costWatch,
          docId: advertising.docId,
        );
        await AdvertisingRepository().updateSites(data);
      },
    );
  }

  var _darkTheme = true;
  @override
  Future<PaletteGenerator> _updatePaletteGenerator() async {
    paletteGenerator = await PaletteGenerator.fromImageProvider(
      Image.network(advertising.photoAd).image,
    );
    return paletteGenerator;
  }

  Color face = AppColors.black;
  Widget build(BuildContext context) {
    widget.indexPage == 0
        ? Future.delayed(
            Duration(seconds: 180),
            () async {
              _pullRefresh();
            },
          )
        : Container();

    final themeNotifier = Provider.of<ThemeNotifier>(context);
    _darkTheme = (themeNotifier.getTheme() == darkTheme);
    bool is12HoursFormat = MediaQuery.of(context).alwaysUse24HourFormat;
    return advertising.photoAd == ""
        ? Container(
            child: CircularProgressIndicator(
              color: AppColors.strongCyan,
            ),
          )
        : Container(
            child: Stack(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                    left: 8.0,
                    right: 8,
                  ),
                  child: Container(
                    margin: EdgeInsets.all(14),
                    alignment: Alignment.center,
                    height: 180,
                    child: Card(
                      color: AppColors.white,
                      margin: EdgeInsets.only(
                        left: 59,
                      ),
                      // elevation: 30,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Container(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4.0),
                                child: Container(
                                  height: 20,
                                  padding: EdgeInsets.only(),
                                  color: AppColors.greyishNavyBlue,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        child: Text(
                                          advertising.title,
                                          style: Styles.advertisingTitle,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    alignment: Alignment.center,
                                  ),
                                  Flexible(
                                    child: Container(
                                      padding: EdgeInsets.only(
                                        right: 13.0,
                                        left: 38,
                                      ),
                                      child: Text(
                                        advertising.description,
                                        overflow: TextOverflow.fade,
                                        style: Styles.flexibleContainer,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                height: 5,
                              ),
                              Row(
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.only(
                                      left: 40,
                                    ),
                                  ),
                                  Container(
                                    width: 5,
                                  ),
                                ],
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
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: new EdgeInsets.only(
                        top: 50.0,
                        bottom: 1,
                        right: 100,
                      ),
                      child: Row(
                        children: <Widget>[
                          GestureDetector(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 15.0,
                              ),
                              child: Container(
                                height: 100,
                                width: 100,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      advertising.photoAd,
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                              ),
                            ),
                            onTap: () {
                              setState(
                                () {
                                  _showDialog(advertising);
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          margin: EdgeInsets.only(
                            top: 135,
                          ),
                          child: ButtonTheme(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              side: BorderSide(
                                  width: 3, color: AppColors.lightNavyBlue),
                            ),
                            minWidth: 35.0,
                            height: 35.0,
                            child: RaisedButton(
                              elevation: 20,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              color: AppColors.strongCyan,
                              child: Text(
                                advertising.textButton ,
                                style: Styles.advertisingTextButton,
                              ),
                              onPressed: () async {
                                var data = Advertising(
                                  money: advertising.money -
                                      advertising.costOpen,
                                  docId: advertising.docId,
                                );
                                await AdvertisingRepository().updateSites(data);
                                launch(
                                  '${advertising.url}',
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    GestureDetector(
                      child: SizedBox(
                        width: 95,
                        child: Container(
                          margin: EdgeInsets.only(
                            top: 155,
                            left: 18,
                          ),
                          child: Text(
                            AppStrings.advert,
                            overflow: TextOverflow.fade,
                            style: Styles.gestureDetectorAdvert,
                          ),
                        ),
                      ),
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          );
  }

  void _showDialog(Advertising advertising) async {
    var data = Advertising(
      money: advertising.money - advertising.costOpen,
      docId: advertising.docId,
    );
    await AdvertisingRepository().updateSites(data);
    showDialog(
      barrierColor: AppColors.black87,
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            decoration: new BoxDecoration(
              borderRadius: BorderRadius.circular(40.0),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.black,
                  face,
                  AppColors.black,
                ],
              ),
              color: face,
            ),
            height: 500,
            width: 330,
            child: Column(
              children: <Widget>[
                Container(
                  height: 20,
                  width: 20,
                  margin: EdgeInsets.only(left: 280),
                  child: FloatingActionButton(
                    backgroundColor: AppColors.red,
                    child: Icon(
                      Icons.close,
                      size: 20,
                      color: AppColors.white,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                Material(
                  color: AppColors.transparent,
                  child: Container(
                    padding: EdgeInsets.all(3),
                    child: Text(
                      advertising.title,
                      style: Styles.materialAdvertising,
                    ),
                  ),
                ),
                Stack(
                  children: [
                    Container(
                      height: 250,
                      width: 250,
                      margin: const EdgeInsets.only(
                        left: 20.0,
                        right: 20.0,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        image: DecorationImage(
                          image: NetworkImage(
                            advertising.photoAd,
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(
                      //width: 220.0,
                      child: Container(
                        margin: EdgeInsets.only(top: 380, left: 75),
                        child: RaisedButton(
                          elevation: 20,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          color: AppColors.greyishNavyBlue,
                          child: Text(
                            advertising.textButton,
                            style: Styles.raisedButton,
                          ),
                          onPressed: () async {
                            var data = Advertising(
                              money: advertising.money - advertising.costOpen,
                              docId: advertising.docId,
                            );
                            await AdvertisingRepository().updateSites(data);
                            launch(
                              '${advertising.url}',
                            );
                          },
                        ),
                      ),
                    ),
                    Material(
                      color: AppColors.transparent,
                      child: Container(
                        margin: EdgeInsets.only(
                          top: 260,
                          left: 25,
                        ),
                        child: Text(
                          advertising.description,
                          style: Styles.materialAdvertisingDescription,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pullRefresh() async {
    Future.delayed(
      Duration(seconds: 3),
      () async {
        advertising = await AdvertisingRepository().getAdvertising();
        var data = Advertising(
          money: advertising.money - advertising.costWatch,
          docId: advertising.docId,
        );
        await AdvertisingRepository().updateSites(data);
      },
    );
    setState(() => {});
  }
}
