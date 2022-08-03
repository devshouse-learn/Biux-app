import 'package:biux/config/colors.dart';
import 'package:biux/data/models/group.dart';
import 'package:biux/data/models/member.dart';
import 'package:biux/data/models/user.dart';
import 'package:biux/data/models/user_membership.dart';
import 'package:biux/data/repositories/members/members_repository.dart';
import 'package:biux/data/repositories/users/user_repository.dart';
import 'package:biux/data/local_storage/localstorage.dart';
import 'package:biux/ui/screens/user/ui/screens/button_members.dart';
import 'package:flutter/material.dart';

class MembersGroup extends StatefulWidget {
  final String id;
  final Group _group;
  MembersGroup(this.id, this._group);
  _MembersGroupState createState() => _MembersGroupState();
}

late Member member;

class _MembersGroupState extends State<MembersGroup> {
  List<UserMembership> userMembership = <UserMembership>[];
  late List<Member> listMembers;
  ScrollController _scrollController = ScrollController();
  int offset = 1;
  int limit = 20;
  late BiuxUser user;
  @override
  void initState() {
    super.initState();
    listMembers = [];
    Future.delayed(Duration.zero, () async {
      var username = (await LocalStorage().getToken());
      user = await UserRepository().getPerson(username);
      listMembers = await MembersRepository().getMembersGroup(
        widget.id,
        offset,
      );
      userMembership = await UserRepository().getMembershipList();
      setState(() {});
    });
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _getMoreData();
      }
    });
  }

  _getMoreData() async {
    List<Member> nextGroups =
        await MembersRepository().getMembersGroup(widget.id, ++offset);
    listMembers.addAll(nextGroups);
    setState(() {});
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.transparent,
      body: ListView(
        controller: _scrollController,
        children: <Widget>[
          Container(
            width: 90,
            height: 20,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            child: Column(
              children: _listMembers(listMembers),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: listMembers.length == 0
                ? CircularProgressIndicator()
                : CircularProgressIndicator(),
          ),
        ],
      ),
    );
  }

  _listMembers(List<Member> member) {
    List<Widget> listMembers = [];
    for (Member member in member) {
      listMembers.add(
        Container(
          margin: EdgeInsets.all(3),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(20.0),
            ), // set rounded corner radius
          ),
          child: ButtonMembers(
            member,
            widget._group,
            userMembership,
            user,
            // admin del grupo
            BiuxUser()
          ),
        ),
      );
    }
    return listMembers;
  }
}
