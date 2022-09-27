import 'package:biux/config/colors.dart';
import 'package:biux/config/images.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/config/themes/theme.dart';
import 'package:biux/data/models/group.dart';
import 'package:biux/data/models/member.dart';
import 'package:biux/data/models/user.dart';
import 'package:biux/data/repositories/groups/groups_repository.dart';
import 'package:biux/data/repositories/members/members_repository.dart';
import 'package:biux/data/local_storage/localstorage.dart';
import 'package:biux/ui/screens/group/ui/screens/group_slider/detail_group.dart';
import 'package:biux/ui/screens/group/ui/screens/group_slider/edit_group.dart';
import 'package:biux/ui/screens/group/ui/screens/group_slider/members_group.dart';
import 'package:biux/ui/screens/group/ui/screens/group_slider/roads_group.dart';
import 'package:biux/ui/screens/group/ui/screens/groups_list.dart';
import 'package:biux/ui/screens/home.dart';
import 'package:biux/ui/screens/zoom_screen/zoom_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class GroupSlider extends StatefulWidget {
  final Group? _group;
  final int? id;
  final Function? byEnd;
  final Member? member;
  final BiuxUser? admin;

  GroupSlider(
    this._group, {
    this.id,
    this.member,
    this.byEnd,
    this.admin,
  });

  final ThemeData theme = darkTheme;
  @override
  GrupoSliderState createState() => new GrupoSliderState();
}

