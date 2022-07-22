import 'package:biux/config/colors.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/data/models/group.dart';
import 'package:flutter/material.dart';
import 'package:biux/data/models/road.dart';
import 'package:biux/data/repositories/roads/roads_repository.dart';
import 'button_roads_group.dart';

class RoadsGroup extends StatefulWidget {
  final Group groups;
  RoadsGroup(this.groups);
  _RoadsGroupState createState() => _RoadsGroupState();
}

class _RoadsGroupState extends State<RoadsGroup> {
  late List<Road> listRoads;

  ScrollController _scrollController = ScrollController();
  int offset = 1;
  int limit = 20;
  @override
  void initState() {
    super.initState();
    listRoads = [];
    Future.delayed(Duration.zero, () async {
      listRoads = (await RoadsRepository().getRoadsGroups(
        widget.groups.id!,
        limit,
        offset,
      ));
      this.setState(() => {
            // listadoRodadas.sort((a, b) => a.fechaHora!.compareTo(b.fechaHora!)),
            // listadoRodadas.removeLast(),
          });
    });
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.minScrollExtent) {
        ++offset;
        _getMoreData();
      }
    });
  }

  _getMoreData() async {
    List<Road> nextRoad = await RoadsRepository().getRoadsGroups(
      widget.groups.id!,
      limit,
      offset,
    );
    listRoads.addAll(nextRoad);

    setState(() {});
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: ListView(
        controller: _scrollController,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(10),
          ),
          Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 2,
                ),
                child: Column(
                  children: _listRoads(
                    listRoads.reversed.toList(),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: widget.groups.numberRoads == 0
                    ? Container(
                        child: Text(
                          AppStrings.noFoundGroup,
                          style: Styles.noGroupsText,
                        ),
                        height: 150,
                      )
                    : Align(
                        alignment: Alignment.center,
                        child: listRoads.length == 0
                            ? CircularProgressIndicator()
                            : Container(),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _listRoads(List<Road> road) {
    List<Widget> listRoads = [];
    for (Road road in road) {
      listRoads.add(
        Container(
          margin: EdgeInsets.all(10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(30.0),
            ), // set rounded corner radius
          ),
          child: ButtonRoadsGroup(road),
        ),
      );
    }
    return listRoads;
  }
}
