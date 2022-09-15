import 'package:biux/data/models/state.dart';

class City {
  String id;
  String name;
  String state;
  String country;

  City({
    this.id = "",
    this.name = "",
    this.state = "",
    this.country = "",
  });

  factory City.fromJson({required Map json}) => City(
        id: json["id"],
        name: json["name"],
        state: json["state"],
        country: json["country"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "state": state,
        "country": country,
      };
}
