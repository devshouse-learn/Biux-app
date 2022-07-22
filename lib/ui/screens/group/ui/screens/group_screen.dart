import 'package:biux/data/models/group.dart';
import 'package:biux/ui/screens/group/ui/screens/groups.dart';
import 'package:biux/ui/screens/group/ui/screens/groups_screen.dart';
import 'package:flutter/material.dart';

class GroupScreen extends StatelessWidget {
  final Group _group;
  GroupScreen(this._group);

  @override
  Widget build(BuildContext context) {
    List<Group> group = groupsbyId(_group.id);

    return Scaffold(
      body: ListView(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 1, vertical: 2),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              children: _listGroups(group),
            ),
          ),
        ],
      ),
    );
  }

  _listGroups(List<Group> group) {
    List<Widget> listGroups = [];
    for (Group group in group) {
      listGroups.add(
        GroupsScreen(group),
      );
    }
    return listGroups;
  }
}
