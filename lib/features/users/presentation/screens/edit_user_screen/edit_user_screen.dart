import 'dart:io';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/config/images.dart';
import 'package:biux/core/config/strings.dart';
import 'package:biux/core/config/styles.dart';
import 'package:biux/features/cities/data/models/city.dart';
import 'package:biux/features/users/presentation/screens/edit_user_screen/edit_user_screen_bloc.dart';
import 'package:biux/shared/widgets/text_form_field_biux_widget.dart';
import 'package:biux/shared/services/optimized_cache_manager.dart';
import 'package:biux/core/utils/snackbar_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserEditScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffolState = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<EditUserScreenBloc>();
    return Scaffold(
      key: _scaffolState,
      backgroundColor: ColorTokens.neutral100,
      appBar: AppBar(
        backgroundColor: ColorTokens.primary30,
        title: Text(AppStrings.editProfile, style: Styles.containerNameUser),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: <Widget>[
            Stack(
              children: [
                if (bloc.focusNodeCity.hasFocus)
                  _ListCity(listCities: bloc.listCities)
                else ...[
                  _FormGroupWidget(form: _formKey),
                  Selector<EditUserScreenBloc, File?>(
                    selector: (_, bloc) => bloc.imageNew,
                    builder: (context, imageLogo, child) {
                      return _LogoBiuxWidget();
                    },
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FormGroupWidget extends StatelessWidget {
  final GlobalKey<FormState> form;
  _FormGroupWidget({Key? key, required this.form}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final bloc = context.read<EditUserScreenBloc>();
    return Padding(
      padding: const EdgeInsets.only(top: 70),
      child: Center(
        child: Container(
          height: 630,
          width: 350,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16.0)),
          child: Card(
            color: ColorTokens.neutral100,
            shadowColor: ColorTokens.neutral60,
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Column(
              children: <Widget>[
                Padding(padding: EdgeInsets.only(top: 70)),
                TextFormFieldBiuxWidget(
                  maxLine: 1,
                  controller: bloc.nameController,
                  text: AppStrings.nameText,
                  image: Image.asset(
                    Images.kImageSocial,
                    scale: 4,
                    color: ColorTokens.neutral60,
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return value;
                    }
                    return null;
                  },
                ),
                TextFormFieldBiuxWidget(
                  maxLine: 1,
                  enabled: false,
                  controller: bloc.nameUserController,
                  text: AppStrings.nameUserText,
                  image: Image.asset(
                    Images.kImageIconFacebook,
                    height: 1,
                    scale: 4,
                    color: ColorTokens.neutral60,
                  ),
                ),
                TextFormFieldBiuxWidget(
                  maxLine: 1,
                  enabled: false,
                  controller: bloc.correoController,
                  text: AppStrings.gmail,
                  image: SizedBox(
                    width: 5,
                    child: Image.asset(
                      Images.kImageLetterGrey,
                      scale: 4,
                      color: ColorTokens.neutral60,
                    ),
                  ),
                ),
                TextFormFieldBiuxWidget(
                  maxLine: 1,
                  controller: bloc.numberController,
                  text: AppStrings.numberText,
                  image: Image.asset(
                    Images.kImagePhone,
                    scale: 4,
                    color: ColorTokens.neutral60,
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return value;
                    }
                    return null;
                  },
                ),
                _WidgetSearchCity(),
                SizedBox(
                  height: 120,
                  child: TextFormFieldBiuxWidget(
                    maxLine: 5,
                    controller: bloc.descripcionController,
                    text: AppStrings.descriptionText,
                    radiusCircular: 15,
                    maxLength: 200,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return value;
                      }
                      return null;
                    },
                  ),
                ),
                _BotonSend(form: form),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BotonSend extends StatelessWidget {
  final GlobalKey<FormState> form;
  _BotonSend({Key? key, required this.form}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<EditUserScreenBloc>();
    return Column(
      children: <Widget>[
        ElevatedButtonTheme(
          data: ElevatedButtonThemeData(
            style: ButtonStyle(
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
              ),
              padding: WidgetStateProperty.all(
                EdgeInsets.only(left: 80, right: 80),
              ),
            ),
          ),
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(
                ColorTokens.neutral100,
              ),
            ),
            child: Text(AppStrings.cancelText, style: Styles.textLightBlack),
            onPressed: () {
              bloc.onTapPop(context);
            },
          ),
        ),
        ElevatedButtonTheme(
          data: ElevatedButtonThemeData(
            style: ButtonStyle(
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
              ),
              padding: WidgetStateProperty.all(
                EdgeInsets.only(left: 70, right: 70),
              ),
            ),
          ),
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(
                ColorTokens.secondary50,
              ),
            ),
            child: Text(AppStrings.update, style: Styles.daysRoadListDateTime),
            onPressed: () async {
              if (form.currentState!.validate()) {
                bloc.uploadUpdate(context);
                bloc.onTapPop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBarUtils.customSnackBar(
                    content: AppStrings.userUpdate,
                    backgroundColor: ColorTokens.secondary50,
                  ),
                );
              } else
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBarUtils.customSnackBar(
                    content:
                        bloc.nameController.text.isEmpty
                            ? AppStrings.fullNameIsEmpty
                            : bloc.numberController.text.isEmpty
                            ? AppStrings.numberIsEmpty
                            : bloc.cityController.text.isEmpty
                            ? AppStrings.cityIsEmpty
                            : bloc.descripcionController.text.isEmpty
                            ? AppStrings.descritionIsEmpty
                            : '',
                    backgroundColor: ColorTokens.error50,
                  ),
                );
            },
          ),
        ),
      ],
    );
  }
}

class _LogoBiuxWidget extends StatelessWidget {
  _LogoBiuxWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<EditUserScreenBloc>();
    return Stack(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(top: 10, left: 130),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(60.0),
            boxShadow: [
              BoxShadow(color: ColorTokens.neutral100, spreadRadius: 3),
            ],
          ),
          child: GestureDetector(
            onTap: bloc.getImageLogo,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ColorTokens.secondary50,
              ),
              height: 120,
              width: 120,
              child:
                  bloc.imageNew == null
                      ? Container(
                        alignment: (Alignment(-1.0, 2.5)),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: ColorTokens.neutral100,
                            width: 4,
                          ),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: CachedNetworkImageProvider(
                              bloc.user.photo,
                              cacheManager:
                                  OptimizedCacheManager.avatarInstance,
                            ),
                          ),
                          borderRadius: BorderRadius.all(
                            const Radius.circular(80.0),
                          ),
                        ),
                      )
                      : Container(
                        alignment: (Alignment(-1.0, 2.5)),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: FileImage(bloc.imageNew),
                          ),
                          borderRadius: BorderRadius.all(
                            const Radius.circular(80.0),
                          ),
                        ),
                      ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 100, left: 210),
          child: GestureDetector(
            child: Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(60.0),
                color: ColorTokens.primary30,
                boxShadow: [
                  BoxShadow(blurRadius: 1.0, color: ColorTokens.neutral0),
                ],
              ),
              child: const Icon(
                Icons.add,
                color: ColorTokens.neutral100,
                size: 25,
              ),
            ),
            onTap: bloc.getImageLogo,
          ),
        ),
      ],
    );
  }
}

