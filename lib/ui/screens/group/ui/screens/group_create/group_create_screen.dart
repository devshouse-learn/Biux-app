import 'dart:io';

import 'package:biux/config/colors.dart';
import 'package:biux/config/images.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/data/models/group.dart';
import 'package:biux/data/models/user.dart';
import 'package:biux/data/repositories/groups/groups_firebase_repository.dart';
import 'package:biux/ui/screens/group/ui/screens/group_create/group_create_BLOC.dart';
import 'package:biux/ui/screens/story/ui/screens/upload_page.dart';
import 'package:biux/ui/widgets/button_continue_biux_widget.dart';
import 'package:biux/ui/widgets/logo_biux_widget.dart';
import 'package:biux/ui/widgets/profile_cover_biux_widget.dart';
import 'package:biux/ui/widgets/text_form_field_biux_widget.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class GroupCreateScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffolState = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    final bloc = context.read<GroupCreateBloc>();
    return Scaffold(
      key: _scaffolState,
      backgroundColor: AppColors.darkBlue,
      body: Form(
          key: _formKey,
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(Images.kBackground),
                fit: BoxFit.cover,
              ),
            ),
            child: ListView(children: <Widget>[
              Stack(
                children: [
                  Selector<GroupCreateBloc, File?>(
                      selector: (_, bloc) => bloc.imageProfileCover,
                      builder: (context, imageProfileCover, child) {
                        return ProfileCoverBiuxWidget(
                          getProfileCover: () => bloc.getImageProfileCover,
                          imageProfileCover: imageProfileCover,
                        );
                      }),
                  _FormGroupWidget(),
                  ButtonContinueBiuxWidget(
                    onPressed: () => bloc.uploadGroup,
                  ),
                  Selector<GroupCreateBloc, File?>(
                      selector: (_, bloc) => bloc.imageLogo,
                      builder: (context, imageLogo, child) {
                        return LogoBiuxWidget(
                          getImage: () => bloc.getImageLogo,
                          imageLogo: imageLogo,
                        );
                      }),
                ],
              )
            ]),
          )),
    );
  }
}

class _FormGroupWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = context.read<GroupCreateBloc>();
    return Padding(
      padding: const EdgeInsets.only(top: 150),
      child: Center(
        child: Container(
          height: 560,
          width: 380,
          child: Card(
            color: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(padding: EdgeInsets.only(top: 20)),
                  GroupCreateTextFormFieldWidget(
                    controller: bloc.nameController,
                    text: AppStrings.nameText,
                  ),
                  GroupCreateTextFormFieldWidget(
                    controller: bloc.whatsappController,
                    text: AppStrings.WhatsappText,
                  ),
                  GroupCreateTextFormFieldWidget(
                    controller: bloc.ciudadController,
                    text: AppStrings.cityText,
                  ),
                  GroupCreateTextFormFieldWidget(
                    controller: bloc.facebookController,
                    text: AppStrings.facebookText,
                  ),
                  GroupCreateTextFormFieldWidget(
                    controller: bloc.instagramController,
                    text: AppStrings.instagramText,
                  ),
                  SizedBox(
                    height: 120,
                    child: GroupCreateTextFormFieldWidget(
                      maxLine: 5,
                      controller: bloc.descripcionController,
                      text: AppStrings.descriptionText,
                      radiusCircular: 30,
                    ),
                  ),
                ]),
          ),
        ),
      ),
    );
  }
}
