import 'package:biux/config/colors.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/data/models/user.dart';
import 'package:biux/ui/widgets/loading_widget.dart';
import 'package:biux/ui/widgets/textField_widget.dart';
import 'package:flutter/material.dart';

class PasswordScreen extends StatefulWidget {
  final BiuxUser user;
  PasswordScreen(this.user);
  @override
  _PasswordScreenState createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  late String _password;
  late String _surnames;
  bool obscureText = true;
  late bool loading = false;
  final surnamesController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  List<FocusNode> _focusNodes = [
    FocusNode(),
    FocusNode(),
  ];
  void _toggle() {
    setState(
      () {
        obscureText = !obscureText;
      },
    );
  }

  final GlobalKey<ScaffoldState> _scaffolState = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        key: _scaffolState,
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
                          AppStrings.newPassword,
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
                                          nameController: passwordController,
                                          text: AppStrings.newPassword,
                                          icon: Icon(
                                            Icons.lock,
                                            color: AppColors.gray,
                                          ),
                                          iconButton: IconButton(
                                            icon: Icon(
                                              obscureText
                                                  ? Icons.visibility
                                                  : Icons.visibility_off,
                                            ),
                                            color: obscureText == true
                                                ? AppColors.strongCyan
                                                : AppColors.gray,
                                            onPressed: _toggle,
                                          ),
                                          obscureText: obscureText,
                                        ),
                                        TexFieldWidget(
                                          obscureText: obscureText,
                                          focusNode: _focusNodes[1],
                                          nameController:
                                              confirmPasswordController,
                                          text: AppStrings.repeatPassword,
                                          icon: Icon(
                                            Icons.lock,
                                            color: AppColors.gray,
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
                        GestureDetector(
                          child: Container(
                            margin: EdgeInsets.only(top: 230),
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
                                      ]),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.strongCyan,
                                    ),
                                    height: 70,
                                    width: 70,
                                    child: Stack(
                                      children: <Widget>[
                                        Center(
                                          child: Icon(
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
                          ),
                          onTap: () async {
                            if (passwordController.text.isEmpty ||
                                passwordController.text.length > 7 &&
                                    passwordController.text ==
                                        confirmPasswordController.text) {
                              _password = passwordController.text;
                              setState(
                                () {
                                  loading = true;
                                },
                              );
                              var user = BiuxUser(
                                id: widget.user.id,
                                password: _password,
                              );
                              /*  await UsuariosRepositorio().actualizarUsuario(
                  usuario,
                );*/
                              Future.delayed(
                                Duration(seconds: 1),
                                () {
                                  Navigator.pop(context, user);
                                },
                              );
                            } else {
                              Future.delayed(
                                Duration(seconds: 1),
                                () {
                                  setState(
                                    () {
                                      loading = false;
                                    },
                                  );
                                  _scaffolState.currentState!.showSnackBar(
                                    SnackBar(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(40),
                                          topRight: Radius.circular(40),
                                        ),
                                      ),
                                      backgroundColor: AppColors.red,
                                      content: Text(
                                        passwordController.text.length < 8
                                            ? AppStrings.errorPassword
                                            : passwordController.text !=
                                                    confirmPasswordController
                                                        .text
                                                ? AppStrings.yourPasswordDoesNotMatch2
                                                : '',
                                        style: Styles.advertisingTitle,
                                      ),
                                    ),
                                  );
                                },
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  loading == true ? Loading() : Container(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
