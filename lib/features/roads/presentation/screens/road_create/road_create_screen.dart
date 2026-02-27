import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/config/images.dart';
import 'package:biux/core/config/router/app_routes.dart';
import 'package:biux/core/config/strings.dart';
import 'package:biux/core/config/styles.dart';
import 'package:biux/features/cities/data/models/city.dart';
import 'package:biux/features/roads/data/models/road.dart';
import 'package:biux/core/utils/datetime_utils.dart';
import 'package:biux/core/utils/snackbar_utils.dart';
import 'package:biux/features/roads/presentation/screens/road_create/road_create_bloc.dart';
import 'package:biux/shared/widgets/text_form_field_biux_widget.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';

class RoadCreateScreen extends StatelessWidget {
  RoadCreateScreen({Key? key}) : super(key: key);
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController controllerRouteName = TextEditingController();
  final TextEditingController controllerMeetingPoint = TextEditingController();
  final TextEditingController controllerGeolocationPoint =
      TextEditingController();
  final TextEditingController controllerDateTime = TextEditingController();
  final TextEditingController controllerDescriptionRecomendations =
      TextEditingController();
  final TextEditingController controllerDistance = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final sizeScreen = MediaQuery.of(context).size;
    final bloc = context.watch<RoadCreateBloc>();
    return Scaffold(
      backgroundColor: ColorTokens.neutral100,
      appBar: AppBar(
        backgroundColor: ColorTokens.primary30,
        centerTitle: true,
        title: Text(AppStrings.createRoadText, style: Styles.mainMenuTextBiux),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: sizeScreen.width * 0.8,
            height: sizeScreen.height * 0.8,
            decoration: BoxDecoration(
              color: ColorTokens.neutral100,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: ColorTokens.neutral60.withValues(alpha: 0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  const SizedBox(height: 10),
                  TextFormFieldBiuxWidget(
                    controller: controllerRouteName,
                    text: AppStrings.routeNameText,
                    radiusCircular: 15,
                    fontSize: 15,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return value;
                      }
                      return null;
                    },
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Image.asset(Images.kRouteNameImage, height: 15),
                    ),
                  ),
                  TextFormFieldBiuxWidget(
                    controller: controllerMeetingPoint,
                    text: AppStrings.meetingPointText,
                    radiusCircular: 15,
                    fontSize: 15,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return value;
                      }
                      return null;
                    },
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Image.asset(Images.kPointMeetingImage, height: 15),
                    ),
                  ),
                  TextFormFieldBiuxWidget(
                    controller: controllerGeolocationPoint,
                    text: AppStrings.geolocationPointText,
                    readOnly: true,
                    radiusCircular: 15,
                    fontSize: 15,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return value;
                      }
                      return null;
                    },
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Image.asset(Images.kLocationGreyImage, height: 15),
                    ),
                    onTap: () async {
                      final result = await Navigator.pushNamed(
                        context,
                        AppRoutes.roadMapName,
                      );
                      if (result != null) {
                        final locationData = result as LocationData;
                        controllerGeolocationPoint.text =
                            '${locationData.latitude},${locationData.longitude}';
                      }
                    },
                  ),
                  Container(
                    height: 48,
                    padding: const EdgeInsets.only(left: 5),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: ColorTokens.neutral60),
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                    child: Row(
                      children: [
                        Image.asset(Images.kImageCity, height: 30),
                        SizedBox(width: 10),
                        Expanded(
                          child: DropdownButton<String>(
                            value: bloc.dropdownValueCity.name,
                            isExpanded: true,
                            dropdownColor: ColorTokens.neutral100,
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
                              bloc.replaceDropdownValueCity(value!);
                            },
                            items: bloc.listCities
                                .map<DropdownMenuItem<String>>((City value) {
                                  return DropdownMenuItem<String>(
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
                  TextFormFieldBiuxWidget(
                    controller: controllerDistance,
                    text: AppStrings.distanceText,
                    keyboardType: TextInputType.number,
                    radiusCircular: 15,
                    fontSize: 15,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return value;
                      }
                      return null;
                    },
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Image.asset(Images.kImageDistance, height: 15),
                    ),
                  ),
                  TextFormFieldBiuxWidget(
                    controller: controllerDateTime,
                    text: AppStrings.dateTimeText,
                    radiusCircular: 15,
                    fontSize: 15,
                    readOnly: true,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return value;
                      }
                      return null;
                    },
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Image.asset(Images.kDateTimeImage, height: 10),
                    ),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2022),
                        lastDate: DateTime(2100),
                      );
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (pickedDate != null && picked != null) {
                        controllerDateTime.text =
                            '${pickedDate.dateTimeformatterNative(picked)}';
                      }
                    },
                  ),
                  TextFormFieldBiuxWidget(
                    controller: controllerDescriptionRecomendations,
                    text: AppStrings.descriptionRecomendationsText,
                    radiusCircular: 15,
                    fontSize: 15,
                    maxLine: 4,
                    maxLength: 700,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return value;
                      }
                      return null;
                    },
                    padding: const EdgeInsets.only(
                      left: 15,
                      right: 15,
                      top: 5,
                      bottom: 0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppStrings.levelText, style: Styles.sizedBox),
                        const SizedBox(height: 10),
                        SmoothStarRating(
                          allowHalfRating: false,
                          starCount: 5,
                          rating: bloc.rating,
                          size: 24,
                          halfFilledIconData: Icons.blur_on,
                          borderColor: ColorTokens.secondary50,
                          color: ColorTokens.secondary50,
                          spacing: 0.0,
                          onRatingChanged: (rating) =>
                              bloc.changeRating(rating),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.only(bottom: 7),
              width: 200,
              child: TextButton(
                style: Styles().textButtonStyle,
                onPressed: () async {
                  double distance = 0.0;
                  if (_formKey.currentState!.validate() &&
                      bloc.rating != 0.0 &&
                      RegExp(
                        AppStrings.validatorNumber,
                      ).hasMatch(controllerDistance.text)) {
                    distance = double.parse(controllerDistance.text);
                    final road = Road(
                      cityId: bloc.dropdownValueCity.id,
                      dateTime: controllerDateTime.text,
                      description: controllerDescriptionRecomendations.text,
                      name: controllerRouteName.text,
                      pointmeeting: controllerMeetingPoint.text,
                      geocalizationPoint: controllerGeolocationPoint.text,
                      routeLevel: bloc.rating,
                      distance: distance,
                      group: bloc.group,
                    );
                    final result = await bloc.createRoad(road);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBarUtils.customSnackBar(
                        content: result
                            ? AppStrings.succesCreateRoadText
                            : AppStrings.errorCreateRoadText,
                        backgroundColor: result
                            ? ColorTokens.secondary50
                            : ColorTokens.error50,
                      ),
                    );
                    if (result) {
                      Navigator.of(context).pop();
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBarUtils.customSnackBar(
                        content: !_formKey.currentState!.validate()
                            ? AppStrings.validationCreateRoadText
                            : !RegExp(
                                AppStrings.validatorNumber,
                              ).hasMatch(controllerDistance.text)
                            ? AppStrings.advertDistance
                            : '',
                        backgroundColor: ColorTokens.error50,
                      ),
                    );
                  }
                },
                child: Text(
                  AppStrings.postText,
                  style: Styles.containerNameUser,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
