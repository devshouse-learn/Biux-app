import 'package:biux/data/models/state.dart';

class City {
String? id;
String? name;
int? stateId;
StateCountry? state;

City({
  this.id,
  this.name,
  this.stateId,
  this.state
});

City.fromJsonMap(Map json){
  this.id = json["id"];
  this.name = json["name"];
  this.stateId=json["stateId"];
  this.state = StateCountry.fromJsonMap(json["state"]);

}

Map<String, dynamic> toJson() => {
  "id": id,
  "name": name,
  "stateId":stateId,
  "state":state,
};
}