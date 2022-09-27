import 'package:biux/config/colors.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/data/models/user.dart';
import 'package:biux/data/models/user_membership.dart';
import 'package:biux/ui/screens/user/ui/view_profile_biux.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class CircleImage extends StatefulWidget {
  final BiuxUser user;
  final UserMembership userMembership;

  CircleImage(
    this.user,
    this.userMembership,
  );

  @override
  _CircleImageState createState() => _CircleImageState();
}

class _CircleImageState extends State<CircleImage> {
  var silver = AppColors.lightGrey;
  var golden = AppColors.vividOrange;
  var bronze = AppColors.strongOrange;
  late Color membreciscolor;

  void initState() {
    colorOption();
  }

  colorOption() {
    this.setState(() {
      if (widget.userMembership.membership?.name == AppStrings.silver) {
        membreciscolor = silver;
      } else {}
      if (widget.userMembership.membership?.name == AppStrings.premium) {
        membreciscolor = golden;
      } else {}
      if (widget.userMembership.membership?.name == AppStrings.bronze) {
        membreciscolor = bronze;
      } else {
        if (widget.userMembership.membership?.name == null) {
          membreciscolor = AppColors.transparent;
        } else {}
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => ViewProfileBiux(),
          ),
        );
      },
      child: Container(
        child: Stack(
          children: <Widget>[
            widget.user.photo != null
                ? Container(
                    child: GestureDetector(
                      child: Container(
                        margin: EdgeInsets.only(top: 30),
                        width: 130,
                        height: 130,
                        child: ClipRect(
                          child: CircleAvatar(
                            backgroundColor: AppColors.greyishNavyBlue,
                            backgroundImage: NetworkImage(
                              widget.user.photo != null
                                  ? widget.user.photo
                                  : AppStrings.urlBiuxApp,
                            ),
                            minRadius: 90,
                            maxRadius: 150,
                          ),
                        ),
                      ),
                      onTap: () {},
                    ),
                  )
                : Container(
                    margin: EdgeInsets.only(
                      top: 70,
                      left: 40,
                    ),
                    child: CircularProgressIndicator(
                      color: AppColors.white,
                    ),
                  ),
            widget.userMembership.membership?.name == null
                ? Container()
                : Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: CircularPercentIndicator(
                      animation: true,
                      radius: 135.0,
                      startAngle: 180.0,
                      percent: 0.2,
                      reverse: false,
                      lineWidth: 8.0,
                      circularStrokeCap: CircularStrokeCap.round,
                      backgroundColor: membreciscolor.withOpacity(0),
                      progressColor: membreciscolor,
                    ),
                  ),
            widget.userMembership.membership?.name == null
                ? Container()
                : Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: CircularPercentIndicator(
                      animation: true,
                      startAngle: 100.0,
                      reverse: true,
                      radius: 135.0,
                      percent: 0.4,
                      lineWidth: 8.0,
                      circularStrokeCap: CircularStrokeCap.butt,
                      backgroundColor: membreciscolor.withOpacity(0.5),
                      progressColor: membreciscolor,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