class GrupoSliderState extends State<GroupSlider>
    with SingleTickerProviderStateMixin {
  String whatsapp = Images.kWhatsappLogo;
  String facebook = Images.kFacebookLogo;
  String instagram = Images.kInstagram;
  var username;
  late TabController controller;
  bool cmbscritta = false;
  GroupsList third = GroupsList();
  //se debe llamar los datos del usuario
  late BiuxUser user;

  @override
  void initState() {
    super.initState();
    controller = TabController(vsync: this, length: 3);
    getUserProfile();
    member = Member();
  }

  late String userId;
  bool joinMe = false;
  late String admin = '0';

  getUserProfile() async {
    String? id = await LocalStorage().getUserId();
    username = await LocalStorage().getUser();
    userId = id!;
    Future.delayed(Duration.zero, () async {
      if (username == widget.admin!.userName) {
        if (widget._group!.logo == null ||
            widget._group!.profileCover == null) {
          complete(context);
        }
      }
      member = await MembersRepository().getApproved(
        widget._group!.id,
        userId,
      );
      this.setState(() {
        if (user.id == null)
          admin = '0';
        else {
          admin = user.id;
        }
      });
    });

    this.setState(() {});
  }

  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return MaterialApp(
      home: Scaffold(
        backgroundColor: AppColors.darkBlue,
        body: Container(
          child: Stack(
            alignment: Alignment.bottomRight,
            children: <Widget>[
              GestureDetector(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(
                        bottom: 00,
                      ),
                      height: 250,
                      width: 600,
                      decoration: BoxDecoration(
                        image: new DecorationImage(
                          colorFilter: new ColorFilter.mode(
                              AppColors.darkBlue, BlendMode.hardLight),
                          image: new NetworkImage(
                            widget._group?.profileCover ??
                                AppStrings.urlBiuxApp,
                          ),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                      // child: Hero(
                      //     tag: 'imagen portada',
                      //     child: Image(
                      //         fit: BoxFit.cover,
                      //         image: NetworkImage(
                      //           widget._grupo?.portada ??
                      //               AppStrings.urlBiuxApp,
                      //         ))),
                    ),
                    Container(
                      height: 30,
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) {
                        return ZoomPage(widget._group!.profileCover, widget._group!.name);
                      },
                    ),
                  );
                },
              ),
              Container(
                alignment: Alignment.center,
                margin: new EdgeInsets.only(bottom: 500),
                child: Text(
                  widget._group!.name.toUpperCase(),
                  style: Styles.containerWhite,
                ),
              ),
              Container(
                padding: new EdgeInsets.only(
                  top: 50.0,
                  bottom: 2,
                ),
                child: new Row(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) {
                              return ZoomPage(widget._group!.logo, widget._group!.name);
                            },
                          ),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.only(
                          bottom: size.height * 0.62,
                          left: 30,
                        ),
                        height: 130,
                        width: 130,
                        decoration: new BoxDecoration(
                          image: DecorationImage(
                            image: new NetworkImage(
                              widget._group!.logo == null
                                  ? AppStrings.urlBiuxApp
                                  : widget._group!.logo,
                            ),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(100.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                child: Container(
                  margin: EdgeInsets.only(
                    bottom: size.height * 0.90,
                    right: size.width * 0.90,
                  ),
                  height: 50,
                  width: 50,
                  child: GestureDetector(
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: AppColors.white,
                      size: 45,
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              // username == widget._grupo!.administrador!.usuario
              //     ? PopupMenuButton(
              //         padding: EdgeInsets.only(bottom: 700, right: 20),
              //         onSelected: (value) {
              //           if (value == 1) {
              //             eliminar(context);
              //           }
              //         },
              //         icon: Icon(
              //           Icons.pending_outlined,
              //           size: 35,
              //           color: AppColors.white,
              //         ),
              //         itemBuilder: (context) => [
              //               PopupMenuItem(
              //                 child: Row(
              //                   children: [
              //                     Icon(Icons.delete),
              //                     Text(AppStrings.deletedGroup)
              //                   ],
              //                 ),
              //                 value: 1,
              //               ),
              //             ])
              //     : Container(),
              Container(
                margin: EdgeInsets.only(
                  bottom: 300,
                  left: 150,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    widget._group!.whatsapp == "" ||
                            widget._group!.whatsapp == null
                        ? Row(
                            children: [
                              Container(
                                height: 1,
                                width: 1,
                              ),
                            ],
                          )
                        : GestureDetector(
                            onTap: () {
                              launch(AppStrings.whatsappMessage(
                                  whatsappNumber: widget._group!.whatsapp,
                                  name: widget._group!.name));
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: new AssetImage(whatsapp),
                                ),
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              height: 50,
                              width: 50,
                              // IconButton(
                              //   iconSize: 10,
                              //   alignment: Alignment.centerRight,
                              //   icon: new Icon(FontAwesomeIcons.whatsapp, size: 35.0),
                              //   onPressed: () {
                              //     launch(
                              //         'https://wa.me/+57${widget._grupo!.whatsapp!}');
                              //   },
                              // ),
                            ),
                          ),
                    Container(
                      width: 10,
                    ),
                    widget._group!.instagram == AppStrings.notRegistered ||
                            widget._group!.instagram == null
                        ? Row(
                            children: [
                              Container(
                                height: 1,
                                width: 1,
                              ),
                            ],
                          )
                        : GestureDetector(
                            onTap: () {
                              launch(AppStrings.instagramMessage(
                                  nameInstagram: widget._group!.instagram));
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: new AssetImage(instagram),
                                ),
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              height: 50,
                              width: 50,
                              // child: IconButton(
                              //   iconSize: 10,
                              //   alignment: Alignment.centerRight,
                              //   icon:
                              //       new Icon(FontAwesomeIcons.instagram, size: 35.0),
                              //   onPressed: () {
                              //     launch(
                              //         "https://www.instagram.com/${widget._grupo!.instagram!}/?hl=es-la");
                              //   },
                              // ),
                            ),
                          ),
                    Container(
                      width: 10,
                    ),
                    widget._group!.facebook == AppStrings.notRegistered ||
                            widget._group!.facebook == null
                        ? Row(
                            children: [
                              Container(
                                height: 1,
                                width: 1,
                              ),
                            ],
                          )
                        : GestureDetector(
                            onTap: () {
                              launch("${widget._group!.facebook}");
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: new AssetImage(facebook),
                                  scale: 3,
                                ),
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              height: 50,
                              width: 50,
                            ),
                          ),
                  ],
                ),
              ),

              Container(
                margin: EdgeInsets.only(top: size.height * 0.40),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TabBar(
                        unselectedLabelColor: AppColors.white,
                        indicatorPadding: EdgeInsets.all(10.8),
                        labelPadding: EdgeInsets.zero,
                        controller: controller,
                        tabs: <Container>[
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                              ),
                            ),
                            child: Tab(
                              child: Container(
                                width: 135,
                                child: Text(
                                  AppStrings.profileText,
                                  textAlign: TextAlign.center,
                                  style: Styles.accentTextThemeBlack,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            color: AppColors.white,
                            child: Tab(
                              child: Container(
                                width: 155,
                                child: Text(
                                  AppStrings.rodadas(
                                      numberRodadas: widget._group!.numberRoads
                                          .toString()),
                                  style: Styles.accentTextThemeBlack,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                              ),
                            ),
                            child: Tab(
                              child: Container(
                                width: 135,
                                child: Text(
                                  AppStrings.seguidores(
                                      members: widget._group!.numberMembers
                                          .toString()),
                                  style: Styles.accentTextThemeBlack,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: controller,
                        children: <Widget>[
                          DetailGroup(
                            group: widget._group,
                          ),
                          RoadsGroup(
                            widget._group!,
                          ),
                          MembersGroup(
                            widget._group!.id,
                            widget._group!,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void delete(BuildContext context) {
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
                  borderRadius: BorderRadius.circular(20.0),
                  side: BorderSide(
                    width: 3,
                    color: AppColors.greyishNavyBlue,
                  ),
                ),
                content: Text(
                  AppStrings
                      .deleteGroupConfirmation, //tituloactual == 0 ? titulo1 : titulo2,
                  textAlign: TextAlign.center,
                  style: Styles.showDialogTitleBlack,
                ),
                actions: <Widget>[
                  // usually buttons at the bottom of the dialog
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FlatButton(
                        minWidth: 100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          side: BorderSide(
                            width: 3,
                            color: AppColors.greyishNavyBlue,
                          ),
                        ),
                        child: Text(
                          AppStrings.no,
                          style: Styles.flatButton,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      Container(
                        width: 20,
                      ),
                      FlatButton(
                        minWidth: 100,
                        shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(20.0),
                          side: BorderSide(
                            width: 3,
                            color: AppColors.greyishNavyBlue,
                          ),
                        ),
                        child: Text(
                          AppStrings.si,
                          style: Styles.flatButton,
                        ),
                        onPressed: () async {
                          var button = await GroupsRepository()
                              .deleteGroup(widget._group!);
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
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
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
                    Radius.circular(10.0),
                  ),
                ),
                content: Text(
                  AppStrings
                      .completedGroupText, //tituloactual == 0 ? titulo1 : titulo2,
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
                          MaterialPageRoute(
                            builder: (BuildContext context) => EditGroups(
                              widget._group!,
                              widget.admin!,
                            ),
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

  // _tabBarGrupo() {
  //   return
  // }
}
