import 'package:biux/config/colors.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/data/models/member.dart';
import 'package:biux/data/repositories/members/members_repository.dart';
import 'package:biux/ui/screens/group/ui/screens/group_slider/button_my_groups.dart';
import 'package:flutter/material.dart';

class MyGroups extends StatefulWidget {
  final String id;
  MyGroups(
    this.id,
  );
  _MyGroupsState createState() => _MyGroupsState();
}

class _MyGroupsState extends State<MyGroups> {
  late List<Member> listMyGroups;
  ScrollController _scrollController = ScrollController();
  int offset = 1;

  @override
  void initState() {
    super.initState();
    listMyGroups = [];
    Future.delayed(
      Duration.zero,
      () async {
        listMyGroups = await MembersRepository().getMyGroups(
          widget.id,
        );
        this.setState(
          () => {},
        );
      },
    );
  }

  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.greyishNavyBlue,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context, true);
            },
          ),
          title: Text(AppStrings.MyGroupText),
        ),
        body: ListView(
          controller: _scrollController,
          children: <Widget>[
            Container(
              width: 50,
              height: 20,
            ),
            Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  child: Column(),
                ),
                Column(
                  children: _listMyGroups(
                    listMyGroups.toList(),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: listMyGroups.length == null
                      ? Container(
                          child: Text(
                            AppStrings.errorTextJoinRolls,
                            style: Styles.noGroupsText,
                          ),
                          height: 150,
                        )
                      : Align(
                          alignment: Alignment.center,
                          child: listMyGroups.length == 0
                              ? CircularProgressIndicator()
                              : Container(),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _listMyGroups(List<Member> member) {
    List<Widget> listMyGroups = [];
    for (Member member in member) {
      listMyGroups.add(
        Container(
          margin: EdgeInsets.all(10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(20.0),
            ), // set rounded corner radius
          ),
          child: ButtonMyGroups(member),
        ),
      );
    }
    return listMyGroups;
  }
}
