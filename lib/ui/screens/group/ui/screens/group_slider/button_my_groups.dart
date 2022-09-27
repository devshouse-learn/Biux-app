import 'package:biux/config/colors.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/data/models/group.dart';
import 'package:biux/data/models/member.dart';
import 'package:biux/data/models/user.dart';
import 'package:biux/ui/screens/group/ui/screens/group_slider/group_slider.dart';
import 'package:flutter/material.dart';
import '../../../../../../config/themes/theme.dart';

class ButtonMyGroups extends StatelessWidget {
  Member? member;
  BiuxUser? admin;

  ButtonMyGroups(
    this.member,
  );
  final ThemeData theme = darkTheme;
  //se debe obtener los datos del grupo
  late Group group;
  late BiuxUser user;

  void initState() {
    member = Member(id: '0', approved: false, userId: '0');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.centerLeft, children: <Widget>[
      group.adminId == user.id
          ? MyGroupStyle(
              member: member!,
              theme: theme,
              group: group,
            )
          : GroupStyle(
              member: member!,
              theme: theme,
              group: group,
            ),
      Container(
        padding: new EdgeInsets.only(
          top: 10.0,
          bottom: 10,
        ),
        child: Container(
          height: 110,
          width: 110,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                group.logo == null ? AppStrings.urlBiuxApp : group.logo,
              ),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
    ]);
  }
}

class MyGroupStyle extends StatelessWidget {
  const MyGroupStyle({
    Key? key,
    required this.member,
    required this.theme,
    required this.group,
  }) : super(key: key);

  final Member member;
  final ThemeData theme;
  final Group group;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: SizedBox(
        height: 120,
        child: Card(
          color: AppColors.greyishNavyBlue,
          elevation: 15,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          margin: EdgeInsets.only(left: 46),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            //  crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(left: 70, top: 20),
                child: Text(
                  group.name.toUpperCase(),
                  style: Styles.containerMemberGroup,
                ),
              ),
              Container(
                height: 10,
              ),
              Container(
                margin: EdgeInsets.only(left: 70, bottom: 30),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.filter_hdr,
                              size: 20,
                              color: AppColors.white,
                            ),
                            Container(
                              width: 8,
                            ),
                            Text(
                              group.numberMembers.toString(),
                              style: Styles.rowGroupNumberMembers,
                            ),
                          ],
                        ),
                        Container(
                          child: Text(
                            AppStrings.followers,
                            textAlign: TextAlign.start,
                            style: Styles.columnContainerWhite,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 30,
                    ),
                    Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.directions_bike,
                              size: 20,
                              color: AppColors.white,
                            ),
                            Container(
                              width: 8,
                            ),
                            Text(
                              group.numberRoads.toString(),
                              style: Styles.rowGroupNumberMembers,
                            )
                          ],
                        ),
                        Text(
                          AppStrings.rolled,
                          textAlign: TextAlign.start,
                          style: Styles.columnContainerWhite,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GroupSlider(
              group,
              member: member,
            ),
          ),
        );
      },
    );
  }
}

class GroupStyle extends StatelessWidget {
  const GroupStyle({
    Key? key,
    required this.member,
    required this.theme,
    required this.group,
  }) : super(key: key);

  final Member member;
  final ThemeData theme;
  final Group group;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: SizedBox(
        height: 125,
        child: Card(
          elevation: 15,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          margin: EdgeInsets.only(
            left: 46,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            //  crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(
                  left: 70,
                  top: 20,
                ),
                child: Text(
                  group.name.toUpperCase(),
                  style: Styles.columnContainerGreyishNavyBlue,
                ),
              ),
              Container(
                height: 10,
              ),
              Container(
                margin: EdgeInsets.only(
                  left: 70,
                  bottom: 30,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.filter_hdr,
                              size: 20,
                              color: AppColors.greyishNavyBlue,
                            ),
                            Container(
                              width: 8,
                            ),
                            Text(
                              group.numberMembers.toString(),
                              style: Styles.rowGroupNumberMembers,
                            ),
                          ],
                        ),
                        Container(
                          child: Text(
                            AppStrings.followers,
                            textAlign: TextAlign.start,
                            style: Styles.columnContainer,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 30,
                    ),
                    Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.directions_bike,
                              size: 20,
                              color: AppColors.greyishNavyBlue,
                            ),
                            Container(
                              width: 8,
                            ),
                            Text(
                              group.numberRoads.toString(),
                              style: Styles.rowGroupNumberMembers,
                            )
                          ],
                        ),
                        Text(
                          AppStrings.rolled,
                          textAlign: TextAlign.start,
                          style: Styles.columnContainer,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GroupSlider(
              group,
              member: member,
            ),
          ),
        );
      },
    );
  }
}
