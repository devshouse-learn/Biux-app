import 'dart:io';
import 'package:biux/config/colors.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/config/themes/theme.dart';
import 'package:biux/data/models/user.dart';
import 'package:biux/data/local_storage/localstorage.dart';
import 'package:biux/ui/screens/zoom_screen/zoom_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

class DetailUsers extends StatefulWidget {
  final BiuxUser? _user;
  DetailUsers(this._user);

  @override
  _DetailUsersState createState() => _DetailUsersState(this._user);
}

class _DetailUsersState extends State<DetailUsers> {
  late Function byEnd;
  bool pressGeoON = false;
  bool cmbscritta = false;
  ThemeData theme = darkTheme;
  BiuxUser? user;
  late String? username = '';

  _DetailUsersState(BiuxUser? user);

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () async {
      username = (await LocalStorage().getUser())!;
    });
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Container(
                  height: 350,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      colorFilter: new ColorFilter.mode(
                          AppColors.black.withOpacity(0.6),
                          BlendMode.colorBurn),
                      image: NetworkImage(
                        widget._user!.profileCover == null
                            ? AppStrings.urlBiuxApp
                            : widget._user!.profileCover,
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 70),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: GestureDetector(
                              child: Icon(
                                Icons.arrow_back,
                                color: AppColors.white,
                              ),
                              onTap: () {
                                SchedulerBinding.instance.addPostFrameCallback(
                                  (_) {
                                    Navigator.of(context).pop();
                                  },
                                );
                              },
                            ),
                          ),
                          username == widget._user!.userName
                              ? Container(
                                  child: IconButton(
                                    icon: Icon(Icons.share,
                                        color: AppColors.white),
                                    onPressed: () async {
                                      final RenderObject? box =
                                          context.findRenderObject();
                                      if (Platform.isAndroid) {
                                        AppStrings.messageWhatsapp(
                                          usuario: widget._user!.userName,
                                        );
                                        // );
                                      }
                                    },
                                  ),
                                )
                              : Container()
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment(0.0, 3.0),
                      child: GestureDetector(
                        child: Material(
                          elevation: 20,
                          borderRadius: BorderRadius.circular(55.0),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(60.0),
                                boxShadow: [
                                  BoxShadow(
                                      color: AppColors.white, spreadRadius: 5)
                                ]),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) {
                                      return ZoomPage3(
                                        widget._user!.photo == null
                                            ? AppStrings.urlBiuxApp
                                            : widget._user!.photo,
                                      );
                                    },
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.strongCyan,
                                ),
                                height: 110,
                                width: 110,
                                child: InkWell(
                                  child: new Container(
                                    alignment: (Alignment(-1.0, 2.5)),
                                    decoration: new BoxDecoration(
                                      image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: NetworkImage(
                                            widget._user!.photo == null
                                                ? AppStrings.urlBiuxApp
                                                : widget._user!.photo,
                                          )),
                                      borderRadius: new BorderRadius.all(
                                        const Radius.circular(80.0),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.only(top: 15.0),
                          child: Text(
                            widget._user!.names,
                            style: Styles.containerWhite,
                          ),
                        ),
                        Container(
                          width: 5,
                        ),
                        Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.only(top: 15.0),
                          child: Text(
                            widget._user!.surnames == ''
                                ? ''
                                : widget._user!.surnames,
                            style: Styles.containerWhite,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            widget._user!.userName,
                            style: Styles.containerDescription,
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            widget._user!.email == null
                                ? ''
                                : "- ${widget._user!.email}",
                            style: Styles.containerDescription,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        widget._user!.cellphone == null
                            ? ''
                            : "${widget._user!.cellphone}",
                        style: Styles.containerDescription,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.only(top: 3.0),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailScreen extends StatefulWidget {
  final BiuxUser _user;
  DetailScreen(this._user);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  initState() {
    SystemChrome.setEnabledSystemUIOverlays([]);
    super.initState();
  }

  @override
  void dispose() {
    //SystemChrome.restoreSystemUIOverlays();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        child: Center(
          child: Hero(
            tag: AppStrings.zoomImagen,
            child: Container(
              child: Image(
                image: NetworkImage(
                  widget._user.photo == null
                      ? AppStrings.urlBiuxApp
                      : widget._user.photo,
                ),
              ),
            ),
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}

class DetailScreen2 extends StatefulWidget {
  final BiuxUser _user;
  DetailScreen2(this._user);

  @override
  _DetailScreen2State createState() => _DetailScreen2State();
}

class _DetailScreen2State extends State<DetailScreen2> {
  initState() {
    SystemChrome.setEnabledSystemUIOverlays([]);
    super.initState();
  }

  @override
  void dispose() {
    //SystemChrome.restoreSystemUIOverlays();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        child: Center(
          child: Hero(
            tag: AppStrings.zoomImagen,
            child: Container(
              child: Image(
                image: NetworkImage(
                  widget._user.profileCover == null
                      ? AppStrings.urlBiuxApp
                      : widget._user.profileCover,
                ),
              ),
            ),
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
