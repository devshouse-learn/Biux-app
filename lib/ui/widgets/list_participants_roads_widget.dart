import 'package:biux/data/models/competitor_road.dart';
import 'package:biux/ui/screens/roads/ui/screens/button_competitor.dart';
import 'package:flutter/material.dart';
import 'package:biux/data/repositories/roads/roads_repository.dart';

class ListParticipantsRoads extends StatefulWidget {
  final String id;
  ListParticipantsRoads(this.id);
  _ListParticipantsRoadsState createState() => _ListParticipantsRoadsState();
}

class _ListParticipantsRoadsState extends State<ListParticipantsRoads> {

  late List<CompetitorRoad> listRoads;
  ScrollController _scrollController = ScrollController();
  int offset = 1;
  int limit = 20;
  @override
  void initState() {
    super.initState();
    listRoads = [];
    Future.delayed(
      Duration.zero,
      () async {
        listRoads = await RoadsRepository().getListParticipantRoad(
          widget.id,
        ); // EJEMPLOOOOO RodadasRepositorio()
        this.setState(() => {});
      },
    );

    _scrollController.addListener(
      () {
        if (_scrollController.position.pixels ==
            _scrollController.position.minScrollExtent) {}
      },
    );
  }

  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      controller: _scrollController,
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(5),
        ),
        Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 2,
                vertical: 2,
              ),
              child: Column(
                children: _listParticipants(listRoads
                    //.reversed.toList(),
                    ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  _listParticipants(List<CompetitorRoad> competitorRoad) {
    List<Widget> listCompetitor = [];
    for (CompetitorRoad competitorRoad in competitorRoad) {
      listCompetitor.add(
        Container(
          margin: EdgeInsets.all(2),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(30.0),
            ), // set rounded corner radius
          ),
          child: ButtonCompetitorRoad(competitorRoad),
        ),
      );
    }
    return listCompetitor;
  }
}
