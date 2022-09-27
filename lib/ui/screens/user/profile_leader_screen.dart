import 'package:biux/config/colors.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/config/themes/theme.dart';
import 'package:biux/data/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileLeaderScreen extends StatefulWidget {
  final String nameADM;
  final String surnameADM;
  final String logoADM;
  final String profileCoverADM;
  final String instagramADM;
  final String facebookADM;
  ProfileLeaderScreen(
    this.nameADM,
    this.surnameADM,
    this.logoADM,
    this.profileCoverADM,
    this.instagramADM,
    this.facebookADM,
  );

  @override
  _ProfileLeaderScreenState createState() => _ProfileLeaderScreenState();
}

class _ProfileLeaderScreenState extends State<ProfileLeaderScreen> {
  late Function byEnd;
  bool pressGeoON = false;
  bool cmbscritta = false;
  ThemeData theme = darkTheme;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            Text(
              widget.nameADM,
              style: Styles.appBarChildren,
            ),
            Container(
              width: 5,
            ),
            Text(
              widget.surnameADM,
              style: Styles.appBarChildren,
            ),
          ],
        ),
      ),
      body: ListView(
        children: <Widget>[
          Stack(
            alignment: Alignment.bottomRight,
            children: <Widget>[
              GestureDetector(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(
                        bottom: 20,
                      ),
                      height: 160,
                      width: 600,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                            widget.profileCoverADM == null
                                ? AppStrings.urlBiuxApp
                                : widget.profileCoverADM,
                          ),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                    ),
                    Container(
                      height: 25,
                    ),
                  ],
                ),
                onTap: () {},
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 90),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.only(
                  top: 50.0,
                  bottom: 2,
                ),
                child: Row(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: EdgeInsets.only(bottom: 30),
                        height: 110,
                        width: 110,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(
                              widget.logoADM == null
                                  ? AppStrings.urlBiuxApp
                                  : widget.logoADM,
                            ),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(60.0),
                        ),
                      ),
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
            children: <Widget>[
              Container(
                width: 10,
              ),
              Container(
                padding: EdgeInsets.only(
                  left: 10,
                  bottom: 5,
                ),
                child: Text(
                  widget.nameADM,
                  style: Styles.rowPadding,
                ),
              ),
              Container(
                padding: EdgeInsets.only(
                  left: 10,
                  bottom: 5,
                ),
                child: Text(
                  widget.surnameADM,
                  style: Styles.rowPadding,
                ),
              ),
            ],
          ),
          Container(
            color: AppColors.black45,
            padding: const EdgeInsets.only(
              top: 5,
              bottom: 5,
            ),
            child: Row(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(
                    top: 5.0,
                    bottom: 5,
                    left: 50,
                  ),
                  child: Text(
                    AppStrings.cityText,
                    style: Styles.indicatePerson,
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(
                    top: 5.0,
                    bottom: 5,
                    left: 130,
                  ),
                  child: Text(
                    AppStrings.socialNetworks,
                    style: Styles.rowSocialNetworks,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: <Widget>[
              Row(
                children: [
                  SizedBox(
                    child: Container(
                      margin: EdgeInsets.only(left: 10),
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        AppStrings.ibagueTolima /*_grupo. m==null?"":_grupo.ciudad*/,
                        style: Styles.rowPadding,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                width: 50,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  widget.instagramADM == ""
                      ? Container()
                      : Container(
                          child: IconButton(
                            icon: Icon(
                              FontAwesomeIcons.instagram,
                              size: 35.0,
                            ),
                            onPressed: () {
                              launch(
                                AppStrings.instagramMessage2(nameInstagram: widget.instagramADM)
                              );
                            },
                          ),
                        ),
                  widget.facebookADM == null
                      ? Container()
                      : Container(
                          child: new IconButton(
                            icon: new Icon(
                              FontAwesomeIcons.facebook,
                              size: 35.0,
                            ),
                            onPressed: () {
                              launch(
                                "${widget.facebookADM}",
                              );
                            },
                          ),
                        ),
                ],
              ),
            ],
          ),
          Container(
            height: 20,
          ),
        ],
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
                  widget._user.photo,
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
