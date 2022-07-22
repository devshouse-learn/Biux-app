import 'package:biux/data/models/road.dart';
import 'package:flutter/material.dart';

class RoadsWidget extends StatelessWidget {
  final Road _road;
  RoadsWidget(this._road);
  @override
  Widget build(BuildContext context) {
/*List rodada =  rodadasPorId(_rodada);*/
    return Scaffold(
      body: ListView(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 1,
              vertical: 2,
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              //  children: _listadoRodada(rodada),
            ),
          ),
        ],
      ),
    );
  }

  _listRoad(List<Road> road) {
    List<Widget> listRoad = [];
    for (Road road in road) {
      listRoad.add(RoadsWidget(road));
    }
    return listRoad;
  }
}
