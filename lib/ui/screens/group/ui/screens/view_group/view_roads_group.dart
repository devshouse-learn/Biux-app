import 'package:biux/config/colors.dart';
import 'package:biux/config/images.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/data/models/road.dart';
import 'package:biux/ui/screens/group/ui/screens/view_group/view_group_bloc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';
import 'package:biux/utils/strings_utils.dart';

class ViewRoadsGroup extends StatelessWidget {
  const ViewRoadsGroup({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<ViewGroupBloc>();
    return Container(
        padding: const EdgeInsets.only(
          left: 30,
        ),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Wrap(
              children: bloc.roads
                  .map(
                    (road) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Stack(
                        children: <Widget>[
                          Container(
                            margin: const EdgeInsets.only(top: 20),
                            height: 180,
                            width: 320,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: AppColors.grey, width: 1)),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  _DateSection(
                                    road: road,
                                  ),
                                  _TextSection(
                                    road: road,
                                  ),
                                ]),
                          ),
                          _ImageCircular(
                            road: road,
                          ),
                          _ButtonSection(
                            road: road,
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList()),
        ));
  }
}

 class _DateSection extends StatelessWidget {
  Road road;
  _DateSection({Key? key, required this.road}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(left: 12),
            width: 50,
            height: 140,
            decoration: BoxDecoration(
              color: AppColors.darkBlue,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Text(
                        StringsExtension(road.dateTime)
                            .dateFormatterWithDe
                            .replaceRange(
                                2,
                                StringsExtension(road.dateTime)
                                    .dateFormatterWithDe
                                    .length,
                                ''),
                        textAlign: TextAlign.center,
                        style: Styles.daysRoadListDateTime),
                  ),
                  Text(
                      StringsExtension(road.dateTime)
                          .dateFormatterWithDe
                          .toUpperCase()
                          .replaceRange(0, 2, ''),
                      style: Styles.monthsRoadListDateTime),
                  Text(StringsExtension(road.dateTime).hourFormatter,
                      textAlign: TextAlign.center, style: Styles.TextRoadsName),
                ]),
          ),
        ]);
  }
}

class _TextSection extends StatelessWidget {
  Road road;
  _TextSection({Key? key, required this.road}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
              margin: const EdgeInsets.only(top: 5, left: 25),
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
              padding: const EdgeInsets.only(left: 20),
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
                    road.name,
                    style: Styles.TextRoadsName,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 10),
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
            padding: const EdgeInsets.only(top: 5, left: 20),
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
                    rating: road.routeLevel.toDouble(),
                    size: 24,
                    halfFilledIconData: Icons.blur_on,
                    borderColor: AppColors.strongCyan,
                    color: AppColors.strongCyan,
                    spacing: 0.0),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 20),
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
                  road.numberParticipants.toString(),
                  style: Styles.containerTextGroup,
                )
              ],
            ),
          ),
        ]);
  }
}

class _ImageCircular extends StatelessWidget {
  Road road;
  _ImageCircular({Key? key, required this.road}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: GestureDetector(
        onTap: () {},
        child: Container(
          height: 80,
          width: 80,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.white, width: 4),
            image: DecorationImage(
              image: NetworkImage(road.image),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(100.0),
          ),
        ),
      ),
    );
  }
}

class _ButtonSection extends StatelessWidget {
  Road road;
  _ButtonSection({Key? key, required this.road}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<ViewGroupBloc>();
    return Padding(
      padding: const EdgeInsets.only(top: 170, left: 110),
      child: Row(
        children: [
          if (road.competitorRoad.map((e) => e.id).contains(bloc.user.id))
            ButtonTheme(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
              minWidth: 80,
              height: 40,
              child: RaisedButton(
                  color: AppColors.white,
                  child: Text(AppStrings.outText, style: Styles.TextMemberList),
                  onPressed: () {
                    bloc.onTapOutRoads(road);
                  }),
            )
          else if (road.public == true ||
              bloc.member.map((e) => e.userId).contains(bloc.user.id))
            ButtonTheme(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
              minWidth: 80,
              height: 40,
              child: RaisedButton(
                  color: AppColors.darkBlue,
                  child:
                      Text(AppStrings.joinMe, style: Styles.containerTextName),
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
              borderRadius: BorderRadius.all(Radius.circular(15)),
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
    );
  }
}
