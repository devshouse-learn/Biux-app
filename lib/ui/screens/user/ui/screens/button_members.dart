import 'package:biux/config/colors.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/config/themes/theme.dart';
import 'package:biux/data/models/group.dart';
import 'package:biux/data/models/member.dart';
import 'package:biux/data/models/user.dart';
import 'package:biux/data/models/user_membership.dart';
import 'package:biux/ui/screens/user/ui/screens/detail_users.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:flutter/material.dart';

class ButtonMembers extends StatelessWidget {
  final Member? member;
  final Group? group;
  final List<UserMembership>? memberships;
  final BiuxUser? user;
  final BiuxUser? admin;

  ButtonMembers(
    this.member,
    this.group,
    this.memberships,
    this.user,
    this.admin
  );

  final ThemeData theme = darkTheme;
  @override
  Widget build(BuildContext context) {
    final plata = AppColors.lightGrey;
    final oro = AppColors.gold;
    final bronce = AppColors.bronze;
    Color membershipColor = AppColors.bronze;
    var userMembership = memberships!.firstWhere(
      (mem) => mem.user!.id! == member!.userId,
      orElse: () => memberships!.first,
    );
    // if (membresiaUsuario == null) {
    //   miembro.usuario.premium == false;
    // }
    final nameMembership = userMembership.membership?.name ?? AppStrings.notFound2;
    switch (nameMembership) {
      case AppStrings.silver:
        membershipColor = plata;
        break;
      case AppStrings.premium:
        membershipColor = oro;
        break;
      case AppStrings.bronze:
        membershipColor = bronce;
        break;
    }
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        user!.id! == group!.adminId
            ? AdminStyle(
                member: member!,
                theme: theme,
                user: user!,
              )
            : user!.premium!
                ? UserMembershipStyle(
                    membershipColor: membershipColor,
                    member: member!,
                    userMembership: nameMembership,
                    theme: theme,
                    user: user!,
                  )
                : UserStyle(
                    member: member!,
                    theme: theme,
                    user: user!,
                  ),
        Container(
          child: Stack(
            children: <Widget>[
              Container(
                child: GestureDetector(
                  child: Container(
                    padding: EdgeInsets.only(
                      top: 10.0,
                      bottom: 10,
                    ),
                    child: Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: new NetworkImage(
                            user?.photo ??
                                AppStrings.urlBiuxApp,
                          ),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(40.0),
                      ),
                    ),
                  ),
                  onTap: () {},
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: 10.0,
                  bottom: 10,
                ),
                child: CircularPercentIndicator(
                  animation: true,
                  rotateLinearGradient: true,
                  arcType: ArcType.FULL,
                  radius: 60.0,
                  startAngle: 20.0,
                  percent: 1,
                  reverse: false,
                  lineWidth: 1.5,
                  circularStrokeCap: CircularStrokeCap.square,
                  backgroundColor: user!.premium! == true
                      ? membershipColor
                      : AppColors.transparent,
                  progressColor: user!.premium! == true
                      ? membershipColor
                      : AppColors.transparent,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: 10.0,
                  bottom: 10,
                ),
                child: CircularPercentIndicator(
                  animation: true,
                  rotateLinearGradient: true,
                  startAngle: 40.0,
                  reverse: false,
                  radius: 60.0,
                  percent: 0.4,
                  lineWidth: 5.5,
                  circularStrokeCap: CircularStrokeCap.butt,
                  backgroundColor: user!.premium! == true
                      ? membershipColor.withOpacity(0.5)
                      : AppColors.transparent,
                  progressColor: user!.premium == true
                      ? membershipColor
                      : AppColors.transparent,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AdminStyle extends StatelessWidget {
  const AdminStyle({
    Key? key,
    required this.member,
    required this.theme,
    required this.user,
  }) : super(key: key);

  final Member member;
  final ThemeData theme;
  final BiuxUser user;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: SizedBox(
        height: 50,
        child: Card(
          color: theme == darkTheme
              ? AppColors.paleBlue
              : AppColors.greyishNavyBlue3,
          elevation: 2,
          shape: StadiumBorder(
              side: BorderSide(
            color: AppColors.indigo,
            width: 1.0,
          )),
          margin: EdgeInsets.only(left: 40),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            //  crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(
                      top: 15,
                    ),
                    child: Text(
                      user.names!,
                      style: theme == darkTheme
                          ? Styles.containerColorligth
                          : Styles.containerColordark,
                    ),
                  ),
                  Container(
                    width: 5,
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      top: 15,
                    ),
                    child: Text(
                      user.surnames!,
                      style: theme == darkTheme
                          ? Styles.containerColorligth
                          : Styles.containerColordark,
                    ),
                  ),
                ],
              ),
              Container(
                height: 10,
              ),
              Container(
                //   margin: EdgeInsets.only(left: 120),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 30,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          new MaterialPageRoute(
            builder: (BuildContext context) => DetailUsers(
              user,
            ),
          ),
        );
      },
    );
  }
}

class UserStyle extends StatelessWidget {
  const UserStyle({
    Key? key,
    required this.member,
    required this.theme,
    required this.user,
  }) : super(key: key);

  final Member member;
  final ThemeData theme;
  final BiuxUser user;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: SizedBox(
        height: 50,
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          margin: EdgeInsets.only(left: 40),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            //  crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(
                      top: 15,
                    ),
                    child: Text(
                      user.names!,
                      style: Styles.rowMember,
                    ),
                  ),
                  Container(
                    width: 5,
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      top: 15,
                    ),
                    child: Text(
                      user.surnames!,
                      style: Styles.rowMember,
                    ),
                  ),
                ],
              ),
              Container(
                height: 10,
              ),
              Container(
                //   margin: EdgeInsets.only(left: 120),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 30,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          new MaterialPageRoute(
            builder: (BuildContext context) => DetailUsers(
              user,
            ),
          ),
        );
      },
    );
  }
}

class UserMembershipStyle extends StatefulWidget {
  UserMembershipStyle({
    Key? key,
    required this.member,
    required this.userMembership,
    required this.theme,
    required this.membershipColor,
    required this.user,
  }) : super(key: key);

  final Member member;
  final String userMembership;
  final ThemeData theme;
  final Color membershipColor;
  final BiuxUser user;

  @override
  _UserMembershipStyleState createState() => _UserMembershipStyleState();
}

class _UserMembershipStyleState extends State<UserMembershipStyle> {
  var plata = AppColors.lightGrey;
  var oro = AppColors.gold;
  var bronce = AppColors.strongOrange;
  late Color membrecia;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: SizedBox(
        height: 50,
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: new BorderSide(
                color: widget.user.premium! == true
                    ? widget.membershipColor
                    : AppColors.transparent,
                width: 2.0),
          ),
          margin: EdgeInsets.only(left: 40),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            //  crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(
                      top: 15,
                    ),
                    child: Text(
                      widget.user.names!,
                      style: widget.user.premium! == true
                          ? Styles.rowMember
                              .copyWith(color: widget.membershipColor)
                          : Styles.rowMember,
                    ),
                  ),
                  Container(
                    width: 5,
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      top: 15,
                    ),
                    child: Text(
                      widget.user.surnames!,
                      style: widget.user.premium! == true
                          ? Styles.rowMember
                              .copyWith(color: widget.membershipColor)
                          : Styles.rowMember,
                    ),
                  ),
                ],
              ),
              Container(
                height: 10,
              ),
              Container(
                //   margin: EdgeInsets.only(left: 120),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 30,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          new MaterialPageRoute(
            builder: (BuildContext context) => DetailUsers(
              widget.user,
            ),
          ),
        );
      },
    );
  }
}
