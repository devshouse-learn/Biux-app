import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/config/images.dart';
import 'package:biux/core/config/strings.dart';
import 'package:biux/core/config/styles.dart';
import 'package:biux/features/users/data/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class RecoverPassword extends StatefulWidget {
  @override
  _RecoverPasswordState createState() => _RecoverPasswordState();
}

class _RecoverPasswordState extends State<RecoverPassword> {
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
          backgroundColor: ColorTokens.primary30,
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
                                  color: ColorTokens.neutral100,
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
                                      color: ColorTokens.neutral100,
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
                                                  color: ColorTokens.neutral60,
                                                ),
                                                fillColor: ColorTokens.neutral100,
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: ColorTokens.neutral60,
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
                                                hintText: AppStrings.enterGmail,
                                                errorBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: ColorTokens.neutral60,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                focusedErrorBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: ColorTokens.neutral60,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: ColorTokens.neutral60,
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
                                                } else {
                                                  return null;
                                                }
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
                                            color: ColorTokens.neutral100,
                                            spreadRadius: 10,
                                          )
                                        ]),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: ColorTokens.secondary50,
                                      ),
                                      height: 70,
                                      width: 70,
                                      child: new Stack(
                                        children: <Widget>[
                                          new Center(
                                            child: new Icon(
                                              Icons.arrow_forward,
                                              color: ColorTokens.neutral100,
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
                                        backgroundColor: ColorTokens.error50,
                                        content: Text(
                                          AppStrings.emailNotExist,
                                          style: Styles.advertisingTitle,
                                        ),
                                      );
                                      ScaffoldMessenger.of(context)
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
                                      backgroundColor: ColorTokens.secondary50,
                                      content: Text(
                                        AppStrings.checkYourEmail,
                                        style: Styles.advertisingTitle,
                                      ),
                                    );
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                    Future.delayed(
                                      Duration(seconds: 3),
                                      () async {},
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
                                    backgroundColor: ColorTokens.error50,
                                    content: Text(
                                      AppStrings.enterGmail2,
                                      style: Styles.advertisingTitle,
                                    ),
                                  );
                                  ScaffoldMessenger.of(context)
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: ColorTokens.error50,
        content: Text(
          AppStrings.checkYourEmail2,
          style: Styles.advertisingTitle,
        ),
      ),
    );
  }
}


