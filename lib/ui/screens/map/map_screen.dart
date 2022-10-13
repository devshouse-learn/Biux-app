import 'dart:typed_data';

import 'package:biux/config/colors.dart';
import 'package:biux/config/images.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/data/models/city.dart';
import 'package:biux/data/models/sites.dart';
import 'package:biux/ui/screens/map/map_screen_bloc.dart';
import 'package:biux/ui/widgets/button_facebook_widget.dart';
import 'package:biux/ui/widgets/button_instagram_widget.dart';
import 'package:biux/ui/widgets/button_whatsapp_widget.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

class MapScreen extends StatelessWidget {
  MapScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<MapScreenBloc>();
    return Scaffold(
      body: Stack(
        children: <Widget>[
          ListView(
            primary: false,
            children: [
              Column(
                children: [
                  Selector<MapScreenBloc, bool?>(
                      selector: (_, bloc) => bloc.serviceEnabled,
                      builder: (context, serviceEnabled, child) {
                        return _WidgetSearchCity();
                      }),
                  if (bloc.focusNodeCity.hasFocus)
                    Selector<MapScreenBloc, bool?>(
                        selector: (_, bloc) => bloc.serviceEnabled,
                        builder: (context, serviceEnabled, child) {
                          return _ListCity(
                            listCities: bloc.listCities,
                          );
                        })
                  else ...[
                    if (bloc.serviceEnabled)
                      Selector<MapScreenBloc, LocationData?>(
                          selector: (_, bloc) => bloc.result,
                          builder: (context, result, child) {
                            return _MainMapEnabled();
                          })
                    else
                      Selector<MapScreenBloc, LocationData?>(
                          selector: (_, bloc) => bloc.result,
                          builder: (context, result, child) {
                            return _MainMapDisabled();
                          })
                  ]
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MainMapEnabled extends StatelessWidget {
  _MainMapEnabled({Key? key}) : super(key: key);
  List image = [];

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<MapScreenBloc>();
    var size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height * 0.724,
      child: GoogleMap(
        mapToolbarEnabled: false,
        zoomControlsEnabled: false,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        mapType: MapType.normal,
        initialCameraPosition: bloc.currentLocation,
        onMapCreated: (
          GoogleMapController controller,
        ) {
          bloc.controller.complete(
            controller,
          );
        },
        markers: bloc.sites
            .map((site) => Marker(
                markerId: MarkerId(
                  site.id,
                ),
                position: LatLng(
                  site.latitude,
                  site.longitude,
                ),
                icon: site.iconBytes!,
                onTap: () async {
                  _showDialogDescrpition(
                    context: context,
                    onTapMarkRoute: () {
                      bloc.getRoute(
                        LatLng(
                          bloc.result.latitude!,
                          bloc.result.longitude!,
                        ),
                        LatLng(
                          site.latitude,
                          site.longitude,
                        ),
                      );
                    },
                    site: site,
                    serviceEnabled: bloc.serviceEnabled,
                    onTapPermissions: bloc.onTapPermissions,
                  );
                }))
            .toSet(),
        polylines: Set<Polyline>.of(
          bloc.polylines.values,
        ),
      ),
    );
  }
}

class _MainMapDisabled extends StatelessWidget {
  _MainMapDisabled({Key? key}) : super(key: key);
  List image = [];

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<MapScreenBloc>();
    var size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height * 0.724,
      child: GoogleMap(
        onCameraMove: (value) {
          bloc.onTapService();
        },
        mapToolbarEnabled: false,
        zoomControlsEnabled: false,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        mapType: MapType.normal,
        initialCameraPosition: bloc.currentLocation,
        onMapCreated: (
          GoogleMapController controller,
        ) {
          bloc.controller.complete(
            controller,
          );
        },
        markers: bloc.sites
            .map((site) => Marker(
                markerId: MarkerId(
                  site.id,
                ),
                position: LatLng(
                  site.latitude,
                  site.longitude,
                ),
                icon: site.iconBytes!,
                onTap: () async {
                  _showDialogDescrpition(
                    context: context,
                    onTapMarkRoute: () {
                      bloc.onTapService();
                    },
                    site: site,
                    serviceEnabled: bloc.serviceEnabled,
                    onTapPermissions: bloc.onTapPermissions,
                  );
                }))
            .toSet(),
      ),
    );
  }
}

void _showDialogDescrpition({
  required Sites site,
  required Function onTapMarkRoute,
  required BuildContext context,
  required bool serviceEnabled,
  required VoidCallback onTapPermissions,
}) async {
  return await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        backgroundColor: AppColors.transparent,
        alignment: Alignment.center,
        contentPadding: EdgeInsets.zero,
        content: DecoratedBox(
          decoration: ShapeDecoration(
            color: AppColors.transparent,
            shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: AppColors.white,
                    width: double.infinity,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(20),
                  ),
                ) +
                Border(
                  bottom: BorderSide(
                    width: 20,
                    color: AppColors.transparent,
                  ),
                  top: BorderSide(
                    width: 10,
                    color: AppColors.transparent,
                  ),
                ) +
                Border.symmetric(
                  vertical: BorderSide(
                    width: 5,
                    color: AppColors.transparent,
                  ),
                ) +
                Border.symmetric(
                  vertical: BorderSide(
                    width: 5,
                    color: AppColors.transparent,
                  ),
                ) +
                Border(
                  top: BorderSide(
                    width: 20,
                    color: AppColors.transparent,
                  ),
                ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: const SizedBox(),
                  ),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.white,
                        width: 4,
                      ),
                      image: DecorationImage(
                        image: NetworkImage(
                          site.icon,
                        ),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(
                        100.0,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topRight,
                      child: ClipOval(
                        child: Material(
                          color: AppColors.strongCyan,
                          child: InkWell(
                            splashColor: AppColors.strongCyan,
                            onTap: () => Navigator.of(context).pop(),
                            child: SizedBox(
                              width: 25,
                              height: 25,
                              child: Icon(
                                Icons.close,
                                color: AppColors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 25,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Text(
                  site.description,
                  style: Styles.sizedBoxHintStyle,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              _WidgetCarousel(
                imageSliders: site.files,
              ),
              _buttonSocialNetworks(
                site: site,
              ),
              Center(
                child: SizedBox(
                  width: 130,
                  child: TextButton(
                    style: Styles().textButtonStyle,
                    onPressed: () {
                      if (serviceEnabled) {
                        onTapMarkRoute();
                        Navigator.pop(context);
                      } else {
                        Navigator.pop(context);
                        showDialogPermissions(
                          context: context,
                          onTap: onTapPermissions,
                        );
                      }
                    },
                    child: Text(
                      AppStrings.HowGet,
                      style: Styles.containerImage,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

void showDialogPermissions({
  required BuildContext context,
  required VoidCallback onTap,
}) async {
  return await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        backgroundColor: AppColors.transparent,
        alignment: Alignment.center,
        contentPadding: EdgeInsets.zero,
        content: DecoratedBox(
          decoration: ShapeDecoration(
            color: AppColors.transparent,
            shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: AppColors.white,
                    width: double.infinity,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(
                      20,
                    ),
                  ),
                ) +
                Border(
                  bottom: BorderSide(
                    width: 20,
                    color: AppColors.transparent,
                  ),
                ) +
                Border.symmetric(
                  vertical: BorderSide(
                    width: 5,
                    color: AppColors.transparent,
                  ),
                ) +
                Border.symmetric(
                  vertical: BorderSide(
                    width: 5,
                    color: AppColors.transparent,
                  ),
                ) +
                Border(
                  top: BorderSide(
                    width: 20,
                    color: AppColors.transparent,
                  ),
                ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 25,
              ),
              Container(
                alignment: Alignment.bottomCenter,
                margin: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 10,
                ),
                child: Text(
                  AppStrings.permissionsText,
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 110,
                    child: TextButton(
                      style: Styles().textButtonWhiteStyle,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        AppStrings.cancelText,
                        style: Styles.containerImage.copyWith(
                          color: AppColors.black,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 110,
                    child: TextButton(
                      style: Styles().textButtonStyle,
                      onPressed: () {
                        onTap();
                        Navigator.pop(context);
                      },
                      child: Text(
                        AppStrings.confirm,
                        style: Styles.containerImage,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _buttonSocialNetworks extends StatelessWidget {
  Sites site;
  _buttonSocialNetworks({Key? key, required this.site}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ButtonInstagramWidget(
            linkinstagram: site.instagram,
          ),
          const SizedBox(
            width: 20,
          ),
          ButtonWhatsappWidget(
            whatsapp: site.whatsapp,
            name: site.name,
          ),
          const SizedBox(
            width: 20,
          ),
          ButtonFacebookWidget(
            linkFacebook: site.facebook,
          ),
        ],
      ),
    );
  }
}

class _WidgetCarousel extends StatefulWidget {
  List<String> imageSliders;
  _WidgetCarousel({Key? key, required this.imageSliders}) : super(key: key);

  @override
  State<_WidgetCarousel> createState() => _WidgetCarouselState();
}

class _WidgetCarouselState extends State<_WidgetCarousel> {
  int current = 0;
  final CarouselController imageController = CarouselController();

  void changeImage(int? index) async {
    current = index!;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: 300,
      child: Column(
        children: [
          CarouselSlider(
            items: widget.imageSliders
                .map((e) => Container(
                      margin: EdgeInsets.only(
                        left: 40,
                        right: 40,
                        bottom: 10,
                        top: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          20,
                        ),
                        image: DecorationImage(
                          image: NetworkImage(
                            e,
                          ),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ))
                .toList(),
            carouselController: imageController,
            options: CarouselOptions(
              aspectRatio: 50,
              enableInfiniteScroll: false,
              viewportFraction: 1.0,
              initialPage: 0,
              enlargeCenterPage: false,
              height: 250,
              onPageChanged: (index, reason) {
                changeImage(
                  index,
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.imageSliders.asMap().entries.map(
              (entry) {
                return GestureDetector(
                  onTap: () => imageController.animateToPage(
                    entry.key,
                  ),
                  child: Container(
                    width: 10.0,
                    height: 10.0,
                    margin: EdgeInsets.symmetric(
                      vertical: 5.0,
                      horizontal: 4.0,
                    ),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.black,
                      ),
                      color: (current == entry.key
                          ? AppColors.strongCyan
                          : AppColors.darkBlue),
                    ),
                  ),
                );
              },
            ).toList(),
          ),
        ],
      ),
    );
  }
}

class _WidgetSearchCity extends StatelessWidget {
  _WidgetSearchCity({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<MapScreenBloc>();
    return Container(
      width: 350,
      margin: EdgeInsets.all(
        10,
      ),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          20,
        ),
        border: Border.all(
          color: AppColors.gray,
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: bloc.cityController,
        onTap: bloc.setState,
        style: Styles.TextCityList,
        focusNode: bloc.focusNodeCity,
        onChanged: (value) {
          bloc.filterCities();
        },
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(
            10.0,
            15.0,
            20.0,
            15.0,
          ),
          border: InputBorder.none,
          hintText: AppStrings.searchCitie,
          hintStyle: Styles.TextSearch,
          prefixIcon: Image.asset(
            Images.kImageLocationGrey,
            height: 10,
            scale: 3.0,
          ),
          suffixIcon: bloc.focusNodeCity.hasFocus
              ? IconButton(
                  icon: Icon(
                    Icons.close,
                    color: AppColors.gray,
                  ),
                  onPressed: () {
                    bloc.cityController.clear();
                    bloc.getCities();
                    bloc.focusNodeCity.unfocus();
                    bloc.setState();
                  })
              : SizedBox(),
        ),
      ),
    );
  }
}

class _ListCity extends StatelessWidget {
  List<City> listCities = [];
  _ListCity({Key? key, required this.listCities}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<MapScreenBloc>();
    return Container(
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.only(
              left: 25,
            ),
            horizontalTitleGap: 0,
            minLeadingWidth: 36,
            iconColor: AppColors.black,
            leading: Image.asset(
              Images.kImageLocation2,
              height: 20,
            ),
            title: Text(
              AppStrings.currentLocation,
              style: Styles.TextCityList,
            ),
            onTap: () {
              if (bloc.serviceEnabled) {
                bloc.onTapMyLocation();
              } else if (!bloc.serviceEnabled && 
                  bloc.validate == AppStrings.deniedText) {
                bloc.onTapService();
              } else if (bloc.validate == AppStrings.deniedForeverText) {
                showDialogPermissions(
                  context: context,
                  onTap: bloc.onTapPermissions,
                );
              }
            },
          ),
          Divider(
            color: AppColors.gray,
            height: 1,
          ),
          SingleChildScrollView(
            child: Wrap(
              children: listCities
                  .map(
                    (city) => Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.only(
                            left: 60,
                          ),
                          title: Text(
                            city.name,
                            style: Styles.TextCityList,
                          ),
                          onTap: () {
                            bloc.onTapCities(
                              city.name,
                              double.parse(
                                city.latitude,
                              ),
                              double.parse(
                                city.longitude,
                              ),
                            );
                          },
                        ),
                        Divider(
                          color: AppColors.gray,
                          height: 1,
                        ),
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
