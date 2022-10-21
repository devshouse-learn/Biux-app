import 'dart:io';
import 'package:biux/config/colors.dart';
import 'package:biux/config/images.dart';
import 'package:biux/config/router/router_path.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/data/models/city.dart';
import 'package:biux/data/models/response.dart';
import 'package:biux/data/models/user.dart';
import 'package:biux/data/models/analitics.dart';
import 'package:biux/data/repositories/authentication_repository.dart';
import 'package:biux/data/repositories/users/user_firebase_repository.dart';
import 'package:biux/ui/screens/login/create_user/create_user_bloc.dart';
import 'package:biux/ui/widgets/loading_widget.dart';
import 'package:biux/ui/widgets/textField_widget.dart';
import 'package:biux/utils/snackbar_utils.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class CreateUserScreen extends StatelessWidget {
  CreateUserScreen();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnamesController = TextEditingController();
  final TextEditingController cellphoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future getImageFromGallery(CreateUserBloc bloc) async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile pickedFile;
    pickedFile = (await imagePicker.getImage(
      source: ImageSource.gallery,
    ))!;
    File image = File(pickedFile.path);
    if (image != null) {
      bloc.replaceImage(image);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<CreateUserBloc>();
    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      body: ListView(
        children: [
          Form(
            key: _formKey,
            child: Stack(
              children: [
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(Images.kRecordCyclist),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(
                        top: 20,
                        left: 15,
                      ),
                      child: Text(
                        AppStrings.welcomePart1,
                        textAlign: TextAlign.center,
                        style: Styles.wrapDrawerWhite,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                        top: 20,
                        left: 5,
                      ),
                      child: Text(
                        AppStrings.welcomePart2,
                        textAlign: TextAlign.center,
                        style: Styles.stackWhite,
                      ),
                    )
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(
                    top: 45,
                    left: 15,
                  ),
                  child: Text(
                    AppStrings.signUpToRoll,
                    textAlign: TextAlign.center,
                    style: Styles.containerDescription,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 70),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Center(
                          child: Container(
                            height: 600,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 10,
                            ),
                            child: Card(
                              color: AppColors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  16.0,
                                ),
                              ),
                              child: Column(
                                children: [
                                  const SizedBox(
                                    height: 70,
                                  ),
                                  TexFieldWidget(
                                    obscureText: false,
                                    focusNode: FocusNode(),
                                    nameController: nameController,
                                    text: AppStrings.nameText,
                                    icon: Icon(
                                      Icons.person_outline,
                                      color: AppColors.gray,
                                    ),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return value;
                                      }
                                      return null;
                                    },
                                  ),
                                  TexFieldWidget(
                                    obscureText: false,
                                    color: bloc.validateColor1 ==
                                            AppStrings.validatedText
                                        ? AppColors.red
                                        : AppColors.black,
                                    focusNode: FocusNode(),
                                    nameController: userNameController,
                                    text: AppStrings.nameUserText,
                                    icon: Icon(
                                      Icons.pedal_bike_outlined,
                                      color: AppColors.gray,
                                    ),
                                    onChanged: (String value) async {},
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return value;
                                      }
                                      return null;
                                    },
                                  ),
                                  TexFieldWidget(
                                    obscureText: false,
                                    focusNode: FocusNode(),
                                    nameController: emailController,
                                    color: bloc.validateColor2 ==
                                            AppStrings.validatedText
                                        ? AppColors.red
                                        : AppColors.black,
                                    text: AppStrings.correoText,
                                    icon: Icon(
                                      Icons.email,
                                      color: AppColors.gray,
                                    ),
                                    validator: (value) {
                                      if (!value!
                                              .contains(AppStrings.gmailText) &&
                                          !value.contains(
                                              AppStrings.hotmailText) &&
                                          !value.contains(
                                            AppStrings.outlookText,
                                          )) {
                                        return '';
                                      }
                                      if (value.isEmpty) {
                                        return value;
                                      }
                                      return null;
                                    },
                                  ),
                                  TexFieldWidget(
                                    obscureText: false,
                                    keyboardType: TextInputType.number,
                                    focusNode: FocusNode(),
                                    nameController: cellphoneController,
                                    text: AppStrings.phoneText,
                                    icon: Icon(
                                      Icons.phone_outlined,
                                      color: AppColors.gray,
                                    ),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return value;
                                      }
                                      if (value.length != 10) {
                                        return '';
                                      }
                                      return null;
                                    },
                                  ),
                                  Container(
                                    height: 48,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 15,
                                    ),
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 15,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColors.gray,
                                      ),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(15),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.room,
                                          color: AppColors.gray,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: DropdownButton<String>(
                                            value: bloc.dropdownValueCity,
                                            isExpanded: true,
                                            dropdownColor: AppColors.white,
                                            style: Styles.accentTextThemeBlack,
                                            icon: const Icon(
                                              Icons.keyboard_arrow_down,
                                              color: AppColors.gray,
                                            ),
                                            underline: ColoredBox(
                                              color: AppColors.transparent,
                                            ),
                                            elevation: 16,
                                            onChanged: (String? value) {
                                              bloc.replaceDropdownValueCity(
                                                value!,
                                              );
                                            },
                                            items: bloc.listCities
                                                .map<DropdownMenuItem<String>>(
                                              (City value) {
                                                return DropdownMenuItem<String>(
                                                  value: value.name,
                                                  child: Text(value.name),
                                                );
                                              },
                                            ).toList(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  TexFieldWidget(
                                    focusNode: FocusNode(),
                                    nameController: passwordController,
                                    text: AppStrings.passwordText,
                                    icon: Icon(
                                      Icons.lock_outline,
                                      color: AppColors.gray,
                                    ),
                                    iconButton: IconButton(
                                      icon: Icon(
                                        bloc.obscureText
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                      ),
                                      color: AppColors.strongCyan,
                                      onPressed: () => bloc.toggle(),
                                    ),
                                    obscureText: bloc.obscureText,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return value;
                                      }
                                      return null;
                                    },
                                  ),
                                  TexFieldWidget(
                                    focusNode: FocusNode(),
                                    nameController: confirmPasswordController,
                                    text: AppStrings.repeatPassword,
                                    icon: Icon(
                                      Icons.lock_outline,
                                      color: AppColors.gray,
                                    ),
                                    obscureText: bloc.obscureText,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return value;
                                      }
                                      if (value != passwordController.text) {
                                        return '';
                                      }
                                      return null;
                                    },
                                  ),
                                  Theme(
                                    data: ThemeData(
                                      unselectedWidgetColor: AppColors.black,
                                    ),
                                    child: CheckboxListTile(
                                      title: Text(
                                        AppStrings.termsConditions
                                            .toUpperCase(),
                                        style:
                                            Styles.rowGestureDetector.copyWith(
                                          color: AppColors.black,
                                        ),
                                      ),
                                      value: bloc.isChecked,
                                      onChanged: (newValue) {
                                        bloc.changeChecked(newValue!);
                                      },
                                      activeColor: AppColors.strongCyan,
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                    ),
                                  ),
                                  SizedBox(height: 30),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        child: Container(
                          margin: EdgeInsets.only(top: 600),
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
                                  height: 60,
                                  width: 60,
                                  child: Stack(
                                    children: <Widget>[
                                      Center(
                                        child: Icon(
                                          Icons.arrow_forward,
                                          color: AppColors.white,
                                          size: 30,
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
                          if (_formKey.currentState!.validate() &&
                              bloc.image.path != '' &&
                              bloc.isChecked) {
                            bloc.changeLoading(true);
                            City citySeleted = City();
                            bloc.listCities.forEach(
                              (element) {
                                if (element.name == bloc.dropdownValueCity) {
                                  citySeleted = element;
                                }
                              },
                            );
                            createUser(
                              BiuxUser(
                                userName: userNameController.text,
                                modality: [
                                  AppStrings.urbanoText.toLowerCase(),
                                  AppStrings.rutaText.toLowerCase()
                                ],
                                premium: false,
                                cityId: citySeleted,
                                email: emailController.text,
                                fullName: nameController.text,
                                password: passwordController.text,
                                whatsapp: cellphoneController.text,
                              ),
                              bloc,
                              context,
                            );
                          } else {
                            if (!_formKey.currentState!.validate()) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBarUtils.customSnackBar(
                                  content: AppStrings.validationCreateRoadText,
                                  backgroundColor: AppColors.redAccent,
                                ),
                              );
                            } else if (bloc.image.path == '') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBarUtils.customSnackBar(
                                  content: AppStrings.textErrorImageProfile,
                                  backgroundColor: AppColors.redAccent,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBarUtils.customSnackBar(
                                  content:
                                      AppStrings.errorConfirmTermsConditions,
                                  backgroundColor: AppColors.redAccent,
                                ),
                              );
                            }
                          }
                        },
                      ),
                      Align(
                        alignment: Alignment(0.0, 3.8),
                        child: GestureDetector(
                          child: Material(
                            elevation: 20,
                            borderRadius: BorderRadius.circular(55.0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(60.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.white,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.strongCyan,
                                ),
                                height: 100,
                                width: 100,
                                child: bloc.image.path == ''
                                    ? Stack(
                                        children: <Widget>[
                                          GestureDetector(
                                            onTap: () =>
                                                getImageFromGallery(bloc),
                                          ),
                                        ],
                                      )
                                    : InkWell(
                                        child: Container(
                                          alignment: (Alignment(
                                            -1.0,
                                            2.5,
                                          )),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                              const Radius.circular(
                                                80.0,
                                              ),
                                            ),
                                            image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: FileImage(
                                                bloc.image,
                                              ),
                                            ),
                                          ),
                                        ),
                                        onTap: () => getImageFromGallery(bloc),
                                      ),
                              ),
                            ),
                          ),
                          onTap: () => getImageFromGallery(bloc),
                        ),
                      ),
                      Positioned(
                        bottom: 580,
                        left: 86,
                        right: 0,
                        child: GestureDetector(
                          child: Align(
                            alignment: Alignment(0.0, 0.0),
                            child: Material(
                              elevation: 10,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(60.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.white,
                                      spreadRadius: 6,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.camera_alt_outlined,
                                  color: AppColors.strongCyan,
                                  size: 19,
                                ),
                              ),
                            ),
                          ),
                          onTap: () => getImageFromGallery(bloc),
                        ),
                      ),
                    ],
                  ),
                ),
                bloc.loading == true ? Loading() : Container(),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  void createUser(
      BiuxUser user, CreateUserBloc bloc, BuildContext context) async {
    try {
      final userRepeted = await bloc.getValidationUserName(
        userNameController.text,
      );
      if (!userRepeted) {
        bloc.replacevalidateColor1(AppStrings.novalidoText2);
        final ResponseRepo response = await bloc.registerUser(user);
        if (response.message != AppStrings.emailAlreadyUse) {
          bloc.replacevalidateColor2(AppStrings.novalidoText2);
          if (response.statusCode == 200) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBarUtils.customSnackBar(
                content: AppStrings.biuxUserText,
              ),
            );
            String id = response.message;
            Analitycs.sendSignUp(id);
            await bloc.uploadPhoto(id);
            Future.delayed(
              Duration(seconds: 3),
              () async {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.mainMenuRoute,
                  (route) => false,
                );
              },
            );
          } else {
            bloc.changeLoading(false);
            bloc.replacevalidateColor2(AppStrings.validatedText);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBarUtils.customSnackBar(
                content: AppStrings.messageRegisteredGmail(
                  message: response.message,
                ),
                backgroundColor: AppColors.redAccent,
              ),
            );
          }
        } else {
          bloc.changeLoading(false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBarUtils.customSnackBar(
              content: AppStrings.messageRegisteredGmail(
                message: emailController.text,
              ),
              backgroundColor: AppColors.redAccent,
            ),
          );
        }
      } else {
        bloc.changeLoading(false);
        bloc.replacevalidateColor1(AppStrings.validatedText);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBarUtils.customSnackBar(
            content: AppStrings.messageRegisteredUser(
              message: userNameController.text,
            ),
            backgroundColor: AppColors.redAccent,
          ),
        );
      }
    } catch (e) {
      bloc.changeLoading(false);
    }
  }
}
