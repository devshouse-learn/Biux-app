import 'package:biux/config/colors.dart';
import 'package:biux/config/images.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/data/models/city.dart';
import 'package:biux/ui/screens/roads/ui/screens/roads_list/roads_list_screen_bloc.dart';
import 'package:biux/utils/strings_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';

class RoadsListScreen extends StatelessWidget {
  RoadsListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<RoadsListScreenBloc>();
    return WillPopScope(
      onWillPop: bloc.willPopScope,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: ListView(children: [
          Selector<RoadsListScreenBloc, FocusNode>(
              selector: (_, bloc) => bloc.focusNodeCity,
              builder: (context, value, child) {
                return WidgetSearchCity();
              }),
          if (bloc.focusNodeCity.hasFocus)
            ListCity(
              listCities: bloc.listCities,
            )
          else
            RoadsList()
        ]),
      ),
    );
  }
}

class WidgetSearchCity extends StatelessWidget {
  WidgetSearchCity({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<RoadsListScreenBloc>();
    return Container(
        width: 300,
        margin: EdgeInsets.only(top: 10, left: 20, right: 20),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.gray, width: 1)),
        child: TextFormField(
          controller: bloc.searchCityController,
          onTap: bloc.setState,
          style: Styles.TextCityList,
          focusNode: bloc.focusNodeCity,
          onChanged: (value) {
            bloc.filterCities();
            if (bloc.searchCityController.text.isEmpty) bloc.getRoads();
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
                        bloc.searchCityController.clear();
                        bloc.getRoads();
                        bloc.getCities();
                        bloc.focusNodeCity.unfocus();
                        bloc.setState();
                      })
                  : SizedBox()),
        ));
  }
}

class ListCity extends StatelessWidget {
  List<City> listCities = [];
  ListCity({Key? key, required this.listCities}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<RoadsListScreenBloc>();
    return Container(
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.only(left: 25),
            horizontalTitleGap: 0,
            minLeadingWidth: 36,
            iconColor: AppColors.black,
            leading: Image.asset(
              Images.kImageLocation2,
              height: 20,
            ),
            title: Text(AppStrings.currentLocation, style: Styles.TextCityList),
            onTap: () {},
          ),
          Divider(
            color: AppColors.gray,
            height: 1,
          ),
          SingleChildScrollView(
              child: Wrap(
                  children: listCities
                      .map((city) => Column(
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.only(left: 60),
                                title:
                                    Text(city.name, style: Styles.TextCityList),
                                onTap: () {
                                  bloc.onTapCities(city.id, city.name);
                                },
                              ),
                              Divider(
                                color: AppColors.gray,
                                height: 1,
                              ),
                            ],
                          ))
                      .toList())),
        ],
      ),
    );
  }
}

class RoadsList extends StatelessWidget {
  RoadsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<RoadsListScreenBloc>();
    return Container(
        padding: EdgeInsets.only(left: 30),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Wrap(
              children: bloc.listRoads
                  .map(
                    (road) => Stack(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(top: 40),
                          height: 180,
                          width: 320,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border:
                                  Border.all(color: AppColors.grey, width: 1)),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(left: 12),
                                        width: 50,
                                        height: 140,
                                        decoration: BoxDecoration(
                                          color: AppColors.darkBlue,
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 40),
                                                child: Text(
                                                    StringsExtension(
                                                            road.dateTime)
                                                        .dateFormatterWithDe
                                                        .replaceRange(
                                                            2,
                                                            StringsExtension(road
                                                                    .dateTime)
                                                                .dateFormatterWithDe
                                                                .length,
                                                            ''),
                                                    textAlign: TextAlign.center,
                                                    style: Styles
                                                        .daysRoadListDateTime),
                                              ),
                                              Text(
                                                  StringsExtension(
                                                          road.dateTime)
                                                      .dateFormatterWithDe
                                                      .toUpperCase()
                                                      .replaceRange(0, 2, ''),
                                                  style: Styles
                                                      .monthsRoadListDateTime),
                                              Text(
                                                  StringsExtension(
                                                          road.dateTime)
                                                      .hourFormatter,
                                                  textAlign: TextAlign.center,
                                                  style: Styles.TextRoadsName),
                                            ]),
                                      ),
                                    ]),
                                Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                          margin:
                                              EdgeInsets.only(top: 5, left: 25),
                                          child: Text(
                                            road.group.name,
                                            style: Styles.TextRoads,
                                          )),
                                      Container(
                                        height: 29,
                                        width: 256,
                                        color: AppColors.strongCyan,
                                        alignment: Alignment.centerLeft,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 20),
                                          child: Row(
                                            children: [
                                              Image.asset(
                                                Images.kImageRoute,
                                                height: 20,
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                road.route,
                                                style: Styles.TextRoadsName,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 20, top: 10),
                                        child: Row(
                                          children: [
                                            Image.asset(
                                              Images.kMeetingPoint,
                                              height: 20,
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              road.pointmeeting,
                                              style: Styles.TextRoads,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 5, left: 20),
                                        child: Row(
                                          children: [
                                            Image.asset(
                                              Images.kdifficulty,
                                              height: 20,
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            SmoothStarRating(
                                                allowHalfRating: false,
                                                starCount: 5,
                                                rating:
                                                    road.routeLevel.toDouble(),
                                                size: 24,
                                                halfFilledIconData:
                                                    Icons.blur_on,
                                                borderColor:
                                                    AppColors.strongCyan,
                                                color: AppColors.strongCyan,
                                                spacing: 0.0),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 5, left: 20),
                                        child: Row(
                                          children: [
                                            Image.asset(
                                              Images.kImageSocial,
                                              height: 20,
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              road.numberParticipants
                                                  .toString(),
                                              style: Styles.containerTextGroup,
                                            )
                                          ],
                                        ),
                                      ),
                                    ]),
                              ]),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 25),
                          child: GestureDetector(
                            onTap: () {},
                            child: Container(
                              height: 80,
                              width: 80,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: AppColors.white, width: 4),
                                image: DecorationImage(
                                  image: NetworkImage(road.image),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.circular(100.0),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 190, left: 110),
                          child: Row(
                            children: [
                              if (road.competitorRoad
                                  .map((e) => e.id)
                                  .contains(bloc.user.id))
                                ButtonTheme(
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15)),
                                  ),
                                  minWidth: 80,
                                  height: 40,
                                  child: RaisedButton(
                                      color: AppColors.white,
                                      child: Text(AppStrings.outText,
                                          style: Styles.TextMemberList),
                                      onPressed: () {
                                        bloc.onTapOutRoads(road);
                                      }),
                                )
                              else if (bloc.member
                                          .map((e) => e.groupId)
                                          .contains(road.groupId) &&
                                      bloc.member
                                          .map((e) => e.userId)
                                          .contains(bloc.user.id) ||
                                  road.public == true)
                                ButtonTheme(
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15)),
                                  ),
                                  minWidth: 80,
                                  height: 40,
                                  child: RaisedButton(
                                      color: AppColors.darkBlue,
                                      child: Text(AppStrings.joinMe,
                                          style: Styles.containerTextName),
                                      onPressed: () {
                                        bloc.onTapJoinRoads(road);
                                      }),
                                )
                              else
                                const SizedBox(
                                  width: 90,
                                ),
                              const SizedBox(
                                width: 10,
                              ),
                              ButtonTheme(
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                ),
                                minWidth: 80,
                                height: 40,
                                child: RaisedButton(
                                    color: AppColors.strongCyan,
                                    child: Text(AppStrings.seeMoreText,
                                        style: Styles.containerTextName),
                                    onPressed: () {}),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList()),
        ));
  }
}
