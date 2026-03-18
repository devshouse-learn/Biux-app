import 'dart:io';

import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/config/images.dart';
import 'package:biux/core/config/router/app_routes.dart';
import 'package:biux/core/config/strings.dart';
import 'package:biux/core/config/styles.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:go_router/go_router.dart';
// import 'package:biux/data/models/analitics.dart'; // IMPLEMENTADO (STUB): Migrate analytics
import 'package:biux/features/cities/data/models/city.dart';
import 'package:biux/core/models/common/response.dart';
import 'package:biux/features/users/data/models/user.dart';
import 'create_user_bloc.dart';
import 'package:biux/shared/widgets/loading_widget.dart';
import 'package:biux/shared/widgets/text_field_widget.dart';
import 'package:biux/core/utils/snackbar_utils.dart';
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
    final ImagePicker picker = ImagePicker();

    // pickImage devuelve un XFile?
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      final File image = File(pickedFile.path);
      bloc.replaceImage(image);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<CreateUserBloc>();
    final l = Provider.of<LocaleNotifier>(context);
    return Scaffold(
      backgroundColor: ColorTokens.primary30,
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
                      margin: const EdgeInsets.only(top: 20, left: 15),
                      child: Text(
                        l.t('welcome_part_1'),
                        textAlign: TextAlign.center,
                        style: Styles.wrapDrawerWhite,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 20, left: 5),
                      child: Text(
                        'BIUX',
                        textAlign: TextAlign.center,
                        style: Styles.stackWhite,
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(top: 45, left: 15),
                  child: Text(
                    l.t('sign_up_to_roll'),
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
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            child: Card(
                              color: ColorTokens.neutral100,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Column(
                                children: [
                                  const SizedBox(height: 70),
                                  TexFieldWidget(
                                    obscureText: false,
                                    focusNode: FocusNode(),
                                    nameController: nameController,
                                    text: l.t('full_name'),
                                    icon: Icon(
                                      Icons.person_outline,
                                      color: ColorTokens.neutral60,
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
                                    color:
                                        bloc.validateColor1 ==
                                            AppStrings.validatedText
                                        ? ColorTokens.error50
                                        : ColorTokens.neutral0,
                                    focusNode: FocusNode(),
                                    nameController: userNameController,
                                    text: l.t('username'),
                                    icon: Icon(
                                      Icons.pedal_bike_outlined,
                                      color: ColorTokens.neutral60,
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
                                    color:
                                        bloc.validateColor2 ==
                                            AppStrings.validatedText
                                        ? ColorTokens.error50
                                        : ColorTokens.neutral0,
                                    text: l.t('email_label'),
                                    icon: Icon(
                                      Icons.email,
                                      color: ColorTokens.neutral60,
                                    ),
                                    validator: (value) {
                                      if (!value!.contains(
                                            AppStrings.gmailText,
                                          ) &&
                                          !value.contains(
                                            AppStrings.hotmailText,
                                          ) &&
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
                                    text: l.t('phone_label'),
                                    icon: Icon(
                                      Icons.phone_outlined,
                                      color: ColorTokens.neutral60,
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
                                        color: ColorTokens.neutral60,
                                      ),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(15),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.room,
                                          color: ColorTokens.neutral60,
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: DropdownButton<String>(
                                            value: bloc.dropdownValueCity,
                                            isExpanded: true,
                                            dropdownColor:
                                                ColorTokens.neutral100,
                                            style: Styles.accentTextThemeBlack,
                                            icon: const Icon(
                                              Icons.keyboard_arrow_down,
                                              color: ColorTokens.neutral60,
                                            ),
                                            underline: ColoredBox(
                                              color: ColorTokens.transparent,
                                            ),
                                            elevation: 16,
                                            onChanged: (String? value) {
                                              bloc.replaceDropdownValueCity(
                                                value!,
                                              );
                                            },
                                            items: bloc.listCities
                                                .map<DropdownMenuItem<String>>((
                                                  City value,
                                                ) {
                                                  return DropdownMenuItem<
                                                    String
                                                  >(
                                                    value: value.name,
                                                    child: Text(value.name),
                                                  );
                                                })
                                                .toList(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  TexFieldWidget(
                                    focusNode: FocusNode(),
                                    nameController: passwordController,
                                    text: l.t('password_label'),
                                    icon: Icon(
                                      Icons.lock_outline,
                                      color: ColorTokens.neutral60,
                                    ),
                                    iconButton: IconButton(
                                      icon: Icon(
                                        bloc.obscureText
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                      ),
                                      color: ColorTokens.secondary50,
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
                                    text: l.t('repeat_password'),
                                    icon: Icon(
                                      Icons.lock_outline,
                                      color: ColorTokens.neutral60,
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
                                      unselectedWidgetColor:
                                          ColorTokens.neutral0,
                                    ),
                                    child: CheckboxListTile(
                                      title: Text(
                                        l.t('terms_accept').toUpperCase(),
                                        style: Styles.rowGestureDetector
                                            .copyWith(
                                              color: ColorTokens.neutral0,
                                            ),
                                      ),
                                      value: bloc.isChecked,
                                      onChanged: (newValue) {
                                        bloc.changeChecked(newValue!);
                                      },
                                      fillColor:
                                          WidgetStateProperty.resolveWith<
                                            Color
                                          >((Set<WidgetState> states) {
                                            if (states.contains(
                                              WidgetState.selected,
                                            )) {
                                              return ColorTokens.secondary50;
                                            }
                                            return ColorTokens.neutral0;
                                          }),
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
                                      color: ColorTokens.neutral100,
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: ColorTokens.secondary50,
                                  ),
                                  height: 60,
                                  width: 60,
                                  child: Stack(
                                    children: <Widget>[
                                      Center(
                                        child: Icon(
                                          Icons.arrow_forward,
                                          color: ColorTokens.neutral100,
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
                            bloc.listCities.forEach((element) {
                              if (element.name == bloc.dropdownValueCity) {
                                citySeleted = element;
                              }
                            });
                            createUser(
                              BiuxUser(
                                userName: userNameController.text,
                                modality: [
                                  l.t('urban').toLowerCase(),
                                  l.t('route').toLowerCase(),
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
                                  content: l.t('must_complete_all_fields'),
                                  backgroundColor: ColorTokens.error50,
                                ),
                              );
                            } else if (bloc.image.path == '') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBarUtils.customSnackBar(
                                  content: l.t('profile_image_not_selected'),
                                  backgroundColor: ColorTokens.error50,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBarUtils.customSnackBar(
                                  content: l.t('accept_terms_to_continue'),
                                  backgroundColor: ColorTokens.error50,
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
                                    color: ColorTokens.neutral100,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: ColorTokens.secondary50,
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
                                          alignment: (Alignment(-1.0, 2.5)),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                              const Radius.circular(80.0),
                                            ),
                                            image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: FileImage(bloc.image),
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
                                      color: ColorTokens.neutral100,
                                      spreadRadius: 6,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.camera_alt_outlined,
                                  color: ColorTokens.secondary50,
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
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void createUser(
    BiuxUser user,
    CreateUserBloc bloc,
    BuildContext context,
  ) async {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
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
              SnackBarUtils.customSnackBar(content: l.t('now_biux_user')),
            );
            String id = response.message;
            // Analitycs.sendSignUp(id); // IMPLEMENTADO (STUB): Migrate analytics
            await bloc.uploadPhoto(id);
            Future.delayed(Duration(seconds: 3), () async {
              if (context.mounted) {
                context.go(AppRoutes.mainMenu);
              }
            });
          } else {
            bloc.changeLoading(false);
            bloc.replacevalidateColor2(AppStrings.validatedText);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBarUtils.customSnackBar(
                content: l
                    .t('email_already_registered')
                    .replaceAll('{email}', response.message),
                backgroundColor: ColorTokens.error50,
              ),
            );
          }
        } else {
          bloc.changeLoading(false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBarUtils.customSnackBar(
              content: l
                  .t('email_already_registered')
                  .replaceAll('{email}', emailController.text),
              backgroundColor: ColorTokens.error50,
            ),
          );
        }
      } else {
        bloc.changeLoading(false);
        bloc.replacevalidateColor1(AppStrings.validatedText);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBarUtils.customSnackBar(
            content: l
                .t('username_already_registered')
                .replaceAll('{username}', userNameController.text),
            backgroundColor: ColorTokens.error50,
          ),
        );
      }
    } catch (e) {
      bloc.changeLoading(false);
    }
  }
}
