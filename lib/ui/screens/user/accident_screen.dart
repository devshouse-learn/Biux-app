import 'package:biux/config/colors.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/data/models/eps.dart';
import 'package:biux/data/repositories/accidents/accident_repository.dart';
import 'package:biux/ui/widgets/dropdowm_widget.dart';
import 'package:biux/ui/widgets/textField_widget.dart';
import 'package:flutter/material.dart';

class AccidentScreen extends StatefulWidget {
  @override
  _AccidentScreenState createState() => _AccidentScreenState();
}

class _AccidentScreenState extends State<AccidentScreen> {
  var _myActivity;
  var _myActivity2;
  var _myActivity3;
  var _health;
  final healthController = TextEditingController();
  final numberController = TextEditingController();
  final allergiesController = TextEditingController();
  final drugsController = TextEditingController();
  var _darkTheme = true;
  final _formKey = GlobalKey<FormState>();
  List<FocusNode> _focusNodes = [
    FocusNode(),
    FocusNode(),
    FocusNode(),
  ];
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: AppColors.darkBlue,
        body: Form(
          child: ListView(
            children: [
              Stack(
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 20,
                          top: 20,
                        ),
                        child: GestureDetector(
                          child: Icon(
                            Icons.arrow_back,
                            color: AppColors.white,
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      Container(
                        width: 10,
                      ),
                      Container(
                        margin: EdgeInsets.only(
                          top: 20,
                          left: 10,
                        ),
                        child: Text(
                          AppStrings.accidentText,
                          textAlign: TextAlign.center,
                          style: Styles.wrapDrawerWhite,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 65),
                    child: Stack(

                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 50),
                          child: Stack(

                            children: [
                              Center(
                                child: Container(
                                  height: 220,
                                  width: 370,
                                  child: Card(
                                    color: AppColors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        16.0,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        TexFieldWidget(
                                          focusNode: _focusNodes[0],
                                          nameController: healthController,
                                          text: AppStrings.healthEntity,
                                          icon: Icon(
                                            Icons.lock,
                                            color: AppColors.gray,
                                          ),
                                          obscureText: false,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: <Widget>[
                                            // Container(
                                            //   width: 120,
                                            //   decoration: ShapeDecoration(
                                            //     color: AppColors.white,
                                            //     shape: RoundedRectangleBorder(
                                            //       side: BorderSide(
                                            //         color: AppColors.gray,
                                            //         width: 1,
                                            //       ),
                                            //       borderRadius:
                                            //           BorderRadius.all(
                                            //         Radius.circular(45),
                                            //       ),
                                            //     ),
                                            //   ),
                                            //   child: DropDownFormField(
                                            //     hintText:
                                            //         AppStrings.bloodType,
                                            //     value: _myActivity3,
                                            //     onSaved: (value) {
                                            //       setState(
                                            //         () {
                                            //           _myActivity3 = value;
                                            //         },
                                            //       );
                                            //     },
                                            //     onChanged: (value) {
                                            //       setState(
                                            //         () {
                                            //           _myActivity3 = value;
                                            //         },
                                            //       );
                                            //     },
                                            //     filled: false,
                                            //     dataSource: [
                                            //       {
                                            //         AppStrings.displayText: "     ${AppStrings.o}",
                                            //         AppStrings.valueText: AppStrings.o.toUpperCase(),
                                            //       },
                                            //       {
                                            //         AppStrings.displayText: "     ${AppStrings.o2}",
                                            //         AppStrings.valueText: AppStrings.o2.toUpperCase(),
                                            //       },
                                            //       {
                                            //         AppStrings.displayText: "     ${AppStrings.a}",
                                            //         AppStrings.valueText: AppStrings.a.toUpperCase(),
                                            //       },
                                            //       {
                                            //         AppStrings.displayText: "     ${AppStrings.a2}",
                                            //         AppStrings.valueText: AppStrings.a2.toUpperCase(),
                                            //       },
                                            //       {
                                            //         AppStrings.displayText: "     ${AppStrings.a3}",
                                            //         AppStrings.valueText: AppStrings.a3.toUpperCase(),
                                            //       },
                                            //     ],
                                            //     textField: AppStrings.displayText,
                                            //     valueField: AppStrings.valueText,
                                            //   ),
                                            // ),
                                            SizedBox(
                                              width: 170,
                                              child: TextFormField(
                                                decoration: InputDecoration(
                                                  fillColor: AppColors.white,
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: AppColors.gray,
                                                      width: 1,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      45,
                                                    ),
                                                  ),
                                                  filled: true,
                                                  contentPadding:
                                                      EdgeInsets.fromLTRB(
                                                    10.0,
                                                    15.0,
                                                    20.0,
                                                    15.0,
                                                  ),
                                                  hintText: AppStrings.number2,
                                                  errorBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: AppColors.gray,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      15,
                                                    ),
                                                  ),
                                                  focusedErrorBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: AppColors.gray,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      15,
                                                    ),
                                                  ),
                                                  prefixIcon: Icon(
                                                    Icons.phone_android,
                                                    size: 30,
                                                    color: AppColors.gray,
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
                                              ),
                                            ),
                                            TexFieldWidget(
                                              focusNode: _focusNodes[1],
                                              nameController:
                                                  allergiesController,
                                              text: AppStrings.enterYourAllergies,
                                              icon: Icon(
                                                Icons.lock,
                                                color: AppColors.gray,
                                              ),
                                              obscureText: false,
                                            ),
                                            TexFieldWidget(
                                              focusNode: _focusNodes[2],
                                              nameController: drugsController,
                                              text:
                                                  AppStrings.healthEntity,
                                              icon: Icon(
                                                Icons.lock,
                                                color: AppColors.gray,
                                              ),
                                              obscureText: false,
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
                                    borderRadius: BorderRadius.circular(60.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.white,
                                        spreadRadius: 10,
                                      )
                                    ],
                                  ),
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
                              _health = healthController.text;
                              var eps = Eps(
                                id: '58',
                                name: AppStrings.epsTest,
                              );

                              await AccidentRepository()
                                  .sendDatesAccident(_health);
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
    );
  }
}
