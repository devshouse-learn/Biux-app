import 'package:biux/config/colors.dart';
import 'package:biux/config/images.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/data/models/user.dart';
import 'package:biux/ui/screens/login/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class RecoverPassword extends StatefulWidget {
  @override
  _RecoverPasswordState createState() => _RecoverPasswordState();
}

class _RecoverPasswordState extends State<RecoverPassword> {
  var _darkTheme = true;
  var emailList = BiuxUser(
    gender: "",
    id: '0',
    password: "",
    email: "",
    facebook: "",
    dateBirth: "",
    photo: "",
    instagram: "",
    modality: [],
    profileCover: "",
    premium: false,
    followerS: 0,
    token: "",
    userName: "",
    whatsapp: "",
  );

  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final emailController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffolState = GlobalKey<ScaffoldState>();

  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Form(
        key: _formKey,
        child: Scaffold(
          key: _scaffolState,
          backgroundColor: AppColors.darkBlue,
          body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(Images.kBackground),
                fit: BoxFit.cover,
              ),
            ),
            child: ListView(
              children: [
                Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                        top: 0,
                        left: 0,
                      ),
                      height: 150,
                      width: 400,
                      child: Stack(children: <Widget>[
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
                                AppStrings.recoverPassword,
                                textAlign: TextAlign.center,
                                style: Styles.accentTextThemeWhite,
                              ),
                            ),
                          ],
                        )
                      ]),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 65),
                      child: Stack(

                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 50),
                            child: Stack(

                              //   alignment: Alignment.center,
                              children: [
                                Center(
                                  child: Container(
                                    height: 300,
                                    width: 370,
                                    child: Card(
                                      color: AppColors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Container(
                                              child: Text(
                                                AppStrings.enterGmail,
                                                textAlign: TextAlign.center,
                                                style: Styles.paddingText,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 15,
                                              right: 15,
                                              top: 5,
                                              bottom: 5,
                                            ),
                                            child: TextFormField(
                                              style: Styles.indicatePerson,
                                              controller: emailController,
                                              decoration: InputDecoration(
                                                prefixIcon: Icon(
                                                  Icons.email,
                                                  color: AppColors.gray,
                                                ),
                                                fillColor: AppColors.white,
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: AppColors.gray,
                                                    width: 1,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(45),
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
                                                    AppStrings.enterGmail,
                                                errorBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: AppColors.gray,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                focusedErrorBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: AppColors.gray,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(15),
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
                                              validator: (value) {
                                                if (emailController
                                                    .text.isEmpty) {
                                                  return '';
                                                } else {}
                                              },
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
                          Positioned(
                            bottom: -30,
                            left: 0,
                            right: 0,
                            child: GestureDetector(
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Material(
                                  elevation: 20,
                                  borderRadius: BorderRadius.circular(55.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(60.0),
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
                              onTap: () async {
                                if (_formKey.currentState!.validate()) {
                                  // emailList = await UserRepository()
                                  //     .getValidationEmails(
                                  //   emailController.text,
                                  // );
                                  if (emailList.email == '') {
                                    setState(() {
                                      final snackBar = SnackBar(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(40),
                                            topRight: Radius.circular(40),
                                          ),
                                        ),
                                        backgroundColor: AppColors.red,
                                        content: Text(
                                          AppStrings.emailNotExist,
                                          style: Styles.advertisingTitle,
                                        ),
                                      );
                                      _scaffolState.currentState!
                                          .showSnackBar(snackBar);
                                    });
                                  } else {
                                    final snackBar = SnackBar(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(40),
                                          topRight: Radius.circular(40),
                                        ),
                                      ),
                                      backgroundColor: AppColors.strongCyan,
                                      content: Text(
                                        AppStrings.checkYourEmail,
                                        style: Styles.advertisingTitle,
                                      ),
                                    );
                                    _scaffolState.currentState!
                                        .showSnackBar(snackBar);
                                    Future.delayed(
                                      Duration(seconds: 3),
                                      () async {
                                        Navigator.push(
                                          context,
                                          new MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                LoginPage(),
                                          ),
                                        );
                                      },
                                    );
                                    // await UserRepository()
                                    //     .sendEmail(emailList.userName);
                                  }
                                } else {
                                  final snackBar = SnackBar(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(40),
                                        topRight: Radius.circular(40),
                                      ),
                                    ),
                                    backgroundColor: AppColors.red,
                                    content: Text(
                                      AppStrings.enterGmail2,
                                      style: Styles.advertisingTitle,
                                    ),
                                  );
                                  _scaffolState.currentState!
                                      .showSnackBar(snackBar);
                                }
                              },
                            ),
                          ),
                        ],
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

  void testAlert(BuildContext context) {
    Scaffold.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.red,
        content: Text(
          AppStrings.checkYourEmail2,
          style: Styles.advertisingTitle,
        ),
      ),
    );
  }
}