class _WidgetSearchCity extends StatelessWidget {
  _WidgetSearchCity({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<EditUserScreenBloc>();
    return Container(
      width: 350,
      margin: EdgeInsets.only(top: 5, left: 15, right: 15, bottom: 5),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(80),
        border: Border.all(color: ColorTokens.neutral60, width: 1),
      ),
      child: TextFormField(
        controller: bloc.cityController,
        onTap: bloc.setState,
        style: Styles.textLightBlack,
        focusNode: bloc.focusNodeCity,
        onChanged: (value) {
          bloc.filterCities();
        },
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(10.0, 15.0, 20.0, 15.0),
          border: InputBorder.none,
          hintText: AppStrings.cityText,
          hintStyle: Styles.TextSearch,
          prefixIcon: Image.asset(
            Images.kImageLocationGrey,
            height: 10,
            scale: 3.0,
          ),
          suffixIcon:
              bloc.focusNodeCity.hasFocus
                  ? IconButton(
                    icon: Icon(Icons.close, color: ColorTokens.neutral60),
                    onPressed: () {
                      bloc.getCities();
                      bloc.focusNodeCity.unfocus();
                      bloc.setState();
                    },
                  )
                  : SizedBox(),
        ),
      ),
    );
  }
}

class _ListCity extends StatelessWidget {
  final List<City> listCities;
  _ListCity({Key? key, required this.listCities}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<EditUserScreenBloc>();
    return Container(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: _WidgetSearchCity(),
          ),
          ListTile(
            contentPadding: EdgeInsets.only(left: 25),
            horizontalTitleGap: 0,
            minLeadingWidth: 36,
            iconColor: ColorTokens.neutral0,
            leading: Image.asset(Images.kImageLocation2, height: 20),
            title: Text(AppStrings.currentLocation, style: Styles.TextCityList),
            onTap: () {},
          ),
          Divider(color: ColorTokens.neutral60, height: 1),
          SingleChildScrollView(
            child: Wrap(
              children:
                  listCities
                      .map(
                        (city) => Column(
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.only(left: 60),
                              title: Text(
                                city.name,
                                style: Styles.TextCityList,
                              ),
                              onTap: () {
                                bloc.onTapCities(city.name, city.id);
                              },
                            ),
                            Divider(color: ColorTokens.neutral60, height: 1),
                          ],
                        ),
                      )
                      .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
