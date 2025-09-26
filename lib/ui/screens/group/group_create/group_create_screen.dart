import 'dart:io';

import 'package:biux/config/colors.dart';
import 'package:biux/config/images.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/ui/screens/group/group_create/group_create_bloc.dart';
import 'package:biux/ui/widgets/logo_biux_widget.dart';
import 'package:biux/ui/widgets/text_form_field_biux_widget.dart';
import 'package:biux/utils/snackbar_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupCreateScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffolState = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    final bloc = context.read<GroupCreateBloc>();
    return Scaffold(
      key: _scaffolState,
      backgroundColor: AppColors.white,
      body: Form(
          key: _formKey,
          child: ListView(children: <Widget>[
            Stack(
              children: [
                _FormGroupWidget(form: _formKey),
                Selector<GroupCreateBloc, File?>(
                    selector: (_, bloc) => bloc.imageLogo,
                    builder: (context, imageLogo, child) {
                      return LogoBiuxWidget(
                        getImage: () => bloc.getImageLogo,
                        imageLogo: imageLogo,
                        left: 130,
                        top: 20,
                      );
                    }),
              ],
            )
          ])),
    );
  }
}

class _FormGroupWidget extends StatelessWidget {
  GlobalKey<FormState> form;
  _FormGroupWidget({Key? key, required this.form}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final bloc = context.read<GroupCreateBloc>();
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Center(
        child: Container(
          height: 600,
          width: 350,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Card(
            color: AppColors.white,
            shadowColor: AppColors.gray,
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Column(children: <Widget>[
              Padding(padding: EdgeInsets.only(top: 70)),
              TextFormFieldBiuxWidget(
                controller: bloc.nameController,
                text: AppStrings.groupNameText,
                image: Image.asset(Images.kImageSocial,
                    scale: 4, color: AppColors.gray),
                validator: (value) {
                  if (value!.isEmpty) {
                    return '';
                  }
                  return null;
                },
              ),
              TextFormFieldBiuxWidget(
                controller: bloc.facebookController,
                text: AppStrings.linkFacebook,
                image: Image.asset(
                  Images.kImageIconFacebook,
                  height: 1,
                  scale: 4,
                  color: AppColors.gray,
                ),
              ),
              TextFormFieldBiuxWidget(
                controller: bloc.whatsappController,
                text: AppStrings.WhatsappText,
                image: Image.asset(
                  Images.kImageIconWhatsapp,
                  scale: 4,
                  color: AppColors.gray,
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return '';
                  }
                  return null;
                },
              ),
              TextFormFieldBiuxWidget(
                controller: bloc.instagramController,
                text: AppStrings.instagramText,
                image: Image.asset(
                  Images.kImageIconInstagram,
                  scale: 4,
                  color: AppColors.gray,
                ),
              ),
              SizedBox(
                height: 120,
                child: TextFormFieldBiuxWidget(
                  maxLine: 5,
                  controller: bloc.descripcionController,
                  text: AppStrings.descriptionText,
                  radiusCircular: 15,
                  maxLength: 300,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return '';
                    }
                    return null;
                  },
                ),
              ),
              _SelectorPublic(),
              _BotonSend(
                form: form,
              )
            ]),
          ),
        ),
      ),
    );
  }
}

class _SelectorPublic extends StatelessWidget {
  _SelectorPublic({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<GroupCreateBloc>();
    return Padding(
      padding: const EdgeInsets.only(left: 30),
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              bloc.onTapValidator(AppStrings.public);
            },
            child: Row(children: <Widget>[
              if (bloc.publicValidator == true)
                Image.asset(
                  Images.kSelectedBlackImage,
                  scale: 4,
                )
              else
                Image.asset(
                  Images.kDeselectedBlackImage,
                  scale: 4,
                ),
              const SizedBox(
                width: 5,
              ),
              Text(
                AppStrings.public,
                style: Styles.containerTextGroup,
              )
            ]),
          ),
          const SizedBox(
            width: 30,
          ),
          GestureDetector(
            onTap: () {
              bloc.onTapValidator(AppStrings.private);
            },
            child: Row(children: <Widget>[
              if (bloc.publicValidator == false)
                Image.asset(
                  Images.kSelectedBlackImage,
                  scale: 4,
                )
              else
                Image.asset(
                  Images.kDeselectedBlackImage,
                  scale: 4,
                ),
              const SizedBox(
                width: 5,
              ),
              Text(
                AppStrings.private,
                style: Styles.containerTextGroup,
              )
            ]),
          ),
        ],
      ),
    );
  }
}

class _BotonSend extends StatelessWidget {
  GlobalKey<FormState> form;
  _BotonSend({Key? key, required this.form}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<GroupCreateBloc>();
    return Column(
      children: <Widget>[
        ButtonTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          minWidth: 220,
          height: 40,
          child: ElevatedButton(
              //color: AppColors.white,
              child: Text(AppStrings.cancelText, style: Styles.textLightBlack),
              onPressed: () {
                bloc.onTapPop(context);
              }),
        ),
        ButtonTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          minWidth: 220,
          height: 40,
          child: ElevatedButton(
              // color: AppColors.strongCyan,
              child:
                  Text(AppStrings.create, style: Styles.daysRoadListDateTime),
              onPressed: () {
                if (form.currentState!.validate() &&
                    bloc.imageLogo != null &&
                    bloc.publicValidator != null)
                  bloc.uploadGroup(context);
                else
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBarUtils.customSnackBar(
                        content: bloc.imageLogo == null
                            ? AppStrings.missingLogo
                            : bloc.nameController.text.isEmpty
                                ? AppStrings.missingNameGroup
                                : bloc.whatsappController.text.isEmpty
                                    ? AppStrings.missingWhatssap
                                    : bloc.whatsappController.text.length != 10
                                        ? AppStrings.missingWhatssapLength
                                        : bloc.descripcionController.text
                                                .isEmpty
                                            ? AppStrings.missingDescription
                                            : bloc.publicValidator == null
                                                ? AppStrings
                                                    .missingValidatorPublic
                                                : '',
                        backgroundColor: AppColors.red),
                  );
              }),
        )
      ],
    );
  }
}
