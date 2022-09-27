import 'package:biux/config/colors.dart';
import 'package:biux/config/images.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/data/models/user.dart';
import 'package:biux/data/repositories/users/user_repository.dart';
import 'package:biux/ui/widgets/loading_widget.dart';
import 'package:biux/ui/widgets/textField_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class SocialNetworksScreen extends StatefulWidget {
  final BiuxUser user;
  SocialNetworksScreen(this.user);
  @override
  _SocialNetworksScreenState createState() => _SocialNetworksScreenState();
}

class _SocialNetworksScreenState extends State<SocialNetworksScreen> {
  late String _instagram;
  late String _facebook;
  late String _cellphone;
  var facebookAuth;
  String instagram = (Images.kInstagramLogo);
  late bool loading = false;
  final _formKey = GlobalKey<FormState>();

  final cellphoneController = TextEditingController();
  final facebookController = TextEditingController();
  final instagramController = TextEditingController();

  void initState() {
    super.initState();
    cellphoneController.text = widget.user.cellphone;
    facebookController.text = widget.user.facebook;
    instagramController.text = widget.user.instagram;
    Future.delayed(
      Duration.zero,
      () async {
        facebookAuth = await FacebookAuth.instance.getUserData();
      },
    );
  }

  List<FocusNode> _focusNodes = [
    FocusNode(),
    FocusNode(),
    FocusNode(),
  ];
  final GlobalKey<ScaffoldState> _scaffolState = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return MaterialApp(
      home: Scaffold(
        key: _scaffolState,
        backgroundColor: AppColors.darkBlue,
        body: Form(
          key: _formKey,
          child: ListView(
            children: [
              Stack(
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20, top: 20),
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
                        margin: EdgeInsets.only(top: 20, left: 10),
                        child: Text(
                          AppStrings.socialNetworks,
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
                                  height: 320,
                                  width: 370,
                                  child: Card(
                                    color: AppColors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: size.width * 0.85,
                                          child: TextFormField(
                                            maxLength: 10,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              FilteringTextInputFormatter.deny(
                                                RegExp(
                                                  r'[@/]',
                                                ),
                                              ),
                                            ],
                                            style: Styles.sizedBox,
                                            controller: cellphoneController,
                                            decoration: InputDecoration(
                                              fillColor: AppColors.white,
                                              enabledBorder: OutlineInputBorder(
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
                                              errorBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: AppColors.gray,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                              hintText: AppStrings.number,
                                              focusedErrorBorder:
                                                  OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: AppColors.gray,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                              prefixIcon: Icon(
                                                Icons.phone,
                                                color: AppColors.gray,
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: AppColors.gray,
                                                ),
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(45),
                                                ),
                                              ),
                                              hintStyle:
                                                  Styles.sizedBoxHintStyle,
                                            ),
                                            validator: (value) {
                                              _cellphone =
                                                  cellphoneController.text;
                                            },
                                          ),
                                        ),
                                        TexFieldWidget(
                                          obscureText: false,
                                          focusNode: _focusNodes[1],
                                          nameController: instagramController,
                                          text: AppStrings.enterYourInstagram,
                                          icon: Image.asset(
                                            instagram,
                                            scale: 30,
                                          ),
                                          validator: (value) {
                                            if (instagramController
                                                .text.isEmpty) {
                                              _instagram = AppStrings.notRegistered;
                                            } else {
                                              _instagram =
                                                  instagramController.text;
                                            }
                                          },
                                        ),
                                        TexFieldWidget(
                                          enabled: facebookAuth != null
                                              ? false
                                              : true,
                                          obscureText: false,
                                          focusNode: _focusNodes[2],
                                          nameController: facebookController,
                                          text: AppStrings.urlFacebook,
                                          icon: Icon(
                                            Icons.facebook,
                                            color: AppColors.gray,
                                          ),
                                          validator: (value) {
                                            if (facebookController
                                                .text.isEmpty) {
                                              _facebook = AppStrings.notRegistered;
                                            } else {
                                              _facebook =
                                                  facebookController.text;
                                            }
                                          },
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
                            margin: EdgeInsets.only(top: 320),
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
                            var userfacebook =
                                await UserRepository().getValidationFacebook(
                              facebookController.text,
                            );
                            if (_formKey.currentState!.validate() &&
                                cellphoneController.text.length == 10) {
                              if (facebookController.text.isEmpty ||
                                  facebookController.text ==
                                      widget.user.facebook ||
                                  facebookController.text.contains(
                                          AppStrings.urlFacebook) &&
                                      userfacebook.facebook == '' ||
                                  userfacebook.facebook ==
                                      widget.user.facebook) {
                                setState(
                                  () {
                                    loading = true;
                                  },
                                );
                                var user = BiuxUser(
                                  cellphone: _cellphone,
                                  id: widget.user.id,
                                  facebook: _facebook,
                                  instagram: _instagram,
                                );

                                /*   await UsuariosRepositorio().actualizarUsuario(
                  usuario,
                );*/
                                Future.delayed(
                                  Duration(seconds: 1),
                                  () {
                                    Navigator.pop(context, user);
                                  },
                                );
                              } else {
                                _showDialog2(facebookController.text !=
                                        AppStrings.urlFacebook
                                    ? AppStrings.enterYourFacebook
                                    : AppStrings.messageRegisteredFacebook(facebook: facebookController.text));
                              }
                            } else {
                              _showDialog2(cellphoneController.text.isEmpty
                                  ? AppStrings.errorEnterYourPhone
                                  : cellphoneController.text.length < 10
                                      ? AppStrings.errorEnterYourPhone2
                                      : '');
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

  void _showDialog2(String response) {
    // flutter defined function
    Future.delayed(
      Duration.zero,
      () {
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
              response,
              style: Styles.advertisingTitle,
            ),
          ),
        );
      },
    );
  }
}
