import 'package:biux/data/models/state.dart';

class City {
  final String id;
  final String name;
  final String state;
  final String country;

  const City({
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

  factory City.fromMapUser(Map json) {
    return City(
      id: json["id"],
      name: json["name"],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "state": state,
        "country": country,
      };

  Map<String, dynamic> toMapUser() => {
        "id": id,
        "name": name,
      };
}
